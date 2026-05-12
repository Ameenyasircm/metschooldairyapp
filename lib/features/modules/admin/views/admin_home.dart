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
import 'list_all_students_screen.dart';

class AdminHome extends StatelessWidget {
  final String userid, userName, phone;

  // New Theme Colors
  static const Color primaryBlue = Color(0xFF031937);
  static const Color secondaryBlue = Color(0xFF003865);

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
      backgroundColor: const Color(0xFFF1F5F9), // Slate background for a modern feel
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
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
        final provider = context.watch<AdminProvider>();
        provider.getQualifications();
        return AdminMenuOptions();
      default:
        return _buildDashboardGrid(context);
    }
  }

  Widget _buildDashboardGrid(BuildContext context) {
    return Column(
      children: [
        _buildTopHeader(context),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "System Modules",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 25),
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 350,
                    crossAxisSpacing: 25,
                    mainAxisSpacing: 25,
                    childAspectRatio: 1.8,
                  ),
                  children: [
                    _buildModuleCard(context, 1, "Staff Management", "Manage Teachers & Roles", Icons.badge_outlined, primaryBlue),
                    _buildModuleCard(context, 2, "Academic Year", "Manage Academic Years", Icons.calendar_today_outlined, Colors.indigo),
                    _buildModuleCard(context, 3, "School Gallery", "Upload Event Photos", Icons.collections_outlined, Colors.blueGrey),
                    _buildModuleCard(context, 4, "Student Management", "Manage Students Data", Icons.school_outlined, secondaryBlue),
                    _buildModuleCard(context, 5, "Parent Management", "Manage Parent Data", Icons.people_alt_outlined, secondaryBlue),
                    _buildModuleCard(context, 6, "School Calendar", "Events & Holidays", Icons.calendar_month, Colors.deepPurple),
                    _buildModuleCard(context, 7, "Bell Timing", "Schedule & Slots", Icons.access_time_filled, Colors.blue),
                    _buildModuleCard(context, 8, "Rules & Regulations", "Policies & Conduct", Icons.gavel_rounded, Colors.blueGrey),
                    _buildModuleCard(context, 9, "Parent Instructions", "Guidelines for Parents", Icons.info_outline_rounded, primaryBlue),
                    _buildModuleCard(context, 10, "Menu", "Admin Menu Options", Icons.menu, primaryBlue),
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
      height: 140,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      decoration: const BoxDecoration(
        color: primaryBlue,
        gradient: LinearGradient(
          colors: [primaryBlue, secondaryBlue],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset('assets/images/metTextLogo.png', height: 90, errorBuilder: (c, e, s) => const SizedBox()),
                  const SizedBox(width: 15),
                ],
              ),
              const SizedBox(height: 8),

            ],
          ),
          Row(
            children: [
              // User Info Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_circle_outlined, color: Colors.white70, size: 20),
                    const SizedBox(width: 10),
                    Text(userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Logout Button
              IconButton(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout_rounded, color: Colors.white70),
                tooltip: "Logout",
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(color: primaryBlue.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: primaryBlue),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text("Manage", style: TextStyle(color: accentColor, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5)),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios_rounded, size: 10, color: accentColor),
                ],
              )
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                child: Icon(Icons.logout_rounded, color: Colors.red.shade400, size: 30),
              ),
              const SizedBox(height: 20),
              const Text("Logout", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("Are you sure you want to logout\nfrom your admin account?", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5)),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<AuthProvider>().logout(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: const Text("Yes, Logout"),
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