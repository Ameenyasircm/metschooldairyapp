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

  @override
  Widget build(BuildContext context) {
    final adminProv = Provider.of<AdminProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 HEADER
            _buildHeader(context, adminProv),

            const SizedBox(height: 30),

            /// 🔹 DATA TABLE CARD
            Expanded(
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7090B0).withOpacity(0.1),
                      blurRadius: 40,
                      offset: const Offset(0, 15),
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
                          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                          final filteredList = snapshot.data!.docs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final name = (data['name'] ?? "").toString().toLowerCase();
                            final phone = (data['phone'] ?? "").toString();
                            final query = searchQuery.toLowerCase();
                            return name.contains(query) || phone.contains(query);
                          }).toList();

                          if (filteredList.isEmpty) return _buildEmptyState();

                          return ListView.builder(
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              final doc = filteredList[index];
                              final staff = doc.data() as Map<String, dynamic>;
                              return _StaffRow(
                                staff: staff,
                                docId: doc.id,
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
        InkWell(
          onTap: () {
            Provider.of<AdminProvider>(context, listen: false).setIndex(0);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
              ],
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF1B2559)),
          ),
        ),
        const SizedBox(width: 20),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Staff Directory", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1B2559))),
          ],
        ),
        const Spacer(),
        Container(
          width: 320,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              const Icon(Icons.search, color: Color(0xFFA3AED0), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => searchQuery = v),
                  decoration: const InputDecoration(
                    hintText: "Search name or phone...",
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: 14, color: Color(0xFFA3AED0)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 15),
        ElevatedButton.icon(
          onPressed: () {
            prov.clearStaffForm();
            Navigator.push(context, MaterialPageRoute(builder: (_) => AddStaffScreen(userId: widget.userId, userName: widget.userName, docId: null)));
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text("Add Member"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildTableHead() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
      child: const Row(
        children: [
          Expanded(flex: 3, child: Text("STAFF NAME", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.black, letterSpacing: 1))),
          Expanded(flex: 2, child: Text("CONTACT / AADHAR", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.black, letterSpacing: 1))),
          Expanded(flex: 2, child: Text("POSITION", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.black, letterSpacing: 1))),
          SizedBox(width: 150, child: Text("ACTIONS", textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.black, letterSpacing: 1))),
        ],
      ),
    );
  }

  void _viewStaff(BuildContext context, Map<String, dynamic> staff) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: 600,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: AppColors.primary,
                      child: Text(staff['name']?[0] ?? "?", style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(staff['name'] ?? "—", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1B2559))),
                          const SizedBox(height: 4),
                          Text((staff['role'] ?? "Staff").toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1)),
                        ],
                      ),
                    ),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: Color(0xFFA3AED0))),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    children: [
                      _sectionHeader("Personal Information"),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(child: _dataItem(Icons.fingerprint, "Aadhar Number", staff['aadhar'])),
                          Expanded(child: _dataItem(Icons.wc_rounded, "Gender", staff['gender'])),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: _dataItem(Icons.cake_rounded, "Date of Birth", _formatDate(staff['dob']))),
                          Expanded(child: _dataItem(Icons.auto_awesome, "Current Age", "${staff['age'] ?? '--'} Years")),
                        ],
                      ),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Color(0xFFF1F4F9))),

                      _sectionHeader("Professional Record"),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(child: _dataItem(Icons.school_rounded, "Qualification", staff['qualification'])),
                          Expanded(child: _dataItem(Icons.history_edu_rounded, "Total Experience", "${staff['total_experience'] ?? '0'} Yrs")),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: _dataItem(Icons.event_available_rounded, "Joining Date", _formatDate(staff['joining_date']))),
                          if (staff['role'] == 'teacher')
                            Expanded(child: _dataItem(Icons.book_rounded, "Subjects", (staff['subjects'] as List?)?.join(', '))),
                        ],
                      ),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Color(0xFFF1F4F9))),

                      _sectionHeader("Contact Details"),
                      const SizedBox(height: 15),
                      _dataItem(Icons.phone_android_rounded, "Phone Number", staff['phone']),
                      const SizedBox(height: 15),
                      _dataItem(Icons.home_work_outlined, "Residential Address", staff['address']),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String t) => Row(children: [
    Text(t.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.black, letterSpacing: 1)),
    const SizedBox(width: 10),
    const Expanded(child: Divider(color: Color(0xFFF1F4F9))),
  ]);

  Widget _dataItem(IconData i, String l, dynamic v) => Row(
    children: [
      Icon(i, size: 18, color: AppColors.primary.withOpacity(0.6)),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
            Text(v?.toString() ?? "Not Provided", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.black)),
          ],
        ),
      ),
    ],
  );

  String _formatDate(dynamic d) {
    if (d == null) return "N/A";
    try {
      DateTime dt = (d is Timestamp) ? d.toDate() : DateTime.parse(d.toString());
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) { return d.toString(); }
  }

  void _handleEdit(BuildContext context, Map<String, dynamic> staff, String docId) {
    final prov = context.read<AdminProvider>();
    prov.clearStaffForm();

    // 1. Text Controllers
    prov.nameCtrl.text = staff['name'] ?? "";
    prov.phoneCtrl.text = staff['phone'] ?? "";
    prov.aadharCtrl.text = staff['aadhar'] ?? "";
    prov.ageCtrl.text = staff['age']?.toString() ?? "";
    prov.passwordCtrl.text = staff['password'] ?? "";
    prov.addressCtrl.text = staff['address'] ?? "";
    prov.expCtrl.text = staff['total_experience']?.toString() ?? "";

    // 2. Dropdown Selections
    prov.selectedRole = staff['role'];
    prov.selectedGender = staff['gender'];
    prov.selectedQual = staff['qualification'];
    prov.selectedDesignation = staff['designation'];

    // 3. Subjects (CORRECTED: Changed 'doc' to 'staff')
    if (staff['subjects'] != null) {
      prov.selectedSubjects = List<Map<String, dynamic>>.from(staff['subjects']);
    } else {
      prov.selectedSubjects = [];
    }

    // 4. Dates (Improved timestamp handling)
    if (staff['dob'] != null) {
      prov.dob = (staff['dob'] is Timestamp)
          ? (staff['dob'] as Timestamp).toDate()
          : DateTime.tryParse(staff['dob'].toString());
    }

    if (staff['joining_date'] != null) {
      prov.joiningDate = (staff['joining_date'] is Timestamp)
          ? (staff['joining_date'] as Timestamp).toDate()
          : DateTime.tryParse(staff['joining_date'].toString());
    }

    // 5. Navigate
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddStaffScreen(
          userId: widget.userId,
          userName: widget.userName,
          docId: docId,
        ),
      ),
    );
  }
  void _handleDelete(BuildContext context, String id, String? name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 50),
            const SizedBox(height: 20),
            const Text("Remove Staff?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Delete records for $name? This cannot be undone.", textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await context.read<AdminProvider>().removeStaff(docId: id, adminId: widget.userId, adminName: widget.userName);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Confirm Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() => Center(child: Text("No records found for '$searchQuery'"));

  Widget _buildStatusMessage(String m) => Center(child: Text(m, style: const TextStyle(color: Colors.redAccent)));
}

