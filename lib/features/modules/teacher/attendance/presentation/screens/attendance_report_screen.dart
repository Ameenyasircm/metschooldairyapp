import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:met_school/core/utils/loader/customLoader.dart';
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
                  return const Center(child: CustomLoader());
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
      padding: AppPadding.pXs,
      color: AppColors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.primary,size: 24,),
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
            icon: const Icon(Icons.chevron_right, color: AppColors.primary,size: 24,),
            onPressed: _selectedMonth.isBefore(DateTime(DateTime.now().year, DateTime.now().month))
                ? () {
                    setState(() {
                      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
                    });
                    _loadReport();
                  }
                : null,
          )
        ],
      ),
    );
  }

  Widget _buildSummaryCard(AttendanceReportViewModel vm) {
    double totalPresent = 0, totalAbsent = 0;
    int totalLate = 0;
    for (var stat in vm.studentStats.values) {
      totalPresent += stat.present;
      totalAbsent += stat.absent;
      totalLate += stat.late;
    }

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
          _buildSummaryItem("Days Present", totalPresent, AppColors.successGreen),
          _buildSummaryItem("Days Absent", totalAbsent, AppColors.errorRed),
          _buildSummaryItem("Late Count", totalLate, AppColors.warningOrange),
        ],
      ),
    );
  }
  Widget _buildSummaryItem(String label, dynamic value, Color color) {
    String displayValue = value is double ? (value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1)) : value.toString();
    return Column(
      children: [
        Text(displayValue, style: AppTypography.h6.copyWith(color: color)),
        Text(label, style: AppTypography.caption.copyWith(color: AppColors.grey5E,fontSize: 11.sp)),
      ],
    );
  }

  Widget _buildStatsTable(AttendanceReportViewModel vm) {
    final students = vm.studentStats.entries.toList();

    String formatVal(double val) =>
        val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(1);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Padding(
          padding: AppPadding.phM,
          child: DataTable(
            columnSpacing: 16,
            showCheckboxColumn: false,
            border: TableBorder.all( // ✅ full border
              color: AppColors.greyGreen,
              width: 1,
            ),
            headingRowColor: MaterialStateProperty.all(AppColors.lightBackground),
            columns: [
              DataColumn(label: Text("RN", style: AppTypography.caption)),
              DataColumn(label: Text("Student Name", style: AppTypography.caption)),
              DataColumn(label: Text("Pres", style: AppTypography.caption.copyWith(color: AppColors.successGreen))),
              DataColumn(label: Text("Abs", style: AppTypography.caption.copyWith(color: AppColors.errorRed))),
              DataColumn(label: Text("Late", style: AppTypography.caption.copyWith(color: AppColors.warningOrange))),
              DataColumn(label: Text("%", style: AppTypography.caption)),
            ],
            rows: List.generate(students.length, (index) {
              final studentId = students[index].key;
              final stat = students[index].value;

              return DataRow(
                onSelectChanged: (_) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StudentAttendanceHistoryScreen(
                        studentId: studentId,
                        studentName: stat.name,
                      ),
                    ),
                  );
                },
                cells: [
                  DataCell(Text(stat.rollNo.toString())),
                  DataCell(
                    SizedBox(
                      width: 120,
                      child: Text(
                        stat.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(Text(formatVal(stat.present))),
                  DataCell(Text(formatVal(stat.absent))),
                  DataCell(Text(stat.late.toString())),
                  DataCell(
                    Text(
                      "${stat.attendancePercentage.toInt()}%",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getPercentageColor(stat.attendancePercentage),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
  Color _getPercentageColor(double percentage) {
    if (percentage >= 90) return AppColors.successGreen;
    if (percentage >= 75) return AppColors.primary;
    if (percentage >= 50) return AppColors.warningOrange;
    return AppColors.errorRed;
  }
}

