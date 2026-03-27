import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/constants/app_padding.dart';
import 'package:met_school/core/constants/app_radius.dart';
import 'package:met_school/core/constants/app_spacing.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_typography.dart';

class StudentProgressCard extends StatelessWidget {
  const StudentProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPadding.pL,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusL,
        border: Border.all(color: AppColors.grey5E.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PERFORMANCE ANALYTICS',
            style: AppTypography.caption.copyWith(
              color: AppColors.primary,
              letterSpacing: 1.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.vs,
          Text(
            'Student Progress',
            style: AppTypography.h5.copyWith(color: AppColors.darkGreen,fontWeight: FontWeight.bold),
          ),
          AppSpacing.vs,
          Text(
            'Detailed mapping of developmental milestones and grade trajectories across all active cohorts.',
            style: AppTypography.body2.copyWith(
              color: AppColors.grey5E,
            ),
          ),
          AppSpacing.vl,
          SizedBox(
            height: 120.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar(40, AppColors.greenE1),
                AppSpacing.hs,
                _buildBar(60, AppColors.greenE1),
                AppSpacing.hs,
                _buildBar(50, AppColors.greenE1),
                AppSpacing.hs,
                _buildBar(100, AppColors.primary),
                AppSpacing.hs,
                _buildBar(80, AppColors.lightGreen),
                AppSpacing.hs,
                _buildBar(40, AppColors.greenE1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double heightPercent, Color color) {
    return Expanded(
      child: FractionallySizedBox(
        heightFactor: heightPercent / 100.0,
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppRadius.radiusS,
          ),
        ),
      ),
    );
  }
}
