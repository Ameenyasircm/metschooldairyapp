import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../teacher/punctuality/data/models/PunctualityModel.dart';
import '../../teacher/students/data/models/tech_student_model.dart';
import '../../teacher/students/presentation/provider/student_provider.dart';


// ─── Code → visual config (same as student screen) ───────────────────────────
class _CodeStyle {
  final Color bg;
  final Color text;
  final IconData icon;
  const _CodeStyle({required this.bg, required this.text, required this.icon});
}

const Map<String, _CodeStyle> _codeStyles = {
  'AWL': _CodeStyle(bg: Color(0xFFFFECEC), text: Color(0xFFD94040), icon: Icons.cancel_outlined),
  'CC':  _CodeStyle(bg: Color(0xFFFFF3DC), text: Color(0xFFC97B00), icon: Icons.warning_amber_rounded),
  'IU':  _CodeStyle(bg: Color(0xFFE3F2FD), text: Color(0xFF1565C0), icon: Icons.checkroom_outlined),
  'BNB': _CodeStyle(bg: Color(0xFFF3E5F5), text: Color(0xFF6A1B9A), icon: Icons.menu_book_outlined),
  'HND': _CodeStyle(bg: Color(0xFFFFECEC), text: Color(0xFFB71C1C), icon: Icons.assignment_late_outlined),
  'LC':  _CodeStyle(bg: Color(0xFFFCE4EC), text: Color(0xFFC62828), icon: Icons.schedule_outlined),
  'OTP': _CodeStyle(bg: Color(0xFFE8F5E9), text: Color(0xFF2E7D32), icon: Icons.alarm_on_outlined),
  'EW':  _CodeStyle(bg: Color(0xFFF1F8E9), text: Color(0xFF33691E), icon: Icons.star_outline_rounded),
  'GC':  _CodeStyle(bg: Color(0xFFE0F7FA), text: Color(0xFF006064), icon: Icons.sentiment_very_satisfied_outlined),
  'HL':  _CodeStyle(bg: Color(0xFFFFF8E1), text: Color(0xFFFF6F00), icon: Icons.emoji_events_outlined),
  'HWD': _CodeStyle(bg: Color(0xFFE8EAF6), text: Color(0xFF283593), icon: Icons.task_alt_outlined),
  'PU':  _CodeStyle(bg: Color(0xFFE0F2F1), text: Color(0xFF00695C), icon: Icons.checkroom_outlined),
};

_CodeStyle _styleFor(String code) =>
    _codeStyles[code] ??
        const _CodeStyle(bg: Color(0xFFEEF2FF), text: Color(0xFF3949AB), icon: Icons.circle_outlined);

// ─── Date filter enum ─────────────────────────────────────────────────────────
enum _DateFilter { today, week, month, all }

extension _DateFilterLabel on _DateFilter {
  String get label {
    switch (this) {
      case _DateFilter.today: return 'Today';
      case _DateFilter.week:  return 'This Week';
      case _DateFilter.month: return 'This Month';
      case _DateFilter.all:   return 'All Time';
    }
  }
}

// ─── Type filter enum ─────────────────────────────────────────────────────────
enum _TypeFilter { all, positive, negative }

// ─── Parent Punctuality Screen (View Only) ────────────────────────────────────
class ParentPunctualityScreen extends StatefulWidget {
  final EnrollerModel student;
  const ParentPunctualityScreen({super.key, required this.student});

  @override
  State<ParentPunctualityScreen> createState() => _ParentPunctualityScreenState();
}

