import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_typography.dart';

import '../../../../../../core/theme/app_padding.dart';
import '../../../../../../core/theme/app_spacing.dart';
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
           Image.asset(
          action.icon,
          color: AppColors.blue90,
          width: 24.w,height: 24.h,
        ),
            AppSpacing.v12,
            Text(
              action.title,
              textAlign: TextAlign.center,
              style: AppTypography.body2.copyWith(
                color: AppColors.blue90,
                fontWeight: FontWeight.w600,
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

class QuickListActionCard extends StatelessWidget {
  final QuickAction action;

  const QuickListActionCard({
    super.key,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPadding.pt10,
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.only(bottomLeft:Radius.circular(12.r),
            bottomRight:Radius.circular(12.r),topRight:Radius.circular(12.r)  ),
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        child: Container(
          padding: AppPadding.pM,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(bottomLeft:Radius.circular(12.r),bottomRight:Radius.circular(12.r),topRight:Radius.circular(12.r)  ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                action.icon,
                color: AppColors.blue90,
                width: 24.w,height: 24.h,
              ),
              AppSpacing.w8,
              Text(
                action.title,
                style: AppTypography.body2.copyWith(
                  color: AppColors.blue90,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
