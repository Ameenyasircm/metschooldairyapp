import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../students/data/models/tech_student_model.dart';
import '../models/PunctualityModel.dart';
import '../../../students/presentation/provider/student_provider.dart';

// ─── Code → visual config ─────────────────────────────────────────────────────
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

// ─── Screen ───────────────────────────────────────────────────────────────────
class StudentPunctualityScreen extends StatefulWidget {
  final EnrollerModel student;
  const StudentPunctualityScreen({super.key, required this.student});

  @override
  State<StudentPunctualityScreen> createState() => _StudentPunctualityScreenState();
}

class _StudentPunctualityScreenState extends State<StudentPunctualityScreen>
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
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  String get _initials {
    final parts = widget.student.name.trim().split(' ');
    return parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : widget.student.name.substring(0, 2).toUpperCase();
  }

  // ── Filter logic ─────────────────────────────────────────────────────────────
  List<dynamic> _applyFilters(List<dynamic> records) {
    final now = DateTime.now();
    return records.where((r) {
      final date = r.date as DateTime;

      // Date filter
      final passDate = switch (_dateFilter) {
        _DateFilter.today => date.year == now.year && date.month == now.month && date.day == now.day,
        _DateFilter.week  => date.isAfter(now.subtract(const Duration(days: 7))),
        _DateFilter.month => date.year == now.year && date.month == now.month,
        _DateFilter.all   => true,
      };

      // Type filter
      final passType = switch (_typeFilter) {
        _TypeFilter.all      => true,
        _TypeFilter.positive => r.isPositive as bool,
        _TypeFilter.negative => !(r.isPositive as bool),
      };

      return passDate && passType;
    }).toList();
  }

  // ── Group records by date label ───────────────────────────────────────────
  // Returns a list of either String (date header) or record
  List<dynamic> _groupByDate(List<dynamic> records) {
    if (records.isEmpty) return [];
    final now = DateTime.now();

    String _label(DateTime d) {
      if (d.year == now.year && d.month == now.month && d.day == now.day) return 'Today';
      final yesterday = now.subtract(const Duration(days: 1));
      if (d.year == yesterday.year && d.month == yesterday.month && d.day == yesterday.day) return 'Yesterday';
      return "${d.day.toString().padLeft(2, '0')} ${_monthName(d.month)} ${d.year}";
    }

    final grouped = <dynamic>[];
    String? lastLabel;
    for (final r in records) {
      final label = _label(r.date as DateTime);
      if (label != lastLabel) {
        grouped.add(label); // date header
        lastLabel = label;
      }
      grouped.add(r);
    }
    return grouped;
  }

  String _monthName(int m) =>
      ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m - 1];

  @override
  Widget build(BuildContext context) {
    final provider  = context.watch<StudentProvider>();
    final allRecords = provider.records;
    final filtered  = _applyFilters(allRecords);
    final grouped   = _groupByDate(filtered);

    // Score from ALL records (not filtered) — shows true running total
    final totalScore = allRecords.fold<int>(0, (s, r) => s + (r.point as int));
    // Filtered stats
    final filteredPos = filtered.where((r) => r.isPositive as bool).length;
    final filteredNeg = filtered.where((r) => !(r.isPositive as bool)).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(children: [
          // ── Compact header ─────────────────────────────────────────────────
          _CompactHeader(
            initials:   _initials,
            student:    widget.student,
            totalScore: totalScore,
            onBack:     () => Navigator.pop(context),
          ),

          // ── Sticky filter bar ──────────────────────────────────────────────
          _FilterBar(
            dateFilter:    _dateFilter,
            typeFilter:    _typeFilter,
            filteredCount: filtered.length,
            posCount:      filteredPos,
            negCount:      filteredNeg,
            onDateChanged: (f) => setState(() => _dateFilter = f),
            onTypeChanged: (f) => setState(() => _typeFilter = f),
          ),

          // ── Records ────────────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? _EmptyState(isFiltered: _dateFilter != _DateFilter.all || _typeFilter != _TypeFilter.all)
                : ListView.builder(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 90.h),
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text("Add Record",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14.sp)),
        onPressed: _showAddDialog,
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => _AddRecordDialog(
        student: widget.student,
        onSaved: (code, remark, date) async {
          await context.read<StudentProvider>().addRecord(
            student: widget.student, code: code, remark: remark, date: date,
          );
        },
      ),
    );
  }
}

