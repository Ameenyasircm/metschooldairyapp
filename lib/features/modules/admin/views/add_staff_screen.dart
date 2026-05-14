import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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

  // Theme Colors - Updated as per request
  static const Color primaryBlue = Color(0xFF031937);
  static const Color secondaryBlue = Color(0xFF003865);
  static const Color bgColor = Color(0xFFF8FAFC);

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
      backgroundColor: bgColor,
      appBar: _buildModernAppBar(),
      bottomNavigationBar: _buildThemedFooter(prov),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// --- COLUMN 1: IDENTITY ---
                    Expanded(
                      flex: 3,
                      child: _buildPanel(
                        title: "Identity",
                        subtitle: "Basic personal identifiers",
                        icon: Icons.person_pin_rounded,
                        children: [
                          _item("Full Name", _field(prov.nameCtrl, "Enter full name", Icons.badge_outlined)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _item("Phone Number", _field(prov.phoneCtrl, "Contact Number", Icons.phone_android, isNumber: true))),
                              const SizedBox(width: 12),
                              Expanded(child: _item("Gender", _dropdown(['Male', 'Female', 'Other'], prov.selectedGender, (v) => prov.selectedGender = v))),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _item("Date of Birth", _dobPicker(context, prov)),
                          const SizedBox(height: 16),
                          _item("Address", _field(prov.addressCtrl, "Full residential address", Icons.map_outlined, maxLines: 2)),
                        ],
                      ),
                    ),

                    const SizedBox(width: 24),

                    /// --- COLUMN 2: PROFESSIONAL ---
                    Expanded(
                      flex: 4,
                      child: _buildPanel(
                        title: "Professional & System",
                        subtitle: "Role assignment and credentials",
                        icon: Icons.admin_panel_settings_rounded,
                        children: [
                          _item("System Role", _dropdown(['admin', 'staff', 'teacher'], prov.selectedRole, (v) => prov.selectedRole = v)),
                          const SizedBox(height: 16),
                          Consumer<AdminProvider>(
                            builder: (contextss, val, child) {
                              List<String> qualificationNames = val.qualificationList
                                  .map((e) => e['qualification'].toString())
                                  .toList();

                              return Row(
                                children: [
                                  Expanded(
                                    child: _item(
                                      "Qualification",
                                      _dropdown(
                                        qualificationNames,
                                        val.selectedQual,
                                            (v) {
                                          val.selectedQual = v;
                                          val.notifyListeners();
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _item(
                                      "Experience (Yrs)",
                                      _field(
                                        val.expCtrl,
                                        "e.g. 5",
                                        Icons.history,
                                        isNumber: true,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          _item("Aadhar Number", _field(prov.aadharCtrl, "0000 0000 0000", Icons.fingerprint, isNumber: true)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _item("Joining Date", _dateButton(context, prov))),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Consumer<AdminProvider>(
                                  builder: (context, val, child) {
                                    return _item(
                                      "Portal Password",
                                      _field(
                                        val.passwordCtrl,
                                        "Set password",
                                        Icons.key_outlined,
                                        isPassword: val.obscurePassword,
                                        suffix: IconButton(
                                          icon: Icon(
                                            val.obscurePassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            size: 18,
                                            color: secondaryBlue.withOpacity(0.6),
                                          ),
                                          onPressed: () => val.togglePasswordVisibility(),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: BackButton(color: primaryBlue.withOpacity(0.7)),
      shape: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.docId == null ? "Staff Enrollment" : "Update Profile",
              style: const TextStyle(color: primaryBlue, fontSize: 18, fontWeight: FontWeight.bold)),
          Text("Acting Admin: ${widget.userName}", style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildPanel({required String title, required String subtitle, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: secondaryBlue),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryBlue)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ],
          ),
          const Divider(height: 40, color: Color(0xFFF1F5F9)),
          ...children,
        ],
      ),
    );
  }

  Widget _item(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.5)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

// Updated _field to allow optional validation
  Widget _field(TextEditingController c, String h, IconData i, {
    bool isNumber = false,
    bool isPassword = false,
    int maxLines = 1,
    Widget? suffix,
    bool required = true, // 👈 Add this parameter
  }) {
    return TextFormField(
      controller: c,
      obscureText: isPassword,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(fontSize: 14, color: primaryBlue),
      // 👈 Only validate if 'required' is true
      validator: (v) => (required && (v == null || v.isEmpty)) ? "Required" : null,
      decoration: _deco(h, i, suffix: suffix),
    );
  }
  Widget _dropdown(List<String> items, String? value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
      onChanged: (v) {
        onChanged(v);
        context.read<AdminProvider>().notifyListeners();
      },
      decoration: _deco("Select ", Icons.keyboard_arrow_down_rounded),
    );
  }

  Widget _dateButton(BuildContext context, AdminProvider prov) => InkWell(
    onTap: () async {
      final d = await showDatePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: secondaryBlue)),
          child: child!,
        ),
      );
      if (d != null) {
        prov.joiningDate = d;
        prov.notifyListeners();
      }
    },
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(children: [
        const Icon(Icons.calendar_month, size: 18, color: secondaryBlue),
        const SizedBox(width: 10),
        Text(prov.joiningDate == null ? "Select Date" : DateFormat('dd-MM-yyyy').format(prov.joiningDate!), style: const TextStyle(fontSize: 14)),
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
          data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: secondaryBlue)),
          child: child!,
        ),
      );
      if (d != null) {
        prov.dob = d;
        DateTime now = DateTime.now();
        int age = now.year - d.year;
        if (now.month < d.month || (now.month == d.month && now.day < d.day)) age--;
        prov.ageCtrl.text = age.toString();
        prov.notifyListeners();
      }
    },
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(children: [
        const Icon(Icons.cake_outlined, size: 18, color: secondaryBlue),
        const SizedBox(width: 10),
        Text(prov.dob == null ? "Birthday" : DateFormat('dd-MM-yyyy').format(prov.dob!), style: const TextStyle(fontSize: 14)),
        const Spacer(),
        if(prov.dob != null)
          Text("${prov.ageCtrl.text} Yrs", style: const TextStyle(fontSize: 12, color: secondaryBlue, fontWeight: FontWeight.bold)),
      ]),
    ),
  );

  InputDecoration _deco(String hint, IconData? icon, {Widget? suffix}) => InputDecoration(
    prefixIcon: icon != null ? Icon(icon, size: 18, color: secondaryBlue.withOpacity(0.5)) : null,
    suffixIcon: suffix,
    hintText: hint,
    isDense: true,
    filled: true,
    fillColor: bgColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: secondaryBlue, width: 1.5)),
  );

  Widget _buildThemedFooter(AdminProvider prov) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: prov.isLoading ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: const Text("Discard Changes",
                style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: prov.isLoading
                ? null
                : () async {
              bool isValid = _formKey.currentState!.validate();

              if (isValid && prov.joiningDate != null) {
                try {
                  await prov.saveStaffFull(
                      docId: widget.docId,
                      userId: widget.userId,
                      userName: widget.userName
                  );
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  if (mounted) {
                    // This captures the "Already registered" error from the provider
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                        )
                    );
                  }
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill all required fields and select a joining date"))
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              disabledBackgroundColor: primaryBlue.withOpacity(0.6),
            ),
            child: prov.isLoading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : Text(
                widget.docId == null ? "Enroll Staff Member" : "Save Profile Changes",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
            ),
          ),
        ],
      ),
    );
  }
}