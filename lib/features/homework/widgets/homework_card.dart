import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_padding.dart';
import '../../modules/teacher/homework/data/models/homework_model.dart';

class HomeworkCard extends StatelessWidget {
  final HomeworkModel homework;
  final VoidCallback onTap;

  const HomeworkCard({
    super.key,
    required this.homework,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = homework.dueDate.isBefore(DateTime.now()) &&
        !DateUtils.isSameDay(homework.dueDate, DateTime.now());

    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: 12.0),
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusM),
      child: ListTile(
        onTap: onTap,
        contentPadding: AppPadding.pM,
        title: Row(
          children: [
            Expanded(
              child: Text(
                homework.title,
                style: AppTypography.body1.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            if (homework.subject!='')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: AppRadius.radiusS,
                ),
                child: Text(
                  homework.subject??'',
                  style: AppTypography.caption.copyWith(color: AppColors.primary),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.h4,
            Text(
              homework.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body2.copyWith(color: AppColors.grey5E),
            ),
            AppSpacing.h8,
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 14, color: isOverdue ? Colors.red : AppColors.grey5E),
                AppSpacing.w4,
                Text(
                  'Due: ${DateFormat('dd MMM').format(homework.dueDate)}',
                  style: AppTypography.caption.copyWith(
                    color: isOverdue ? Colors.red : AppColors.grey5E,
                    fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const Spacer(),
                Text(
                  'Posted: ${DateFormat('dd MMM').format(homework.createdAt)}',
                  style: AppTypography.caption.copyWith(color: AppColors.grey5E),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
