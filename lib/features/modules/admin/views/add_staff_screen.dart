import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/admin_provider.dart';

class AddStaffScreen extends StatefulWidget {
  final String userId, userName;
  final String? docId;
  const AddStaffScreen({super.key, required this.userId, required this.userName, required this.docId});

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  static const Color primaryTeal = Color(0xff00796B);

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
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: _buildThemedAppBar(),
      bottomNavigationBar: _buildThemedFooter(prov),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// --- COLUMN 1: IDENTITY ---
                Expanded(
                  flex: 3,
                  child: _buildPanel(
                    title: "Identity",
                    icon: Icons.person_pin_rounded,
                    children: [
                      _item("Full Name", _field(prov.nameCtrl, "Enter name", Icons.badge_outlined)),
                      const SizedBox(height: 12),
                      _item("Phone Number", _field(prov.phoneCtrl, "Contact Number", Icons.phone_android, isNumber: true)),
                      const SizedBox(height: 12),

                      // Grouped: Date of Birth and Gender
                      Row(
                        children: [
                          Expanded(child: _item("Date of Birth", _dobPicker(context, prov))),
                          const SizedBox(width: 12),
                          Expanded(child: _item("Gender", _dropdown(['Male', 'Female', 'Other'], prov.selectedGender, (v) => prov.selectedGender = v))),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _item("Address", _field(prov.addressCtrl, "Residential Address", Icons.map_outlined, maxLines: 2)),
                    ],
                  ),
                ),

                const SizedBox(width: 20),

                /// --- COLUMN 2: PROFESSIONAL & SYSTEM ---
                Expanded(
                  flex: 4,
                  child: _buildPanel(
                    title: "Professional & System Access",
                    icon: Icons.admin_panel_settings_rounded,
                    children: [
                      _item("Role", _dropdown(['admin', 'staff', 'teacher'], prov.selectedRole, (v) => prov.selectedRole = v)),
                      const SizedBox(height: 12),

                      // Grouped: Qualification & Experience
                      Row(
                        children: [
                          Expanded(child: _item("Qualification", _dropdown(['B.Ed', 'M.Ed', 'PhD', 'B.Tech'], prov.selectedQual, (v) => prov.selectedQual = v))),
                          const SizedBox(width: 12),
                          Expanded(child: _item("Experience (Yrs)", _field(prov.expCtrl, "e.g. 5", Icons.history, isNumber: true))),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _item("Aadhar Number", _field(prov.aadharCtrl, "0000 0000 0000", Icons.fingerprint, isNumber: true)),
                      const SizedBox(height: 12),

                      // Grouped: Joining Date & Password
                      Row(
                        children: [
                          Expanded(child: _item("Joining Date", _dateButton(context, prov))),
                          const SizedBox(width: 12),
                          Expanded(child: _item("System Password", _field(prov.passwordCtrl, "Set password", Icons.key_outlined, isPassword: true))),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 20),

                /// --- COLUMN 3: ACADEMIC MAPPING ---
                Expanded(
                  flex: 3,
                  child: prov.selectedRole == 'teacher'
                      ? _buildPanel(
                    title: "Academic Assignments",
                    icon: Icons.school_rounded,
                    children: [
                      _item("Designation", _dropdown(['Teacher', 'Class Teacher'], prov.selectedDesignation, (v) => prov.selectedDesignation = v)),
                      const SizedBox(height: 12),
                      _item("Subjects Assignment", _buildSubjectGrid(prov)),
                    ],
                  )
                      : _buildPlaceholder(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildThemedAppBar() {
    return AppBar(
      backgroundColor: primaryTeal,
      elevation: 4,
      leading: const BackButton(color: Colors.white),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.docId == null ? "Staff Enrollment" : "Update Profile",
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          Text(" ${widget.userName}", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildPanel({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 20, color: primaryTeal),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          ]),
          const Divider(height: 30, color: Color(0xFFF1F5F9)),
          ...children,
        ],
      ),
    );
  }

  Widget _item(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.5)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _field(TextEditingController c, String h, IconData i, {bool isNumber = false, bool isPassword = false, bool isReadOnly = false, int maxLines = 1}) {
    return TextFormField(
      controller: c,
      obscureText: isPassword,
      readOnly: isReadOnly,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
      validator: (v) => (v == null || v.isEmpty) ? "Field Required" : null,
      decoration: _deco(h, i),
    );
  }

  Widget _dropdown(List<String> items, String? value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
      onChanged: (v) {
        onChanged(v);
        context.read<AdminProvider>().notifyListeners();
      },
      decoration: _deco("Select Option", Icons.keyboard_arrow_down_rounded),
    );
  }

  Widget _dateButton(BuildContext context, AdminProvider prov) => InkWell(
    onTap: () async {
      final d = await showDatePicker(context: context, firstDate: DateTime(2000), lastDate: DateTime.now(), builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: primaryTeal)), child: child!));
      if (d != null) {
        prov.joiningDate = d;
        prov.notifyListeners();
      }
    },
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(children: [
        const Icon(Icons.calendar_month, size: 16, color: primaryTeal),
        const SizedBox(width: 10),
        Text(prov.joiningDate == null ? "Select Date" : prov.joiningDate.toString().split(' ')[0], style: const TextStyle(fontSize: 13)),
      ]),
    ),
  );

  Widget _dobPicker(BuildContext context, AdminProvider prov) => InkWell(
    onTap: () async {
      final d = await showDatePicker(
          context: context,
          initialDate: DateTime(1995, 1, 1),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
          builder: (context, child) => Theme(
              data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: primaryTeal)),
              child: child!
          )
      );
      if (d != null) {
        prov.dob = d;
        DateTime now = DateTime.now();
        int age = now.year - d.year;
        if (now.month < d.month || (now.month == d.month && now.day < d.day)) {
          age--;
        }
        prov.ageCtrl.text = age.toString();
        prov.notifyListeners();
      }
    },
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(children: [
        const Icon(Icons.cake_outlined, size: 16, color: primaryTeal),
        const SizedBox(width: 10),
        Text(prov.dob == null ? "Birthday" : prov.dob.toString().split(' ')[0], style: const TextStyle(fontSize: 13)),
        const Spacer(),
        if(prov.dob != null)
          Text("Age: ${prov.ageCtrl.text}", style: const TextStyle(fontSize: 12, color: primaryTeal, fontWeight: FontWeight.bold)),
      ]),
    ),
  );

