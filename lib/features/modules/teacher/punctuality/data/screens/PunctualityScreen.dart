import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/widgets/buttons/gradient_button.dart';
import '../../../students/data/models/tech_student_model.dart';
import '../models/PunctualityModel.dart';
import '../../../students/presentation/provider/student_provider.dart';
import '../../../../../../core/constants/app_spacing.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';

// ─── Punctuality code → visual config ────────────────────────────────────────
class _CodeStyle {
  final Color bg;
  final Color text;
  final IconData icon;
  const _CodeStyle({required this.bg, required this.text, required this.icon});
}

const Map<String, _CodeStyle> _codeStyles = {
  'AWL': _CodeStyle(
      bg: Color(0xFFFFECEC), text: Color(0xFFD94040), icon: Icons.cancel_outlined),
  'LT':  _CodeStyle(
      bg: Color(0xFFFFF3DC), text: Color(0xFFC97B00), icon: Icons.schedule_outlined),
  'OT':  _CodeStyle(
      bg: Color(0xFFE8F5E9), text: Color(0xFF2E7D32), icon: Icons.check_circle_outline),
  'EL':  _CodeStyle(
      bg: Color(0xFFEDE7F6), text: Color(0xFF5E35B1), icon: Icons.logout_outlined),
};

_CodeStyle _styleFor(String code) =>
    _codeStyles[code] ??
        const _CodeStyle(
            bg: Color(0xFFEEF2FF), text: Color(0xFF3949AB), icon: Icons.circle_outlined);

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
        vsync: this, duration: const Duration(milliseconds: 600));
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

  // ── helpers ────────────────────────────────────────────────────────────────
  String get _initials {
    final parts = widget.student.name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return widget.student.name.substring(0, 2).toUpperCase();
  }

  // ── build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentProvider>();
    final records  = provider.records;

    final totalAWL = records.where((r) => r.code == 'AWL').length;
    final totalLT  = records.where((r) => r.code == 'LT').length;
    final totalOT  = records.where((r) => r.code == 'OT').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            // ── Rich header ─────────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 220.h,
              pinned: true,
              elevation: 0,
              backgroundColor: AppColors.primary,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    // Gradient backdrop
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                        ),
                      ),
                    ),

                    // Decorative circles
                    Positioned(
                      top: -30.h,
                      right: -40.w,
                      child: _DecorCircle(size: 180.w, opacity: 0.08),
                    ),
                    Positioned(
                      bottom: 30.h,
                      left: -20.w,
                      child: _DecorCircle(size: 120.w, opacity: 0.06),
                    ),

                    // Content
                    SafeArea(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 20.h),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Avatar
                                Container(
                                  width: 52.w,
                                  height: 52.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.4),
                                        width: 2),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _initials,
                                    style: AppTypography.body1.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18.sp,
                                    ),
                                  ),
                                ),

                                SizedBox(width: 14.w),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.student.name,
                                        style: AppTypography.h4.copyWith(
                                            color: Colors.white),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        "Punctuality Records",
                                        style: AppTypography.caption.copyWith(
                                          color:
                                          Colors.white.withValues(alpha: 0.75),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 20.h),

                            // ── Quick stats ───────────────────────────────
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _StatChip(
                                        label: 'Total',
                                        count: records.length,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: _StatChip(
                                        label: 'Absent',
                                        count: totalAWL,
                                        color: const Color(0xFFFF8A80),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _StatChip(
                                        label: 'Late',
                                        count: totalLT,
                                        color: const Color(0xFFFFD180),
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: _StatChip(
                                        label: 'On time',
                                        count: totalOT,
                                        color: const Color(0xFFB9F6CA),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Record list ──────────────────────────────────────────────────
            if (records.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _RecordCard(
                      record: records[index],
                      index: index,
                    ),
                    childCount: records.length,
                  ),
                ),
              ),
          ],
        ),
      ),

      // ── FAB ─────────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          "Add Record",
          style: AppTypography.caption
              .copyWith(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        onPressed: _showAddDialog,
      ),
    );
  }

  // ── Dialog ─────────────────────────────────────────────────────────────────
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

// ─── Decorative circle ────────────────────────────────────────────────────────
class _DecorCircle extends StatelessWidget {
  final double size;
  final double opacity;
  const _DecorCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: opacity),
    ),
  );
}

