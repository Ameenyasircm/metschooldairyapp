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

// ─── Correct code styles matching PunctualityCodes ───────────────────────────
const Map<String, _CodeStyle> _codeStyles = {
  'AWL': _CodeStyle(
      bg: Color(0xFFFFECEC),
      text: Color(0xFFD94040),
      icon: Icons.cancel_outlined),
  'CC': _CodeStyle(
      bg: Color(0xFFFFF3DC),
      text: Color(0xFFC97B00),
      icon: Icons.warning_amber_rounded),
  'IU': _CodeStyle(
      bg: Color(0xFFE3F2FD),
      text: Color(0xFF1565C0),
      icon: Icons.checkroom_outlined),
  'BNB': _CodeStyle(
      bg: Color(0xFFF3E5F5),
      text: Color(0xFF6A1B9A),
      icon: Icons.menu_book_outlined),
  'HND': _CodeStyle(
      bg: Color(0xFFE8F5E9),
      text: Color(0xFF2E7D32),
      icon: Icons.assignment_late_outlined),
  'LC': _CodeStyle(
      bg: Color(0xFFFCE4EC),
      text: Color(0xFFC62828),
      icon: Icons.schedule_outlined),
};

_CodeStyle _styleFor(String code) =>
    _codeStyles[code] ??
        const _CodeStyle(
            bg: Color(0xFFEEF2FF),
            text: Color(0xFF3949AB),
            icon: Icons.circle_outlined);

