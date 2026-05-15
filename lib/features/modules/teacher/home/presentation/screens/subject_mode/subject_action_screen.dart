import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_padding.dart';
import 'package:met_school/core/theme/app_radius.dart';
import 'package:met_school/core/theme/app_spacing.dart';
import 'package:met_school/core/theme/app_typography.dart';
import 'package:met_school/core/utils/navigation/navigation_helper.dart';
import 'package:met_school/features/modules/teacher/home/data/models/subject_assignment_model.dart';
import 'package:met_school/features/modules/teacher/homework/presentation/screens/homework_list_screen.dart';
import 'package:met_school/features/modules/teacher/punctuality/data/screens/students_list_punctuality.dart';
import 'package:met_school/features/modules/teacher/students/presentation/provider/student_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../../core/router/app_navigation.dart';

class SubjectActionScreen extends StatelessWidget {
  final SubjectAssignmentModel assignment;

  const SubjectActionScreen({super.key, required this.assignment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(assignment.subjectName),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: AppPadding.pM,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            AppSpacing.vxl,
            Text(
              "Management",
              style: AppTypography.h6.copyWith(fontWeight: FontWeight.bold),
            ),
            AppSpacing.vm,
            _buildActionCard(
              context,
              title: "Homework",
              subtitle: "Create and manage homework assignments",
              icon: Icons.assignment_outlined,
              color: Colors.blue,
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString("classId", assignment.classId);
                await prefs.setString("className", assignment.className);
                await prefs.setString("divisionId", assignment.divisionId);
                await prefs.setString("divisionName", assignment.divisionName);
                await prefs.setString("subjectId", assignment.subjectId);
                await prefs.setString("subjectName", assignment.subjectName);
                
                if (context.mounted) {
                  NavigationService.push(context, const HomeworkListScreen());
                }
              },
            ),
            AppSpacing.vm,
            _buildActionCard(
              context,
              title: "Punctuality Record",
              subtitle: "Track student punctuality and arrival",
              icon: Icons.access_time_outlined,
              color: Colors.orange,
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString("classId", assignment.classId);
                await prefs.setString("className", assignment.className);
                await prefs.setString("divisionId", assignment.divisionId);
                await prefs.setString("divisionName", assignment.divisionName);
                
                if (context.mounted) {
                  final studentProvider = context.read<StudentProvider>();
                  studentProvider.fetchMyStudentsInitial();
                  NavigationService.push(context, const PunctualityStudentListScreen());
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: AppPadding.pM,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: AppRadius.radiusL,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25.r,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Icon(Icons.school, color: Colors.white, size: 30.sp),
          ),
          AppSpacing.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${assignment.className} - ${assignment.divisionName}",
                  style: AppTypography.h6.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Assigned Subject: ${assignment.subjectName}",
                  style: AppTypography.caption.copyWith(color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusL,
      child: Container(
        padding: AppPadding.pM,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.radiusL,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: AppPadding.pM,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: AppRadius.radiusM,
              ),
              child: Icon(icon, color: color, size: 28.sp),
            ),
            AppSpacing.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body1.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(color: AppColors.grey5E),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16.sp, color: AppColors.grey5E),
          ],
        ),
      ),
    );
  }
}
