import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController admissionController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String? selectedClass;
  String? selectedGender;
  DateTime? dob;

  final List<String> classList = [
    "CLASS 1",
    "CLASS 2",
    "CLASS 3",
    "CLASS 4"
  ];

  final List<String> genderList = ["Male", "Female", "Other"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: Column(
        children: [

          /// ================= HEADER =================
          Container(
            height: 90,
            padding: const EdgeInsets.symmetric(horizontal: 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back,
                      color: Colors.white),
                ),

                const SizedBox(width: 10),

                const Text(
                  "Add Student",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          /// ================= FORM =================
          Expanded(
            child: Center(
              child: Container(
                width: 800, // 🔥 web centered form
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),

                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// TITLE
                      const Text(
                        "Student Information",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 25),

                      /// NAME + ADMISSION ID
                      Row(
                        children: [
                          Expanded(
                            child: _textField(
                              controller: nameController,
                              label: "Student Name",
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _textField(
                              controller: admissionController,
                              label: "Admission ID",
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// CLASS + GENDER
                      Row(
                        children: [
                          Expanded(
                            child: _dropdown(
                              label: "Class",
                              value: selectedClass,
                              items: classList,
                              onChanged: (val) {
                                setState(() {
                                  selectedClass = val;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _dropdown(
                              label: "Gender",
                              value: selectedGender,
                              items: genderList,
                              onChanged: (val) {
                                setState(() {
                                  selectedGender = val;
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// DOB + PHONE
                      Row(
                        children: [
                          Expanded(
                            child: _dateField(),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _textField(
                              controller: phoneController,
                              label: "Phone Number",
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// ADDRESS
                      _textField(
                        controller: addressController,
                        label: "Address",
                        maxLines: 3,
                      ),

                      const SizedBox(height: 30),

                      /// SAVE BUTTON
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            const Color(0xFF0F766E),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _saveStudent,
                          child: const Text("Save Student",
                              style:
                              TextStyle(color: Colors.white)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  /// ================= SAVE =================
  void _saveStudent() {
    if (nameController.text.isEmpty ||
        admissionController.text.isEmpty ||
        selectedClass == null) return;

    /// 👉 call provider here
    print("Student Saved");
  }

  /// ================= WIDGETS =================

  Widget _textField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
      items: items
          .map((e) =>
          DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _dateField() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime(2010),
          firstDate: DateTime(1990),
          lastDate: DateTime.now(),
        );

        if (picked != null) {
          setState(() {
            dob = picked;
          });
        }
      },
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 18),
            const SizedBox(width: 10),
            Text(
              dob == null
                  ? "Date of Birth"
                  : DateFormat('dd MMM yyyy').format(dob!),
            ),
          ],
        ),
      ),
    );
  }
}