class _ParentPunctualityScreenState extends State<ParentPunctualityScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  _DateFilter _dateFilter = _DateFilter.all;
  _TypeFilter _typeFilter = _TypeFilter.all;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    Future.microtask(() =>
        context.read<StudentProvider>().fetchStudentRecords(widget.student.studentId));
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  String get _initials {
    final parts = widget.student.name.trim().split(' ');
    return parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : widget.student.name.substring(0, 2).toUpperCase();
  }

  List<dynamic> _applyFilters(List<dynamic> records) {
    final now = DateTime.now();
    return records.where((r) {
      final date = r.date as DateTime;
      final passDate = switch (_dateFilter) {
        _DateFilter.today => date.year == now.year && date.month == now.month && date.day == now.day,
        _DateFilter.week  => date.isAfter(now.subtract(const Duration(days: 7))),
        _DateFilter.month => date.year == now.year && date.month == now.month,
        _DateFilter.all   => true,
      };
      final passType = switch (_typeFilter) {
        _TypeFilter.all      => true,
        _TypeFilter.positive => r.isPositive as bool,
        _TypeFilter.negative => !(r.isPositive as bool),
      };
      return passDate && passType;
    }).toList();
  }

  List<dynamic> _groupByDate(List<dynamic> records) {
    if (records.isEmpty) return [];
    final now = DateTime.now();

    String label(DateTime d) {
      if (d.year == now.year && d.month == now.month && d.day == now.day) return 'Today';
      final yesterday = now.subtract(const Duration(days: 1));
      if (d.year == yesterday.year && d.month == yesterday.month && d.day == yesterday.day) return 'Yesterday';
      return "${d.day.toString().padLeft(2, '0')} ${_monthName(d.month)} ${d.year}";
    }

    final grouped = <dynamic>[];
    String? lastLabel;
    for (final r in records) {
      final lbl = label(r.date as DateTime);
      if (lbl != lastLabel) {
        grouped.add(lbl);
        lastLabel = lbl;
      }
      grouped.add(r);
    }
    return grouped;
  }

  String _monthName(int m) =>
      ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m - 1];

  @override
  Widget build(BuildContext context) {
    final provider    = context.watch<StudentProvider>();
    final allRecords  = provider.records;
    final filtered    = _applyFilters(allRecords);
    final grouped     = _groupByDate(filtered);

    final totalScore  = allRecords.fold<int>(0, (s, r) => s + (r.point as int));
    final filteredPos = filtered.where((r) => r.isPositive as bool).length;
    final filteredNeg = filtered.where((r) => !(r.isPositive as bool)).length;

    // Compute stats for the summary cards
    final totalPos   = allRecords.where((r) => r.isPositive as bool).length;
    final totalNeg   = allRecords.where((r) => !(r.isPositive as bool)).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(children: [
          // ── Header ────────────────────────────────────────────────────────
          _ParentHeader(
            initials:    _initials,
            student:     widget.student,
            totalScore:  totalScore,
            totalPos:    totalPos,
            totalNeg:    totalNeg,
            onBack:      () => Navigator.pop(context),
          ),

          // ── Filter bar ────────────────────────────────────────────────────
          _FilterBar(
            dateFilter:    _dateFilter,
            typeFilter:    _typeFilter,
            filteredCount: filtered.length,
            posCount:      filteredPos,
            negCount:      filteredNeg,
            onDateChanged: (f) => setState(() => _dateFilter = f),
            onTypeChanged: (f) => setState(() => _typeFilter = f),
          ),

          // ── Record list ───────────────────────────────────────────────────
          Expanded(
            child: provider.isRecordsLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                ? _EmptyState(
                isFiltered: _dateFilter != _DateFilter.all || _typeFilter != _TypeFilter.all)
                : ListView.builder(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
              physics: const BouncingScrollPhysics(),
              itemCount: grouped.length,
              itemBuilder: (ctx, i) {
                final item = grouped[i];
                if (item is String) return _DateHeader(label: item);
                return _RecordCard(record: item, index: i);
              },
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── Parent Header (with summary stat cards) ──────────────────────────────────
class _ParentHeader extends StatelessWidget {
  final String initials;
  final EnrollerModel student;
  final int totalScore, totalPos, totalNeg;
  final VoidCallback onBack;

  const _ParentHeader({
    required this.initials,
    required this.student,
    required this.totalScore,
    required this.totalPos,
    required this.totalNeg,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isPos      = totalScore >= 0;
    final scoreColor = isPos ? const Color(0xFF4CAF50) : const Color(0xFFEF5350);
    final scoreLabel = isPos ? '+$totalScore' : '$totalScore';
    final scoreBg    = isPos ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primary, Color(0xFF002D62)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withOpacity(0.22),
              blurRadius: 14,
              offset: const Offset(0, 6)),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── Top row: back + avatar + name + score ──────────────────────
            Row(children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 34.w, height: 34.w,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10.r)),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 15),
                ),
              ),
              SizedBox(width: 12.w),

              // Avatar
              Container(
                width: 38.w, height: 38.w,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withOpacity(0.35), width: 1.5)),
                alignment: Alignment.center,
                child: Text(initials,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13.sp)),
              ),
              SizedBox(width: 12.w),

              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(student.name,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2),
                          overflow: TextOverflow.ellipsis),
                      Text("Punctuality Report",
                          style: TextStyle(
                              color: Colors.white60, fontSize: 10.sp)),
                    ]),
              ),

              SizedBox(width: 10.w),

              // Score badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                    color: scoreBg,
                    borderRadius: BorderRadius.circular(14.r)),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(scoreLabel,
                      style: TextStyle(
                          color: scoreColor,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                          height: 1.1)),
                  Text("SCORE",
                      style: TextStyle(
                          color: scoreColor.withOpacity(0.7),
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8)),
                ]),
              ),
            ]),

            SizedBox(height: 14.h),

            // ── Summary stat cards (parent-specific) ───────────────────────
            Row(children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.thumb_up_alt_outlined,
                  label: "Positive",
                  value: '+$totalPos',
                  color: const Color(0xFF2E7D32),
                  bg: const Color(0xFFE8F5E9),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _StatCard(
                  icon: Icons.thumb_down_alt_outlined,
                  label: "Negative",
                  value: '-$totalNeg',
                  color: const Color(0xFFD94040),
                  bg: const Color(0xFFFFECEC),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _StatCard(
                  icon: Icons.bar_chart_rounded,
                  label: "Total",
                  value: '${totalPos + totalNeg}',
                  color: const Color(0xFF1565C0),
                  bg: const Color(0xFFE3F2FD),
                ),
              ),
            ]),

            // ── View-only notice ───────────────────────────────────────────
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(8.r)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.lock_outline_rounded,
                    color: Colors.white60, size: 11.sp),
                SizedBox(width: 5.w),
                Text("View only – managed by the school",
                    style: TextStyle(
                        color: Colors.white60,
                        fontSize: 10.sp,
                        fontStyle: FontStyle.italic)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─── Small stat card inside header ───────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color, bg;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(12.r)),
      child: Row(children: [
        Icon(icon, color: color, size: 14.sp),
        SizedBox(width: 6.w),
        Column(crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, children: [
              Text(value,
                  style: TextStyle(
                      color: color, fontSize: 14.sp, fontWeight: FontWeight.w900, height: 1.1)),
              Text(label,
                  style: TextStyle(
                      color: color.withOpacity(0.7), fontSize: 9.sp, fontWeight: FontWeight.w600)),
            ]),
      ]),
    );
  }
}

