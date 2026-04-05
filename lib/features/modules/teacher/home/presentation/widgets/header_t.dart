import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/app_spacing.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../viewmodels/teacher_home_viewmodel.dart';

Widget buildHeaderT(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Consumer<TeacherHomeViewModel>(
          builder: (context, vm, _) {
          return Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: AppColors.lightGreen,
                child: Icon(Icons.person, color: AppColors.primary),
              ),
              AppSpacing.hs,
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text:'${vm.greetingText}\n',
                      style: AppTypography.caption,
                    ),
                    TextSpan(
                      text:vm.teacherName,
                      style: AppTypography.body2.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            ],
          );
        }
      ),
      Icon(Icons.notifications_none_outlined, color: AppColors.primary, size: 28.sp),
    ],
  );
}