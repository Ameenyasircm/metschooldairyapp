import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
   const StudentTile({super.key, required this.student,required this.isSelected,
    required this.isSelectable,this.onTap,});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSelectable ? onTap : null,
      child: Container(
        margin:EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        padding:AppPadding.p12,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          borderRadius:AppRadius.radiusS,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
          ),
          boxShadow: [
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
                activeColor:Colors.blue,
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
                    style:AppTypography.body1.copyWith(
                      fontWeight: FontWeight.w600
                    ),
                  ),
                AppSpacing.h4,
                  Text(student.parentPhone,style: AppTypography.captionL,),
                  Text(student.bloodGroup,style: AppTypography.captionL,),
                ],
              ),
            ),
      
            // 🔹 Right Side Info
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  student.admissionNumber,
                  style: AppTypography.body2.copyWith(
                    fontWeight: FontWeight.w700,color: AppColors.primary
                  )
                ),
               AppSpacing.h4,
                Text(
                  student.dob,
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