class _StaffRow extends StatefulWidget {
  final Map<String, dynamic> staff;
  final String docId;
  final VoidCallback onView, onEdit, onDelete;
  const _StaffRow({required this.staff, required this.docId, required this.onView, required this.onEdit, required this.onDelete});

  @override
  State<_StaffRow> createState() => _StaffRowState();
}

class _StaffRowState extends State<_StaffRow> {
  bool isH = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isH = true),
      onExit: (_) => setState(() => isH = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
        decoration: BoxDecoration(
          color: isH ? const Color(0xFFF4F7FE).withOpacity(0.5) : Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey.shade50)),
        ),
        child: Row(
          children: [
            Expanded(flex: 3, child: Row(children: [
              CircleAvatar(radius: 16, backgroundColor: AppColors.primary.withOpacity(0.1), child: Text(widget.staff['name']?[0] ?? "?", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary))),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.staff['name'] ?? "—", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B2559))),
                  Text(widget.staff['qualification'] ?? "No Qualification", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ])),
            Expanded(flex: 2, child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.staff['phone'] ?? "—", style: const TextStyle(fontSize: 13, color: Color(0xFF1B2559))),
                Text("Aadhar: ${widget.staff['aadhar'] ?? 'N/A'}", style: const TextStyle(fontSize: 11, color: Color(0xFFA3AED0))),
              ],
            )),
            Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.staff['role']?.toUpperCase() ?? "STAFF", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF1B2559))),
              Text(widget.staff['designation'] ?? "General", style: const TextStyle(fontSize: 10, color: Color(0xFFA3AED0))),
            ])),
            SizedBox(
              width: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(onPressed: widget.onView, icon: const Icon(Icons.visibility_rounded, size: 18, color: Color(0xFF422AFB))),
                  IconButton(onPressed: widget.onEdit, icon: const Icon(Icons.edit_square, size: 18, color: Color(0xFF1B2559))),
                  IconButton(onPressed: widget.onDelete, icon: const Icon(Icons.delete_rounded, size: 18, color: Colors.redAccent)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}