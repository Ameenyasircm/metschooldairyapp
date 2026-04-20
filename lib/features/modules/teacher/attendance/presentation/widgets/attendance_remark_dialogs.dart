import 'package:flutter/material.dart';
import 'package:met_school/core/constants/app_spacing.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_typography.dart';
import 'package:met_school/core/constants/app_radius.dart';
import '../../data/models/attendance_model.dart';
import '../provider/attendance_view_model.dart';

class AttendanceRemarkDialogs {
  static void showLateRemarkDialog(BuildContext context, AttendanceViewModel vm, String studentId) {
    final controller = TextEditingController();
    final durationController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
        title: Text("Late Remark", style: AppTypography.h5),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              style: AppTypography.body1,
              decoration: InputDecoration(
                hintText: "Enter reason for being late",
                hintStyle: AppTypography.body2.copyWith(color: AppColors.greyB2),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.xs)),
              ),
              autofocus: true,
            ),
            AppSpacing.h12,
            TextField(
              controller: durationController,
              style: AppTypography.body1,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter duration of late (minutes)",
                hintStyle: AppTypography.body2.copyWith(color: AppColors.greyB2),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.xs)),
              ),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: AppTypography.label.copyWith(color: AppColors.grey5E)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final duration = int.tryParse(durationController.text.trim()) ?? 0;
                vm.markSingleStudent(
                  studentId, 
                  AttendanceStatus.late, 
                  remark: controller.text.trim(),
                  lateDuration: duration,
                );
                Navigator.pop(context);
              }
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  static void showAbsentRemarkDialog(BuildContext context, AttendanceViewModel vm, String studentId) {
    final student = vm.attendanceMap[studentId];
    final currentRemark = vm.selectedSession == AttendanceSession.morning 
        ? student?.morningAbsentRemark 
        : student?.afternoonAbsentRemark;
        
    final controller = TextEditingController(text: currentRemark);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
        title: Text("${vm.selectedSession == AttendanceSession.morning ? 'Morning' : 'Afternoon'} Absent Remark (Optional)", style: AppTypography.h5),
        content: TextField(
          controller: controller,
          style: AppTypography.body1,
          decoration: InputDecoration(
            hintText: "Enter reason for absence",
            hintStyle: AppTypography.body2.copyWith(color: AppColors.greyB2),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.xs)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              vm.markSingleStudent(studentId, AttendanceStatus.absent);
              Navigator.pop(context);
            },
            child: Text("Skip", style: AppTypography.label.copyWith(color: AppColors.grey5E)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white),
            onPressed: () {
              vm.markSingleStudent(studentId, AttendanceStatus.absent, absentRemark: controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }
}
