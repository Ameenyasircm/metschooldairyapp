import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/theme/app_colors.dart';

import '../../../../../../core/constants/app_padding.dart';
import '../../../../../../core/constants/app_radius.dart';
import '../../../../../../core/constants/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';

class LogoutTile extends StatelessWidget {
  const LogoutTile({super.key});

  @override
  Widget build(BuildContext context) {
    return  Container(
      padding: AppPadding.pS,
      // margin: AppPadding.phM,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusM,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children:  [
          CircleAvatar(
            backgroundColor: AppColors.errorRed,
            radius: 24.r,
            child: Icon(Icons.logout, color: AppColors.white,size: 20,),),
          AppSpacing.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Logout",
                    style: AppTypography.body2.copyWith(
                        color: AppColors.red,fontWeight: FontWeight.w600
                    )),
                AppSpacing.h2,
                Text(
                  "Securely sign out from your account.",
                  style: AppTypography.caption.copyWith(
                      color: AppColors.grey9E
                  ),
                ),
              ],
            ),
          ),

          Icon(Icons.arrow_forward_ios, size: 18,color: AppColors.greyB2,)
        ],
      ),
    );
  }
}