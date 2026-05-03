import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_typography.dart';
import 'package:met_school/core/constants/app_spacing.dart';
import 'package:met_school/core/constants/app_padding.dart';
import 'package:met_school/core/constants/app_radius.dart';
import 'package:met_school/core/models/leave_request_model.dart';
import '../../../../../../core/widgets/buttons/action_button.dart';
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
                style: AppTypography.subtitle2.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                "${_formatDate(leave.startDate)} - ${_formatDate(leave.endDate)}",
                style: AppTypography.caption.copyWith(color: Colors.grey),
              ),
            ],
          ),
          AppSpacing.h4,
          Text(leave.className, style: AppTypography.caption.copyWith(color: AppColors.primary)),
          AppSpacing.h2,
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "Reason: ",
                  style: AppTypography.caption.copyWith(color: Colors.grey),
                ),
                TextSpan(
                  text: leave.reason,
                  style: AppTypography.body2,
                ),
              ],
            ),
          ),
          
          if (leave.status == 'pending') ...[
            AppSpacing.h16,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showRejectDialog(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.errorRed,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusM),
                    ),
                    child:Text("Reject",style: AppTypography.body2.copyWith(
                      color: AppColors.errorRed
                    ),),
                  ),
                ),
                AppSpacing.w16,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showApproveConfirmation(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successGreen,
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusM),
                    ),
                    child: Text("Approve", style: AppTypography.body2.copyWith(
                        color: AppColors.white
                    ),),
                  ),
                ),
              ],
            ),
          ] else if (leave.status == 'rejected' && leave.rejectionReason != null) ...[
            AppSpacing.h4,
             Divider(color: AppColors.greyE0,),
            AppSpacing.h4,
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "Rejection Note: ",
                    style: AppTypography.caption.copyWith(color: Colors.red),
                  ),
                  TextSpan(
                    text: leave.rejectionReason ?? "",
                    style: AppTypography.body2.copyWith(color: Colors.red),
                  ),
                ],
              ),
            )
          ],
        ],
      ),
    );
  }

  void _showApproveConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        title:Text("Approve Leave Request",style: AppTypography.body1.copyWith(
        fontWeight: FontWeight.w600)),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Are you sure you want to approve leave for ${leave.studentName}?",
              style: AppTypography.body2,),
            AppSpacing.vl,
            Row(
              children: [
                Expanded(
                  child: ActionButtonsRow(
                    text: "Approve",
                    onCancel: () {
                      Navigator.of(context).pop(false);
                    },
                    onSave: () async {
                      Navigator.pop(context);
                      onUpdateStatus('approved');
                    },
                  ),
                ),
              ],
            ),
            AppSpacing.h4,
          ],
        ),
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
