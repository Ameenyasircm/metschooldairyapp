import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/theme/app_typography.dart';
import 'package:met_school/core/constants/app_radius.dart';

class AttendanceActionChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const AttendanceActionChip({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: AppRadius.radiusXL,
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