// ─── Filter bar (same as student screen, no logic changes) ───────────────────
class _FilterBar extends StatelessWidget {
  final _DateFilter dateFilter;
  final _TypeFilter typeFilter;
  final int filteredCount, posCount, negCount;
  final ValueChanged<_DateFilter> onDateChanged;
  final ValueChanged<_TypeFilter> onTypeChanged;

  const _FilterBar({
    required this.dateFilter,
    required this.typeFilter,
    required this.filteredCount,
    required this.posCount,
    required this.negCount,
    required this.onDateChanged,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(height: 12.h),

        // Date filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(children: _DateFilter.values.map((f) {
            final active = f == dateFilter;
            return GestureDetector(
              onTap: () => onDateChanged(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: EdgeInsets.only(right: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                      color: active ? AppColors.primary : const Color(0xFFE2E8F0),
                      width: 1),
                  boxShadow: active
                      ? [BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2))]
                      : [],
                ),
                child: Text(f.label,
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: active ? Colors.white : const Color(0xFF64748B))),
              ),
            );
          }).toList()),
        ),

        SizedBox(height: 10.h),

        // Type toggle + summary
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(children: [
            Container(
              decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10.r)),
              padding: EdgeInsets.all(3.w),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                _TypeChip(
                    label: 'All',
                    active: typeFilter == _TypeFilter.all,
                    color: AppColors.primary,
                    onTap: () => onTypeChanged(_TypeFilter.all)),
                _TypeChip(
                    label: '＋ Pos',
                    active: typeFilter == _TypeFilter.positive,
                    color: const Color(0xFF2E7D32),
                    onTap: () => onTypeChanged(_TypeFilter.positive)),
                _TypeChip(
                    label: '－ Neg',
                    active: typeFilter == _TypeFilter.negative,
                    color: const Color(0xFFD94040),
                    onTap: () => onTypeChanged(_TypeFilter.negative)),
              ]),
            ),

            const Spacer(),

            Row(children: [
              _SummaryChip(count: posCount, color: const Color(0xFF2E7D32),
                  bg: const Color(0xFFE8F5E9), prefix: '+'),
              SizedBox(width: 6.w),
              _SummaryChip(count: negCount, color: const Color(0xFFD94040),
                  bg: const Color(0xFFFFECEC), prefix: '-'),
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8.r)),
                child: Text("$filteredCount total",
                    style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B))),
              ),
            ]),
          ]),
        ),

        SizedBox(height: 10.h),
        Divider(height: 1, color: const Color(0xFFE9EEF4)),
      ]),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;
  const _TypeChip({required this.label, required this.active, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 6.h),
        decoration: BoxDecoration(
            color: active ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r)),
        child: Text(label,
            style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : const Color(0xFF94A3B8))),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final int count;
  final Color color, bg;
  final String prefix;
  const _SummaryChip({required this.count, required this.color, required this.bg, required this.prefix});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8.r)),
      child: Text("$prefix$count",
          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

// ─── Date section header ──────────────────────────────────────────────────────
class _DateHeader extends StatelessWidget {
  final String label;
  const _DateHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 14.h, bottom: 8.h),
      child: Row(children: [
        Text(label,
            style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF64748B),
                letterSpacing: 0.3)),
        SizedBox(width: 8.w),
        Expanded(child: Container(height: 1, color: const Color(0xFFE9EEF4))),
      ]),
    );
  }
}

