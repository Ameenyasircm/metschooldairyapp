import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_typography.dart';
import 'package:met_school/core/constants/app_spacing.dart';
import 'package:met_school/core/constants/app_padding.dart';
import 'package:met_school/core/constants/app_radius.dart';
import '../../data/models/attendance_model.dart';
import '../provider/attendance_view_model.dart';

class AttendanceScreen extends StatefulWidget {
  final String divisionId;
  final String divisionName;
  final String academicYearId;
  final String teacherId;

  const AttendanceScreen({
    super.key,
    required this.divisionId,
    required this.divisionName,
    required this.academicYearId,
    required this.teacherId,
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceViewModel>().init(
            widget.divisionId,
            widget.academicYearId,
            widget.teacherId,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Attendance - ${widget.divisionName}', style: AppTypography.h6.copyWith(color: AppColors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.white),
        elevation: 0,
      ),
      body: Consumer<AttendanceViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading && vm.attendanceMap.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          return Column(
            children: [
              _buildHeader(context, vm),
              _buildActionBar(vm),
              Expanded(
                child: vm.attendanceMap.isEmpty
                    ? Center(child: Text("No students found", style: AppTypography.body1.copyWith(color: AppColors.grey5E)))
                    : ListView.builder(
                        padding: AppPadding.pM,
                        itemCount: vm.attendanceMap.length,
                        itemBuilder: (context, index) {
                          final studentId = vm.attendanceMap.keys.elementAt(index);
                          final data = vm.attendanceMap[studentId]!;
                          return AttendanceTile(
                            studentData: data,
                            session: vm.selectedSession,
                            onStatusChanged: (status) {
                              if (status == AttendanceStatus.late) {
                                _showLateRemarkDialog(context, vm, studentId);
                              } else {
                                vm.markSingleStudent(studentId, status);
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomButton(context),
    );
  }

  Widget _buildHeader(BuildContext context, AttendanceViewModel vm) {
    return Container(
      padding: AppPadding.pM,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.greyGreen, width: 1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: vm.selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: AppColors.primary,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) vm.setSelectedDate(date);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.greyGreen),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                        AppSpacing.hs,
                        Text(
                          DateFormat('dd MMM yyyy').format(vm.selectedDate),
                          style: AppTypography.subtitle2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AppSpacing.hm,
              Container(
                decoration: BoxDecoration(
                  color: AppColors.greyGreen.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Row(
                  children: [
                    _SessionToggle(
                      label: 'Morning',
                      isSelected: vm.selectedSession == AttendanceSession.morning,
                      onTap: () => vm.setSelectedSession(AttendanceSession.morning),
                    ),
                    _SessionToggle(
                      label: 'Afternoon',
                      isSelected: vm.selectedSession == AttendanceSession.afternoon,
                      onTap: () => vm.setSelectedSession(AttendanceSession.afternoon),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(AttendanceViewModel vm) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _ActionChip(
              label: "All Present",
              color: AppColors.successGreen,
              onTap: () => vm.markAll(AttendanceStatus.present),
            ),
            AppSpacing.hm,
            _ActionChip(
              label: "All Absent",
              color: AppColors.errorRed,
              onTap: () => vm.markAll(AttendanceStatus.absent),
            ),
            AppSpacing.hm,
            _ActionChip(
              label: "Reset All",
              color: AppColors.grey5E,
              onTap: () => vm.markAll(AttendanceStatus.none),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
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
          if (mounted) {
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Attendance saved successfully!'), backgroundColor: AppColors.successGreen),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(vm.validationMessage ?? 'Error saving attendance.'), backgroundColor: AppColors.errorRed),
              );
            }
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

  void _showLateRemarkDialog(BuildContext context, AttendanceViewModel vm, String studentId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
        title: Text("Late Remark", style: AppTypography.h5),
        content: TextField(
          controller: controller,
          style: AppTypography.body1,
          decoration: InputDecoration(
            hintText: "Enter reason for being late",
            hintStyle: AppTypography.body2.copyWith(color: AppColors.greyB2),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.xs)),
          ),
          autofocus: true,
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
                vm.markSingleStudent(studentId, AttendanceStatus.late, remark: controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }
}

class _SessionToggle extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SessionToggle({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.s),
        ),
        child: Text(
          label,
          style: AppTypography.label.copyWith(color: isSelected ? AppColors.white : AppColors.grey5E),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius:AppRadius.radiusXL,
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
        borderRadius:AppRadius.radiusM,
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
                        child: Text("Remark: ${studentData.lateRemark}", style: AppTypography.caption.copyWith(color: AppColors.warningOrange)),
                      ),
                  ],
                ),
              ),
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
        _StatusButton(
          label: 'P',
          isSelected: status == AttendanceStatus.present,
          color: AppColors.successGreen,
          onTap: () => onStatusChanged(AttendanceStatus.present),
        ),
        AppSpacing.hs,
        _StatusButton(
          label: 'A',
          isSelected: status == AttendanceStatus.absent,
          color: AppColors.errorRed,
          onTap: () => onStatusChanged(AttendanceStatus.absent),
        ),
        if (session == AttendanceSession.morning) ...[
          AppSpacing.hs,
          _StatusButton(
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

class _StatusButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _StatusButton({
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
