import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/features/modules/parent/view_time_table/screens/parent_table.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/utils/loader/customLoader.dart';
import '../../../teacher/timetable/presentation/provider/timetable_provider.dart';
import '../../../teacher/timetable/presentation/widgets/timetable_table.dart';


class StudentTimetableScreen extends StatefulWidget {
  final String academicId;
  final String standard;
  final String division;

  const StudentTimetableScreen({
    super.key,
    required this.academicId,
    required this.standard,
    required this.division,
  });

  @override
  State<StudentTimetableScreen> createState() =>
      _StudentTimetableScreenState();
}

class _StudentTimetableScreenState extends State<StudentTimetableScreen>
    with SingleTickerProviderStateMixin {
  // Index 0 = full table view, 1 = day view
  int _viewMode = 0;
  int _selectedDayIndex = _todayIndex();

  static int _todayIndex() {
    // Mon=0 … Fri=4; weekend defaults to Mon
    final w = DateTime.now().weekday; // 1=Mon … 7=Sun
    return (w >= 1 && w <= 5) ? w - 1 : 0;
  }

  static const List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  static const List<String> _fullDays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TimetableProvider>().fetchTimetable(
        widget.standard,
        widget.division,
        widget.academicId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Consumer<TimetableProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.timetable == null) {
                  return const Center(child: CustomLoader());
                }
                if (provider.timetable == null) {
                  return _buildEmpty();
                }
                return _viewMode == 0
                    ? _buildFullTable()
                    : _buildDayView(provider);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primary, Color(0xFF002D62)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28.r),
          bottomRight: Radius.circular(28.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Nav row ──────────────────────────────────────────────────
              Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(9.r),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 14),
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // Class icon
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3), width: 1.5),
                    ),
                    child: Icon(Icons.grid_view_rounded,
                        color: Colors.white, size: 17.sp),
                  ),

                  SizedBox(width: 10.w),

                  // Class info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Class ${widget.standard}-${widget.division}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          "Timetable",
                          style: TextStyle(
                              color: Colors.white60,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),

                  // Today chip
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.2), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.today_rounded,
                            color: Colors.white70, size: 12.sp),
                        SizedBox(width: 4.w),
                        Text(
                          _fullDays[_todayIndex()],
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 14.h),

              // ── View toggle + day selector row ───────────────────────────
              Row(
                children: [
                  // Table / Day toggle pill
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ViewToggleBtn(
                          icon: Icons.table_chart_outlined,
                          label: "Table",
                          active: _viewMode == 0,
                          onTap: () => setState(() => _viewMode = 0),
                        ),
                        SizedBox(width: 2.w),
                        _ViewToggleBtn(
                          icon: Icons.view_day_outlined,
                          label: "Day",
                          active: _viewMode == 1,
                          onTap: () => setState(() => _viewMode = 1),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 10.w),

                  // Day selector (only visible in Day view)
                  if (_viewMode == 1)
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: List.generate(_days.length, (i) {
                            final isToday = i == _todayIndex();
                            final isSelected = i == _selectedDayIndex;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedDayIndex = i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: EdgeInsets.only(right: 6.w),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: isToday
                                      ? Border.all(
                                      color: Colors.amber, width: 1.5)
                                      : null,
                                ),
                                child: Text(
                                  _days[i],
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.white70,
                                    fontSize: 12.sp,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Full table view (reuses existing widget, read-only) ───────────────────
  Widget _buildFullTable() {
    return const Padding(
      padding: EdgeInsets.only(top: 8),
      child: ParentTableView(),
    );
  }

  // ── Day view ─────────────────────────────────────────────────────────────────
  Widget _buildDayView(TimetableProvider provider) {
    final timetable = provider.timetable!;
    final dayName = _fullDays[_selectedDayIndex];

    // Access by day name key, falls back to empty list
    final periods = timetable.timetable[dayName] ?? [];

    final isToday = _selectedDayIndex == _todayIndex();

    if (periods.isEmpty) {
      return _buildEmpty();
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 40.h),
      physics: const BouncingScrollPhysics(),
      itemCount: periods.length + 1,
      itemBuilder: (context, index) {
        // ── Section header ────────────────────────────────────────────────
        if (index == 0) {
          return Padding(
            padding: EdgeInsets.only(bottom: 14.h),
            child: Row(
              children: [
                Text(
                  dayName,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(width: 8.w),
                if (isToday)
                  Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                          color: Colors.amber.withOpacity(0.4), width: 1),
                    ),
                    child: Text(
                      "Today",
                      style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.amber.shade700),
                    ),
                  ),
                const Spacer(),
                Text(
                  "${periods.length} periods",
                  style: TextStyle(
                      fontSize: 11.sp, color: const Color(0xFF94A3B8)),
                ),
              ],
            ),
          );
        }

        // ── Period card ───────────────────────────────────────────────────
        final periodIndex = index - 1;
        final subject = periods[periodIndex];
        final periodNum = periodIndex + 1;
        final isEmpty = subject.trim().isEmpty;

        const palette = [
          Color(0xFF3949AB),
          Color(0xFF00897B),
          Color(0xFFC62828),
          Color(0xFF6A1B9A),
          Color(0xFF1565C0),
          Color(0xFF2E7D32),
          Color(0xFFC97B00),
        ];
        final accent = palette[periodIndex % palette.length];

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 240 + periodIndex * 45),
          curve: Curves.easeOut,
          builder: (_, value, child) => Transform.translate(
            offset: Offset(0, 12 * (1 - value)),
            child: Opacity(opacity: value, child: child),
          ),
          child: Container(
            margin: EdgeInsets.only(bottom: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Accent bar
                  Container(
                    width: 4.w,
                    decoration: BoxDecoration(
                      color: isEmpty
                          ? const Color(0xFFE2E8F0)
                          : accent,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(14.r),
                        bottomLeft: Radius.circular(14.r),
                      ),
                    ),
                  ),

                  // Period number badge
                  SizedBox(width: 12.w),
                  Container(
                    width: 30.w,
                    height: 30.w,
                    decoration: BoxDecoration(
                      color: isEmpty
                          ? const Color(0xFFF1F5F9)
                          : accent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "$periodNum",
                      style: TextStyle(
                        color: isEmpty
                            ? const Color(0xFFCBD5E1)
                            : accent,
                        fontWeight: FontWeight.w800,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // Subject
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      child: Text(
                        isEmpty ? "Free Period" : subject,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: isEmpty
                              ? FontWeight.w400
                              : FontWeight.w700,
                          color: isEmpty
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFF0F172A),
                          fontStyle: isEmpty
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                      ),
                    ),
                  ),

                  // Period label chip
                  Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: isEmpty
                            ? const Color(0xFFF1F5F9)
                            : accent.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        "P$periodNum",
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: isEmpty
                              ? const Color(0xFFCBD5E1)
                              : accent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  // ── Empty state ───────────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.grid_off_rounded,
                size: 28.sp, color: AppColors.primary),
          ),
          SizedBox(height: 12.h),
          Text(
            "No Timetable Found",
            style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E)),
          ),
          SizedBox(height: 4.h),
          Text(
            "Contact your class teacher.",
            style:
            TextStyle(fontSize: 12.sp, color: const Color(0xFF9E9E9E)),
          ),
        ],
      ),
    );
  }
}

// ─── View toggle button ───────────────────────────────────────────────────────
class _ViewToggleBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ViewToggleBtn({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 13.sp,
                color: active ? AppColors.primary : Colors.white60),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight:
                active ? FontWeight.w700 : FontWeight.w500,
                color: active ? AppColors.primary : Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}