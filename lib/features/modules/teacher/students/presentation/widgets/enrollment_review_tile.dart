import 'package:flutter/material.dart';
import 'package:met_school/core/theme/app_padding.dart';
import 'package:met_school/core/theme/app_radius.dart';
import 'package:met_school/core/theme/app_spacing.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_typography.dart';

class EnrollmentReviewTile extends StatelessWidget {
  final String title;
  final String value;

  const EnrollmentReviewTile({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.m),
      padding: AppPadding.pM,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusM,
        border: Border.all(color: AppColors.greyE0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTypography.body1.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: AppTypography.body1,
          ),
        ],
      ),
    );
  }
}