// ─── Compact header — score only ─────────────────────────────────────────────
class _CompactHeader extends StatelessWidget {
  final String initials;
  final EnrollerModel student;
  final int totalScore;
  final VoidCallback onBack;

  const _CompactHeader({
    required this.initials,
    required this.student,
    required this.totalScore,
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
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.22), blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
          child: Row(children: [
            // Back
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 34.w, height: 34.w,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10.r)),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 15),
              ),
            ),
            SizedBox(width: 12.w),

            // Avatar
            Container(
              width: 38.w, height: 38.w,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.5)),
              alignment: Alignment.center,
              child: Text(initials,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13.sp)),
            ),
            SizedBox(width: 12.w),

            // Name + subtitle
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text(student.name,
                    style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w700, letterSpacing: -0.2),
                    overflow: TextOverflow.ellipsis),
                Text("Punctuality Tracker",
                    style: TextStyle(color: Colors.white60, fontSize: 10.sp)),
              ]),
            ),

            SizedBox(width: 10.w),

            // ── Score — the ONLY stat in header ────────────────────────────
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: scoreBg,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(scoreLabel,
                    style: TextStyle(
                        color: scoreColor, fontSize: 18.sp, fontWeight: FontWeight.w900, height: 1.1)),
                Text("SCORE",
                    style: TextStyle(color: scoreColor.withOpacity(0.7), fontSize: 8.sp, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─── Filter bar ───────────────────────────────────────────────────────────────
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

        // ── Date filter row ────────────────────────────────────────────────
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
                      color: active ? AppColors.primary : const Color(0xFFE2E8F0), width: 1),
                  boxShadow: active ? [
                    BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 6, offset: const Offset(0, 2)),
                  ] : [],
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

        // ── Type filter + result summary ───────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(children: [
            // All / + / - toggle
            Container(
              decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10.r)),
              padding: EdgeInsets.all(3.w),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                _TypeChip(label: 'All',      active: typeFilter == _TypeFilter.all,      color: AppColors.primary,         onTap: () => onTypeChanged(_TypeFilter.all)),
                _TypeChip(label: '＋ Pos',   active: typeFilter == _TypeFilter.positive, color: const Color(0xFF2E7D32),   onTap: () => onTypeChanged(_TypeFilter.positive)),
                _TypeChip(label: '－ Neg',   active: typeFilter == _TypeFilter.negative, color: const Color(0xFFD94040),   onTap: () => onTypeChanged(_TypeFilter.negative)),
              ]),
            ),

            const Spacer(),

            // Result summary
            Row(children: [
              _SummaryChip(count: posCount, color: const Color(0xFF2E7D32), bg: const Color(0xFFE8F5E9), prefix: '+'),
              SizedBox(width: 6.w),
              _SummaryChip(count: negCount, color: const Color(0xFFD94040), bg: const Color(0xFFFFECEC), prefix: '-'),
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8.r)),
                child: Text("$filteredCount total",
                    style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
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
                fontSize: 11.sp, fontWeight: FontWeight.w700,
                color: const Color(0xFF64748B), letterSpacing: 0.3)),
        SizedBox(width: 8.w),
        Expanded(child: Container(height: 1, color: const Color(0xFFE9EEF4))),
      ]),
    );
  }
}

