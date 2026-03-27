import 'package:flutter/material.dart';
import 'package:met_school/features/modules/admin/views/staff_management.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../providers/admin_provider.dart';


class AdminHome extends StatelessWidget {
  String userid,userName;
   AdminHome({super.key,required this.userid,required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Consumer<AdminProvider>(
        builder: (context, admin, child) {
          // --- NAVIGATION LOGIC ---
          // Index 0: Dashboard Grid
          // Index 1: Staff Management
          // Index 2: Academic Setup (Placeholder)
          // Index 3: Gallery (Placeholder)

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildBody(context, admin,userName,userid),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, AdminProvider admin,String userName,String userId) {
    switch (admin.currentIndex) {
      case 1:
        return  StaffManagementPage(userName: userName, userId: userId,);
      case 2:
        return const Center(child: Text("Academic Setup Screen"));
      case 3:
        return const Center(child: Text("Gallery Screen"));
      default:
        return _buildDashboardGrid(context);
    }
  }

  // --- 1. DASHBOARD GRID VIEW ---
  Widget _buildDashboardGrid(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey(0),
      padding: const EdgeInsets.all(60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 50),
          LayoutBuilder(builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 2 : 1);
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 30,
              mainAxisSpacing: 30,
              childAspectRatio: 1.4,
              children: [
                _buildModuleCard(
                  context,
                  title: "System Overview",
                  subtitle: "Active Year: 2026-27",
                  icon: Icons.analytics_outlined,
                  color: AppColors.primaryBlue,
                  index: 0,
                ),
                _buildModuleCard(
                  context,
                  title: "Staff Management",
                  subtitle: "Manage Teachers & Roles",
                  icon: Icons.badge_outlined,
                  color: AppColors.darkBlue,
                  index: 1,
                ),
                _buildModuleCard(
                  context,
                  title: "Academic Setup",
                  subtitle: "Grades & Divisions",
                  icon: Icons.account_tree_outlined,
                  color: AppColors.successGreen,
                  index: 2,
                ),
                _buildModuleCard(
                  context,
                  title: "School Gallery",
                  subtitle: "Upload Event Photos",
                  icon: Icons.collections_outlined,
                  color: AppColors.warningOrange,
                  index: 3,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // --- 2. UI COMPONENTS ---

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Admin Command Center",
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.textBlack),
        ),
        const SizedBox(height: 10),
        Text(
          "Welcome back, Muhammed Wise. Here is what's happening today.",
          style: TextStyle(fontSize: 18, color: AppColors.textGrey),
        ),
      ],
    );
  }

  Widget _buildModuleCard(BuildContext context,
      {required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required int index}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Provider.of<AdminProvider>(context, listen: false).setIndex(index),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))
            ],
            border: Border.all(color: AppColors.silverGrey.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color, size: 28),
              ),
              const Spacer(),
              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(subtitle, style: const TextStyle(color: AppColors.textGrey)),
              const SizedBox(height: 15),
              Row(
                children: [
                  Text("Open Module", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
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