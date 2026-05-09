import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../providers/admin_provider.dart';
import 'add_staff_screen.dart';

class StaffManagementPage extends StatefulWidget {
  final String userName, userId;

  const StaffManagementPage({
    super.key,
    required this.userName,
    required this.userId,
  });

  @override
  State<StaffManagementPage> createState() => _StaffManagementPageState();
}

class _StaffManagementPageState extends State<StaffManagementPage> {
  String searchQuery = "";

  static const Color primaryBlue = Color(0xFF031937);
  static const Color surfaceColor = Color(0xFFE9EDF7);

  @override
  Widget build(BuildContext context) {
    final adminProv = Provider.of<AdminProvider>(context);

    return Scaffold(
      backgroundColor: surfaceColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, adminProv),
            const SizedBox(height: 15),



            Expanded(
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildTableHead(),
                    const Divider(height: 1, color: Color(0xFFF1F4F9)),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: adminProv.getStaffStream(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) return _buildStatusMessage("Sync error occurred.");
                          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: primaryBlue, strokeWidth: 2));

                          final filteredList = snapshot.data!.docs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final name = (data['name'] ?? "").toString().toLowerCase();
                            final phone = (data['phone'] ?? "").toString();
                            return name.contains(searchQuery.toLowerCase()) || phone.contains(searchQuery);
                          }).toList();

                          if (filteredList.isEmpty) return _buildEmptyState();

                          return ListView.builder(
                            itemCount: filteredList.length,
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              final doc = filteredList[index];
                              final staff = doc.data() as Map<String, dynamic>;
                              return _StaffRow(
                                staff: staff,
                                docId: doc.id,
                                slNo: index + 1,
                                onView: () => _viewStaff(context, staff),
                                onEdit: () => _handleEdit(context, staff, doc.id),
                                onDelete: () => _handleDelete(context, doc.id, staff['name']),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AdminProvider prov) {
    return Row(
      children: [
        // --- Back Button Added Here ---
        IconButton(
          onPressed: () => context.read<AdminProvider>().setIndex(0),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: primaryBlue),
          splashRadius: 22,
          tooltip: 'Back',
        ),
        const SizedBox(width: 8),
        const Text(
            "Staff Management",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryBlue)
        ),
        const Spacer(),
        Container(
          width: 350,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => searchQuery = v),
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: "Search name or phone...",
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
              ),
              const Icon(Icons.search, color: primaryBlue, size: 18),
            ],
          ),
        ),
        const SizedBox(width: 15),
        ElevatedButton.icon(
          onPressed: () {
            prov.clearStaffForm();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AddStaffScreen(
                        userId: widget.userId,
                        userName: widget.userName,
                        docId: null
                    )
                )
            );
          },
          icon: const Icon(Icons.add, size: 16, color: Colors.white),
          label: const Text("Add Staff", style: TextStyle(color: Colors.white, fontSize: 13)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF334DCB),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterDropdown("Status"),
          const SizedBox(width: 8),
          _filterDropdown("Designation"),
          const SizedBox(width: 8),
          _filterDropdown("Visa"),
        ],
      ),
    );
  }

  Widget _filterDropdown(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down, size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildTableHead() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(color: Color(0xFFE1E9FF)),
      child: const Row(
        children: [
          SizedBox(width: 50, child: Text("SL NO", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryBlue))),
          Expanded(flex: 3, child: Text("NAME", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryBlue))),
          Expanded(flex: 2, child: Text("QUALIFICATION", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryBlue))),
          Expanded(flex: 3, child: Text("PHONE / AADHAAR", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryBlue))),
          Expanded(flex: 2, child: Text("POSITION", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryBlue))),
          SizedBox(width: 80, child: Center(child: Text("ACTIONS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryBlue)))),
        ],
      ),
    );
  }

  // logic methods (handleEdit, handleDelete, viewStaff) remain unchanged...
  void _handleEdit(BuildContext context, Map<String, dynamic> staff, String docId) {
    final prov = context.read<AdminProvider>();
    prov.clearStaffForm();
    prov.nameCtrl.text = staff['name'] ?? "";
    prov.phoneCtrl.text = staff['phone'] ?? "";
    prov.aadharCtrl.text = staff['aadhar'] ?? "";
    prov.ageCtrl.text = staff['age']?.toString() ?? "";
    prov.passwordCtrl.text = staff['password'] ?? "";
    prov.addressCtrl.text = staff['address'] ?? "";
    prov.expCtrl.text = staff['total_experience']?.toString() ?? "";
    prov.selectedRole = staff['role'];
    prov.selectedGender = staff['gender'];
    prov.selectedQual = staff['qualification'];
    prov.selectedDesignation = staff['designation'];
    if (staff['subjects'] != null) {
      prov.selectedSubjects = List<Map<String, dynamic>>.from(staff['subjects']);
    } else {
      prov.selectedSubjects = [];
    }
    if (staff['dob'] != null) {
      prov.dob = (staff['dob'] is Timestamp) ? (staff['dob'] as Timestamp).toDate() : DateTime.tryParse(staff['dob'].toString());
    }
    if (staff['joining_date'] != null) {
      prov.joiningDate = (staff['joining_date'] is Timestamp) ? (staff['joining_date'] as Timestamp).toDate() : DateTime.tryParse(staff['joining_date'].toString());
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => AddStaffScreen(userId: widget.userId, userName: widget.userName, docId: docId)));
  }

  void _handleDelete(BuildContext context, String id, String? name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Record"),
        content: Text("Are you sure you want to delete $name?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await context.read<AdminProvider>().removeStaff(docId: id, adminId: widget.userId, adminName: widget.userName);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _viewStaff(BuildContext context, Map<String, dynamic> staff) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(staff['name'] ?? "Details", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            ListTile(dense: true, title: const Text("Phone"), subtitle: Text(staff['phone'] ?? "N/A")),
            ListTile(dense: true, title: const Text("Aadhaar"), subtitle: const Text("[Aadhaar Redacted]")),
            ListTile(dense: true, title: const Text("Address"), subtitle: Text(staff['address'] ?? "N/A")),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() => const Center(child: Text("No records found"));
  Widget _buildStatusMessage(String m) => Center(child: Text(m, style: const TextStyle(color: Colors.redAccent)));
}

class _StaffRow extends StatefulWidget {
  final Map<String, dynamic> staff;
  final String docId;
  final int slNo;
  final VoidCallback onView, onEdit, onDelete;
  const _StaffRow({required this.staff, required this.docId, required this.slNo, required this.onView, required this.onEdit, required this.onDelete});

  @override
  State<_StaffRow> createState() => _StaffRowState();
}

class _StaffRowState extends State<_StaffRow> {
  bool isH = false;

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.staff['isActive'] ?? true;
    const Color primaryBlue = Color(0xFF031937);

    return MouseRegion(
      onEnter: (_) => setState(() => isH = true),
      onExit: (_) => setState(() => isH = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isH ? const Color(0xFFF5F7FF) : Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey.shade50)),
        ),
        child: Row(
          children: [
            SizedBox(width: 50, child: Text(widget.slNo.toString(), style: const TextStyle(fontSize: 12, color: Colors.blueGrey))),
            Expanded(
              flex: 3,
              child: Text(
                widget.staff['name'] ?? "—",
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: primaryBlue),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                widget.staff['qualification'] ?? "N/A",
                style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.staff['phone'] ?? "—", style: const TextStyle(fontSize: 12, color: primaryBlue)),
                  if (widget.staff['aadhar'] != null)
                     Text( widget.staff['aadhar'].toString(), style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                widget.staff['role'] ?? "Staff",
                style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
              ),
            ),
            SizedBox(
              width: 80,
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz, size: 18, color: Colors.grey),
                onSelected: (val) {
                  if (val == 'view') widget.onView();
                  if (val == 'edit') widget.onEdit();
                  if (val == 'delete') widget.onDelete();
                  if (val == 'status') context.read<AdminProvider>().toggleStaffStatus(widget.docId, isActive);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'view', child: Text("View", style: TextStyle(fontSize: 13))),
                  const PopupMenuItem(value: 'edit', child: Text("Edit", style: TextStyle(fontSize: 13))),
                  PopupMenuItem(value: 'status', child: Text(isActive ? "Deactivate" : "Activate", style: const TextStyle(fontSize: 13))),
                  const PopupMenuItem(value: 'delete', child: Text("Delete", style: TextStyle(color: Colors.red, fontSize: 13))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}