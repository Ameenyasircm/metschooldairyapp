import 'package:flutter/material.dart';
import 'package:met_school/features/modules/admin/views/staff_management.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../providers/admin_provider.dart';
import '../../../../providers/auth_provider.dart';
import 'academic_year_management.dart';

class AdminHome extends StatelessWidget {
  String userid, userName, phone;

  AdminHome({
    super.key,
    required this.userid,
    required this.userName,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),

      body: Consumer<AdminProvider>(
        builder: (context, admin, child) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildBody(context, admin, userName, userid),
          );
        },
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, AdminProvider admin, String userName, String userId) {
    switch (admin.currentIndex) {
      case 1:
        return StaffManagementPage(userName: userName, userId: userId);

      case 2:
        return const Center(child: Text("Academic Setup Screen"));

      case 3:
        return const Center(child: Text("Gallery Screen"));

    /// ✅ NEW
      case 4:
        return const AcademicYearScreen();

      case 5:
        return const Center(child: Text("Student Management Screen"));

      default:
        return _buildDashboardGrid(context);
    }  }

  /// ================= DASHBOARD =================
  Widget _buildDashboardGrid(BuildContext context) {
    return Column(
      children: [
        /// 🔥 TOP HEADER (NEW THEME)
        _buildTopHeader(context),

        /// BODY
        Expanded(
          child: SingleChildScrollView(
            key: const ValueKey(0),
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                LayoutBuilder(builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 1200
                      ? 4
                      : (constraints.maxWidth > 800 ? 2 : 1);

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 25,
                    mainAxisSpacing: 25,
                    childAspectRatio: 1.3,
                    children: [
                      _buildModuleCard(
                        context,
                        title: "System Overview",
                        subtitle: "Active Year: 2026-27",
                        icon: Icons.analytics_outlined,
                        color: const Color(0xFF14B8A6),
                        index: 0,
                      ),
                      _buildModuleCard(
                        context,
                        title: "Staff Management",
                        subtitle: "Manage Teachers & Roles",
                        icon: Icons.badge_outlined,
                        color: const Color(0xFF0F766E),
                        index: 1,
                      ),
                      _buildModuleCard(
                        context,
                        title: "Academic Setup",
                        subtitle: "Grades & Divisions",
                        icon: Icons.account_tree_outlined,
                        color: Colors.green,
                        index: 2,
                      ),
                      _buildModuleCard(
                        context,
                        title: "School Gallery",
                        subtitle: "Upload Event Photos",
                        icon: Icons.collections_outlined,
                        color: Colors.orange,
                        index: 3,
                      ),
                      _buildModuleCard(
                        context,
                        title: "Academic Year",
                        subtitle: "Manage Academic Years",
                        icon: Icons.calendar_today_outlined,
                        color: Colors.purple,
                        index: 4,
                      ),

                      _buildModuleCard(
                        context,
                        title: "Student Management",
                        subtitle: "Manage Students Data",
                        icon: Icons.school_outlined,
                        color: Colors.teal,
                        index: 5,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// ================= NEW HEADER =================
  Widget _buildTopHeader(BuildContext context) {
    return Container(
      height: 160,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// LEFT TEXT
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Admin Dashboard",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Manage your system efficiently",
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),

          /// RIGHT ICON
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.admin_panel_settings,
                    color: Colors.white, size: 32),
              ),
              const SizedBox(width: 20),

              /// 🔴 LOGOUT BUTTON
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0F766E),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  context.read<AuthProvider>().logout(context);
                },
                icon: const Icon(Icons.logout, size: 18),
                label: const Text("Logout"),
              ),
            ],
          ),

        ],
      ),
    );
  }

  /// ================= CARD =================
  Widget _buildModuleCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required int index,
      }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () =>
            Provider.of<AdminProvider>(context, listen: false)
                .setIndex(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color, size: 26),
              ),
              const Spacer(),
              Text(title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(subtitle,
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 15),
              Row(
                children: [
                  Text("Open Module",
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(width: 5),
                  Icon(Icons.arrow_forward, size: 16, color: color),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}