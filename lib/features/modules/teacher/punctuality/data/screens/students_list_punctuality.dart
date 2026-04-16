import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/app_padding.dart';
import '../../../../../../core/constants/app_radius.dart';
import '../../../../../../core/constants/app_spacing.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../students/data/models/tech_student_model.dart';
import '../../../students/presentation/provider/student_provider.dart'
    show StudentProvider;


import 'PunctualityScreen.dart';

class PunctualityStudentListScreen extends StatelessWidget {
  const PunctualityStudentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();
    final List<EnrollerModel> students = studentProvider.myStudents;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              AppSpacing.h24,

              /// 🔹 MAIN CARD
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: AppPadding.pL,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: AppRadius.radiusL,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// 🔹 SMALL HEADER (FIXED)
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Row(
                          children: [
                            /// 🔹 Back Button (Styled)
                            InkWell(
                              borderRadius: BorderRadius.circular(12.r),
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: AppColors.lightGreen,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 18.sp,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),

                            SizedBox(width: 12.w),

                            /// 🔹 Title Section
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Punctuality",
                                    style: AppTypography.h4.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    "Student Records",
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.grey5E,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      AppSpacing.h4,

                      Text(
                        "Student List",
                        style: AppTypography.caption.copyWith(
                          color: AppColors.grey5E,
                        ),
                      ),

                      AppSpacing.h16,

                      /// 🔹 CONTENT
                      Expanded(
                        child: students.isEmpty
                            ? Center(
                          child: Text(
                            "No students found",
                            style: AppTypography.body1.copyWith(
                              color: AppColors.grey5E,
                            ),
                          ),
                        )
                            : ListView.separated(
                          itemCount: students.length,
                          separatorBuilder: (_, __) => Divider(
                            color: AppColors.greenE1,
                            height: 1,
                          ),
                          itemBuilder: (context, index) {
                            final student = students[index];

                            return InkWell(
                              borderRadius: AppRadius.radiusM,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        StudentPunctualityScreen(
                                          student: student,
                                        ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12.h),
                                child: Row(
                                  children: [
                                    /// 🔹 Avatar
                                    CircleAvatar(
                                      radius: 22.r,
                                      backgroundColor:
                                      AppColors.lightGreen,
                                      child: Text(
                                        student.name.isNotEmpty
                                            ? student.name[0]
                                            .toUpperCase()
                                            : "?",
                                        style: AppTypography.body1
                                            .copyWith(
                                          color:
                                          AppColors.primary,
                                          fontWeight:
                                          FontWeight.w600,
                                        ),
                                      ),
                                    ),

                                    AppSpacing.w12,

                                    /// 🔹 Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            student.name,
                                            style: AppTypography
                                                .body1
                                                .copyWith(
                                              fontWeight:
                                              FontWeight.w600,
                                            ),
                                          ),
                                          AppSpacing.h4,
                                          Text(
                                            "Roll No: ${student.rollNumber}",
                                            style: AppTypography
                                                .caption
                                                .copyWith(
                                              color: AppColors
                                                  .grey5E,
                                            ),
                                          ),
                                          Text(
                                            "${student.className}-${student.divisionName}",
                                            style: AppTypography
                                                .caption
                                                .copyWith(
                                              color: AppColors
                                                  .grey5E,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    /// 🔹 Arrow
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16.sp,
                                      color:
                                      AppColors.grey5E,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              AppSpacing.h16,

              /// 🔹 FOOTER
              Text(
                "Select a student to view punctuality",
                style: AppTypography.captionL.copyWith(
                  color: AppColors.grey5E,
                ),
              ),

              AppSpacing.h12,
            ],
          ),
        ),
      ),
    );
  }
}