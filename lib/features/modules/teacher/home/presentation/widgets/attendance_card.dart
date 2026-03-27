import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/constants/app_padding.dart';
import 'package:met_school/core/constants/app_radius.dart';
import 'package:met_school/core/constants/app_spacing.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_typography.dart';

class AttendanceCard extends StatelessWidget {
  const AttendanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppPadding.pL,
      decoration: BoxDecoration(
        color: AppColors.secondary, // Design uses dark teal/slate, secondary maps nicely
        borderRadius: AppRadius.radiusL,
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            child: Icon(
              Icons.bar_chart, 
              size: 80.sp, 
              color: AppColors.white.withValues(alpha: 0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Class Attendance',
                style: AppTypography.h5.copyWith(color: AppColors.white),
              ),
              AppSpacing.vxs,
              Text(
                'Weekly trends & absenteeism alerts',
                style: AppTypography.captionL.copyWith(
                  color: AppColors.white.withValues(alpha: 0.8),
                ),
              ),
              AppSpacing.vl,
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '94.2%',
                    style: AppTypography.h2.copyWith(
                      color: AppColors.white, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.hm,
                  Container(
                    padding: AppPadding.phMvS,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      borderRadius: AppRadius.radiusS,
                    ),
                    child: Text(
                      '+2.4% vs LW',
                      style: AppTypography.caption.copyWith(color: AppColors.white),
                    ),
                  )
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
