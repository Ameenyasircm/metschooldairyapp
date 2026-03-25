import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/admin_provider.dart';

class StaffManagementPage extends StatelessWidget {
  const StaffManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final adminProv = Provider.of<AdminProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER SECTION ---
          Row(
            children: [
              IconButton(
                onPressed: () => adminProv.setIndex(0),
                icon: const Icon(Icons.arrow_back_ios, size: 20, color: AppColors.textBlack),
              ),
              const SizedBox(width: 10),
              const Text("Staff Directory",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textBlack)),
              const Spacer(),
              _buildAddButton(context),
            ],
          ),
          const SizedBox(height: 30),

          // --- DATA TABLE CONTAINER ---
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.silverGrey.withOpacity(0.2)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: StreamBuilder<QuerySnapshot>(
                  stream: adminProv.getStaffStream(), // Logic from Provider
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return const Center(child: Text("Error loading data"));
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
                    }

                    final staffList = snapshot.data!.docs;

                    if (staffList.isEmpty) {
                      return const Center(child: Text("No staff members found. Add your first employee!"));
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(AppColors.offWhite),
                        dataRowMinHeight: 70,
                        dataRowMaxHeight: 80,
                        horizontalMargin: 24,
                        columns: const [
                          DataColumn(label: Text("NAME", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("DESIGNATION", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("CATEGORY", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("PHONE", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("ACTIONS", style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: staffList.map((doc) {
                          var staff = doc.data() as Map<String, dynamic>;
                          String docId = doc.id;
                          return _buildDataRow(context, staff, docId);
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      onPressed: () => _showStaffDrawer(context, null),
      icon: const Icon(Icons.add_rounded),
      label: const Text("Add New Employee", style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  DataRow _buildDataRow(BuildContext context, Map<String, dynamic> staff, String docId) {
    return DataRow(cells: [
      DataCell(Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
            child: Text(staff['name']?[0] ?? "?", style: const TextStyle(color: AppColors.primaryBlue)),
          ),
          const SizedBox(width: 15),
          Text(staff['name'] ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      )),
      DataCell(Text(staff['designation'] ?? "-")),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.silverGrey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(staff['category'] ?? "General", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      )),
      DataCell(Text(staff['phone'] ?? "-")),
      DataCell(Row(
        children: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: AppColors.primaryBlue),
            onPressed: () => _showStaffDrawer(context, staff, docId: docId),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.errorRed),
            onPressed: () => _confirmDelete(context, docId, staff['name']),
          ),
        ],
      )),
    ]);
  }

  void _showStaffDrawer(BuildContext context, Map<String, dynamic>? staff, {String? docId}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "StaffForm",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.centerRight,
          child: StaffFormDialog(staff: staff, docId: docId),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(1, 0), end: const Offset(0, 0)).animate(anim1),
          child: child,
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, String docId, String? name) {
    final adminProv = Provider.of<AdminProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: Text("Are you sure you want to remove $name? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            onPressed: () async {
              await adminProv.removeStaff(docId);
              if (context.mounted) Navigator.pop(context);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("$name deleted successfully"), backgroundColor: AppColors.textBlack),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// --- SIDE DRAWER FORM ---
class StaffFormDialog extends StatefulWidget {
  final Map<String, dynamic>? staff;
  final String? docId;
  const StaffFormDialog({super.key, this.staff, this.docId});

  @override
  State<StaffFormDialog> createState() => _StaffFormDialogState();
}

class _StaffFormDialogState extends State<StaffFormDialog> {
  // Controllers
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final empIdCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final qualCtrl = TextEditingController();
  final expCtrl = TextEditingController();
  final subjectCtrl = TextEditingController(); // For simple comma-separated input

  // Dropdown States
  String? selectedRole; // admin | staff | teacher
  String? selectedCategory; // KG | LP | UP | HS
  String? selectedGender;

  @override
  void initState() {
    super.initState();
    if (widget.staff != null) {
      nameCtrl.text = widget.staff?['name'] ?? '';
      phoneCtrl.text = widget.staff?['phone'] ?? '';
      empIdCtrl.text = widget.staff?['employee_id'] ?? '';
      addressCtrl.text = widget.staff?['address'] ?? '';
      qualCtrl.text = widget.staff?['qualification'] ?? '';
      expCtrl.text = widget.staff?['total_experience']?.toString() ?? '';
      selectedRole = widget.staff?['role'];
      selectedCategory = widget.staff?['category'];
      selectedGender = widget.staff?['gender'];
    }
  }

  void _clearForm() {
    nameCtrl.clear();
    phoneCtrl.clear();
    empIdCtrl.clear();
    addressCtrl.clear();
    qualCtrl.clear();
    expCtrl.clear();
    setState(() {
      selectedRole = null;
      selectedCategory = null;
      selectedGender = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProv = Provider.of<AdminProvider>(context, listen: false);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        height: double.infinity,
        decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)]),
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 40),
            Expanded(
              child: ListView(
                children: [
                  _buildSectionTitle("Basic Information"),
                  _buildTextField(nameCtrl, "Full Name", Icons.person_outline),
                  _buildTextField(phoneCtrl, "Phone Number", Icons.phone_outlined),
                  _buildDropdown("Role", ['admin', 'staff', 'teacher'], selectedRole, (v) => setState(() => selectedRole = v)),

                  const SizedBox(height: 20),
                  _buildSectionTitle("Staff Profile Details"),
                  _buildTextField(empIdCtrl, "Employee ID", Icons.badge_outlined),
                  _buildDropdown("Category", ['KG', 'LP', 'UP', 'HS'], selectedCategory, (v) => setState(() => selectedCategory = v)),
                  _buildDropdown("Gender", ['Male', 'Female', 'Other'], selectedGender, (v) => setState(() => selectedGender = v)),
                  _buildTextField(qualCtrl, "Qualification", Icons.school_outlined),
                  _buildTextField(expCtrl, "Total Experience (Years)", Icons.timeline, isNumber: true),
                  _buildTextField(addressCtrl, "Address", Icons.home_outlined, maxLines: 2),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSubmitButton(adminProv),
          ],
        ),
      ),
    );
  }

  // --- Helper UI Components ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.staff == null ? "Add New Staff" : "Edit Staff", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Text(title, style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 14)),
  );

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase()))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSubmitButton(AdminProvider prov) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        onPressed: () async {
          final userData = {
            'name': nameCtrl.text,
            'phone': phoneCtrl.text,
            'role': selectedRole,
            'uid': widget.docId,
            'createdAt': FieldValue.serverTimestamp(),
          };

          final profileData = {
            'employee_id': empIdCtrl.text,
            'designation': selectedRole, // Mapping role to designation for now
            'category': selectedCategory,
            'gender': selectedGender,
            'qualification': qualCtrl.text,
            'address': addressCtrl.text,
            'uid': widget.docId,
            'total_experience': int.tryParse(expCtrl.text) ?? 0,
          };

          await prov.saveStaffFull(docId: widget.docId, userData: userData, profileData: profileData);
          _clearForm();
          if (mounted) Navigator.pop(context);
        },
        child: const Text("Save Staff Member", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
