import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_spacing.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../buttons/action_button.dart';

Future<bool?> showLogoutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Logout',
              style: AppTypography.body1.copyWith(
                  fontWeight: FontWeight.w600
              ),
            ),
            AppSpacing.v12,
            Text(
              'Are you sure you want to logout?',
              style: AppTypography.body2,
            ),
            AppSpacing.vl,
            Row(
              children: [
                Expanded(
                  child: ActionButtonsRow(
                    text: "Yes",
                    onCancel: () {
                      Navigator.of(context).pop(false);
                    },
                    onSave: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ),
              ],
            ),
            AppSpacing.h4,
          ],
        ),
      );
    },
  );
}