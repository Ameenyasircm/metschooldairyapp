import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_typography.dart';
import 'package:met_school/core/constants/app_spacing.dart';
import 'package:met_school/core/constants/app_padding.dart';
import 'package:met_school/core/constants/app_radius.dart';
import '../../data/models/attendance_model.dart';

class AttendanceTile extends StatelessWidget {
  final StudentAttendanceData studentData;
  final AttendanceSession session;
  final Function(AttendanceStatus) onStatusChanged;

  const AttendanceTile({
    super.key,
    required this.studentData,
    required this.session,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final status = session == AttendanceSession.morning ? studentData.morning : studentData.afternoon;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: AppPadding.pM,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusM,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: const BoxDecoration(color: AppColors.greyGreen, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(studentData.rollNo, style: AppTypography.label.copyWith(color: AppColors.primary)),
              ),
              AppSpacing.hm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(studentData.name, style: AppTypography.h6),
                    if (session == AttendanceSession.morning && studentData.morning == AttendanceStatus.late)
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Text(
                          "Late: ${studentData.lateDurationMinutes} mins - ${studentData.lateRemark}", 
                          style: AppTypography.caption.copyWith(color: AppColors.warningOrange)
                        ),
                      ),
                    if (session == AttendanceSession.morning && studentData.morning == AttendanceStatus.absent && studentData.morningAbsentRemark.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Text("Morning Absent Remark: ${studentData.morningAbsentRemark}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: AppTypography.caption.copyWith(color: AppColors.errorRed)),
                      ),
                    if (session == AttendanceSession.afternoon && studentData.afternoon == AttendanceStatus.absent && studentData.afternoonAbsentRemark.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Text("Afternoon Absent Remark: ${studentData.afternoonAbsentRemark}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: AppTypography.caption.copyWith(color: AppColors.errorRed)),
                      ),
                  ],
                ),
              ),
              AppSpacing.w2,
              _buildStatusSelectors(status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSelectors(AttendanceStatus status) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StatusButton(
          label: 'P',
          isSelected: status == AttendanceStatus.present,
          color: AppColors.successGreen,
          onTap: () => onStatusChanged(AttendanceStatus.present),
        ),
        AppSpacing.hs,
        StatusButton(
          label: 'A',
          isSelected: status == AttendanceStatus.absent,
          color: AppColors.errorRed,
          onTap: () => onStatusChanged(AttendanceStatus.absent),
        ),
        if (session == AttendanceSession.morning) ...[
          AppSpacing.hs,
          StatusButton(
            label: 'L',
            isSelected: status == AttendanceStatus.late,
            color: AppColors.warningOrange,
            onTap: () => onStatusChanged(AttendanceStatus.late),
          ),
        ],
      ],
    );
  }
}

class StatusButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const StatusButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34.w,
        height: 34.w,
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.white,
          border: Border.all(color: isSelected ? color : AppColors.greyGreen, width: 1.5),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.label.copyWith(
            color: isSelected ? AppColors.white : AppColors.grey5E,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
