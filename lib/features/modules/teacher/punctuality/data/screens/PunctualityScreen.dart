import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../students/data/models/tech_student_model.dart';
import '../models/PunctualityModel.dart';
import '../../../students/presentation/provider/student_provider.dart';

// ─── Code → visual config ────────────────────────────────────────────────────
class _CodeStyle {
  final Color bg;
  final Color text;
  final IconData icon;
  const _CodeStyle({required this.bg, required this.text, required this.icon});
}

const Map<String, _CodeStyle> _codeStyles = {
  'AWL': _CodeStyle(
      bg: Color(0xFFFFECEC),
      text: Color(0xFFD94040),
      icon: Icons.cancel_outlined),
  'LT': _CodeStyle(
      bg: Color(0xFFFFF3DC),
      text: Color(0xFFC97B00),
      icon: Icons.schedule_outlined),
  'OT': _CodeStyle(
      bg: Color(0xFFE8F5E9),
      text: Color(0xFF2E7D32),
      icon: Icons.check_circle_outline),
  'EL': _CodeStyle(
      bg: Color(0xFFEDE7F6),
      text: Color(0xFF5E35B1),
      icon: Icons.logout_outlined),
};

_CodeStyle _styleFor(String code) =>
    _codeStyles[code] ??
        const _CodeStyle(
            bg: Color(0xFFEEF2FF),
            text: Color(0xFF3949AB),
            icon: Icons.circle_outlined);

// ─── Screen ──────────────────────────────────────────────────────────────────
class StudentPunctualityScreen extends StatefulWidget {
  final EnrollerModel student;
  const StudentPunctualityScreen({super.key, required this.student});

  @override
  State<StudentPunctualityScreen> createState() =>
      _StudentPunctualityScreenState();
}

class _StudentPunctualityScreenState extends State<StudentPunctualityScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    Future.microtask(() {
      context
          .read<StudentProvider>()
          .fetchStudentRecords(widget.student.studentId);
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  String get _initials {
    final parts = widget.student.name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return widget.student.name.substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentProvider>();
    final records = provider.records;

    final totalAWL = records.where((r) => r.code == 'AWL').length;
    final totalLT = records.where((r) => r.code == 'LT').length;
    final totalOT = records.where((r) => r.code == 'OT').length;
    final totalEL = records.where((r) => r.code == 'EL').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Compact Header ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _CompactHeader(
                initials: _initials,
                student: widget.student,
                totalRecords: records.length,
                totalAWL: totalAWL,
                totalLT: totalLT,
                totalOT: totalOT,
                totalEL: totalEL,
                onBack: () => Navigator.pop(context),
              ),
            ),

            // ── Section label ────────────────────────────────────────────────
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 8.h),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Text(
                      "Records",
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    if (records.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          "${records.length}",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── Record list / Empty state ─────────────────────────────────────
            if (records.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                        _RecordCard(record: records[index], index: index),
                    childCount: records.length,
                  ),
                ),
              ),
          ],
        ),
      ),

      // ── FAB ──────────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          "Add Record",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14.sp),
        ),
        onPressed: _showAddDialog,
      ),
    );
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddRecordSheet(
        student: widget.student,
        onSaved: (code, remark, date) async {
          await context.read<StudentProvider>().addRecord(
            student: widget.student,
            code: code,
            remark: remark,
            date: date,
          );
        },
      ),
    );
  }
}

// ─── Compact Header ───────────────────────────────────────────────────────────
class _CompactHeader extends StatelessWidget {
  final String initials;
  final EnrollerModel student;
  final int totalRecords, totalAWL, totalLT, totalOT, totalEL;
  final VoidCallback onBack;

  const _CompactHeader({
    required this.initials,
    required this.student,
    required this.totalRecords,
    required this.totalAWL,
    required this.totalLT,
    required this.totalOT,
    required this.totalEL,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primary, Color(0xFF002D62)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36.r),
          bottomRight: Radius.circular(36.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.28),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Nav row ───────────────────────────────────────────────────
              Row(
                children: [
                  GestureDetector(
                    onTap: onBack,
                    child: Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.15), width: 1),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 16),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Text(
                    "Punctuality",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // ── Student identity row ───────────────────────────────────────
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 46.w,
                    height: 46.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3), width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),

