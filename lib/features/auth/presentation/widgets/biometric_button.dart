import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

Widget buildBiometricButton({
  required IconData icon,
  required String text,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius:AppRadius.radiusM,
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.greenE1.withValues(alpha: 0.5),
        borderRadius:AppRadius.radiusM,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 20.sp),
          AppSpacing.w8,
          Text(
            text,
            style: AppTypography.label.copyWith(
              color: AppColors.darkGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}