// ─── Record card (read-only, no swipe/tap actions) ───────────────────────────
class _RecordCard extends StatelessWidget {
  final dynamic record;
  final int index;
  const _RecordCard({required this.record, required this.index});

  @override
  Widget build(BuildContext context) {
    final style      = _styleFor(record.code);
    final isPositive = record.isPositive as bool;
    final point      = record.point as int;
    final chipColor  = isPositive ? const Color(0xFF2E7D32) : const Color(0xFFD94040);
    final chipBg     = isPositive ? const Color(0xFFE8F5E9) : const Color(0xFFFFECEC);
    final pointLabel = isPositive ? '+$point' : '$point';
    final codeName   =
        (isPositive ? PunctualityCodes.positive : PunctualityCodes.negative)[record.code] ?? '';

    // Format the time if available
    final date      = record.date as DateTime;
    final timeLabel = "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 220 + (index % 10) * 35),
      curve: Curves.easeOut,
      builder: (_, v, child) => Transform.translate(
          offset: Offset(0, 10 * (1 - v)),
          child: Opacity(opacity: v, child: child)),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: IntrinsicHeight(
          child: Row(children: [
            // Color accent bar
            Container(
              width: 4.w,
              decoration: BoxDecoration(
                  color: style.text,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(14.r),
                      bottomLeft: Radius.circular(14.r))),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                child: Row(children: [
                  // Icon box
                  Container(
                    width: 42.w, height: 42.w,
                    decoration: BoxDecoration(
                        color: style.bg,
                        borderRadius: BorderRadius.circular(11.r)),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(style.icon, color: style.text, size: 15.sp),
                      SizedBox(height: 2.h),
                      Text(record.code,
                          style: TextStyle(
                              color: style.text,
                              fontWeight: FontWeight.w800,
                              fontSize: 8.5.sp)),
                    ]),
                  ),
                  SizedBox(width: 11.w),

                  // Text block
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(codeName,
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1A1A2E)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          SizedBox(height: 2.h),
                          if ((record.remark as String).isNotEmpty)
                            Text(record.remark,
                                style: TextStyle(
                                    fontSize: 11.sp,
                                    color: const Color(0xFF64748B)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          SizedBox(height: 3.h),
                          // Time label — useful context for parents
                          Row(children: [
                            Icon(Icons.access_time_rounded,
                                size: 9.sp, color: const Color(0xFFB0BEC5)),
                            SizedBox(width: 3.w),
                            Text(timeLabel,
                                style: TextStyle(
                                    fontSize: 9.5.sp,
                                    color: const Color(0xFFB0BEC5),
                                    fontWeight: FontWeight.w500)),
                          ]),
                        ]),
                  ),
                  SizedBox(width: 8.w),

                  // Point chip
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                    decoration: BoxDecoration(
                        color: chipBg, borderRadius: BorderRadius.circular(9.r)),
                    child: Text(pointLabel,
                        style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w900,
                            color: chipColor)),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isFiltered;
  const _EmptyState({required this.isFiltered});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 64.w, height: 64.w,
        decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            shape: BoxShape.circle),
        child: Icon(
          isFiltered ? Icons.filter_list_off_rounded : Icons.event_note_outlined,
          size: 28.sp, color: AppColors.primary,
        ),
      ),
      SizedBox(height: 12.h),
      Text(
        isFiltered ? "No records match filters" : "No Records Yet",
        style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E)),
      ),
      SizedBox(height: 4.h),
      Text(
        isFiltered
            ? "Try changing the date or type filter."
            : "Your child's records will appear here.",
        style: TextStyle(fontSize: 12.sp, color: const Color(0xFF9E9E9E)),
      ),
    ]),
  );
}