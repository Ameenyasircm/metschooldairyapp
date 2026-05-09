import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:met_school/core/theme/app_padding.dart';
import 'package:met_school/core/theme/app_radius.dart';
import 'package:met_school/core/theme/app_spacing.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_typography.dart';
import 'package:met_school/core/widgets/inputs/app_dropdown.dart';
import 'package:met_school/core/widgets/inputs/app_textfield.dart';
import 'package:met_school/core/widgets/buttons/gradient_button.dart';
import '../widgets/enrollment_review_tile.dart';

class AddStudentForTeacherScreen extends StatefulWidget {
  const AddStudentForTeacherScreen({super.key});

  @override
  State<AddStudentForTeacherScreen> createState() =>
      _AddStudentForTeacherScreenState();
}

class _AddStudentForTeacherScreenState
    extends State<AddStudentForTeacherScreen> {
  final PageController _pageController = PageController();

  final _formKeys = List.generate(
    5,
    (_) => GlobalKey<FormState>(),
  );

  int currentStep = 0;

  // Controllers

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
  String? relation;
  String? occupation;
  String? medium;
  String? selectedClass;

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

  final classes = [
    "LKG",
    "UKG",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10"
  ];

  void nextStep() {
    if (_formKeys[currentStep].currentState!.validate()) {
      if (currentStep < 4) {
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

  void saveStudent() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Student Saved Successfully"),
      ),
    );
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
                _personalStep(),
                _familyStep(),
                _addressStep(),
                _academicStep(),
                _reviewStep(),
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
            value: (currentStep + 1) / 5,
            color: AppColors.primary,
            backgroundColor: Colors.grey.shade300,
          ),
          AppSpacing.vs,
          Text(
            "Step ${currentStep + 1} of 5",
            style: AppTypography.subtitle2.copyWith(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _personalStep() {
    return _pageWrapper(
      formKey: _formKeys[0],
      title: "Personal Information",
      children: [
        AppTextField(
          controller: nameCtrl,
          hintText: "Full Name",
          labelText: "Full Name",
          prefixIcon: Icons.person_outline,
          fillColor: Colors.white,
        ),
        AppSpacing.vm,
        InkWell(
          onTap: pickDob,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 16.h,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.radiusM,
              border: Border.all(
                color: AppColors.greyE0,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: AppColors.darkGreen),
                AppSpacing.hm,
                Text(
                  dob == null
                      ? "Select DOB"
                      : DateFormat("dd MMM yyyy").format(dob!),
                  style: AppTypography.body1,
                ),
              ],
            ),
          ),
        ),
        AppSpacing.vm,
        AppTextField(
          controller: ageCtrl,
          hintText: "Age",
          labelText: "Age",
          prefixIcon: Icons.cake_outlined,
          readOnly: true,
          fillColor: Colors.white,
        ),
        AppSpacing.vm,
        AppDropdown(
          label: "Gender",
          value: gender,
          items: const ["Male", "Female", "Other"],
          onChanged: (v) {
            setState(() {
              gender = v;
            });
          },
        ),
        AppSpacing.vm,
        AppDropdown(
          label: "Religion",
          value: religion,
          items: const ["Islam", "Hindu", "Christian", "Other"],
          onChanged: (v) {
            setState(() {
              religion = v;
            });
          },
        ),
        AppSpacing.vm,
        AppTextField(
          controller: aadhaarCtrl,
          hintText: "Aadhaar Number",
          labelText: "Aadhaar Number",
          prefixIcon: Icons.fingerprint,
          keyboardType: TextInputType.number,
          fillColor: Colors.white,
        ),
      ],
    );
  }

  Widget _familyStep() {
    return _pageWrapper(
      formKey: _formKeys[1],
      title: "Family Information",
      children: [
        AppTextField(
          controller: parentCtrl,
          hintText: "Parent/Guardian",
          labelText: "Parent/Guardian",
          prefixIcon: Icons.person,
          fillColor: Colors.white,
        ),
        AppSpacing.vm,
        AppDropdown(
          label: "Relation",
          value: relation,
          items: const ["Father", "Mother", "Brother", "Sister", "Other"],
          onChanged: (v) {
            setState(() {
              relation = v;
            });
          },
        ),
        AppSpacing.vm,
        AppDropdown(
          label: "Occupation",
          value: occupation,
          items: occupations,
          onChanged: (v) {
            setState(() {
              occupation = v;
            });
          },
        ),
        AppSpacing.vm,
        AppTextField(
          controller: motherCtrl,
          hintText: "Mother Name",
          labelText: "Mother Name",
          prefixIcon: Icons.woman,
          fillColor: Colors.white,
        ),
        AppSpacing.vm,
        AppTextField(
          controller: phoneCtrl,
          hintText: "Phone Number",
          labelText: "Phone Number",
          prefixIcon: Icons.phone,
          keyboardType: TextInputType.phone,
          fillColor: Colors.white,
          onChanged: (v) {
            if (whatsappSame) {
              whatsappCtrl.text = v;
            }
          },
        ),
        AppSpacing.vs,
        Row(
          children: [
            Checkbox(
              value: whatsappSame,
              activeColor: AppColors.primary,
              onChanged: (v) {
                setState(() {
                  whatsappSame = v!;
                  if (whatsappSame) {
                    whatsappCtrl.text = phoneCtrl.text;
                  }
                });
              },
            ),
            Expanded(
              child: Text(
                "WhatsApp same as phone number",
                style: AppTypography.body2,
              ),
            ),
          ],
        ),
        AppSpacing.vs,
        AppTextField(
          controller: whatsappCtrl,
          hintText: "WhatsApp Number",
          labelText: "WhatsApp Number",
          prefixIcon: Icons.chat,
          keyboardType: TextInputType.phone,
          readOnly: whatsappSame,
          fillColor: Colors.white,
        ),
      ],
    );
  }

  Widget _addressStep() {
    return _pageWrapper(
      formKey: _formKeys[2],
      title: "Address Information",
      children: [
        AppTextField(
          controller: placeCtrl,
          hintText: "Place",
          labelText: "Place",
          prefixIcon: Icons.location_on_outlined,
          fillColor: Colors.white,
        ),
        AppSpacing.vm,
        AppTextField(
          controller: addressCtrl,
          hintText: "Address",
          labelText: "Address",
          prefixIcon: Icons.home_outlined,
          maxLine: 4,
          fillColor: Colors.white,
        ),
      ],
    );
  }

  Widget _academicStep() {
    return _pageWrapper(
      formKey: _formKeys[3],
      title: "Academic Information",
      children: [
        AppDropdown(
          label: "Class",
          value: selectedClass,
          items: classes,
          onChanged: (v) {
            setState(() {
              selectedClass = v;
            });
          },
        ),
        AppSpacing.vm,
        AppDropdown(
          label: "Medium",
          value: medium,
          items: const ["English", "Malayalam"],
          onChanged: (v) {
            setState(() {
              medium = v;
            });
          },
        ),
        AppSpacing.vm,
        AppTextField(
          controller: previousSchoolCtrl,
          hintText: "Previous School",
          labelText: "Previous School",
          prefixIcon: Icons.school_outlined,
          fillColor: Colors.white,
        ),
        AppSpacing.vm,
        AppTextField(
          controller: identificationCtrl,
          hintText: "Identification Mark",
          labelText: "Identification Mark",
          prefixIcon: Icons.edit_note_outlined,
          fillColor: Colors.white,
        ),
      ],
    );
  }

  Widget _reviewStep() {
    return _pageWrapper(
      formKey: _formKeys[4],
      title: "Review Details",
      children: [
        EnrollmentReviewTile(title: "Name", value: nameCtrl.text),
        EnrollmentReviewTile(title: "Gender", value: gender ?? ""),
        EnrollmentReviewTile(title: "Religion", value: religion ?? ""),
        EnrollmentReviewTile(title: "Parent", value: parentCtrl.text),
        EnrollmentReviewTile(title: "Phone", value: phoneCtrl.text),
        EnrollmentReviewTile(title: "Class", value: selectedClass ?? ""),
        EnrollmentReviewTile(title: "Medium", value: medium ?? ""),
        EnrollmentReviewTile(title: "Place", value: placeCtrl.text),
      ],
    );
  }

  Widget _pageWrapper({
    required GlobalKey<FormState> formKey,
    required String title,
    required List<Widget> children,
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
              style: AppTypography.h3,
            ),
            AppSpacing.vl,
            ...children,
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
                text: currentStep == 4 ? "Save Student" : "Continue",
                onPressed: nextStep,
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
    );

    if (picked != null) {
      setState(() {
        dob = picked;
        ageCtrl.text = (DateTime.now().year - picked.year).toString();
      });
    }
  }
}
