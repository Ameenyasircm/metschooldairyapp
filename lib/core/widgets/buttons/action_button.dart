import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants/app_padding.dart';
import '../../constants/app_radius.dart';
import '../../constants/app_spacing.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class ActionButtonsRow extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback? onSave;
  final String text;
  final bool isLoading;

  const ActionButtonsRow({
    super.key,
    required this.onCancel,
    this.onSave,
    this.text = "Save",
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        /// Cancel Button
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : onCancel,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primary,),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.radiusS,
              ),
              padding: AppPadding.pvS,
            ),
            child: Text(
              "Cancel",
              style: AppTypography.h6.copyWith(
                color:AppColors.primary,
              ),
            ),
          ),
        ),

        /// Space only if Save exists
        if (onSave != null) AppSpacing.w16,

        /// Save Button
        if (onSave != null)
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.radiusS,
                ),
                padding: AppPadding.pvS,
              ),
              child: isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Text(
                text,
                style: AppTypography.h6.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}