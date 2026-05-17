/// lesson_plan_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:met_school/core/utils/navigation/navigation_helper.dart';
import 'package:met_school/providers/teacher_provider.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_padding.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../models/lesson_plan_model.dart';
import 'add_lesson_plan.dart';

class LessonPlanScreen extends StatefulWidget {
  const LessonPlanScreen({super.key});

  @override
  State<LessonPlanScreen> createState() => _LessonPlanScreenState();
}

class _LessonPlanScreenState extends State<LessonPlanScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TeacherProvider>().fetchLessonPlans("TEACHER_001");
  }

  // ── Delete confirmation dialog ─────────────────────────────
  Future<void> _confirmDelete(
      BuildContext context,
      TeacherProvider provider,
      LessonPlanModel item,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),

        title: Row(
          children: [
            Icon(
              Icons.delete_outline_rounded,
              color: Colors.red,
              size: 22.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              "Delete Plan?",
              style: AppTypography.body1.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        content: RichText(
          text: TextSpan(
            style: AppTypography.body3.copyWith(
              color: AppColors.grey5E,
              height: 1.5,
            ),
            children: [
              const TextSpan(text: "You are about to delete\n"),
              TextSpan(
                text: '"${item.topicName}"',
                style: AppTypography.body3.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const TextSpan(
                text: "\n\nThis action cannot be undone.",
              ),
            ],
          ),
        ),

        actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 14.h),

        actions: [
          // ── Cancel ──────────────────────────────────
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              side: BorderSide(color: AppColors.grey5E.withOpacity(.4)),
            ),
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              "Cancel",
              style: AppTypography.body3.copyWith(
                color: AppColors.grey5E,
              ),
            ),
          ),

          // ── Delete ──────────────────────────────────
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              "Delete",
              style: AppTypography.body3.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await provider.deleteLessonPlan(
        lessonPlanId: item.id,
        teacherId: item.teacherId,
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeacherProvider>();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,

      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        title: Text(
          "Lesson Plans",
          style: AppTypography.body1.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: provider.lessonPlanList.isEmpty
                ? _emptyWidget()
                : ListView.builder(
              padding: AppPadding.pM,
              itemCount: provider.lessonPlanList.length,
              itemBuilder: (context, index) {
                final item = provider.lessonPlanList[index];

                final bool isApproved =
                    item.status.toLowerCase() == "approved";

                final Color chipBg = isApproved
                    ? Colors.green.shade100
                    : Colors.orange.shade100;
                final Color chipFg =
                isApproved ? Colors.green : Colors.orange;

                return Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Title + Status chip ──────
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.topicName,
                              style: AppTypography.body2.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 5.h,
                            ),
                            decoration: BoxDecoration(
                              color: chipBg,
                              borderRadius:
                              BorderRadius.circular(30.r),
                            ),
                            child: Text(
                              item.status,
                              style: AppTypography.body3.copyWith(
                                color: chipFg,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      AppSpacing.h8,

                      Text(
                        "${item.subject} • ${item.grade}",
                        style: AppTypography.body3,
                      ),

                      AppSpacing.h6,

                      Text(
                        "Duration : ${item.duration}",
                        style: AppTypography.body3,
                      ),

                      AppSpacing.h6,

                      Text(
                        "Periods : ${item.periodsAllotted}",
                        style: AppTypography.body3,
                      ),

                      AppSpacing.h10,

                      Divider(
                        height: 1,
                        color: AppColors.lightBackground,
                      ),

                      AppSpacing.h10,

                      // ── Added date ───────────────
                      _dateRow(
                        icon: Icons.calendar_today_outlined,
                        label: "Added",
                        date: item.createdAt,
                        color: AppColors.grey5E,
                      ),

                      // ── Approved date ────────────
                      if (isApproved && item.approvedAt != null) ...[
                        AppSpacing.h4,
                        _dateRow(
                          icon: Icons.check_circle_outline_rounded,
                          label: "Approved",
                          date: item.approvedAt!,
                          color: Colors.green,
                        ),
                      ],

                      // ── Delete button (pending only) ──
                      if (!isApproved) ...[
                        AppSpacing.h10,
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () => _confirmDelete(
                              context,
                              provider,
                              item,
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius:
                                BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.red,
                                    size: 15.sp,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    "Delete",
                                    style:
                                    AppTypography.body3.copyWith(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor:
        provider.isAllowedDay() ? AppColors.primary : Colors.grey,
        onPressed: () {
          if (!provider.isAllowedDay()) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Lesson plan can only be added on Sunday or Monday",
                ),
              ),
            );
            return;
          }
          callNext(const AddLessonPlanScreen(), context);
        },
        label: Text(
          "Add Plan",
          style: AppTypography.body2.copyWith(color: AppColors.white),
        ),
        icon: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _dateRow({
    required IconData icon,
    required String label,
    required DateTime date,
    required Color color,
  }) {
    final formatted = DateFormat("dd MMM yyyy, hh:mm a").format(date);
    return Row(
      children: [
        Icon(icon, size: 13.sp, color: color),
        SizedBox(width: 5.w),
        Text(
          "$label : $formatted",
          style: AppTypography.body3.copyWith(color: color),
        ),
      ],
    );
  }

  Widget _emptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 70.sp,
            color: AppColors.grey5E.withOpacity(.3),
          ),
          AppSpacing.h12,
          Text(
            "No Lesson Plans Added",
            style: AppTypography.body2.copyWith(color: AppColors.grey5E),
          ),
        ],
      ),
    );
  }
}