// ─── Stat chip ────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatChip(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration:
            BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          SizedBox(width: 5.w),
          Text(
            "$count $label",
            style: AppTypography.caption.copyWith(
                color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// ─── Record card ─────────────────────────────────────────────────────────────
class _RecordCard extends StatelessWidget {
  final dynamic record;
  final int index;
  const _RecordCard({required this.record, required this.index});

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(record.code);
    final date  = record.date as DateTime;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + index * 60),
      curve: Curves.easeOut,
      builder: (_, value, child) => Transform.translate(
        offset: Offset(0, 20 * (1 - value)),
        child: Opacity(opacity: value, child: child),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Color accent bar
              Container(
                width: 5.w,
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
                  padding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                  child: Row(
                    children: [
                      // Badge
                      Container(
                        width: 44.w,
                        height: 44.w,
                        decoration: BoxDecoration(
                          color: style.bg,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(style.icon, color: style.text, size: 16.sp),
                            SizedBox(height: 2.h),
                            Text(
                              record.code,
                              style: AppTypography.caption.copyWith(
                                  color: style.text,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10.sp),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: 14.w),

                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              record.remark.isEmpty ? "No remark" : record.remark,
                              style: AppTypography.body1.copyWith(
                                  fontWeight: FontWeight.w500),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "${date.day}/${date.month}/${date.year}",
                              style: AppTypography.caption.copyWith(
                                  color: const Color(0xFF9E9E9E)),
                            ),
                          ],
                        ),
                      ),
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

// ─── Empty state ─────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.event_note_outlined,
              size: 36.sp, color: AppColors.primary),
        ),
        SizedBox(height: 16.h),
        Text(
          "No Records Yet",
          style: AppTypography.h4.copyWith(color: const Color(0xFF424242)),
        ),
        SizedBox(height: 6.h),
        Text(
          "Tap the button below to add a punctuality record.",
          style: AppTypography.caption
              .copyWith(color: const Color(0xFF9E9E9E)),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

// ─── Add Record Bottom Sheet ──────────────────────────────────────────────────
class _AddRecordSheet extends StatefulWidget {
  final EnrollerModel student;
  final Future<void> Function(String code, String remark, DateTime date) onSaved;

  const _AddRecordSheet({required this.student, required this.onSaved});

  @override
  State<_AddRecordSheet> createState() => _AddRecordSheetState();
}

class _AddRecordSheetState extends State<_AddRecordSheet> {
  String _selectedCode   = PunctualityCodes.codes.keys.first;
  DateTime _selectedDate = DateTime.now();
  final _remarkCtrl      = TextEditingController();
  bool _saving           = false;

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
    final style     = _styleFor(_selectedCode);
    final codeLabel = PunctualityCodes.codes[_selectedCode] ?? '';

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
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

            SizedBox(height: 20.h),

            Text("New Record",
                style: AppTypography.h4
                    .copyWith(fontWeight: FontWeight.w700)),

            SizedBox(height: 4.h),

            Text("Fill in the details for ${widget.student.name}",
                style: AppTypography.caption
                    .copyWith(color: const Color(0xFF9E9E9E))),

            SizedBox(height: 24.h),

            // ── Code selector ──────────────────────────────────────────────
            Text("Status Code",
                style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF424242))),

            SizedBox(height: 8.h),

            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: PunctualityCodes.codes.keys.map((code) {
                final s       = _styleFor(code);
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
                            ? s.text.withValues(alpha: 0.4)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(s.icon,
                            size: 14.sp,
                            color: selected
                                ? s.text
                                : const Color(0xFF9E9E9E)),
                        SizedBox(width: 5.w),
                        Text(
                          "$code · ${PunctualityCodes.codes[code]}",
                          style: AppTypography.caption.copyWith(
                            color: selected
                                ? s.text
                                : const Color(0xFF9E9E9E),
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 20.h),

            // ── Date ──────────────────────────────────────────────────────
            Text("Date",
                style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF424242))),

            SizedBox(height: 8.h),

            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 18.sp, color: AppColors.primary),
                    SizedBox(width: 12.w),
                    Text(_formattedDate,
                        style: AppTypography.body1
                            .copyWith(fontWeight: FontWeight.w500)),
                    const Spacer(),
                    Icon(Icons.chevron_right_rounded,
                        color: const Color(0xFF9E9E9E), size: 20.sp),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // ── Remark ────────────────────────────────────────────────────
            Text("Remark",
                style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF424242))),

            SizedBox(height: 8.h),

            TextField(
              controller: _remarkCtrl,
              maxLines: 2,
              style: AppTypography.body1,
              decoration: InputDecoration(
                hintText: "Optional note about this record…",
                hintStyle: AppTypography.caption
                    .copyWith(color: const Color(0xFFBDBDBD)),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      width: 1.5),
                ),
                contentPadding: EdgeInsets.all(14.w),
              ),
            ),

            SizedBox(height: 28.h),

            // ── Action buttons ────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                    ),
                    child: Text(
                      "Cancel",
                      style: AppTypography.body1.copyWith(
                          color: const Color(0xFF757575)),
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
                      padding: EdgeInsets.symmetric(vertical: 14.h),
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
                      style: AppTypography.body1.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
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