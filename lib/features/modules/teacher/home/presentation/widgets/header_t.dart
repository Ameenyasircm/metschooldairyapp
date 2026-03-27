import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/constants/app_spacing.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';

Widget buildHeaderT(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: AppColors.lightGreen,
            child: Icon(Icons.person, color: AppColors.primary),
          ),
          AppSpacing.hs,
          Text(
            'Academic Atelier',
            style: AppTypography.h5.copyWith(color: AppColors.primary),
          ),
        ],
      ),
      Icon(Icons.notifications_none_outlined, color: AppColors.primary, size: 28.sp),
    ],
  );
}