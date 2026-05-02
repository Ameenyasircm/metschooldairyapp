import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_typography.dart';
import 'package:met_school/core/constants/app_spacing.dart';
import 'package:met_school/core/constants/app_padding.dart';
import 'package:met_school/core/constants/app_radius.dart';

import '../../../teacher/attendance/presentation/provider/attendance_report_view_model.dart';
import '../../../teacher/attendance/presentation/screens/student_attendance_history_screen.dart';


class ParentViewAttendanceScreen extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String divisionId;
  final String divisionName;

  const ParentViewAttendanceScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.divisionId,
    required this.divisionName,
  });

  @override
  State<ParentViewAttendanceScreen> createState() => _ParentViewAttendanceScreenState();
}

class _ParentViewAttendanceScreenState extends State<ParentViewAttendanceScreen>
    with SingleTickerProviderStateMixin {
  DateTime _selectedMonth = DateTime.now();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadReport());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadReport() {
    final monthYear = DateFormat('yyyy-MM').format(_selectedMonth);
    context
        .read<AttendanceReportViewModel>()
        .loadMonthlyReport(widget.divisionId, monthYear);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        leading: BackButton(color: AppColors.primary),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.studentName,
              style: AppTypography.h6.copyWith(color: AppColors.primary),
            ),
            Text(
              widget.divisionName,
              style: AppTypography.caption.copyWith(
                color: AppColors.grey5E,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.grey5E,
          indicatorColor: AppColors.primary,
          labelStyle: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Monthly Summary'),
            Tab(text: 'Daily History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MonthlySummaryTab(
            studentId: widget.studentId,
            selectedMonth: _selectedMonth,
            onMonthChanged: (month) {
              setState(() => _selectedMonth = month);
              _loadReport();
            },
          ),
          // Reuse your existing StudentAttendanceHistoryScreen body/content
          // wrapped to show only this student's data
          StudentAttendanceHistoryScreen(
            studentId: widget.studentId,
            studentName: widget.studentName,
          ),
        ],
      ),
    );
  }
}

// ─── Monthly Summary Tab ────────────────────────────────────────────────────

class _MonthlySummaryTab extends StatelessWidget {
  final String studentId;
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onMonthChanged;

