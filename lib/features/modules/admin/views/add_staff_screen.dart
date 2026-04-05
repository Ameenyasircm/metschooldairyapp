import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../providers/admin_provider.dart';

class AddStaffScreen extends StatefulWidget {
  final String userId, userName;

  const AddStaffScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<AdminProvider>().fetchSubjects());
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Center(
        child: Container(
          width: 900,
          padding: const EdgeInsets.all(25),
          child: ListView(
            children: [
              /// 🔥 ROLE FIRST
              _card(
                title: "Staff Type",
                child: _dropdown(
                  "Select Role",
                  prov.selectedRole,
                  ['admin', 'staff', 'teacher'],
                      (v) {
                    prov.selectedRole = v;
                    prov.notifyListeners();
                  },
                ),
              ),

              const SizedBox(height: 20),

              /// BASIC
              /// ADD THESE INSIDE YOUR EXISTING UI (important changes only)

              /// 🔥 BASIC (UPDATED)
              _card(
                title: "Basic Info",
                child: Column(
                  children: [
                    _two(_field(prov.nameCtrl, "Name"),
                        _field(prov.phoneCtrl, "Phone")),

                    _two(_field(prov.usernameCtrl, "Username"),
                        _field(prov.passwordCtrl, "Password")),

                    _two(_field(prov.emailCtrl, "Email"),
                        _dropdown(
                          "Gender",
                          prov.selectedGender,
                          ['Male', 'Female', 'Other'],
                              (v) {
                            prov.selectedGender = v;
                            prov.notifyListeners();
                          },
                        )),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 🔥 STAFF / TEACHER DETAILS
              if (prov.selectedRole == "staff" ||
                  prov.selectedRole == "teacher")
              /// 🔥 PROFESSIONAL (UPDATED)
                _card(
                  title: "Professional Details",
                  child: Column(
                    children: [
                      _two(
                        _field(prov.empIdCtrl, "Employee ID"),
                        _dropdown(
                          "Category",
                          prov.selectedCategory,
                          ['KG', 'LP', 'UP', 'HS'],
                              (v) {
                            prov.selectedCategory = v;
                            prov.notifyListeners();
                          },
                        ),
                      ),

                      _two(
                        _field(prov.qualCtrl, "Qualification"),
                        _field(prov.expCtrl, "Experience", isNumber: true),
                      ),

                      _two(
                        _field(prov.addressCtrl, "Address"),
                        _datePicker(context, prov),
                      ),

                      const SizedBox(height: 10),

                      /// SUBJECTS
                      Wrap(
                        spacing: 8,
                        children: prov.subjectsList.map((subject) {
                          final selected =
                          prov.selectedSubjects.contains(subject);

                          return FilterChip(
                            label: Text(subject),
                            selected: selected,
                            onSelected: (val) {
                              if (val) {
                                prov.selectedSubjects.add(subject);
                              } else {
                                prov.selectedSubjects.remove(subject);
                              }
                              prov.notifyListeners();
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 30),

              /// 🔥 SAVE BUTTON (BOTTOM)
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: () async {
                    await prov.saveStaffFull(
                      userId: widget.userId,
                      userName: widget.userName,
                    );

                    Navigator.pop(context);
                  },
                  child: const Text("Save Staff",
                      style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// ---------- UI HELPERS ----------

  Widget _card({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary)),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _two(Widget a, Widget b) {
    return Row(
      children: [
        Expanded(child: a),
        const SizedBox(width: 10),
        Expanded(child: b),
      ],
    );
  }

  Widget _field(TextEditingController c, String label,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        keyboardType:
        isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.lightBackground,
        ),
      ),
    );
  }

  Widget _dropdown(String label, String? value, List<String> items,
      Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map((e) => DropdownMenuItem(
        value: e,
        child: Text(e.toUpperCase()),
      ))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _datePicker(BuildContext context, AdminProvider prov) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          prov.joiningDate = date;
          prov.notifyListeners();
        }
      },
      child: Container(
        height: 55,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.lightBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          prov.joiningDate == null
              ? "Select Joining Date"
              : prov.joiningDate.toString().split(' ')[0],
        ),
      ),
    );
  }
}