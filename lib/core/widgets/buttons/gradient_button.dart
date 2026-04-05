import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/constants/app_spacing.dart';

import '../../constants/app_radius.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

Widget gradientButton({
  required String text,
  final VoidCallback? onPressed,
  final bool isLoading = false,
  Widget? icon,

}) {
  return SizedBox(
    width: double.infinity,
    height: 50.h,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius:AppRadius.radiusXL,
        ),
        elevation: 0,
      ),
      child:isLoading
          ? SizedBox(
        height: 20.h,
        width: 20.w,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      )
          :Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: AppTypography.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          if (icon != null) ...[
            AppSpacing.w8,
           icon
          ],
        ],
      ),
    ),
  );
}