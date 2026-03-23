import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/admin_provider.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Section
            _buildHeader(),
            const SizedBox(height: 40),

            // 2. Main Options Grid
            LayoutBuilder(builder: (context, constraints) {
              // Adjust columns based on screen width
              int crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 2 : 1);

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 25,
                mainAxisSpacing: 25,
                childAspectRatio: 1.3, // Makes boxes look professional
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
                    subtitle: "24 Total Employees",
                    icon: Icons.badge_outlined,
                    color: AppColors.darkBlue,
                    index: 1,
                  ),
                  _buildModuleCard(
                    context,
                    title: "Academic Setup",
                    subtitle: "Grades, Years & Divisions",
                    icon: Icons.account_tree_outlined,
                    color: AppColors.successGreen,
                    index: 2,
                  ),
                  _buildModuleCard(
                    context,
                    title: "School Gallery",
                    subtitle: "124 Event Photos",
                    icon: Icons.collections_outlined,
                    color: AppColors.warningOrange,
                    index: 3,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Admin Command Center",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textBlack),
        ),
        SizedBox(height: 8),
        Text(
          "Manage your school operations and configurations",
          style: TextStyle(fontSize: 16, color: AppColors.textGrey),
        ),
      ],
    );
  }

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
        onTap: () {
          // Navigate using Provider
          Provider.of<AdminProvider>(context, listen: false).setIndex(index);
          // You can also use Navigator.push if you prefer separate routes
        },
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.silverGrey.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon Circle
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              // Text Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textBlack),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
                  ),
                ],
              ),
              // "Manage" Arrow
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("Manage", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                  Icon(Icons.chevron_right, color: AppColors.primaryBlue, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}