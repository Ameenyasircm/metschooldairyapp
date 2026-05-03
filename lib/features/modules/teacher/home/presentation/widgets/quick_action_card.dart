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
      borderRadius: BorderRadius.only(bottomLeft:Radius.circular(12.r),bottomRight:Radius.circular(12.r),topRight:Radius.circular(12.r)  ),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: AppPadding.pS,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(bottomLeft:Radius.circular(12.r),bottomRight:Radius.circular(12.r),topRight:Radius.circular(12.r)  ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: AppPadding.pS,
              decoration: BoxDecoration(
                borderRadius: AppRadius.radiusS,
              ),
              child: Icon(
                action.icon,
                color: AppColors.blue90,
                size: 24.sp,
              ),
            ),
            AppSpacing.v12,
            Text(
              action.title,
              style: AppTypography.caption.copyWith(
                color: AppColors.blue90,
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
