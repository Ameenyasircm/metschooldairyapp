import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:met_school/providers/academic_provider.dart';
import 'package:provider/provider.dart';

class AddStudentScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const AddStudentScreen({super.key, this.initialData});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  static const Color primaryTeal = Color(0xff00796B);

  // Controllers
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController admissionCtrl = TextEditingController();
  final TextEditingController parentCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController whatsappCtrl = TextEditingController();
  final TextEditingController motherNameCtrl = TextEditingController();
  final TextEditingController aadharCtrl = TextEditingController();
  final TextEditingController prevSchoolCtrl = TextEditingController();
  final TextEditingController ageCtrl = TextEditingController();
  final TextEditingController placeCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController communityCtrl = TextEditingController();
  final TextEditingController motherTongueCtrl = TextEditingController();
  final TextEditingController tcNumberCtrl = TextEditingController();
  final TextEditingController idMarkCtrl = TextEditingController();

  // Selection Data
  String? selectedClassId;
  String? selectedClassName;
  String? selectedGender;
  String? selectedReligion;
  String? selectedMedium;
  String? selectedRelation;
  String? selectedOccupation; // New Occupation Dropdown Selection
  bool isWhatsappSame = false;
  DateTime? dob;
  DateTime? lastVaccination;

  // Comprehensive Occupation List
  final List<String> occupations = [
    "Agriculture/Farmer", "Business/Self Employed", "Construction Worker",
    "Driver", "Engineer", "Government Employee", "Healthcare/Doctor/Nurse",
    "Home Maker", "IT Professional", "Laborer", "Private Job",
    "Teacher/Professor", "Technician", "Other"
  ];

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final provider = context.read<AcademicProvider>();
      await provider.fetchClasses();

      if (widget.initialData != null && mounted) {
        final data = widget.initialData!;
        final String? targetId = data['classId']?.toString();
        bool classExists = provider.formattedClasses.any((cls) => cls['id'] == targetId);

        if (classExists) {
          setState(() {
            selectedClassId = targetId;
            selectedClassName = provider.formattedClasses
                .firstWhere((cls) => cls['id'] == targetId)['name'];
          });
        }
      }
    });

    if (widget.initialData != null) {
      final data = widget.initialData!;
      nameCtrl.text = data['name'] ?? "";
      admissionCtrl.text = data['admissionId'] ?? "";
      parentCtrl.text = data['parentGuardian'] ?? "";
      phoneCtrl.text = data['phone'] ?? "";
      whatsappCtrl.text = data['whatsapp'] ?? "";
      motherNameCtrl.text = data['motherName'] ?? ""; // Correctly fetching mother name
      aadharCtrl.text = data['aadhar'] ?? "";
      prevSchoolCtrl.text = data['prevSchool'] ?? "";
      ageCtrl.text = data['age'] ?? "";
      placeCtrl.text = data['place'] ?? "";
      addressCtrl.text = data['address'] ?? "";
      communityCtrl.text = data['community'] ?? "";
      motherTongueCtrl.text = data['motherTongue'] ?? "";
      tcNumberCtrl.text = data['tcNumber'] ?? "";
      idMarkCtrl.text = data['identificationMark'] ?? "";

      selectedGender = data['gender'];
      selectedReligion = data['religion'];
      selectedMedium = data['medium'];
      selectedRelation = data['relation'];
      selectedOccupation = data['fatherProfession']; // Correctly fetching occupation

      if (data['phone'] == data['whatsapp'] && data['phone'] != null && data['phone'] != "") {
        isWhatsappSame = true;
      }

      if (data['dob'] != null) {
        dob = (data['dob'] is DateTime) ? data['dob'] : (data['dob'] as dynamic).toDate();
      }
      if (data['lastVaccination'] != null) {
        lastVaccination = (data['lastVaccination'] is DateTime) ? data['lastVaccination'] : (data['lastVaccination'] as dynamic).toDate();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final academicProv = context.watch<AcademicProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: primaryTeal,
        elevation: 0,
        toolbarHeight: 50,
        leading: const BackButton(color: Colors.white),
        title: Text(widget.initialData == null ? "Student Enrollment" : "Update Student Profile",
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      bottomNavigationBar: _buildFooter(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column 1: Personal & Identity
              Expanded(
                flex: 3,
                child: _buildPanel("Personal & Identity", Icons.person_outline, [
                  _item("Full Name", _field(nameCtrl, "Student Name", Icons.badge)),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _item("DOB", _datePicker(true))),
                    const SizedBox(width: 8),
                    Expanded(child: _item("Age", _field(ageCtrl, "0", Icons.cake, isReadOnly: true))),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _item("Gender", _dropdown(["Male", "Female", "Other"], selectedGender, (v) => setState(() => selectedGender = v)))),
                    const SizedBox(width: 8),
                    Expanded(child: _item("Religion", _dropdown(["Islam", "Hindu", "Christian", "Other"], selectedReligion, (v) => setState(() => selectedReligion = v)))),
                  ]),
                  const SizedBox(height: 10),
                  _item("Aadhaar Number", _field(aadharCtrl, "0000 0000 0000", Icons.fingerprint, isNumber: true, isOptional: true)),
                  const SizedBox(height: 10),
                  _item("Address", _field(addressCtrl, "Permanent Address", Icons.home, maxLines: 2)),
                ]),
              ),
              const SizedBox(width: 12),

              // Column 2: Family & Contact
              Expanded(
                flex: 3,
                child: _buildPanel("Family & Contact", Icons.family_restroom, [
                  Row(children: [
                    Expanded(child: _item("Parent/Guardian", _field(parentCtrl, "Name", Icons.person))),
                    const SizedBox(width: 8),
                    Expanded(child: _item("Relation", _dropdown(["Father", "Mother", "Brother", "Sister", "Uncle", "Aunt", "Other"], selectedRelation, (v) => setState(() => selectedRelation = v)))),
                  ]),
                  const SizedBox(height: 10),
                  // UPDATED: Occupation Dropdown
                  _item("Occupation", _dropdown(occupations, selectedOccupation, (v) => setState(() => selectedOccupation = v))),
                  const SizedBox(height: 10),
                  _item("Mother's Name", _field(motherNameCtrl, "Name", Icons.woman)),
                  const SizedBox(height: 10),
                  _item("Contact No", _field(phoneCtrl, "Phone", Icons.phone, isNumber: true, onChanged: (val) {
                    if (isWhatsappSame) setState(() => whatsappCtrl.text = val);
                  })),
                  Row(
                    children: [
                      Checkbox(
                        value: isWhatsappSame,
                        activeColor: primaryTeal,
                        onChanged: (val) {
                          setState(() {
                            isWhatsappSame = val!;
                            if (isWhatsappSame) whatsappCtrl.text = phoneCtrl.text;
                          });
                        },
                      ),
                      const Text("WhatsApp same as contact", style: TextStyle(fontSize: 10, color: Colors.blueGrey)),
                    ],
                  ),
                  _item("WhatsApp No", _field(whatsappCtrl, "WhatsApp", Icons.chat, isNumber: true, isReadOnly: isWhatsappSame)),
                  const SizedBox(height: 10),
                  _item("Place", _field(placeCtrl, "City/Village", Icons.location_on_outlined)),
                ]),
              ),
              const SizedBox(width: 12),

              // Column 3: Academic & Others
              Expanded(
                flex: 3,
                child: _buildPanel("Academic & Others", Icons.school_outlined, [
                  Row(children: [
                    Expanded(child: _item("Class", academicProv.isClassLoading ? const LinearProgressIndicator() : _classDropdown(academicProv))),
                    const SizedBox(width: 8),
                    Expanded(child: _item("Medium", _dropdown(["English", "Malayalam"], selectedMedium, (v) => setState(() => selectedMedium = v)))),
                  ]),
                  const SizedBox(height: 10),
                  // UPDATED: Show Document ID (System ID)
                  _item("System ID", _field(TextEditingController(text: widget.initialData?['id'] ?? "Auto"), "Doc ID", Icons.fingerprint, isReadOnly: true, isOptional: true)),
                  const SizedBox(height: 10),
                  _item("Admission ID", _field(admissionCtrl, "Auto-generated on Save", Icons.vpn_key, isReadOnly: true, isOptional: true)),
                  const SizedBox(height: 10),
                  _item("Previous School", _field(prevSchoolCtrl, "School Name", Icons.history_edu, isOptional: true)),

                  const SizedBox(height: 10),
                  _item("Identification Mark", _field(idMarkCtrl, "Visible marks", Icons.edit_note, isOptional: true)),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Helpers ---

  Widget _classDropdown(AcademicProvider prov) {
    final Set<String> uniqueIds = {};
    final List<DropdownMenuItem<String>> menuItems = [];

    for (var cls in prov.formattedClasses) {
      final String id = cls['id'] ?? "";
      final String name = cls['name'] ?? "Unnamed Class";
      if (id.isNotEmpty && !uniqueIds.contains(id)) {
        uniqueIds.add(id);
        menuItems.add(DropdownMenuItem<String>(value: id, child: Text(name, overflow: TextOverflow.ellipsis)));
      }
    }

    final String? validatedValue = uniqueIds.contains(selectedClassId) ? selectedClassId : null;

    return DropdownButtonFormField<String>(
      value: validatedValue,
      isExpanded: true,
      style: const TextStyle(fontSize: 13, color: Colors.black),
      hint: const Text("Select Class"),
      decoration: InputDecoration(
        isDense: true, filled: true, fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      ),
      items: menuItems,
      onChanged: (String? newVal) {
        if (newVal == null) return;
        final selectedClass = prov.formattedClasses.firstWhere((c) => c['id'] == newVal);
        setState(() {
          selectedClassId = newVal;
          selectedClassName = selectedClass['name'];
        });
      },
      validator: (v) => v == null ? "Required" : null,
    );
  }

  Widget _buildPanel(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, size: 18, color: primaryTeal), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))]),
        const Divider(height: 24),
        ...children,
      ]),
    );
  }

  Widget _item(String label, Widget child) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
      const SizedBox(height: 5),
      child,
    ]);
  }

  Widget _field(TextEditingController ctrl, String hint, IconData icon,
      {bool isNumber = false, int maxLines = 1, bool isReadOnly = false, bool isOptional = false, Function(String)? onChanged}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      readOnly: isReadOnly,
      onChanged: onChanged,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 16, color: primaryTeal.withOpacity(0.5)),
        hintText: hint,
        isDense: true,
        filled: true,
        fillColor: isReadOnly ? Colors.grey[100] : const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      ),
      validator: (v) {
        if (isOptional) return null;
        return (v == null || v.isEmpty) ? "Required" : null;
      },
    );
  }

  Widget _dropdown(List<String> items, String? val, Function(String?) onChange) {
    return DropdownButtonFormField<String>(
      value: val,
      isExpanded: true,
      style: const TextStyle(fontSize: 13, color: Colors.black),
      decoration: InputDecoration(isDense: true, filled: true, fillColor: const Color(0xFFF8FAFC), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChange,
      validator: (v) => (v == null) ? "Required" : null,
    );
  }

  Widget _datePicker(bool isDob) {
    DateTime? current = isDob ? dob : lastVaccination;
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1990), lastDate: DateTime.now());
        if (picked != null) {
          setState(() {
            if (isDob) {
              dob = picked;
              ageCtrl.text = (DateTime.now().year - picked.year).toString();
            } else {
              lastVaccination = picked;
            }
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Row(children: [
          const Icon(Icons.calendar_today, size: 14, color: primaryTeal),
          const SizedBox(width: 8),
          Text(current == null ? (isDob ? "Select" : "Optional") : DateFormat('dd/MM/yy').format(current), style: const TextStyle(fontSize: 12)),
        ]),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE2E8F0)))),
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        const SizedBox(width: 15),
        ElevatedButton(
          onPressed: _saveStudent,
          style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
          child: Text(widget.initialData == null ? "Save Student" : "Update Student", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }

  void _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;
    if (dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Date of Birth is mandatory"), backgroundColor: Colors.red)
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: primaryTeal)),
    );

    try {
      final firestore = FirebaseFirestore.instance;
      final provider = context.read<AcademicProvider>();

      String adminUid = FirebaseAuth.instance.currentUser?.uid ?? "system";
      String parentPhone = phoneCtrl.text.trim();
      String parentName = parentCtrl.text.trim();

      String finalAdmissionId = admissionCtrl.text.trim();
      if (widget.initialData == null) {
        finalAdmissionId = await provider.generateAdmissionId(selectedClassId!);
      }

      String docId = widget.initialData?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();

      // 1. Prepare Student Data Map
      Map<String, dynamic> studentData = {
        "id": docId,
        "name": nameCtrl.text.trim(),
        "admissionId": finalAdmissionId,
        "classId": selectedClassId,
        "className": selectedClassName,
        "parentGuardian": parentName,
        "relation": selectedRelation,
        "fatherProfession": selectedOccupation,
        "motherName": motherNameCtrl.text.trim(),
        "phone": parentPhone,
        "whatsapp": whatsappCtrl.text.trim(),
        "aadhar": aadharCtrl.text.trim(),
        "dob": dob,
        "age": ageCtrl.text,
        "religion": selectedReligion,
        "place": placeCtrl.text.trim(),
        "address": addressCtrl.text.trim(),
        "gender": selectedGender,
        "medium": selectedMedium,
        "prevSchool": prevSchoolCtrl.text.trim(),
        "tcNumber": tcNumberCtrl.text.trim(),
        "identificationMark": idMarkCtrl.text.trim(),
        "updatedAt": FieldValue.serverTimestamp(),
      };

      final batch = firestore.batch();
      DocumentReference studentRef = firestore.collection("students").doc(docId);

      if (widget.initialData == null) {
        // --- CASE A: NEW REGISTRATION ---

        var existingUserQuery = await firestore.collection("users")
            .where("phone", isEqualTo: parentPhone)
            .where("role", isEqualTo: "parent")
            .limit(1)
            .get();

        String parentUid;

        if (existingUserQuery.docs.isNotEmpty) {
          // Parent exists: Link student and update BOTH collections
          parentUid = existingUserQuery.docs.first.id;
          studentData['parentId'] = parentUid;

          batch.set(studentRef, studentData);

          // Update 'parents' collection
          batch.update(firestore.collection("parents").doc(parentUid), {
            "studentIds": FieldValue.arrayUnion([docId]),
            "updatedAt": FieldValue.serverTimestamp(),
          });

          // NEW: Update 'users' collection to keep IDs in sync
          batch.update(firestore.collection("users").doc(parentUid), {
            "studentIds": FieldValue.arrayUnion([docId]),
          });

        } else {
          // New Parent: Create User and Parent Document
          DocumentReference newUserRef = firestore.collection("users").doc();
          parentUid = newUserRef.id;
          studentData['parentId'] = parentUid;

          batch.set(studentRef, studentData);

          // Create User Account (Including studentIds array)
          batch.set(newUserRef, {
            "uid": parentUid,
            "role": "parent",
            "name": parentName,
            "phone": parentPhone,
            "user_name": parentPhone,
            "password": parentPhone,
            "studentIds": [docId], // NEW: Initialize the list in users collection
            "createdAt": FieldValue.serverTimestamp(),
            "createdBy": adminUid,
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
        // --- CASE B: EDIT EXISTING STUDENT ---
        batch.update(studentRef, studentData);

        String? parentId = widget.initialData?['parentId'];
        if (parentId != null) {
          batch.update(firestore.collection("parents").doc(parentId), {
            "parentName": parentName,
            "phone": parentPhone,
            "updatedAt": FieldValue.serverTimestamp(),
          });

          batch.update(firestore.collection("users").doc(parentId), {
            "name": parentName,
            "phone": parentPhone,
            "user_name": parentPhone,
          });
        }
      }

      await batch.commit();

      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.initialData == null ? "Registration Successful" : "Profile Updated Successfully"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      debugPrint("Save Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save: $e"), backgroundColor: Colors.red)
      );
    }
  }
}