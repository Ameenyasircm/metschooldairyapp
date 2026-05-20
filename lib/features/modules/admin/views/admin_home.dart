import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:met_school/features/modules/admin/rules_timing/screens/school_gallery_screen.dart';
import 'package:met_school/features/modules/admin/views/parents_list.dart';
import 'package:met_school/features/modules/admin/views/staff_management.dart';
import 'package:provider/provider.dart';

import '../../../../providers/admin_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../rules_timing/screens/admin_parent_instruction.dart';
import '../rules_timing/screens/admin_rules_and_regulations.dart';
import '../rules_timing/screens/bell_timing_admin_screen.dart';
import '../school_calaender/screens/admin_add_school_calender.dart';
import 'academic_year_management.dart';
import 'admin_menu_options.dart';
import 'admin_notifications_screen.dart';
import 'admin_view_lesson_plan.dart';
import 'list_all_students_screen.dart';

class AdminHome extends StatelessWidget {
  final String userid, userName, phone;

  // Theme Colors
  static const Color primaryBlue = Color(0xFF031937);
  static const Color secondaryBlue = Color(0xFF003865);
  static const Color borderSlate = Color(0xFFE2E8F0);

  const AdminHome({
    super.key,
    required this.userid,
    required this.userName,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    final currentIndex = context.select((AdminProvider p) => p.currentIndex);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Brighter background for clean dashboard contrast
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: KeyedSubtree(
          key: ValueKey(currentIndex),
          child: _buildBody(context, currentIndex),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, int index) {
    switch (index) {
      case 1:
        return StaffManagementPage(userName: userName, userId: userid);
      case 3:
        return SchoolGalleryScreen();
      case 2:
        return AcademicYearScreen(userName: userName, userId: userid);
      case 4:
        return StudentListScreen();
      case 5:
        return ParentMasterDirectory();
      case 6:
        return AdminCalendarWebScreen();
      case 7:
        return BellTimingAdminScreen();
      case 8:
        return RulesAdminScreen();
      case 9:
        return ParentInstructionsAdminScreen();
      case 10:
        return AdminNotificationsScreen();
      case 11:
        return const AdminLessonPlanScreen();
      case 12:
        final provider = context.watch<AdminProvider>();
        provider.getQualifications();
        return AdminMenuOptions();

      default:
        return _buildDashboardGrid(context);
    }
  }

  Widget _buildDashboardGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopHeader(context),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "System Modules",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: primaryBlue,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 20),
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  // Max extent reduced to 300 to create smaller cards per grid segment
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.1,
                  ),
                  children: [
                    _buildModuleCard(context, 1, "Staff Management", "Manage Teachers & Roles", Icons.badge_outlined, primaryBlue),
                    _buildModuleCard(context, 2, "Academic Year", "Manage Academic Years", Icons.calendar_today_outlined, Colors.indigo.shade700),
                    _buildModuleCard(context, 3, "School Gallery", "Upload Event Photos", Icons.collections_outlined, Colors.blueGrey.shade600),
                    _buildModuleCard(context, 4, "Student Management", "Manage Students Data", Icons.school_outlined, secondaryBlue),
                    _buildModuleCard(context, 5, "Parent Management", "Manage Parent Data", Icons.people_alt_outlined, secondaryBlue),
                    _buildModuleCard(context, 6, "School Calendar", "Events & Holidays", Icons.calendar_month_outlined, Colors.deepPurple.shade600),
                    _buildModuleCard(context, 7, "Bell Timing", "Schedule & Slots", Icons.access_time_rounded, Colors.blue.shade700),
                    _buildModuleCard(context, 8, "Rules & Regulations", "Policies & Conduct", Icons.gavel_rounded, Colors.blueGrey.shade600),
                    _buildModuleCard(context, 9, "Parent Instructions", "Guidelines for Parents", Icons.info_outline_rounded, primaryBlue),
                    _buildModuleCard(context, 10, "Notifications", "Send Notifications", Icons.notification_add_outlined, Colors.blueGrey.shade700),
                    _buildModuleCard(context, 11, "Lesson Plans", "Review & Approve Plans", Icons.menu_book_outlined, Colors.teal.shade700),
                    _buildModuleCard(context, 12, "Menu", "Admin Menu Options", Icons.menu_rounded, primaryBlue),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    return Container(
      height: 100, // Reduced from 140 for a crisp, low-profile admin banner
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 48),
      decoration: const BoxDecoration(
        color: primaryBlue,
        gradient: LinearGradient(
          colors: [primaryBlue, Color(0xFF0F2942)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'assets/images/metTextLogo.png',
            height: 55, // Optimized scaling context
            errorBuilder: (c, e, s) => const SizedBox(),
          ),
          Row(
            children: [
              // User Info Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_circle_outlined, color: Colors.white60, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      userName,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Logout Action
              IconButton(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout_rounded, color: Colors.white60, size: 20),
                style: IconButton.styleFrom(
                  hoverColor: Colors.white.withOpacity(0.05),
                ),
                tooltip: "Logout Profile",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(BuildContext context, int index, String title, String subtitle, IconData icon, Color accentColor) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.read<AdminProvider>().setIndex(index),
        child: Container(
          padding: const EdgeInsets.all(16), // Tightened padding constraint
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderSlate),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.015),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left-aligned compact status icon accent container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 14),

              // Text layout structural hierarchy
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryBlue, letterSpacing: -0.2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Arrow action indicator
              Icon(Icons.chevron_right_rounded, size: 16, color: accentColor.withOpacity(0.7)),
            ],
          ),
        ),
      ),
    );
  }

  // --- Logic Methods (Kept Exactly as original) ---

  Future<void> initializeClasses() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();
    final List<String> classNames = ["FLY 1", "FLY 2", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"];

    for (int i = 0; i < classNames.length; i++) {
      String name = classNames[i];
      String docId = name.toLowerCase().contains('kg') ? name.toLowerCase() : "class$name";
      DocumentReference docRef = firestore.collection("classes").doc(docId);
      batch.set(docRef, {
        "id": docId,
        "name": name.contains(RegExp(r'[0-9]')) && !name.contains("KG") ? "CLASS $name" : name,
        "index": i + 1,
        "updatedAt": FieldValue.serverTimestamp(),
      });
    }

    try {
      await batch.commit();
      debugPrint("✅ Classes initialized.");
    } catch (e) {
      debugPrint("❌ Error: $e");
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                child: Icon(Icons.logout_rounded, color: Colors.red.shade500, size: 26),
              ),
              const SizedBox(height: 16),
              const Text("Confirm Logout", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue)),
              const SizedBox(height: 8),
              const Text("Are you sure you want to logout\nfrom your admin account?", textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: borderSlate),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Cancel", style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<AuthProvider>().logout(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade500,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Yes, Logout", style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}