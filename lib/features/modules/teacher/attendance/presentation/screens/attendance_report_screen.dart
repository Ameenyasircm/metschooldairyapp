import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:met_school/features/modules/teacher/attendance/presentation/screens/student_attendance_history_screen.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/constants/app_spacing.dart';
import '../../../../../../core/constants/app_padding.dart';
import '../../../../../../core/constants/app_radius.dart';
import '../provider/attendance_report_view_model.dart';
import '../../data/models/attendance_model.dart';

class AttendanceReportScreen extends StatefulWidget {
  final String divisionId;
  final String divisionName;

  const AttendanceReportScreen({
    super.key,
    required this.divisionId,
    required this.divisionName,
  });

  @override
  State<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReport();
    });
  }

  void _loadReport() {
    final monthYear = DateFormat('yyyy-MM').format(_selectedMonth);
    context.read<AttendanceReportViewModel>().loadMonthlyReport(widget.divisionId, monthYear);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Monthly Report - ${widget.divisionName}', style: AppTypography.h6.copyWith(color: AppColors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: Column(
        children: [
          _buildMonthPicker(context),
          Expanded(
            child: Consumer<AttendanceReportViewModel>(
              builder: (context, vm, child) {
                if (vm.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                if (vm.studentStats.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 64.sp, color: AppColors.greyB2),
                        AppSpacing.vm,
                        Text("No attendance records found for this month.", style: AppTypography.body1.copyWith(color: AppColors.grey5E)),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    _buildSummaryCard(vm),
                    Expanded(child: _buildStatsTable(vm)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthPicker(BuildContext context) {
    return Container(
      padding: AppPadding.pM,
      color: AppColors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.primary),
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
              });
              _loadReport();
            },
          ),
          Text(
            DateFormat('MMMM yyyy').format(_selectedMonth),
            style: AppTypography.h6.copyWith(color: AppColors.primary),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.primary),
            onPressed: _selectedMonth.isBefore(DateTime(DateTime.now().year, DateTime.now().month))
                ? () {
                    setState(() {
                      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
                    });
                    _loadReport();
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(AttendanceReportViewModel vm) {
    int totalPresent = 0, totalAbsent = 0, totalLate = 0;
    for (var stat in vm.studentStats.values) {
      totalPresent += stat.present;
      totalAbsent += stat.absent;
      totalLate += stat.late;
    }

    return Container(
      margin: AppPadding.pM,
      padding: AppPadding.pM,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.m),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem("Present", totalPresent, AppColors.successGreen),
          _buildSummaryItem("Absent", totalAbsent, AppColors.errorRed),
          _buildSummaryItem("Late", totalLate, AppColors.warningOrange),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(value.toString(), style: AppTypography.h5.copyWith(color: color)),
        Text(label, style: AppTypography.caption.copyWith(color: AppColors.grey5E)),
      ],
    );
  }

  Widget _buildStatsTable(AttendanceReportViewModel vm) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: vm.studentStats.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.greyGreen, width: 2)),
            ),
            child: Row(
              children: [
                SizedBox(width: 30.w, child: Text("RN", style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold))),
                Expanded(child: Text("STUDENT NAME", style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold))),
                SizedBox(width: 30.w, child: Text("P", style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.successGreen), textAlign: TextAlign.center)),
                SizedBox(width: 30.w, child: Text("A", style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.errorRed), textAlign: TextAlign.center)),
                SizedBox(width: 30.w, child: Text("L", style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.warningOrange), textAlign: TextAlign.center)),
              ],
            ),
          );
        }

        final studentId = vm.studentStats.keys.elementAt(index - 1);
        final stat = vm.studentStats[studentId]!;

        return InkWell(
          onTap: () {
            // Navigate to Student Wise Report
             Navigator.push(context, MaterialPageRoute(
               builder: (_) => StudentAttendanceHistoryScreen(studentId: studentId, studentName: stat.name)
             ));
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.greyGreen, width: 1)),
            ),
            child: Row(
              children: [
                SizedBox(width: 30.w, child: Text(stat.rollNo, style: AppTypography.body2)),
                Expanded(child: Text(stat.name, style: AppTypography.body2.copyWith(fontWeight: FontWeight.w500))),
                SizedBox(width: 30.w, child: Text(stat.present.toString(), style: AppTypography.body2, textAlign: TextAlign.center)),
                SizedBox(width: 30.w, child: Text(stat.absent.toString(), style: AppTypography.body2, textAlign: TextAlign.center)),
                SizedBox(width: 30.w, child: Text(stat.late.toString(), style: AppTypography.body2, textAlign: TextAlign.center)),
              ],
            ),
          ),
        );
      },
    );
  }
}