// ─── Record card ──────────────────────────────────────────────────────────────
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
    final codeName   = (isPositive ? PunctualityCodes.positive : PunctualityCodes.negative)[record.code] ?? '';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 220 + (index % 10) * 35),
      curve: Curves.easeOut,
      builder: (_, v, child) =>
          Transform.translate(offset: Offset(0, 10 * (1 - v)), child: Opacity(opacity: v, child: child)),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: IntrinsicHeight(
          child: Row(children: [
            // Color accent bar
            Container(
              width: 4.w,
              decoration: BoxDecoration(
                  color: style.text,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(14.r), bottomLeft: Radius.circular(14.r))),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                child: Row(children: [
                  // Icon box
                  Container(
                    width: 42.w, height: 42.w,
                    decoration: BoxDecoration(color: style.bg, borderRadius: BorderRadius.circular(11.r)),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(style.icon, color: style.text, size: 15.sp),
                      SizedBox(height: 2.h),
                      Text(record.code,
                          style: TextStyle(color: style.text, fontWeight: FontWeight.w800, fontSize: 8.5.sp)),
                    ]),
                  ),
                  SizedBox(width: 11.w),

                  // Text block
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center, children: [
                          // Code name
                          Text(codeName,
                              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E)),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          SizedBox(height: 2.h),
                          // Remark
                          if ((record.remark as String).isNotEmpty)
                            Text(record.remark,
                                style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B)),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                        ]),
                  ),
                  SizedBox(width: 8.w),

                  // Point chip
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                    decoration: BoxDecoration(color: chipBg, borderRadius: BorderRadius.circular(9.r)),
                    child: Text(pointLabel,
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w900, color: chipColor)),
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
        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), shape: BoxShape.circle),
        child: Icon(
          isFiltered ? Icons.filter_list_off_rounded : Icons.event_note_outlined,
          size: 28.sp, color: AppColors.primary,
        ),
      ),
      SizedBox(height: 12.h),
      Text(isFiltered ? "No records match filters" : "No Records Yet",
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
      SizedBox(height: 4.h),
      Text(isFiltered ? "Try changing the date or type filter." : "Tap '+ Add Record' to get started.",
          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF9E9E9E))),
    ]),
  );
}

// ─── Add Record Dialog ────────────────────────────────────────────────────────
// (unchanged from previous — keep your existing _AddRecordDialog, _AddRecordDialogState, _ToggleBtn)

// ─── Toggle button widget ─────────────────────────────────────────────────────
class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;
  const _ToggleBtn({required this.label, required this.active,
    required this.activeColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 9.h),
          decoration: BoxDecoration(
              color: active ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: active
                  ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2))]
                  : []),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: active ? activeColor : const Color(0xFF94A3B8))),
        ),
      ),
    );
  }
}



// ─── Add Record Dialog — with Positive / Negative toggle ─────────────────────
class _AddRecordDialog extends StatefulWidget {
  final EnrollerModel student;
  final Future<void> Function(String code, String remark, DateTime date) onSaved;
  const _AddRecordDialog({required this.student, required this.onSaved});

  @override
  State<_AddRecordDialog> createState() => _AddRecordDialogState();
}

class _AddRecordDialogState extends State<_AddRecordDialog> {
  bool _showPositive      = false;   // which tab is active
  late String _selectedCode;
  DateTime _selectedDate  = DateTime.now();
  final _remarkCtrl       = TextEditingController();
  bool _saving            = false;

  @override
  void initState() {
    super.initState();
    _selectedCode = PunctualityCodes.negative.keys.first;
  }

  Map<String, String> get _activeCodes =>
      _showPositive ? PunctualityCodes.positive : PunctualityCodes.negative;

