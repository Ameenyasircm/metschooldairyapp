import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_typography.dart';
import 'package:met_school/core/constants/app_spacing.dart';
import 'package:met_school/core/constants/app_padding.dart';
import 'package:met_school/core/constants/app_radius.dart';
import 'package:met_school/core/models/leave_request_model.dart';

class ParentLeaveCard extends StatelessWidget {
  final LeaveRequestModel leave;

  const ParentLeaveCard({super.key, required this.leave});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (leave.status) {
      case 'approved':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: AppPadding.pM,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusL,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${_formatDate(leave.startDate)} - ${_formatDate(leave.endDate)}",
                style: AppTypography.h6.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  leave.status.toUpperCase(),
                  style: AppTypography.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.h12,
          Text(
            "Reason:",
            style: AppTypography.caption.copyWith(color: Colors.grey),
          ),
          Text(
            leave.reason,
            style: AppTypography.body2,
          ),
          if (leave.status == 'rejected' && leave.rejectionReason != null) ...[
            AppSpacing.h12,
            const Divider(),
            AppSpacing.h8,
            Text(
              "Rejection Note:",
              style: AppTypography.caption.copyWith(color: Colors.red),
            ),
            Text(
              leave.rejectionReason!,
              style: AppTypography.body2.copyWith(color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
