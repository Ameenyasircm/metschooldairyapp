import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/constants/app_padding.dart';
import 'package:met_school/core/constants/app_radius.dart';
import 'package:met_school/core/constants/app_spacing.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_typography.dart';

class GradeOverviewCard extends StatelessWidget {
  const GradeOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPadding.pL,
      decoration: BoxDecoration(
        color: AppColors.greenE1.withValues(alpha: 0.5),
        borderRadius: AppRadius.radiusL,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Grade Overview',
                  style: AppTypography.body1.copyWith(color: AppColors.darkGreen,fontWeight: FontWeight.w600),
                ),
                AppSpacing.vxs,
                Text(
                  'Distribution curve and outliers',
                  style: AppTypography.caption.copyWith(color: AppColors.grey5E),
                ),
              ],
            ),
          ),
          Container(
            padding: AppPadding.pS,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary),
            ),
            child: Icon(Icons.show_chart, color: AppColors.darkGreen, size: 22.sp),
          )
        ],
      ),
    );
  }
}
