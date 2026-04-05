import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../providers/admin_provider.dart';
import 'add_staff_screen.dart';

class StaffManagementPage extends StatelessWidget {
  final String userName, userId;

  const StaffManagementPage({
    super.key,
    required this.userName,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final adminProv = Provider.of<AdminProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 HEADER
            Row(
              children: [
                IconButton(
                  onPressed: () => adminProv.setIndex(0),
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                const Text(
                  "Staff Directory",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                _buildAddButton(context),
              ],
            ),

            const SizedBox(height: 25),

            /// 🔹 LIST CONTAINER
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: StreamBuilder<QuerySnapshot>(
                  stream: adminProv.getStaffStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text("Error loading data"));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final staffList = snapshot.data!.docs;

                    if (staffList.isEmpty) {
                      return const Center(
                        child: Text("No staff found"),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: staffList.length,
                      separatorBuilder: (_, __) => const Divider(height: 30),
                      itemBuilder: (context, index) {
                        final doc = staffList[index];
                        final staff = doc.data() as Map<String, dynamic>;
                        return _buildStaffTile(context, staff, doc.id);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 ADD BUTTON
  Widget _buildAddButton(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      onPressed: () => _showStaffDrawer(context, null),
      icon: const Icon(Icons.add),
      label: const Text(
        "Add Staff",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  /// 🔹 STAFF TILE (Modern UI)
  Widget _buildStaffTile(
      BuildContext context, Map<String, dynamic> staff, String docId) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.lightGreen,
          child: Text(
            staff['name']?[0] ?? "?",
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 15),

        /// TEXT INFO
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                staff['name'] ?? "Unknown",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                staff['designation'] ?? "-",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),

        /// CATEGORY CHIP
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            (staff['category'] ?? "GENERAL").toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),

        const SizedBox(width: 15),

        /// ACTIONS
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primary),
              onPressed: () =>
                  _showStaffDrawer(context, staff, docId: docId),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () =>
                  _confirmDelete(context, docId, staff['name']),
            ),
          ],
        ),
      ],
    );
  }

  /// 🔹 DRAWER
  void _showStaffDrawer(BuildContext context, Map<String, dynamic>? staff,
      {String? docId}) {
    final prov = context.read<AdminProvider>();

    /// ✅ clear previous form
    prov.clearStaffForm();

    /// ✅ if edit → preload data (optional, I’ll show below)
    if (staff != null) {
      prov.nameCtrl.text = staff['name'] ?? "";
      prov.phoneCtrl.text = staff['phone'] ?? "";
      prov.selectedRole = staff['role'];
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddStaffScreen(
          userId: userId,
          userName: userName,
        ),
      ),
    );
  }
  /// 🔹 DELETE
  void _confirmDelete(
      BuildContext context, String docId, String? name) {
    final adminProv = Provider.of<AdminProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text("Delete Staff"),
        content: Text("Remove $name permanently?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              await adminProv.removeStaff(docId);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Delete"),
          )
        ],
      ),
    );
  }
}
