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
import '../widgets/attendance_tile.dart';
import '../widgets/attendance_session_toggle.dart';
import '../widgets/attendance_action_chip.dart';
import '../widgets/attendance_remark_dialogs.dart';
import '../widgets/bottom_button.dart';

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
        title: Text('Attendance - ${widget.divisionName}', style: AppTypography.h6.copyWith(color: AppColors.primary)),
        backgroundColor: AppColors.lightBackground,
        iconTheme: const IconThemeData(color: AppColors.primary),
        elevation: 0,
        actions: [
        Consumer<AttendanceViewModel>(
            builder: (context, vm, child) {
            return InkWell(
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
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 8.h),
                margin: EdgeInsets.symmetric(horizontal: 6.w,),
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
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,fontSize: 10.sp
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        ),
      ],
      ),
      body: Consumer<AttendanceViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading && vm.attendanceMap.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          return Column(
            children: [
              _buildHeader(context, vm),
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
                                AttendanceRemarkDialogs.showLateRemarkDialog(context, vm, studentId);
                              } else if (status == AttendanceStatus.absent) {
                                AttendanceRemarkDialogs.showAbsentRemarkDialog(context, vm, studentId);
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
      bottomNavigationBar: buildBottomButton(context),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.greyGreen.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Row(
                  children: [
                    AttendanceSessionToggle(
                      label: 'Morning',
                      isSelected: vm.selectedSession == AttendanceSession.morning,
                      onTap: () => vm.setSelectedSession(AttendanceSession.morning),
                    ),
                    AppSpacing.hm,
                    AttendanceSessionToggle(
                      label: 'Afternoon',
                      isSelected: vm.selectedSession == AttendanceSession.afternoon,
                      onTap: () => vm.setSelectedSession(AttendanceSession.afternoon),
                    ),
                  ],
                ),
              ),
              AttendanceActionChip(
                label: "All Present",
                color: AppColors.successGreen,
                onTap: () => vm.markAll(AttendanceStatus.present),
              ),
            ],
          ),
        ],
      ),
    );
  }





}
