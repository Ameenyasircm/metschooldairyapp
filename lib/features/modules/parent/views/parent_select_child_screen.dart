import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/features/home/views/home/home_screen.dart';
import 'package:met_school/features/modules/parent/views/parent_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_padding.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/navigation/navigation_helper.dart';
import '../../../../core/widgets/dialogs/logout_alert.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class ParentStudentSelectionScreen extends StatelessWidget {
  final List studentIds;
  String parentName;

   ParentStudentSelectionScreen({
    super.key,
    required this.studentIds,
    required this.parentName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back, color: AppColors.primary),
        //   onPressed: () => Navigator.pop(context),
        // ),
        title: Text(
          "Select Student",
          style: AppTypography.h4.copyWith(color: AppColors.primary),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,

        /// 🔴 Logout Button
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: AppColors.primary),
            onPressed: () async {
              showLogoutDialog(context);
            },
          )
        ],
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: ListView.separated(
          itemCount: studentIds.length,
          separatorBuilder: (_, __) => AppSpacing.h16,
          itemBuilder: (context, index) {
            final student = studentIds[index];

            final studentId = student['studentId'];
            final name = student['studentName'] ?? "No Name";
            final className = student['className'] ?? "";

            return GestureDetector(
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();

                /// ✅ Save selected student
                await prefs.setString("selectedStudentData", jsonEncode(student));

                if (context.mounted) {
                  callNext(
                    ParentHomeScreen(
                      studentId: student['studentId'],
                      academicYearID: student['academicYearId'],
                      teacherName: student['teacherName'],
                      teacherID: student['teacherId'],
                      parentName: parentName,
                    ),
                    context,
                  );
                }
              },
              child: Container(
                padding: AppPadding.pL,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: AppRadius.radiusL,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: AppColors.lightGreen,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.person, color: AppColors.primary),
                    ),
                    AppSpacing.w16,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: AppTypography.body1.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkGreen,
                            ),
                          ),
                          AppSpacing.h4,
                          Text(
                            className,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.grey5E,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        size: 16.sp, color: AppColors.grey5E)
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _loadingCard() {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusL,
      ),
    );
  }
}