import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:met_school/core/theme/app_padding.dart';
import 'package:met_school/core/theme/app_radius.dart';
import 'package:met_school/core/theme/app_spacing.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_typography.dart';
import 'package:met_school/core/utils/loader/customLoader.dart';
import 'package:met_school/core/widgets/buttons/gradient_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../core/utils/snackbarNotification/snackbar_notification.dart';
import '../../../../../../providers/academic_provider.dart';
import '../provider/student_provider.dart';
import '../widgets/personal_info_step.dart';
import '../widgets/family_info_step.dart';
import '../widgets/address_info_step.dart';
import '../widgets/academic_info_step.dart';
import '../widgets/review_details_step.dart';

class AddStudentForTeacherScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const AddStudentForTeacherScreen({super.key, this.initialData});

  @override
  State<AddStudentForTeacherScreen> createState() =>
      _AddStudentForTeacherScreenState();
}

class _AddStudentForTeacherScreenState
    extends State<AddStudentForTeacherScreen> {
  final PageController _pageController = PageController();

  final _formKeys = List.generate(
    4,
    (_) => GlobalKey<FormState>(),
  );

  int currentStep = 0;
  bool _isLoading = false;
  File? _selectedImage;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.initialData != null) {
      final data = widget.initialData!;
      nameCtrl.text = data['name'] ?? '';
      ageCtrl.text = data['age']?.toString() ?? '';
      aadhaarCtrl.text = data['aadhar'] ?? '';
      parentCtrl.text = data['parentGuardian'] ?? '';
      motherCtrl.text = data['motherName'] ?? '';
      phoneCtrl.text = data['phone'] ?? '';
      whatsappCtrl.text = data['whatsapp'] ?? '';
      placeCtrl.text = data['place'] ?? '';
      addressCtrl.text = data['address'] ?? '';
      previousSchoolCtrl.text = data['prevSchool'] ?? '';
      identificationCtrl.text = data['identificationMark'] ?? '';

      gender = data['gender'];
      religion = data['religion'];
      cast = data['cast'];
      relation = data['relation'];
      occupation = data['fatherProfession'];

      if (data['dob'] != null) {
        if (data['dob'] is Timestamp) {
          dob = (data['dob'] as Timestamp).toDate();
        } else if (data['dob'] is DateTime) {
          dob = data['dob'];
        }
      }

      whatsappSame =
          phoneCtrl.text == whatsappCtrl.text && phoneCtrl.text.isNotEmpty;

      _photoUrl = data['photoUrl'];
    }
  }

  // Controllers

  final admissionCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final ageCtrl = TextEditingController();
  final aadhaarCtrl = TextEditingController();

  final parentCtrl = TextEditingController();
  final motherCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final whatsappCtrl = TextEditingController();

  final placeCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  final previousSchoolCtrl = TextEditingController();
  final identificationCtrl = TextEditingController();

  DateTime? dob;

  bool whatsappSame = false;

  String? gender;
  String? religion;
  String? cast;
  String? relation;
  String? occupation;
  String? medium;

  final occupations = [
    "Farmer",
    "Business",
    "Teacher",
    "Doctor",
    "Engineer",
    "Government Employee",
    "Private Job",
    "Home Maker",
    "Driver",
    "Other"
  ];

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (image != null) {
        _cropImage(image.path);
      }
    } catch (e) {
      debugPrint("Pick Image Error: $e");
      SnackbarService().showError("Failed to pick image");
    }
  }

  Future<void> _cropImage(String path) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: path,

        uiSettings: [
          AndroidUiSettings(
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPresetCustom(),
            ],
            toolbarTitle: 'Crop Image',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _selectedImage = File(croppedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Crop Image Error: $e");
      SnackbarService().showError("Failed to crop image");
    }
  }

  Future<String?> _uploadToCloudinary(File file) async {
    try {
      final cloudinary = CloudinaryPublic('dt9qsvvp2', 'METSCHOOL', cache: false);
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'students',
        ),
      );
      return response.secureUrl;
    } catch (e) {
      debugPrint("Cloudinary Upload Error: $e");
      return null;
    }
  }

  void nextStep() {
    if (_formKeys[currentStep].currentState!.validate()) {
      if (currentStep < 3) {
        setState(() {
          currentStep++;
        });

        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        saveStudent();
      }
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });

      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void saveStudent() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final firestore = FirebaseFirestore.instance;
      final prefs = await SharedPreferences.getInstance();
      final provider = context.read<AcademicProvider>();

      // Upload image if selected
      if (_selectedImage != null) {
        String? uploadedUrl = await _uploadToCloudinary(_selectedImage!);
        if (uploadedUrl == null) {
          throw Exception("Failed to upload photo. Please try again.");
        }
        _photoUrl = uploadedUrl;
      }

      // Safely extract SharedPreferences data
      final String divisionId = prefs.getString("divisionId") ?? '';
      final String divisionName = prefs.getString("divisionName") ?? '';
      final String academicYearId = prefs.getString("academicYearId") ?? '';
      final String staffId = prefs.getString("staffId") ?? '';
      final String staffName = prefs.getString("staffName") ?? '';
      final String? classId = prefs.getString("classId");
      final String className = prefs.getString("className") ?? '';

      if (classId == null || classId.isEmpty) {
        throw Exception(
            "Class selection is missing. Please re-select the class.");
      }

      // Form Data
      String parentPhone = phoneCtrl.text.trim();
      String parentName = parentCtrl.text.trim();
      String studentName = nameCtrl.text.trim();

      // 2. Handle IDs
      String docId = widget.initialData?['id'] ??
          firestore.collection("students").doc().id;
      String? parentUid;

      // Determine Admission ID
      String finalAdmissionId = widget.initialData?['admissionId'] ?? "";
      if (widget.initialData == null) {
        finalAdmissionId = await provider.generateAdmissionId(classId);
      }

      final batch = firestore.batch();

      // 3. Parent Logic (Determine parentUid BEFORE writing student/enrollment)
      if (widget.initialData == null) {
        // CASE A: New Registration - Check if parent already exists by phone
        var existingUserQuery = await firestore
            .collection("users")
            .where("phone", isEqualTo: parentPhone)
            .where("role", isEqualTo: "parent")
            .limit(1)
            .get();

        if (existingUserQuery.docs.isNotEmpty) {
          parentUid = existingUserQuery.docs.first.id;

          // Update existing parent's student list
          batch.update(firestore.collection("parents").doc(parentUid), {
            "studentIds": FieldValue.arrayUnion([docId]),
            "updatedAt": FieldValue.serverTimestamp(),
          });
          batch.update(firestore.collection("users").doc(parentUid), {
            "studentIds": FieldValue.arrayUnion([docId]),
          });
        } else {
          // Create brand new parent
          DocumentReference newUserRef = firestore.collection("users").doc();
          parentUid = newUserRef.id;

          batch.set(newUserRef, {
            "uid": parentUid,
            "role": "parent",
            "name": parentName,
            "phone": parentPhone,
            "user_name": parentPhone,
            "password": parentPhone, // Default password
            "studentIds": [docId],
            "createdAt": FieldValue.serverTimestamp(),
            "createdBy": staffId,
            "createdByName": staffName,
          });

          batch.set(firestore.collection("parents").doc(parentUid), {
            "parentUid": parentUid,
            "studentIds": [docId],
            "parentName": parentName,
            "phone": parentPhone,
            "updatedAt": FieldValue.serverTimestamp(),
          });
        }
      } else {
        // CASE B: Edit Existing Student
        parentUid = widget.initialData?['parentId'];

        if (parentUid != null) {
          batch.update(firestore.collection("parents").doc(parentUid), {
            "parentName": parentName,
            "phone": parentPhone,
            "updatedAt": FieldValue.serverTimestamp(),
          });
          batch.update(firestore.collection("users").doc(parentUid), {
            "name": parentName,
            "phone": parentPhone,
            "user_name": parentPhone,
          });
        }
      }

      // 4. Prepare Student Data Map (Now with guaranteed parentUid)
      Map<String, dynamic> studentData = {
        "id": docId,
        "name": studentName,
        "admissionId": finalAdmissionId,
        "classId": classId,
        "className": className,
        "parentId": parentUid, // Correctly linked
        "parentGuardian": parentName,
        "relation": relation,
        "fatherProfession": occupation,
        "motherName": motherCtrl.text.trim(),
        "phone": parentPhone,
        "whatsapp": whatsappCtrl.text.trim(),
        "aadhar": aadhaarCtrl.text.trim(),
        "dob": dob,
        "age": ageCtrl.text,
        "religion": religion,
        "cast": cast,
        "place": placeCtrl.text.trim(),
        "address": addressCtrl.text.trim(),
        "gender": gender,
        "medium": "ENGLISH",
        "prevSchool": previousSchoolCtrl.text.trim(),
        "tcNumber": '',
        "identificationMark": identificationCtrl.text.trim(),
        "photoUrl": _photoUrl ?? '',
        "updatedAt": FieldValue.serverTimestamp(),
        "isEnrolled": true,
      };

      // 5. Batch Writes for Student and Enrollment
      DocumentReference studentRef =
          firestore.collection("students").doc(docId);
      if (widget.initialData == null) {
        batch.set(studentRef, studentData);
      } else {
        batch.update(studentRef, studentData);
      }

      // Always create a new enrollment record for tracking history/academic year
      DocumentReference enrollRef = firestore.collection('enrollments').doc();
      batch.set(enrollRef, {
        "student_id": docId,
        "student_name": studentName,
        "academic_year_id": academicYearId,
        "class_id": classId,
        "class_name": className,
        "division_id": divisionId,
        "division_name": divisionName,
        "enrollment_id": finalAdmissionId,
        "parent_phone": parentPhone,
        "parent_id": parentUid ?? "", // Fixed the logic here
        "roll_number": null,
        "status": "active",
        "photoUrl": _photoUrl ?? '',
        "createdAt": FieldValue.serverTimestamp(),
        "createdById": staffId,
        "createdByName": staffName,
      });

      // 6. Execute Transactionally
      await batch.commit();

      if (mounted) {
        context.read<StudentProvider>().fetchMyStudentsInitial();

        SnackbarService().showSuccess("Student Saved Successfully");
        Navigator.pop(context); // Return to previous screen
      }
    } catch (e) {
      debugPrint("Save Error: $e");
      SnackbarService().showError("Error: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        title: Text(
          "Student Enrollment",
          style: AppTypography.h5.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildProgress(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _pageWrapper(
                  formKey: _formKeys[0],
                  title: "Personal Information",
                  child: PersonalInfoStep(
                    nameCtrl: nameCtrl,
                    ageCtrl: ageCtrl,
                    aadhaarCtrl: aadhaarCtrl,
                    dob: dob,
                    gender: gender,
                    religion: religion,
                    cast: cast,
                    selectedImage: _selectedImage,
                    photoUrl: _photoUrl,
                    onPickDob: pickDob,
                    onPickImage: _pickImage,
                    onGenderChanged: (v) => setState(() => gender = v),
                    onReligionChanged: (v) => setState(() => religion = v),
                    onCastChanged: (v) => setState(() => cast = v),
                  ),
                ),
                _pageWrapper(
                  formKey: _formKeys[1],
                  title: "Family Information",
                  child: FamilyInfoStep(
                    parentCtrl: parentCtrl,
                    motherCtrl: motherCtrl,
                    phoneCtrl: phoneCtrl,
                    whatsappCtrl: whatsappCtrl,
                    relation: relation,
                    occupation: occupation,
                    whatsappSame: whatsappSame,
                    occupations: occupations,
                    onRelationChanged: (v) => setState(() => relation = v),
                    onOccupationChanged: (v) => setState(() => occupation = v),
                    onWhatsappSameChanged: (v) {
                      setState(() {
                        whatsappSame = v!;
                        if (whatsappSame) {
                          whatsappCtrl.text = phoneCtrl.text;
                        }
                      });
                    },
                  ),
                ),
                _pageWrapper(
                  formKey: _formKeys[2],
                  title: "Address & Academic Information",
                  child: AddressInfoStep(
                    placeCtrl: placeCtrl,
                    addressCtrl: addressCtrl,
                    previousSchoolCtrl: previousSchoolCtrl,
                    identificationCtrl: identificationCtrl,
                  ),
                ),
                _pageWrapper(
                  formKey: _formKeys[3],
                  title: "Review Details",
                  child: ReviewDetailsStep(
                    name: nameCtrl.text,
                    dob: dob != null ? DateFormat("dd-MMM-yyyy").format(dob!) : '',
                    age: ageCtrl.text,
                    gender: gender ?? "",
                    religion: religion ?? "",
                    cast: cast ?? "",
                    parent: parentCtrl.text,
                    phone: phoneCtrl.text,
                    place: placeCtrl.text,
                    address: addressCtrl.text,
                    selectedImage: _selectedImage,
                    photoUrl: _photoUrl,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  Widget _buildProgress() {
    return Container(
      padding: AppPadding.pM,
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (currentStep + 1) / 4,
            color: AppColors.primary,
            backgroundColor: Colors.grey.shade300,
          ),
          AppSpacing.vs,
          Text(
            "Step ${currentStep + 1} of 4",
            style: AppTypography.subtitle2.copyWith(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pageWrapper({
    required GlobalKey<FormState> formKey,
    required String title,
    required Widget child,
  }) {
    return SingleChildScrollView(
      padding: AppPadding.pM,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.h6,
            ),
            AppSpacing.vl,
            child,
          ],
        ),
      ),
    );
  }

  Widget _bottomBar() {
    return SafeArea(
      child: Container(
        padding: AppPadding.pM,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black.withOpacity(.05),
            ),
          ],
        ),
        child: Row(
          children: [
            if (currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: previousStep,
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(
                      double.infinity,
                      50.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.radiusXL,
                    ),
                    side: const BorderSide(color: AppColors.primary),
                  ),
                  child: Text(
                    "Previous",
                    style: AppTypography.body2.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            if (currentStep > 0) AppSpacing.hm,
            Expanded(
              child: gradientButton(
                text: currentStep == 3 ? "Save Student" : "Continue",
                isLoading: currentStep == 3 ? _isLoading : false,
                onPressed: _isLoading ? null : nextStep,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2015),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        dob = picked;
        ageCtrl.text = (DateTime.now().year - picked.year).toString();
      });
    }
  }
}
class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}