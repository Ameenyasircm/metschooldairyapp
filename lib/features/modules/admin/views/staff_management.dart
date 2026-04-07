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
            /// 🔹 IMPROVED HEADER WITH BACK BUTTON
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
        /// 🔙 NEW: CIRCULAR BACK BUTTON
        InkWell(
          onTap: () {
            // Instead of Navigator.pop, we reset the dashboard index
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Staff Directory", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1B2559))),
          ],
        ),
        const Spacer(),
        // 🔍 SEARCH BAR
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
                    hintText: "Search name...",
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: 14, color: Color(0xFFA3AED0)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 15),
        // ➕ ADD BUTTON
        ElevatedButton.icon(
          onPressed: () {
            prov.clearStaffForm();
            Navigator.push(context, MaterialPageRoute(builder: (_) => AddStaffScreen(userId: widget.userId, userName: widget.userName, docId: null,)));
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
      color: Colors.transparent,
      child: Row(
        children: const [
          Expanded(flex: 3, child: Text("STAFF NAME", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.black, letterSpacing: 1))),
          Expanded(flex: 2, child: Text("CONTACT", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.black, letterSpacing: 1))),
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
          width: 580,
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
                      _sectionHeader("Professional Data"),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(child: _dataItem(Icons.card_giftcard, "ID", staff['employee_id'])),
                          Expanded(child: _dataItem(Icons.history_edu_rounded, "Experience", "${staff['total_experience'] ?? '0'} Yrs")),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: _dataItem(Icons.school_rounded, "Degree", staff['qualification'])),
                          Expanded(child: _dataItem(Icons.event_available_rounded, "Joined", _formatDate(staff['joining_date']))),
                        ],
                      ),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Color(0xFFF1F4F9))),
                      _sectionHeader("Contact Info"),
                      const SizedBox(height: 15),
                      _dataItem(Icons.phone_android_rounded, "Phone", staff['phone']),
                      const SizedBox(height: 15),
                      _dataItem(Icons.alternate_email_rounded, "Email", staff['email']),
                      const SizedBox(height: 15),
                      _dataItem(Icons.home_work_outlined, "Address", staff['address']),
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
            Text(l, style: const TextStyle(fontSize: 10, color: AppColors.black, fontWeight: FontWeight.bold)),
            Text(v?.toString() ?? "N/A", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.black)),
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

    // 🔹 Fill Controllers
    prov.nameCtrl.text = staff['name'] ?? "";
    prov.phoneCtrl.text = staff['phone'] ?? "";
    prov.emailCtrl.text = staff['email'] ?? "";
    prov.passwordCtrl.text = staff['password'] ?? "";
    prov.empIdCtrl.text = staff['employee_id'] ?? "";
    prov.addressCtrl.text = staff['address'] ?? "";
    prov.expCtrl.text = staff['total_experience']?.toString() ?? "";

    // 🔹 Fill State Variables (Crucial for Dropdowns)
    prov.selectedRole = staff['role'];
    prov.selectedGender = staff['gender'];
    prov.selectedQual = staff['qualification'];
    prov.selectedDesignation = staff['designation'];

    // 🔹 Handle Subjects (if teacher)
    if (staff['subjects'] != null) {
      prov.selectedSubjects = List<String>.from(staff['subjects']);
    }

    // 🔹 Handle Date
    if (staff['joining_date'] != null) {
      if (staff['joining_date'] is Timestamp) {
        prov.joiningDate = (staff['joining_date'] as Timestamp).toDate();
      } else {
        prov.joiningDate = DateTime.tryParse(staff['joining_date'].toString());
      }
    }

    // 🔹 Pass docId to the screen
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => AddStaffScreen(
              userId: widget.userId,
              userName: widget.userName,
              docId: docId, // 👈 Pass the ID here
            )
        )
    );
  }

  void _handleDelete(BuildContext context, String id, String? name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(30, 30, 30, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// ⚠️ VISUAL WARNING ICON
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 40),
            ),
            const SizedBox(height: 25),

            /// TEXT CONTENT
            const Text(
              "Confirm Deletion",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1B2559)),
            ),
            const SizedBox(height: 12),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(fontSize: 15, color: Color(0xFFA3AED0), height: 1.5),
                children: [
                  const TextSpan(text: "Are you sure you want to remove "),
                  TextSpan(
                    text: name ?? "this staff",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B2559)),
                  ),
                  const TextSpan(text: "? This action is permanent and cannot be undone."),
                ],
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          /// 🔙 CANCEL BUTTON
          SizedBox(
            width: 140,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "Keep Record",
                style: TextStyle(color: Color(0xFF707EAE), fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 10),

          /// 🗑️ DESTRUCTIVE DELETE BUTTON
          SizedBox(
            width: 160,
            child: ElevatedButton(
              onPressed: () async {
                // Optional: Show a loading state here
                await context.read<AdminProvider>().removeStaff(docId: id, adminId: widget.userId, adminName: widget.userName);
                if (context.mounted) Navigator.pop(context);

                // Standard Practice: Show a Snack-bar after successful deletion
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("$name removed successfully"), backgroundColor: Colors.black87),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Yes, Delete", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const Icon(Icons.person_search_rounded, size: 60, color: Color(0xFFE2E8F0)),
    const SizedBox(height: 10),
    Text("No staff matches '$searchQuery'", style: const TextStyle(color: Color(0xFF707EAE))),
  ]));

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
                  Text("Emp ID : "+widget.staff['employee_id'] ?? "No ID", style:  TextStyle(fontSize: 12, color:AppColors.black)),
                ],
              ),
            ])),
            Expanded(flex: 2, child: Text(widget.staff['phone'] ?? "—", style: const TextStyle(fontSize: 13, color: Color(0xFF1B2559)))),
            Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.staff['role']?.toUpperCase() ?? "STAFF", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF1B2559))),
              Text(widget.staff['designation'] ?? "General", style: const TextStyle(fontSize: 10, color: Color(0xFFA3AED0))),
            ])),
            SizedBox(
              width: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _btn(Icons.visibility_rounded, const Color(0xFF422AFB), widget.onView),
                  _btn(Icons.edit_square, const Color(0xFF1B2559), widget.onEdit),
                  _btn(Icons.delete_rounded, Colors.redAccent, widget.onDelete),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _btn(IconData i, Color c, VoidCallback t) => IconButton(onPressed: t, icon: Icon(i, size: 18, color: c.withOpacity(0.7)), hoverColor: c.withOpacity(0.05));
}