// ─── Screen ───────────────────────────────────────────────────────────────────
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
        vsync: this, duration: const Duration(milliseconds: 450));
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentProvider>();
    final records = provider.records;

    // ─── In your build() method — fix the count variables ────────────────────────
    final totalAWL = records.where((r) => r.code == 'AWL').length;
    final totalCC  = records.where((r) => r.code == 'CC').length;
    final totalIU  = records.where((r) => r.code == 'IU').length;
    final totalBNB = records.where((r) => r.code == 'BNB').length;
    final totalHND = records.where((r) => r.code == 'HND').length;
    final totalLC  = records.where((r) => r.code == 'LC').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            // ── Ultra-compact header ─────────────────────────────────────────
            _MiniHeader(
              initials: _initials,
              student: widget.student,
              totalRecords: records.length,
              totalAWL: totalAWL,
              totalCC:  totalCC,
              totalIU:  totalIU,
              totalBNB: totalBNB,
              totalHND: totalHND,
              totalLC:  totalLC,
              onBack: () => Navigator.pop(context),
              onAdd: _showAddDialog,
            ),

            // ── Records section ──────────────────────────────────────────────
            Expanded(
              child: records.isEmpty
                  ? _EmptyState()
                  : ListView.builder(
                padding:
                EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 90.h),
                physics: const BouncingScrollPhysics(),
                itemCount: records.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Row(
                        children: [
                          Text(
                            "Records",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color:
                              AppColors.primary.withOpacity(0.1),
                              borderRadius:
                              BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              "${records.length}",
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return _RecordCard(
                      record: records[index - 1], index: index - 1);
                },
              ),
            ),
          ],
        ),
      ),

      // ── FAB ─────────────────────────────────────────────────────────────────
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

  // ── Alert dialog instead of bottom sheet ────────────────────────────────────
  void _showAddDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => _AddRecordDialog(
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

// ─── Ultra-compact header ─────────────────────────────────────────────────────
// ─── Updated _MiniHeader ─────────────────────────────────────────────────────
class _MiniHeader extends StatelessWidget {
  final String initials;
  final EnrollerModel student;
  final int totalRecords;
  final int totalAWL, totalCC, totalIU, totalBNB, totalHND, totalLC;
  final VoidCallback onBack;
  final VoidCallback onAdd;

  const _MiniHeader({
    required this.initials,
    required this.student,
    required this.totalRecords,
    required this.totalAWL,
    required this.totalCC,
    required this.totalIU,
    required this.totalBNB,
    required this.totalHND,
    required this.totalLC,
    required this.onBack,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
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
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 14.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Identity row ───────────────────────────────────────────
              Row(
                children: [
                  GestureDetector(
                    onTap: onBack,
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
                  SizedBox(width: 10.w),
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
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
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          student.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "Punctuality Records",
                          style: TextStyle(
                              color: Colors.white60,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  // Total badge
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.2), width: 1),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "$totalRecords",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          "Total",
                          style: TextStyle(
                              color: Colors.white54, fontSize: 9.sp),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10.h),

              // ── Stats pills — now using real codes ─────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _MiniPill(
                        label: 'AWL',
                        count: totalAWL,
                        color: const Color(0xFFFF8A80)),
                    SizedBox(width: 6.w),
                    _MiniPill(
                        label: 'LC',
                        count: totalLC,
                        color: const Color(0xFFFFD180)),
                    SizedBox(width: 6.w),
                    _MiniPill(
                        label: 'CC',
                        count: totalCC,
                        color: const Color(0xFFFFCC80)),
                    SizedBox(width: 6.w),
                    _MiniPill(
                        label: 'IU',
                        count: totalIU,
                        color: const Color(0xFF90CAF9)),
                    SizedBox(width: 6.w),
                    _MiniPill(
                        label: 'BNB',
                        count: totalBNB,
                        color: const Color(0xFFCE93D8)),
                    SizedBox(width: 6.w),
                    _MiniPill(
                        label: 'HND',
                        count: totalHND,
                        color: const Color(0xFFB9F6CA)),
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

// ─── Mini pill ────────────────────────────────────────────────────────────────
class _MiniPill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _MiniPill(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border:
        Border.all(color: Colors.white.withOpacity(0.15), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          SizedBox(width: 5.w),
          Text(
            "$count $label",
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.sp,
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
      duration: Duration(milliseconds: 260 + index * 45),
      curve: Curves.easeOut,
      builder: (_, value, child) => Transform.translate(
        offset: Offset(0, 14 * (1 - value)),
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
              Container(
                width: 4.w,
                decoration: BoxDecoration(
                  color: style.text,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(14.r),
                    bottomLeft: Radius.circular(14.r),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 12.w, vertical: 11.h),
                  child: Row(
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: style.bg,
                          borderRadius: BorderRadius.circular(11.r),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(style.icon,
                                color: style.text, size: 14.sp),
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
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          color: const Color(0xFFCFD8DC), size: 16.sp),
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
          width: 64.w,
          height: 64.w,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.event_note_outlined,
              size: 28.sp, color: AppColors.primary),
        ),
        SizedBox(height: 12.h),
        Text(
          "No Records Yet",
          style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E)),
        ),
        SizedBox(height: 4.h),
        Text(
          "Tap '+ Add Record' to get started.",
          style: TextStyle(
              fontSize: 12.sp, color: const Color(0xFF9E9E9E)),
        ),
      ],
    ),
  );
}

// ─── Add Record Alert Dialog ──────────────────────────────────────────────────
class _AddRecordDialog extends StatefulWidget {
  final EnrollerModel student;
  final Future<void> Function(String code, String remark, DateTime date)
  onSaved;
  const _AddRecordDialog({required this.student, required this.onSaved});

  @override
  State<_AddRecordDialog> createState() => _AddRecordDialogState();
}

class _AddRecordDialogState extends State<_AddRecordDialog> {
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

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
      child: Container(color: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Dialog header ──────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Add Record",
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            widget.student.name,
                            style: TextStyle(
                                fontSize: 11.sp,
                                color: const Color(0xFF9E9E9E),
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    // Live selected code badge
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: style.bg,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                            color: style.text.withOpacity(0.25), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(style.icon, color: style.text, size: 13.sp),
                          SizedBox(width: 4.w),
                          Text(
                            _selectedCode,
                            style: TextStyle(
                              color: style.text,
                              fontWeight: FontWeight.w800,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 28.w,
                        height: 28.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close_rounded,
                            size: 15.sp, color: const Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 18.h),

                // ── Status Code ────────────────────────────────────────────
                Text(
                  "STATUS CODE",
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 7.w,
                  runSpacing: 7.h,
                  children: PunctualityCodes.codes.keys.map((code) {
                    final s = _styleFor(code);
                    final selected = code == _selectedCode;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCode = code),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                            horizontal: 11.w, vertical: 7.h),
                        decoration: BoxDecoration(
                          color: selected ? s.bg : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(18.r),
                          border: Border.all(
                            color: selected
                                ? s.text.withOpacity(0.35)
                                : const Color(0xFFE2E8F0),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(s.icon,
                                size: 12.sp,
                                color: selected
                                    ? s.text
                                    : const Color(0xFF94A3B8)),
                            SizedBox(width: 4.w),
                            Text(
                              "$code · ${PunctualityCodes.codes[code]}",
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: selected
                                    ? s.text
                                    : const Color(0xFF94A3B8),
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

                SizedBox(height: 16.h),

                // ── Date ──────────────────────────────────────────────────
                Text(
                  "DATE",
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: 8.h),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 11.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(11.r),
                      border: Border.all(
                          color: const Color(0xFFE2E8F0), width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 16.sp, color: AppColors.primary),
                        SizedBox(width: 10.w),
                        Text(
                          _formattedDate,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.chevron_right_rounded,
                            color: const Color(0xFFCBD5E1), size: 16.sp),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // ── Remark ────────────────────────────────────────────────
                Text(
                  "REMARK",
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _remarkCtrl,
                  maxLines: 2,
                  style: TextStyle(
                      fontSize: 13.sp, color: const Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    hintText: "Optional note…",
                    hintStyle: TextStyle(
                        fontSize: 12.sp, color: const Color(0xFFCBD5E1)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11.r),
                      borderSide: const BorderSide(
                          color: Color(0xFFE2E8F0), width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11.r),
                      borderSide: const BorderSide(
                          color: Color(0xFFE2E8F0), width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11.r),
                      borderSide: BorderSide(
                          color: AppColors.primary.withOpacity(0.4),
                          width: 1.5),
                    ),
                    contentPadding: EdgeInsets.all(12.w),
                  ),
                ),

                SizedBox(height: 20.h),

                // ── Action buttons ─────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11.r),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11.r),
                          ),
                        ),
                        child: _saving
                            ? SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                            : Text(
                          "Save Record",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}