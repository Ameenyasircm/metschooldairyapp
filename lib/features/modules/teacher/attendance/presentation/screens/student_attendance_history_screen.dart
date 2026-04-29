
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:met_school/core/utils/loader/customLoader.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/app_padding.dart';
import '../../../../../../core/constants/app_radius.dart';
import '../../../../../../core/constants/app_spacing.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../data/models/attendance_model.dart';
import '../provider/attendance_report_view_model.dart';

class StudentAttendanceHistoryScreen extends StatefulWidget {
  final String studentId;
  final String studentName;

  const StudentAttendanceHistoryScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<StudentAttendanceHistoryScreen> createState() => _StudentAttendanceHistoryScreenState();
}

class _StudentAttendanceHistoryScreenState extends State<StudentAttendanceHistoryScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _setInitialDates();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchHistory();
    });
  }

  void _setInitialDates() {
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = now;
  }

  void _fetchHistory() {
    context.read<AttendanceReportViewModel>().loadStudentHistory(
          widget.studentId,
          start: _startDate,
          end: _endDate,
        );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate!, end: _endDate!),
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _fetchHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(widget.studentName, style: AppTypography.h6.copyWith(color: AppColors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateRangeHeader(),
          Expanded(
            child: Consumer<AttendanceReportViewModel>(
              builder: (context, vm, child) {
                if (vm.isLoading) {
                  return const Center(child: CustomLoader());
                }

                if (vm.studentHistory.isEmpty) {
                  return Center(
                      child: Padding(
                        padding: AppPadding.phS,
                        child: Text("No history available for the selected period.",
                            style: AppTypography.body1.copyWith(color: AppColors.grey5E)),
                      ));
                }

                return Column(
                  children: [
                    _buildHistorySummary(vm.studentHistory),
                    Expanded(
                      child: ListView.builder(
                        padding: AppPadding.pM,
                        itemCount: vm.studentHistory.length,
                        itemBuilder: (context, index) {
                          final daily = vm.studentHistory[index];
                          final data = daily.students[widget.studentId];
                          final date = DateFormat('yyyy-MM-dd').parse(daily.date);

                          if (data == null) return const SizedBox.shrink();

                          return Card(
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.s)),
                            margin: EdgeInsets.only(bottom: 8.h),
                            child: Padding(
                              padding: AppPadding.pM,
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(DateFormat('dd MMM yyyy').format(date), style: AppTypography.subtitle2),
                                      Text(DateFormat('EEEE').format(date),
                                          style: AppTypography.caption.copyWith(color: AppColors.grey5E)),
                                      if (data.lateRemark.isNotEmpty) ...[
                                        AppSpacing.h2,
                                        Text("Late: ${data.lateRemark}", style: AppTypography.caption.copyWith(color: AppColors.warningOrange)),
                                      ],
                                      if (data.morningAbsentRemark.isNotEmpty) ...[
                                        AppSpacing.h2,
                                        Text("Morning Absent: ${data.morningAbsentRemark}", style: AppTypography.caption.copyWith(color: AppColors.errorRed)),
                                      ],
                                      if (data.afternoonAbsentRemark.isNotEmpty) ...[
                                        AppSpacing.h2,
                                        Text("Afternoon Absent: ${data.afternoonAbsentRemark}", style: AppTypography.caption.copyWith(color: AppColors.errorRed)),
                                      ],
                                    ],
                                  ),
                                  const Spacer(),
                                  _buildSessionIndicator("Morning", data.morning),
                                  AppSpacing.hm,
                                  _buildSessionIndicator("Afternoon", data.afternoon),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      color: AppColors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16.w, color: AppColors.grey5E),
              AppSpacing.w8,
              Text(
                "${DateFormat('dd MMM').format(_startDate!)} - ${DateFormat('dd MMM yyyy').format(_endDate!)}",
                style: AppTypography.body2.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          InkWell(
            onTap: _selectDateRange,
            child: Text(
              "Change",
              style: AppTypography.body2.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySummary(List<DailyAttendanceModel> history) {
    double present = 0;
    double absent = 0;
    int lateCount = 0;

    for (var daily in history) {
      final data = daily.students[widget.studentId];
      if (data == null) continue;

      if (data.morning == AttendanceStatus.present || data.morning == AttendanceStatus.late) {
        present += 0.5;
        if (data.morning == AttendanceStatus.late) lateCount++;
      } else if (data.morning == AttendanceStatus.absent) {
        absent += 0.5;
      }

      if (data.afternoon == AttendanceStatus.present) {
        present += 0.5;
      } else if (data.afternoon == AttendanceStatus.absent) {
        absent += 0.5;
      }
    }

    String format(double val) => val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(1);

    return Container(
      margin: AppPadding.pM,
      padding: AppPadding.pS,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.m),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem("Days Present", format(present), AppColors.successGreen),
          _buildSummaryItem("Days Absent", format(absent), AppColors.errorRed),
          _buildSummaryItem("Late Count", lateCount.toString(), AppColors.warningOrange),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: AppTypography.h6.copyWith(color: color)),
        Text(label, style: AppTypography.caption.copyWith(color: AppColors.grey5E,fontSize: 11.sp)),
      ],
    );
  }

  Widget _buildSessionIndicator(String session, AttendanceStatus status) {
    Color color = AppColors.greyB2;
    String text = "-";

    switch (status) {
      case AttendanceStatus.present:
        color = AppColors.successGreen;
        text = "P";
        break;
      case AttendanceStatus.absent:
        color = AppColors.errorRed;
        text = "A";
        break;
      case AttendanceStatus.late:
        color = AppColors.warningOrange;
        text = "L";
        break;
      default:
        break;
    }

    return Column(
      children: [
        Text(session.substring(0, 1), style: AppTypography.caption.copyWith(fontSize: 10.sp, fontWeight: FontWeight.bold)),
        AppSpacing.h4,
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(text, style: AppTypography.label.copyWith(color: color, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}