  const _MonthlySummaryTab({
    required this.studentId,
    required this.selectedMonth,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceReportViewModel>(
      builder: (context, vm, _) {
        return Column(
          children: [
            _MonthNavigator(
              selectedMonth: selectedMonth,
              onMonthChanged: onMonthChanged,
            ),
            if (vm.isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (vm.studentStats.isEmpty || !vm.studentStats.containsKey(studentId))
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 56.sp, color: AppColors.greyB2),
                      AppSpacing.vm,
                      Text(
                        "No attendance records for this month.",
                        style: AppTypography.body1.copyWith(color: AppColors.grey5E),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: _buildContent(context, vm),
              ),
          ],
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, AttendanceReportViewModel vm) {
    final stat = vm.studentStats[studentId]!;

    return SingleChildScrollView(
      padding: AppPadding.pM,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacing.vs,
          _AttendanceScoreCard(stat: stat),
          AppSpacing.vm,
          _SessionBreakdownCard(stat: stat),
          AppSpacing.vm,
          _AttendanceBarChart(stat: stat),
          AppSpacing.vl,
        ],
      ),
    );
  }
}

// ─── Month Navigator ────────────────────────────────────────────────────────

class _MonthNavigator extends StatelessWidget {
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onMonthChanged;

  const _MonthNavigator({
    required this.selectedMonth,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentMonth = selectedMonth.year == DateTime.now().year &&
        selectedMonth.month == DateTime.now().month;

    return Container(
      padding: AppPadding.pXs,
      color: AppColors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.primary, size: 24),
            onPressed: () => onMonthChanged(
              DateTime(selectedMonth.year, selectedMonth.month - 1),
            ),
          ),
          Text(
            DateFormat('MMMM yyyy').format(selectedMonth),
            style: AppTypography.h6.copyWith(color: AppColors.primary),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right,
                color: isCurrentMonth ? AppColors.greyB2 : AppColors.primary,
                size: 24),
            onPressed: isCurrentMonth
                ? null
                : () => onMonthChanged(
              DateTime(selectedMonth.year, selectedMonth.month + 1),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Attendance Score Card ───────────────────────────────────────────────────

class _AttendanceScoreCard extends StatelessWidget {
  final dynamic stat; // your StudentAttendanceStat model

  const _AttendanceScoreCard({required this.stat});

  Color _percentageColor(double pct) {
    if (pct >= 90) return AppColors.successGreen;
    if (pct >= 75) return AppColors.primary;
    if (pct >= 50) return AppColors.warningOrange;
    return AppColors.errorRed;
  }

  String _percentageLabel(double pct) {
    if (pct >= 90) return 'Excellent';
    if (pct >= 75) return 'Good';
    if (pct >= 50) return 'Average';
    return 'Poor';
  }

  @override
  Widget build(BuildContext context) {
    final pct = stat.attendancePercentage;
    final color = _percentageColor(pct);

    return Container(
      padding: AppPadding.pM,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.m),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // Circular percentage indicator
          SizedBox(
            width: 80.w,
            height: 80.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: pct / 100,
                  strokeWidth: 7,
                  backgroundColor: AppColors.greyGreen,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${pct.toInt()}%',
                      style: AppTypography.h6.copyWith(
                        color: color,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.hm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attendance Rate',
                  style: AppTypography.caption.copyWith(color: AppColors.grey5E),
                ),
                AppSpacing.vs,
                Text(
                  _percentageLabel(pct),
                  style: AppTypography.h6.copyWith(color: color),
                ),
                AppSpacing.vs,
                _buildStatRow(
                  icon: Icons.check_circle_outline,
                  label: 'Present',
                  value: _fmt(stat.present),
                  color: AppColors.successGreen,
                ),
                AppSpacing.vs,
                _buildStatRow(
                  icon: Icons.cancel_outlined,
                  label: 'Absent',
                  value: _fmt(stat.absent),
                  color: AppColors.errorRed,
                ),
                AppSpacing.vs,
                _buildStatRow(
                  icon: Icons.access_time,
                  label: 'Late',
                  value: stat.late.toString(),
                  color: AppColors.warningOrange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double val) =>
      val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(1);

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: color),
        SizedBox(width: 4.w),
        Text(
          '$label: ',
          style: AppTypography.caption.copyWith(color: AppColors.grey5E, fontSize: 11.sp),
        ),
        Text(
          value,
          style: AppTypography.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 11.sp,
          ),
        ),
      ],
    );
  }
}

// ─── Session Breakdown Card ──────────────────────────────────────────────────

class _SessionBreakdownCard extends StatelessWidget {
  final StudentStats stat;

  const _SessionBreakdownCard({required this.stat});

  String _fmt(double v) => v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPadding.pM,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.m),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Breakdown',
            style: AppTypography.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          AppSpacing.vs,
          Divider(color: AppColors.greyGreen),
          AppSpacing.vs,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(label: 'Present', value: _fmt(stat.present), color: AppColors.successGreen, icon: Icons.check_circle_outline),
              _StatItem(label: 'Absent',  value: _fmt(stat.absent),  color: AppColors.errorRed,     icon: Icons.cancel_outlined),
              _StatItem(label: 'Late',    value: stat.late.toString(), color: AppColors.warningOrange, icon: Icons.access_time),
              _StatItem(label: 'Total Days', value: _fmt(stat.totalDays), color: AppColors.primary, icon: Icons.calendar_month_outlined),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatItem({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20.sp, color: color),
        AppSpacing.vs,
        Text(value, style: AppTypography.h6.copyWith(color: color, fontSize: 16.sp)),
        AppSpacing.vs,
        Text(label, style: AppTypography.caption.copyWith(color: AppColors.grey5E, fontSize: 10.sp)),
      ],
    );
  }
}



// ─── Simple Bar Chart ────────────────────────────────────────────────────────

class _AttendanceBarChart extends StatelessWidget {
  final dynamic stat;

  const _AttendanceBarChart({required this.stat});

  @override
  Widget build(BuildContext context) {
    final total = stat.present + stat.absent + (stat.late as int);
    if (total == 0) return const SizedBox.shrink();

    final presentFrac = stat.present / total;
    final absentFrac = stat.absent / total;
    final lateFrac = stat.late / total;

    return Container(
      padding: AppPadding.pM,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.m),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attendance Breakdown',
            style: AppTypography.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          AppSpacing.vm,
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xs),
            child: Row(
              children: [
                _Bar(flex: (presentFrac * 100).round(), color: AppColors.successGreen),
                _Bar(flex: (lateFrac * 100).round(), color: AppColors.warningOrange),
                _Bar(flex: (absentFrac * 100).round(), color: AppColors.errorRed),
              ],
            ),
          ),
          AppSpacing.vs,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Legend(color: AppColors.successGreen, label: 'Present'),
              _Legend(color: AppColors.warningOrange, label: 'Late'),
              _Legend(color: AppColors.errorRed, label: 'Absent'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final int flex;
  final Color color;
  const _Bar({required this.flex, required this.color});

  @override
  Widget build(BuildContext context) {
    if (flex == 0) return const SizedBox.shrink();
    return Flexible(
      flex: flex,
      child: Container(height: 18.h, color: color),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10.w, height: 10.w, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: 4.w),
        Text(label, style: AppTypography.caption.copyWith(color: AppColors.grey5E, fontSize: 10.sp)),
      ],
    );
  }
}