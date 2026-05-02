import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_typography.dart';
import 'package:met_school/core/constants/app_spacing.dart';
import 'package:met_school/core/constants/app_padding.dart';
import 'package:met_school/core/constants/app_radius.dart';

class ParentFeeScreen extends StatelessWidget {
  final String studentId;
  final String studentName;
  final String divisionId;
  final String divisionName;
  final String academicYearId;

  const ParentFeeScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.divisionId,
    required this.divisionName,
    required this.academicYearId,
  });

  static const List<String> _installments = ['Inst 1', 'Inst 2', 'Inst 3', 'Inst 4'];

  Stream<DocumentSnapshot?> _childEnrollmentStream() {
    return FirebaseFirestore.instance
        .collection('enrollments')
        .where('division_id', isEqualTo: divisionId)
        .where('academic_year_id', isEqualTo: academicYearId)
        .where('student_id', isEqualTo: studentId)
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isEmpty ? null : snap.docs.first);
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
            Text('Fee Status',
                style: AppTypography.h6.copyWith(color: AppColors.primary)),
            Text(divisionName,
                style: AppTypography.caption
                    .copyWith(color: AppColors.grey5E, fontSize: 10.sp)),
          ],
        ),
      ),
      body: StreamBuilder<DocumentSnapshot?>(
        stream: _childEnrollmentStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 56.sp, color: AppColors.greyB2),
                  AppSpacing.vm,
                  Text('No fee records found',
                      style: AppTypography.body1
                          .copyWith(color: AppColors.grey5E)),
                ],
              ),
            );
          }

          final data =
          snapshot.data!.data() as Map<String, dynamic>;
          final Map fees = data['fees'] as Map? ?? {};
          final int paidCount =
              _installments.where((i) => fees.containsKey(i)).length;

          return SingleChildScrollView(
            padding: AppPadding.pM,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSpacing.vs,
                _SummaryBanner(
                    paidCount: paidCount,
                    total: _installments.length,
                    studentName: studentName),
                AppSpacing.vm,
                Text('Installments',
                    style: AppTypography.body1.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary)),
                AppSpacing.vs,
                ..._installments.map((inst) {
                  final isPaid = fees.containsKey(inst);
                  final details =
                  isPaid ? fees[inst] as Map<String, dynamic> : null;
                  return _InstallmentCard(
                      installment: inst,
                      isPaid: isPaid,
                      details: details);
                }),
                AppSpacing.vl,
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Summary Banner ──────────────────────────────────────────────────────────

class _SummaryBanner extends StatelessWidget {
  final int paidCount;
  final int total;
  final String studentName;

  const _SummaryBanner({
    required this.paidCount,
    required this.total,
    required this.studentName,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = paidCount / total;
    final Color statusColor = paidCount == total
        ? AppColors.successGreen
        : paidCount == 0
        ? AppColors.errorRed
        : AppColors.warningOrange;
    final String statusLabel = paidCount == total
        ? 'All Paid'
        : paidCount == 0
        ? 'All Pending'
        : '$paidCount of $total Paid';

    return Container(
      width: double.infinity,
      padding: AppPadding.pM,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.m),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(studentName,
                        style: AppTypography.body1.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                    AppSpacing.h4,
                    Text('Academic Fee Overview',
                        style: AppTypography.caption
                            .copyWith(color: AppColors.grey5E)),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  border:
                  Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(statusLabel,
                    style: AppTypography.caption.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          AppSpacing.vm,
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xs),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8.h,
              backgroundColor: AppColors.greyGreen,
              valueColor: AlwaysStoppedAnimation(statusColor),
            ),
          ),
          AppSpacing.vs,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$paidCount installment${paidCount == 1 ? '' : 's'} paid',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.grey5E, fontSize: 10.sp)),
              Text('${total - paidCount} pending',
                  style: AppTypography.caption.copyWith(
                      color: AppColors.errorRed, fontSize: 10.sp)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Installment Card ────────────────────────────────────────────────────────

class _InstallmentCard extends StatelessWidget {
  final String installment;
  final bool isPaid;
  final Map<String, dynamic>? details;

  const _InstallmentCard({
    required this.installment,
    required this.isPaid,
    required this.details,
  });

  String _formatDate(dynamic raw) {
    if (raw == null) return '—';
    if (raw is Timestamp) {
      return DateFormat('dd MMM yyyy').format(raw.toDate());
    }
    // legacy string date fallback
    return raw.toString();
  }

  @override
  Widget build(BuildContext context) {
    final Color color =
    isPaid ? AppColors.successGreen : AppColors.errorRed;
    final String remark =
        details?['remark']?.toString().trim() ?? '';
    final String date = _formatDate(details?['date']);
    final String updatedBy =
        details?['updated_by_name']?.toString() ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(color: color.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Padding(
        padding: AppPadding.pM,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status icon
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                isPaid ? Icons.check_circle : Icons.radio_button_unchecked,
                color: color,
                size: 20.sp,
              ),
            ),
            AppSpacing.hm,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(installment,
                          style: AppTypography.body1.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius:
                          BorderRadius.circular(AppRadius.xs),
                        ),
                        child: Text(
                          isPaid ? 'PAID' : 'PENDING',
                          style: AppTypography.caption.copyWith(
                              color: color,
                              fontWeight: FontWeight.w800,
                              fontSize: 10.sp),
                        ),
                      ),
                    ],
                  ),
                  if (isPaid) ...[
                    AppSpacing.vs,
                    _DetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Paid on',
                        value: date),
                    if (remark.isNotEmpty) ...[
                      AppSpacing.h4,
                      _DetailRow(
                          icon: Icons.notes_outlined,
                          label: 'Remark',
                          value: remark),
                    ],
                    if (updatedBy.isNotEmpty) ...[
                      AppSpacing.h4,
                      _DetailRow(
                          icon: Icons.person_outline,
                          label: 'Recorded by',
                          value: updatedBy),
                    ],
                  ] else ...[
                    AppSpacing.vs,
                    Text('Payment not yet received',
                        style: AppTypography.caption
                            .copyWith(color: AppColors.greyB2)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13.sp, color: AppColors.grey5E),
        SizedBox(width: 4.w),
        Text('$label: ',
            style: AppTypography.caption.copyWith(
                color: AppColors.grey5E, fontSize: 11.sp)),
        Expanded(
          child: Text(value,
              style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11.sp)),
        ),
      ],
    );
  }
}