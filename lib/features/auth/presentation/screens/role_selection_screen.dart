import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_padding.dart';
import 'package:met_school/core/theme/app_radius.dart';
import 'package:met_school/core/theme/app_spacing.dart';
import 'package:met_school/core/theme/app_typography.dart';
import 'package:met_school/core/utils/navigation/navigation_helper.dart';
import 'package:met_school/features/modules/parent/views/parent_bottom_nav_screen.dart';
import 'package:met_school/features/modules/teacher/home/presentation/screens/teacher_home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_assets.dart';

class RoleSelectionScreen extends StatelessWidget {
  final Map<String, dynamic> teacherData;
  final List<Map<String, dynamic>> studentDataList;
  final String parentName;

  const RoleSelectionScreen({
    super.key,
    required this.teacherData,
    required this.studentDataList,
    required this.parentName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Padding(
          padding: AppPadding.phL,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppSpacing.vxl,
              Center(
                child:Image.asset(AppAssets.metLogo, width: 120.w, height: 120.h),
              ),
              AppSpacing.vxl,
              Text(
                "Welcome Back!",
                style: AppTypography.h4,
              ),
              AppSpacing.vxs,
              Text(
                "Please select your role to continue",
                style: AppTypography.body2.copyWith(color: AppColors.grey5E),
              ),
              AppSpacing.vxl,
              _RoleCard(
                title: "Teacher",
                subtitle: "Access classes, students, and attendance",
                icon: Icons.school_outlined,
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString("role", "teacher");

                  if (context.mounted) {
                    callNext(
                      TeacherHomeScreen(staffName: teacherData['name'] ?? ""),
                      context,
                    );
                  }
                },
              ),
              AppSpacing.vm,
              _RoleCard(
                title: "Parent",
                subtitle: "Monitor your child's academic progress",
                icon: Icons.family_restroom_outlined,
                onTap: () async {
                  print("jjknrjggngrngnribnr ${studentDataList.length}");

                  if (studentDataList.isNotEmpty) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString("role", "parent");
                    final s = studentDataList.first;
                    await prefs.setString("studentId", s['studentId']);
                    await prefs.setString("divisionId", s['divisionId'] ?? "");
                    await prefs.setString("classId", s['classId'] ?? "");

                    if (context.mounted) {
                      callNext(
                        ParentMainScreen(
                          studentId: s['studentId'],
                          academicYearID: s['academicYearId'],
                          teacherName: s['teacherName'],
                          teacherID: s['teacherId'],
                          parentName: parentName,
                        ),
                        context,
                      );
                    }
                  }
                },
              ),
              const Spacer(),

              AppSpacing.vm,
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusL,
      child: Container(
        padding: AppPadding.pM,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.radiusL,
          border: Border.all(color: AppColors.greyE0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: AppPadding.pS,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: AppRadius.radiusM,
              ),
              child: Icon(icon, color: AppColors.primary, size: 32.sp),
            ),
            AppSpacing.hm,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.h5),
                  AppSpacing.vxs,
                  Text(
                    subtitle,
                    style: AppTypography.captionL.copyWith(color: AppColors.grey5E),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.grey5E, size: 16.sp),
          ],
        ),
      ),
    );
  }
}
