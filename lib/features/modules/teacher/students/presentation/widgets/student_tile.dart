import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:met_school/core/constants/app_padding.dart';
import 'package:met_school/core/constants/app_radius.dart';
import 'package:met_school/core/constants/app_spacing.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_typography.dart';

import '../../data/models/tech_student_model.dart';

class StudentTile extends StatelessWidget {
  final TechStudentModel student;
  final bool isSelected;
  final bool isSelectable;
  final VoidCallback? onTap;

  const StudentTile({
    super.key,
    required this.student,
    this.isSelected = false,
    this.isSelectable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSelectable ? onTap : null,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        padding: AppPadding.p12,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          borderRadius: AppRadius.radiusS,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
          ),
          boxShadow: const [
            BoxShadow(
              blurRadius: 4,
              color: Colors.black12,
            ),
          ],
        ),
        child: Row(
          children: [
            if (isSelectable)
              Checkbox(
                activeColor: Colors.blue,
                value: isSelected,
                onChanged: (_) => onTap?.call(),
              ),

            // 🔹 Main Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: AppTypography.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppSpacing.h4,
                  Text(student.parentPhone, style: AppTypography.captionL),
                  Text(student.bloodGroup, style: AppTypography.captionL),
                ],
              ),
            ),

            // 🔹 Right Side Info
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  student.admissionId,
                  style: AppTypography.body2.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                AppSpacing.h4,
                Text(
                  DateFormat('dd/MM/yyyy').format(student.dob!.toDate()),
                  style: AppTypography.captionL,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
class MyStudentTile extends StatelessWidget {
  final EnrollerModel student;
  final VoidCallback? onTap;

  const MyStudentTile({
    super.key,
    required this.student,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      padding: AppPadding.p12,
      decoration: BoxDecoration(
        color:  Colors.white,
        borderRadius: AppRadius.radiusS,
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 4,
            color: Colors.black12,
          ),
        ],
      ),
      child: Row(
        children: [

          // 🔹 Main Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: AppTypography.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppSpacing.h4,
                Text(student.parentPhone, style: AppTypography.captionL),
                Text(student.rollNumber, style: AppTypography.captionL),
              ],
            ),
          ),

          // 🔹 Right Side Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                student.className,
                style: AppTypography.body2.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              AppSpacing.h4,

            ],
          ),
        ],
      ),
    );
  }
}