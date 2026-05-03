import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/constants/app_padding.dart';
import 'package:met_school/core/constants/app_radius.dart';
import 'package:met_school/core/constants/app_spacing.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_typography.dart';

import '../../data/models/quick_action.dart';

class QuickActionCard extends StatelessWidget {
  final QuickAction action;

  const QuickActionCard({
    super.key,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: AppRadius.radiusM,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: AppPadding.pS,
        decoration: BoxDecoration(
          borderRadius: AppRadius.radiusM,
          border: Border.all(color: AppColors.grey5E.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: AppPadding.pS,
              decoration: BoxDecoration(
                color: action.color,
                borderRadius: AppRadius.radiusS,
              ),
              child: Icon(
                action.icon,
                color: AppColors.darkGreen,
                size: 20.sp,
              ),
            ),
            AppSpacing.v12,
            Text(
              action.title,
              style: AppTypography.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
