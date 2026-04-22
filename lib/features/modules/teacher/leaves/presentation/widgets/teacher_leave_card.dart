import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_typography.dart';
import 'package:met_school/core/constants/app_spacing.dart';
import 'package:met_school/core/constants/app_padding.dart';
import 'package:met_school/core/constants/app_radius.dart';
import 'package:met_school/core/models/leave_request_model.dart';
import 'reject_leave_dialog.dart';

class TeacherLeaveCard extends StatelessWidget {
  final LeaveRequestModel leave;
  final Function(String status, {String? reason}) onUpdateStatus;

  const TeacherLeaveCard({
    super.key,
    required this.leave,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
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
                leave.studentName,
                style: AppTypography.h6.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                "${_formatDate(leave.startDate)} - ${_formatDate(leave.endDate)}",
                style: AppTypography.caption.copyWith(color: Colors.grey),
              ),
            ],
          ),
          AppSpacing.h4,
          Text(leave.className, style: AppTypography.caption.copyWith(color: AppColors.primary)),
          AppSpacing.h12,
          Text("Reason:", style: AppTypography.caption.copyWith(color: Colors.grey)),
          Text(leave.reason, style: AppTypography.body2),
          
          if (leave.status == 'pending') ...[
            AppSpacing.h16,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showRejectDialog(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusM),
                    ),
                    child: const Text("Reject"),
                  ),
                ),
                AppSpacing.w16,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showApproveConfirmation(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusM),
                    ),
                    child: const Text("Approve", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ] else if (leave.status == 'rejected' && leave.rejectionReason != null) ...[
            AppSpacing.h12,
            const Divider(),
            AppSpacing.h8,
            Text("Rejection Note:", style: AppTypography.caption.copyWith(color: Colors.red)),
            Text(leave.rejectionReason!, style: AppTypography.body2.copyWith(color: Colors.red)),
          ],
        ],
      ),
    );
  }

  void _showApproveConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Approve Leave Request"),
        content: Text("Are you sure you want to approve leave for ${leave.studentName}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onUpdateStatus('approved');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Approve", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => RejectLeaveDialog(
        onReject: (reason) => onUpdateStatus('rejected', reason: reason),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
