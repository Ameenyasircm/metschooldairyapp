import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../core/constants/app_spacing.dart';
import '../../../../../../core/router/app_navigation.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/widgets/dialogs/logout_alert.dart';
import '../../../../../../providers/auth_provider.dart';
import '../../../../../auth/presentation/screens/login_screen.dart';
import '../../viewmodels/teacher_home_viewmodel.dart';

Widget buildHeaderT(BuildContext context,String staffName) {
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
                      text:staffName,
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
      Row(
        children: [
          Icon(Icons.notifications_none_outlined, color: AppColors.primary, size: 28.sp),
          AppSpacing.w16,
          IconButton(
            onPressed: () async {

              final shouldLogout = await showLogoutDialog(context);
              if (shouldLogout == true) {
                final prefs = await SharedPreferences.getInstance();
                /// Clear saved data
                await prefs.clear();
                NavigationService.pushAndRemoveUntil(
                  context,
                  LoginScreen(),
                );
              }
            },
              icon: Icon(Icons.logout, color: AppColors.primary, size: 28.sp)),
        ],
      ),
    ],
  );
}