  Widget _buildSubjectGrid(AdminProvider prov) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0))
      ),
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 6,
          runSpacing: 0,
          children: prov.subjectsList.map((subject) {
            final String subId = subject['id'].toString();
            final String subName = subject['name'].toString();
            final isSelected = prov.selectedSubjects.any((item) => item['id'] == subId);

            return FilterChip(
              label: Text(subName, style: TextStyle(fontSize: 10, color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  prov.selectedSubjects.add({"id": subId, "name": subName});
                } else {
                  prov.selectedSubjects.removeWhere((item) => item['id'] == subId);
                }
                prov.notifyListeners();
              },
              selectedColor: primaryTeal,
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            );
          }).toList(),
        ),
      ),
    );
  }

  InputDecoration _deco(String hint, IconData icon) => InputDecoration(
    prefixIcon: Icon(icon, size: 16, color: primaryTeal.withOpacity(0.5)),
    hintText: hint,
    isDense: true,
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primaryTeal, width: 1.5)),
  );

  Widget _buildPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(color: const Color(0xFFE2E8F0).withOpacity(0.3), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid)),
      child: const Center(child: Text("Teacher-specific fields will activate here.", textAlign: TextAlign.center, style: TextStyle(color: Colors.blueGrey, fontSize: 11, fontWeight: FontWeight.w500))),
    );
  }

  Widget _buildThemedFooter(AdminProvider prov) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      decoration: BoxDecoration(color: Colors.white, border: const Border(top: BorderSide(color: Color(0xFFE2E8F0)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Discard", style: TextStyle(color: Color(0xFF64748B))),
          ),
          const SizedBox(width: 20),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate() && prov.joiningDate != null) {
                await prov.saveStaffFull(docId: widget.docId, userId: widget.userId, userName: widget.userName);
                if (mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryTeal,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text(widget.docId == null ? "Complete Registration" : "Save Records", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}