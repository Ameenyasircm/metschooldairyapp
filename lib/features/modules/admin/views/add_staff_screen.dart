import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/admin_provider.dart';

class AddStaffScreen extends StatefulWidget {
  final String userId, userName;
  final String? docId;
  const AddStaffScreen({super.key, required this.userId, required this.userName,required this.docId});

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final _formKey = GlobalKey<FormState>(); // 🔹 Key for Validation

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final prov = context.read<AdminProvider>();
      prov.fetchSubjects();
      prov.fetchClasses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildCompactHeader(),
      bottomNavigationBar: _buildStickyFooter(context, prov),
      body: SelectionArea(
        child: Form(
          key: _formKey, // 🔹 Wrap everything in Form
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Staff Registration",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                const SizedBox(height: 25),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 15, // Reduced to fit validation error text space
                      children: [
                        _gridItem("First Name", _field(prov.nameCtrl, "Full Name", Icons.person_outline)),
                        _gridItem("Phone Number", _field(prov.phoneCtrl, "Contact No", Icons.phone_android, isNumber: true)),
                        _gridItem("Email Address", _field(prov.emailCtrl, "email@school.com", Icons.mail_outline, isEmail: true)),
                        _gridItem("Gender", _dropdown(['Male', 'Female', 'Other'], prov.selectedGender, (v) => prov.selectedGender = v)),
                        _gridItem("System Role", _dropdown(['admin', 'staff', 'teacher'], prov.selectedRole, (v) => prov.selectedRole = v)),

                        _gridItem("Qualification", _dropdown(['B.Ed', 'M.Ed', 'TTC', 'PhD', 'B.Tech', 'M.Sc'], prov.selectedQual, (v) => prov.selectedQual = v)),
                        _gridItem("Total Experience", _field(prov.expCtrl, "Years", Icons.history, isNumber: true)),
                        _gridItem("Joining Date", _dateButton(context, prov)),
                        _gridItem("Access Password", _field(prov.passwordCtrl, "••••••••", Icons.lock_outline, isPassword: true)),
                        _gridItem("Employee ID", _field(prov.empIdCtrl, "SF-000", Icons.badge_outlined)),

                        if (prov.selectedRole == "teacher") ...[
                          _gridItem("Designation", _dropdown(['Teacher', 'Class Teacher'], prov.selectedDesignation, (v) => prov.selectedDesignation = v)),
                          // --- SUBJECTS BLOCK ---
                          Container(
                            width: MediaQuery.of(context).size.width * 0.38,
                            height: 180,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: prov.selectedSubjects.isEmpty && prov.selectedRole == 'teacher' ? Colors.red.shade200 : Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Select  Subjects", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: prov.subjectsList.map((subject) {
                                        final isSelected = prov.selectedSubjects.contains(subject);
                                        return FilterChip(
                                          visualDensity: VisualDensity.compact,
                                          label: Text(subject, style: const TextStyle(fontSize: 11)),
                                          selected: isSelected,
                                          onSelected: (val) {
                                            val ? prov.selectedSubjects.add(subject) : prov.selectedSubjects.remove(subject);
                                            prov.notifyListeners();
                                          },
                                          selectedColor: AppColors.primary.withOpacity(0.1),
                                          checkmarkColor: AppColors.primary,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        _gridItem("Residential Address", _field(prov.addressCtrl, "Full street address...", Icons.map_outlined), isWide: true),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ---------- UI HELPERS WITH VALIDATION ----------

  Widget _gridItem(String label, Widget child, {bool isWide = false}) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: isWide ? screenWidth * 0.40 : screenWidth * 0.17,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          // We don't fix the height here anymore to allow the error text to show if validation fails
          child,
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String hint, IconData icon, {bool isNumber = false, bool isPassword = false, bool isEmail = false}) {
    return TextFormField(
      controller: c,
      obscureText: isPassword,
      keyboardType: isNumber ? TextInputType.number : (isEmail ? TextInputType.emailAddress : TextInputType.text),
      style: const TextStyle(fontSize: 14),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return "Required";
        if (isEmail && !RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return "Invalid Email";
        if (isNumber && int.tryParse(value) == null) return "Numbers only";
        return null;
      },
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 18, color: Colors.blueGrey),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        errorStyle: const TextStyle(fontSize: 10, height: 0.8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.red.shade300)),
      ),
    );
  }

  Widget _dropdown(List<String> items, String? value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      isDense: true,
      validator: (v) => (v == null || v.isEmpty) ? "Field Required" : null,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
      onChanged: (v) { onChanged(v); context.read<AdminProvider>().notifyListeners(); },
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        errorStyle: const TextStyle(fontSize: 10, height: 0.8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
      ),
    );
  }

  Widget _dateButton(BuildContext context, AdminProvider prov) {
    bool hasError = prov.joiningDate == null;
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(context: context, firstDate: DateTime(2000), lastDate: DateTime.now());
        if (date != null) { prov.joiningDate = date; prov.notifyListeners(); }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.blueGrey),
            const SizedBox(width: 10),
            Text(
                prov.joiningDate == null ? "Select Date" : prov.joiningDate.toString().split(' ')[0],
                style: const TextStyle(fontSize: 14)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyFooter(BuildContext context, AdminProvider prov) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel Process", style: TextStyle(color: Colors.grey, fontSize: 14)),
          ),
          const SizedBox(width: 30),
          // Inside _buildStickyFooter in AddStaffScreen
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                if (prov.joiningDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select a Joining Date"), backgroundColor: Colors.redAccent),
                  );
                  return;
                }

                // 🔹 Pass the docId from the widget to the save function
                await prov.saveStaffFull(
                    docId: widget.docId, // 👈 Uses the ID if editing, null if adding
                    userId: widget.userId,
                    userName: widget.userName
                );

                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text(
                widget.docId == null ? "Add Data" : "Update Records", // 👈 Dynamic Text
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildCompactHeader() => AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    toolbarHeight: 50,
    leading: const BackButton(color: Colors.black),
  );
}