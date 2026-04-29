import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/app_padding.dart';
import '../../../../../../core/constants/app_radius.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../provider/attendance_view_model.dart';

Widget buildBottomButton(BuildContext context) {
  final vm = context.watch<AttendanceViewModel>();
  return Container(
    padding: AppPadding.pM,
    decoration: BoxDecoration(
      color: AppColors.white,
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
    ),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 50.h),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: AppColors.greyB2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xs)),
        elevation: 0,
      ),
      onPressed: (vm.isLoading || !vm.isValid) ? null : () async {
        final success = await vm.saveAttendance();
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Attendance saved successfully!'), backgroundColor: AppColors.successGreen),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(vm.validationMessage ?? 'Error saving attendance.'), backgroundColor: AppColors.errorRed),
            );
          }
      },
      child: vm.isLoading
          ? SizedBox(height: 20.h, width: 20.h, child: const CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
          : Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Save Attendance', style: AppTypography.h6.copyWith(color: AppColors.white)),
          if (!vm.isValid && vm.attendanceMap.isNotEmpty)
            Text(
              vm.validationMessage ?? '',
              style: TextStyle(fontSize: 10.sp, color: AppColors.white.withOpacity(0.8)),
            ),
        ],
      ),
    ),
  );
}