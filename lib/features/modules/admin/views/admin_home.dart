import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:met_school/features/modules/admin/views/parents_list.dart';
import 'package:met_school/features/modules/admin/views/staff_management.dart';
import 'package:provider/provider.dart';

import '../../../../providers/admin_provider.dart';
import '../../../../providers/auth_provider.dart';
import 'academic_year_management.dart';
import 'list_all_students_screen.dart';

class AdminHome extends StatelessWidget {
  final String userid, userName, phone; // Marked final for best practice

  const AdminHome({
    super.key,
    required this.userid,
    required this.userName,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    // Optimization: Listen only to index changes to prevent unnecessary rebuilds
    final currentIndex = context.select((AdminProvider p) => p.currentIndex);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        // ValueKey ensures the switcher recognizes the change between screens
        child: KeyedSubtree(
          key: ValueKey(currentIndex),
          child: _buildBody(context, currentIndex),
        ),
      ),
    );
  }

  /// 🔹 Content Switcher (Retains all your existing screens)
  Widget _buildBody(BuildContext context, int index) {
    switch (index) {
      case 1:
        return StaffManagementPage(userName: userName, userId: userid);
      case 3:
        return  Center(child: Text("Gallery Screen"));
      case 2:
        return  AcademicYearScreen(userName: userName, userId:userid,);
      case 4:
        return StudentListScreen();
      case 5:
        return ParentMasterDirectory();
      default:
        return _buildDashboardGrid(context);
    }
  }

  /// 🔹 Optimized Dashboard Grid
  Widget _buildDashboardGrid(BuildContext context) {
    return Column(
      children: [
        _buildTopHeader(context),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Using MaxCrossAxisExtent for automatic responsiveness
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 400, // Cards will wrap automatically based on width
                    crossAxisSpacing: 35,
                    mainAxisSpacing: 35,
                    childAspectRatio: 2.0, // Matches your desired card proportion
                  ),
                  children: [
                    _buildModuleCard(context, 1, "Staff Management", "Manage Teachers & Roles", Icons.badge_outlined, const Color(0xFF0F766E)),
                    _buildModuleCard(context, 2, "Academic Year", "Manage Academic Years", Icons.calendar_today_outlined, Colors.purple),
                    _buildModuleCard(context, 3, "School Gallery", "Upload Event Photos", Icons.collections_outlined, Colors.orange),

                    _buildModuleCard(context, 4, "Student Management", "Manage Students Data", Icons.school_outlined, Colors.teal),
                    _buildModuleCard(context, 5, "Parent Management", "Manage Parent Data", Icons.school_outlined, Colors.teal),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 🔹 Top Header (Your existing design, cleaned up)
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Admin Dashboard",
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              const Text("Manage your system efficiently", style: TextStyle(color: Colors.white70)),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0F766E),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => context.read<AuthProvider>().logout(context),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text("Logout"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🔹 Optimized Module Card
  Widget _buildModuleCard(BuildContext context, int index, String title, String subtitle, IconData icon, Color color) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.read<AdminProvider>().setIndex(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20), // Slightly reduced padding to save space
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // 👈 Ensures column only takes needed space
            children: [
              CircleAvatar(
                radius: 20, // Slightly smaller icon
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color, size: 22),
              ),
              const Spacer(),

              /// 🔹 FIX: Wrap text in Flexible or use maxLines to prevent overflow
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis, // 👈 Prevents the 23px overflow
              ),

              const SizedBox(height: 8),
              Row(
                children: [
                  Text("Open Module", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(width: 5),
                  Icon(Icons.arrow_forward, size: 14, color: color),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
  Future<void> initializeClasses() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    // Define the ordered list
    final List<String> classNames = [
      "LKG", "UKG", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"
    ];

    for (int i = 0; i < classNames.length; i++) {
      String name = classNames[i];

      // Create a clean document ID (e.g., 'lkg', 'class1', 'class10')
      String docId = name.toLowerCase().contains('kg')
          ? name.toLowerCase()
          : "class$name";

      DocumentReference docRef = firestore.collection("classes").doc(docId);

      batch.set(docRef, {
        "id": docId,
        "name": name.contains(RegExp(r'[0-9]')) && !name.contains("KG")
            ? "CLASS $name" // Format numbers as "CLASS 1"
            : name,         // Keep LKG/UKG as is
        "index": i + 1,     // The critical field for ordering
        "updatedAt": FieldValue.serverTimestamp(),
      });
    }

    try {
      await batch.commit();
      print("✅ All classes initialized with correct sort order.");
    } catch (e) {
      print("❌ Error initializing classes: $e");
    }
  }
}