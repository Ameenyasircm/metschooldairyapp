import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/app_padding.dart';
import '../../../../../../core/constants/app_radius.dart';
import '../../../../../../core/constants/app_spacing.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../students/data/models/tech_student_model.dart';


import '../../../students/presentation/provider/student_provider.dart';
import 'PunctualityScreen.dart';

class PunctualityStudentListScreen extends StatelessWidget {
  const PunctualityStudentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();
    final List<EnrollerModel> students = studentProvider.myStudents;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,

      /// 🔹 MODERN APP BAR (Like Rules Screen)
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.lightBackground,
        automaticallyImplyActions: false,
        leading: BackButton(color: AppColors.primary,),
        title: const Text(
          "Punctuality",
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [


              AppSpacing.h20,

              /// 🔹 SECTION TITLE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Student List (${students.length})",
                    style: AppTypography.h5.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              AppSpacing.h12,

              /// 🔹 LIST
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
                    : ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];

                    return Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        elevation: 2,
                        shadowColor: Colors.black.withOpacity(0.05),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16.r),
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
                            padding: EdgeInsets.all(14.w),
                            child: Row(
                              children: [
                                /// 🔹 AVATAR
                                Container(
                                  width: 48.w,
                                  height: 48.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.third,
                                    borderRadius:
                                    BorderRadius.circular(14.r),
                                  ),
                                  child: Center(
                                    child: Text(
                                      student.name.isNotEmpty
                                          ? student.name[0].toUpperCase()
                                          : "?",
                                      style: AppTypography.h5.copyWith(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),

                                AppSpacing.w12,

                                /// 🔹 INFO
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        student.name,
                                        style: AppTypography.body1
                                            .copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      AppSpacing.h4,
                                      Text(
                                        "Roll No: ${student.rollNumber}",
                                        style: AppTypography.caption
                                            .copyWith(
                                          color: AppColors.grey5E,
                                        ),
                                      ),
                                      Text(
                                        "${student.className}-${student.divisionName}",
                                        style: AppTypography.caption
                                            .copyWith(
                                          color: AppColors.grey5E,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                /// 🔹 ARROW
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16.sp,
                                  color: AppColors.grey5E,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              /// 🔹 FOOTER
              Text(
                "Select a student to view punctuality",
                style: AppTypography.caption.copyWith(
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