                  SizedBox(width: 12.w),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          "ID · ${student.studentId}",
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Total badge
                  Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.2), width: 1),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "$totalRecords",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800),
                        ),
                        Text(
                          "Total",
                          style: TextStyle(
                              color: Colors.white60, fontSize: 10.sp),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // ── Stats row (single horizontal scroll) ──────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _StatPill(
                        label: 'Absent',
                        count: totalAWL,
                        color: const Color(0xFFFF8A80)),
                    SizedBox(width: 8.w),
                    _StatPill(
                        label: 'Late',
                        count: totalLT,
                        color: const Color(0xFFFFD180)),
                    SizedBox(width: 8.w),
                    _StatPill(
                        label: 'On Time',
                        count: totalOT,
                        color: const Color(0xFFB9F6CA)),
                    SizedBox(width: 8.w),
                    _StatPill(
                        label: 'Early Leave',
                        count: totalEL,
                        color: const Color(0xFFCE93D8)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Stat pill ────────────────────────────────────────────────────────────────
class _StatPill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatPill(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7.w,
            height: 7.w,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          SizedBox(width: 6.w),
          Text(
            "$count $label",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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
    final style = _styleFor(record.code);
    final date = record.date as DateTime;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 280 + index * 50),
      curve: Curves.easeOut,
      builder: (_, value, child) => Transform.translate(
        offset: Offset(0, 16 * (1 - value)),
        child: Opacity(opacity: value, child: child),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Color accent bar
              Container(
                width: 4.w,
                decoration: BoxDecoration(
                  color: style.text,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    bottomLeft: Radius.circular(16.r),
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 12.h),
                  child: Row(
                    children: [
                      // Badge
                      Container(
                        width: 42.w,
                        height: 42.w,
                        decoration: BoxDecoration(
                          color: style.bg,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(style.icon,
                                color: style.text, size: 15.sp),
                            SizedBox(height: 2.h),
                            Text(
                              record.code,
                              style: TextStyle(
                                color: style.text,
                                fontWeight: FontWeight.w800,
                                fontSize: 9.sp,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: 12.w),

                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              record.remark.isEmpty
                                  ? "No remark"
                                  : record.remark,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1A1A2E),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              "${date.day.toString().padLeft(2, '0')}/"
                                  "${date.month.toString().padLeft(2, '0')}/"
                                  "${date.year}",
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: const Color(0xFF9E9E9E),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Right arrow hint
                      Icon(Icons.chevron_right_rounded,
                          color: const Color(0xFFCFD8DC), size: 18.sp),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72.w,
          height: 72.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                AppColors.primary.withOpacity(0.12),
                const Color(0xFF002D62).withOpacity(0.08),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.event_note_outlined,
              size: 30.sp, color: AppColors.primary),
        ),
        SizedBox(height: 14.h),
        Text(
          "No Records Yet",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          "Tap '+ Add Record' to get started.",
          style: TextStyle(
              fontSize: 12.sp, color: const Color(0xFF9E9E9E)),
        ),
      ],
    ),
  );
}

// ─── Add Record Bottom Sheet ──────────────────────────────────────────────────
class _AddRecordSheet extends StatefulWidget {
  final EnrollerModel student;
  final Future<void> Function(String code, String remark, DateTime date)
  onSaved;
  const _AddRecordSheet({required this.student, required this.onSaved});

  @override
  State<_AddRecordSheet> createState() => _AddRecordSheetState();
}

class _AddRecordSheetState extends State<_AddRecordSheet> {
  String _selectedCode = PunctualityCodes.codes.keys.first;
  DateTime _selectedDate = DateTime.now();
  final _remarkCtrl = TextEditingController();
  bool _saving = false;

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
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.primary),
        ),
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
  void dispose() {
    _remarkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(_selectedCode);

    return Padding(
      padding:
      EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),

            SizedBox(height: 18.h),

            // Header row with selected code preview
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "New Record",
                        style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                            letterSpacing: -0.3),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        widget.student.name,
                        style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF9E9E9E),
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                // Live code badge
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                      horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: style.bg,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                        color: style.text.withOpacity(0.25), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(style.icon, color: style.text, size: 14.sp),
                      SizedBox(width: 5.w),
                      Text(
                        _selectedCode,
                        style: TextStyle(
                          color: style.text,
                          fontWeight: FontWeight.w800,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 22.h),

            // ── Status Code ────────────────────────────────────────────────
            Text(
              "Status Code",
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF424242),
                  letterSpacing: 0.2),
            ),

            SizedBox(height: 10.h),

            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: PunctualityCodes.codes.keys.map((code) {
                final s = _styleFor(code);
                final selected = code == _selectedCode;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCode = code),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: selected ? s.bg : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: selected
                            ? s.text.withOpacity(0.4)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(s.icon,
                            size: 13.sp,
                            color: selected
                                ? s.text
                                : const Color(0xFF9E9E9E)),
                        SizedBox(width: 5.w),
                        Text(
                          "$code · ${PunctualityCodes.codes[code]}",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: selected
                                ? s.text
                                : const Color(0xFF9E9E9E),
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 18.h),

            // ── Date ──────────────────────────────────────────────────────
            Text(
              "Date",
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF424242),
                  letterSpacing: 0.2),
            ),

            SizedBox(height: 8.h),

            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 13.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                      color: const Color(0xFFE8ECF0), width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 17.sp, color: AppColors.primary),
                    SizedBox(width: 12.w),
                    Text(_formattedDate,
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A))),
                    const Spacer(),
                    Icon(Icons.chevron_right_rounded,
                        color: const Color(0xFFB0BEC5), size: 18.sp),
                  ],
                ),
              ),
            ),

            SizedBox(height: 18.h),

            // ── Remark ────────────────────────────────────────────────────
            Text(
              "Remark",
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF424242),
                  letterSpacing: 0.2),
            ),

            SizedBox(height: 8.h),

            TextField(
              controller: _remarkCtrl,
              maxLines: 2,
              style: TextStyle(
                  fontSize: 14.sp, color: const Color(0xFF0F172A)),
              decoration: InputDecoration(
                hintText: "Optional note about this record…",
                hintStyle: TextStyle(
                    fontSize: 13.sp, color: const Color(0xFFBDBDBD)),
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide:
                  const BorderSide(color: Color(0xFFE8ECF0), width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide:
                  const BorderSide(color: Color(0xFFE8ECF0), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                      color: AppColors.primary.withOpacity(0.4),
                      width: 1.5),
                ),
                contentPadding: EdgeInsets.all(14.w),
              ),
            ),

            SizedBox(height: 24.h),

            // ── Actions ───────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF757575),
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: _saving
                        ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Text(
                      "Save Record",
                      style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}