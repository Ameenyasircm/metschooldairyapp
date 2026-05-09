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
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Title
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: AppTypography.body2.copyWith(
                fontWeight: FontWeight.w400,
                color: AppColors.grey5E,
              ),
            ),
          ),

          SizedBox(width: AppSpacing.m),

          /// Value
          Expanded(
            flex: 5,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                textAlign: TextAlign.start,
                style: AppTypography.body2.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
