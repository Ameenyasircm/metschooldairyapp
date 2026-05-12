import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../data/models/event_model.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import 'event_status_chip.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;
  final Widget? statusWidget;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.statusWidget,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.radiusM,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: AppTypography.body1.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                statusWidget ?? EventStatusChip(status: event.status),
              ],
            ),
            AppSpacing.h8,
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14.sp, color: AppColors.grey5E),
                AppSpacing.hs,
                Text(
                  DateFormat('dd MMM yyyy, hh:mm a').format(event.dateTime.toDate()),
                  style: AppTypography.caption.copyWith(color: AppColors.grey5E),
                ),
              ],
            ),
            
            if (event.isTaskRequired) ...[
              AppSpacing.h8,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.assignment_turned_in_outlined, size: 12.sp, color: AppColors.primary),
                    AppSpacing.h4,
                    Text(
                      event.taskTitle ?? 'Task Required',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            AppSpacing.h12,
            Text(
              event.description,
              style: AppTypography.body2.copyWith(color: AppColors.grey5E),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
