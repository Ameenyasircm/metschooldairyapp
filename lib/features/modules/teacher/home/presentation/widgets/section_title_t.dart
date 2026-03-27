import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/constants/app_radius.dart';
import '../../../../../../core/constants/app_spacing.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';

Widget buildSectionTitle(String title) {
  return Row(
    children: [
      Container(
        width: 6.w,
        height: 20.h,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: AppRadius.radiusS,
        ),
      ),
      AppSpacing.hs,
      Text(
        title,
        style: AppTypography.h6.copyWith(color: AppColors.darkGreen,fontWeight: FontWeight.w600),
      ),
    ],
  );
}
Widget buildSectionTitleWithAction(String title, String actionText) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      buildSectionTitle(title),
      Text(
        actionText,
        style: AppTypography.label.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}
