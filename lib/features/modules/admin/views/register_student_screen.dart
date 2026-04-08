import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:met_school/providers/academic_provider.dart';
import 'package:provider/provider.dart';

class AddStudentScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData; // Pass this for Edit Mode
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
  final TextEditingController relationCtrl = TextEditingController();
  final TextEditingController fatherJobCtrl = TextEditingController();
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
  String? selectedClassId;      // Fixed: Use String ID for crash-proof dropdown
  String? selectedClassName;    // Store name separately
  String? selectedGender;
  String? selectedReligion;
  String? selectedMedium;
  DateTime? dob;
  DateTime? lastVaccination;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final provider = context.read<AcademicProvider>();

      // 1. Fetch and wait for the formatted classes
      await provider.fetchClasses();

      // 2. Only after classes are loaded, we map the selected class for Edit Mode
      if (widget.initialData != null && mounted) {
        final data = widget.initialData!;

        // Look for the ID in the NEW formattedClasses list
        final String? targetId = data['classId']?.toString();

        bool classExists = provider.formattedClasses.any(
              (cls) => cls['id'] == targetId,
        );

        if (classExists) {
          setState(() {
            selectedClassId = targetId;
            // We take the name from the provider to ensure it matches the dropdown
            selectedClassName = provider.formattedClasses
                .firstWhere((cls) => cls['id'] == targetId)['name'];
          });
        }
      }
    });

    // --- PRE-FILL REMAINING TEXT DATA ---
    if (widget.initialData != null) {
      final data = widget.initialData!;
      nameCtrl.text = data['name'] ?? "";
      admissionCtrl.text = data['admissionId'] ?? "";
      parentCtrl.text = data['parentGuardian'] ?? "";
      relationCtrl.text = data['relation'] ?? "";
      fatherJobCtrl.text = data['fatherProfession'] ?? "";
      phoneCtrl.text = data['phone'] ?? "";
      whatsappCtrl.text = data['whatsapp'] ?? "";
      motherNameCtrl.text = data['motherName'] ?? "";
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

      if (data['dob'] != null) {
        dob = (data['dob'] is DateTime)
            ? data['dob']
            : (data['dob'] as dynamic).toDate();
      }
      if (data['lastVaccination'] != null) {
        lastVaccination = (data['lastVaccination'] is DateTime)
            ? data['lastVaccination']
            : (data['lastVaccination'] as dynamic).toDate();
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
              // Column 1
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
                  _item("Aadhaar Number", _field(aadharCtrl, "0000 0000 0000", Icons.fingerprint, isNumber: true)),
                  const SizedBox(height: 10),
                  _item("Address", _field(addressCtrl, "Permanent Address", Icons.home, maxLines: 2)),
                ]),
              ),
              const SizedBox(width: 12),

              // Column 2
              Expanded(
                flex: 3,
                child: _buildPanel("Family & Contact", Icons.family_restroom, [
                  Row(children: [
                    Expanded(child: _item("Parent/Guardian", _field(parentCtrl, "Name", Icons.person))),
                    const SizedBox(width: 8),
                    Expanded(child: _item("Relation", _field(relationCtrl, "e.g. Father", Icons.link))),
                  ]),
                  const SizedBox(height: 10),
                  _item("Father's Profession", _field(fatherJobCtrl, "Occupation", Icons.work_outline)),
                  const SizedBox(height: 10),
                  _item("Mother's Name", _field(motherNameCtrl, "Name", Icons.woman)),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _item("Contact No", _field(phoneCtrl, "Phone", Icons.phone))),
                    const SizedBox(width: 8),
                    Expanded(child: _item("WhatsApp", _field(whatsappCtrl, "WhatsApp", Icons.chat))),
                  ]),
                  const SizedBox(height: 10),
                  _item("Place", _field(placeCtrl, "City/Village", Icons.location_on_outlined)),
                ]),
              ),
              const SizedBox(width: 12),

              // Column 3
              Expanded(
                flex: 3,
                child: _buildPanel("Academic & Others", Icons.school_outlined, [
                  Row(children: [
                    Expanded(child: _item("Class", academicProv.isClassLoading ? const LinearProgressIndicator() : _classDropdown(academicProv))),
                    const SizedBox(width: 8),
                    Expanded(child: _item("Medium", _dropdown(["English", "Malayalam"], selectedMedium, (v) => setState(() => selectedMedium = v)))),
                  ]),
                  const SizedBox(height: 10),
                  _item("Admission ID", _field(admissionCtrl, "ID", Icons.vpn_key)),
                  const SizedBox(height: 10),
                  _item("Previous School", _field(prevSchoolCtrl, "School Name", Icons.history_edu)),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _item("TC Number", _field(tcNumberCtrl, "TC", Icons.description))),
                    const SizedBox(width: 8),
                    Expanded(child: _item("Vaccination", _datePicker(false))),
                  ]),
                  const SizedBox(height: 10),
                  _item("Identification Mark", _field(idMarkCtrl, "Visible marks", Icons.edit_note)),
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
    // 1. Create unique menu items from the formatted list
    final Set<String> uniqueIds = {};
    final List<DropdownMenuItem<String>> menuItems = [];

    for (var cls in prov.formattedClasses) {
      final String id = cls['id'] ?? "";
      final String name = cls['name'] ?? "Unnamed Class";

      if (id.isNotEmpty && !uniqueIds.contains(id)) {
        uniqueIds.add(id);
        menuItems.add(
          DropdownMenuItem<String>(
            value: id,
            child: Text(name, overflow: TextOverflow.ellipsis),
          ),
        );
      }
    }

    // 2. Safety Check: Validate the current selection against our unique list
    final String? validatedValue = uniqueIds.contains(selectedClassId)
        ? selectedClassId
        : null;

    return DropdownButtonFormField<String>(
      value: validatedValue,
      isExpanded: true,
      style: const TextStyle(fontSize: 13, color: Colors.black),
      hint: const Text("Select Class"),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      items: menuItems,
      onChanged: (String? newVal) {
        if (newVal == null) return;

        try {
          // Find the selected class in the already formatted list
          final selectedClass = prov.formattedClasses.firstWhere(
                  (c) => c['id'] == newVal
          );

          setState(() {
            selectedClassId = newVal;
            selectedClassName = selectedClass['name'];
          });
        } catch (e) {
          debugPrint("Selection mapping error: $e");
        }
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

  Widget _field(TextEditingController ctrl, String hint, IconData icon, {bool isNumber = false, int maxLines = 1, bool isReadOnly = false}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      readOnly: isReadOnly,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 16, color: primaryTeal.withOpacity(0.5)),
        hintText: hint,
        isDense: true,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      ),
      validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
    );
  }

  Widget _dropdown(List<String> items, String? val, Function(String?) onChange) {
    return DropdownButtonFormField<String>(
      value: val,
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
    if (_formKey.currentState!.validate() && dob != null) {
      Map<String, dynamic> data = {
        "name": nameCtrl.text.trim(),
        "admissionId": admissionCtrl.text.trim(),
        "classId": selectedClassId,
        "className": selectedClassName,
        "parentGuardian": parentCtrl.text.trim(),
        "relation": relationCtrl.text.trim(),
        "fatherProfession": fatherJobCtrl.text.trim(),
        "phone": phoneCtrl.text.trim(),
        "whatsapp": whatsappCtrl.text.trim(),
        "motherName": motherNameCtrl.text.trim(),
        "aadhar": aadharCtrl.text.trim(),
        "prevSchool": prevSchoolCtrl.text.trim(),
        "dob": dob,
        "age": ageCtrl.text,
        "religion": selectedReligion,
        "place": placeCtrl.text.trim(),
        "address": addressCtrl.text.trim(),
        "community": communityCtrl.text.trim(),
        "motherTongue": motherTongueCtrl.text.trim(),
        "medium": selectedMedium,
        "tcNumber": tcNumberCtrl.text.trim(),
        "lastVaccination": lastVaccination,
        "identificationMark": idMarkCtrl.text.trim(),
        "gender": selectedGender,
      };

      if (widget.initialData != null) {
        await context.read<AcademicProvider>().updateStudent(widget.initialData!['id'], data);
      } else {
        await context.read<AcademicProvider>().addStudent(studentData: data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.initialData == null ? "Student Registered Successfully" : "Student Profile Updated")));
        Navigator.pop(context);
      }
    } else if (dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select Date of Birth")));
    }
  }
}