  String get _formattedDate =>
      "${_selectedDate.day.toString().padLeft(2, '0')}/"
          "${_selectedDate.month.toString().padLeft(2, '0')}/"
          "${_selectedDate.year}";

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await widget.onSaved(_selectedCode, _remarkCtrl.text, _selectedDate);
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() { _remarkCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final style      = _styleFor(_selectedCode);
    final isPositive = PunctualityCodes.isPositive(_selectedCode);
    final pointLabel = isPositive ? '+1' : '-1';
    final pointColor = isPositive ? const Color(0xFF2E7D32) : const Color(0xFFD94040);
    final pointBg    = isPositive ? const Color(0xFFE8F5E9) : const Color(0xFFFFECEC);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
      child: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [

              // ── Dialog header ────────────────────────────────────────────
              Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("Add Record",
                        style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A), letterSpacing: -0.3)),
                    SizedBox(height: 1.h),
                    Text(widget.student.name,
                        style: TextStyle(fontSize: 11.sp, color: const Color(0xFF9E9E9E), fontWeight: FontWeight.w500)),
                  ]),
                ),
                // Live code badge
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                  decoration: BoxDecoration(
                      color: style.bg,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: style.text.withOpacity(0.25), width: 1)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(style.icon, color: style.text, size: 12.sp),
                    SizedBox(width: 4.w),
                    Text(_selectedCode,
                        style: TextStyle(color: style.text, fontWeight: FontWeight.w800, fontSize: 11.sp)),
                  ]),
                ),
                SizedBox(width: 6.w),
                // Point chip
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 5.h),
                  decoration: BoxDecoration(color: pointBg, borderRadius: BorderRadius.circular(8.r)),
                  child: Text(pointLabel,
                      style: TextStyle(color: pointColor, fontSize: 12.sp, fontWeight: FontWeight.w800)),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 28.w, height: 28.w,
                    decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                    child: Icon(Icons.close_rounded, size: 15.sp, color: const Color(0xFF64748B)),
                  ),
                ),
              ]),

              SizedBox(height: 16.h),

              // ── Positive / Negative toggle ───────────────────────────────
              Container(
                decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12.r)),
                padding: EdgeInsets.all(3.w),
                child: Row(children: [
                  _ToggleBtn(
                    label: "⬆  Positive",
                    active: _showPositive,
                    activeColor: const Color(0xFF2E7D32),
                    onTap: () {
                      if (!_showPositive) setState(() {
                        _showPositive = true;
                        _selectedCode = PunctualityCodes.positive.keys.first;
                      });
                    },
                  ),
                  _ToggleBtn(
                    label: "⬇  Negative",
                    active: !_showPositive,
                    activeColor: const Color(0xFFD94040),
                    onTap: () {
                      if (_showPositive) setState(() {
                        _showPositive = false;
                        _selectedCode = PunctualityCodes.negative.keys.first;
                      });
                    },
                  ),
                ]),
              ),

              SizedBox(height: 12.h),

              // ── Code chips ───────────────────────────────────────────────
              Text("STATUS CODE",
                  style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700,
                      color: const Color(0xFF94A3B8), letterSpacing: 0.8)),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 7.w, runSpacing: 7.h,
                children: _activeCodes.keys.map((code) {
                  final s        = _styleFor(code);
                  final selected = code == _selectedCode;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCode = code),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 7.h),
                      decoration: BoxDecoration(
                        color: selected ? s.bg : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(
                            color: selected ? s.text.withOpacity(0.35) : const Color(0xFFE2E8F0),
                            width: 1.2),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(s.icon, size: 12.sp, color: selected ? s.text : const Color(0xFF94A3B8)),
                        SizedBox(width: 4.w),
                        Text("$code · ${_activeCodes[code]}",
                            style: TextStyle(
                                fontSize: 11.sp,
                                color: selected ? s.text : const Color(0xFF94A3B8),
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
                      ]),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: 14.h),

              // ── Date ─────────────────────────────────────────────────────
              Text("DATE",
                  style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700,
                      color: const Color(0xFF94A3B8), letterSpacing: 0.8)),
              SizedBox(height: 8.h),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(11.r),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1)),
                  child: Row(children: [
                    Icon(Icons.calendar_today_outlined, size: 16.sp, color: AppColors.primary),
                    SizedBox(width: 10.w),
                    Text(_formattedDate,
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                    const Spacer(),
                    Icon(Icons.chevron_right_rounded, color: const Color(0xFFCBD5E1), size: 16.sp),
                  ]),
                ),
              ),

              SizedBox(height: 14.h),

              // ── Remark ────────────────────────────────────────────────────
              Text("REMARK",
                  style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700,
                      color: const Color(0xFF94A3B8), letterSpacing: 0.8)),
              SizedBox(height: 8.h),
              TextField(
                controller: _remarkCtrl,
                maxLines: 2,
                style: TextStyle(fontSize: 13.sp, color: const Color(0xFF0F172A)),
                decoration: InputDecoration(
                  hintText: "Optional note…",
                  hintStyle: TextStyle(fontSize: 12.sp, color: const Color(0xFFCBD5E1)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11.r),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11.r),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11.r),
                      borderSide: BorderSide(color: AppColors.primary.withOpacity(0.4), width: 1.5)),
                  contentPadding: EdgeInsets.all(12.w),
                ),
              ),

              SizedBox(height: 20.h),

              // ── Actions ───────────────────────────────────────────────────
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11.r))),
                    child: Text("Cancel",
                        style: TextStyle(fontSize: 13.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: isPositive ? const Color(0xFF2E7D32) : AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11.r))),
                    child: _saving
                        ? SizedBox(width: 16.w, height: 16.w,
                        child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text("Save Record",
                        style: TextStyle(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}