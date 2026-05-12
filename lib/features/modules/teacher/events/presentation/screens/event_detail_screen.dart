import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:met_school/core/router/app_navigation.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_padding.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/utils/snackbarNotification/snackbar_notification.dart';
import '../../data/models/event_model.dart';
import '../provider/event_provider.dart';
import '../widgets/event_status_chip.dart';
import 'add_edit_event_screen.dart';
import 'event_task_tracking_screen.dart';

class EventDetailScreen extends StatelessWidget {
  final EventModel event;
  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text('Event Details ', style: AppTypography.h6.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddEditEventScreen(event: event)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppPadding.pL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: AppTypography.h5.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                EventStatusChip(status: event.status),
              ],
            ),
            AppSpacing.h16,
            _buildInfoRow(Icons.calendar_today, 'Date & Time', DateFormat('dd MMM yyyy, hh:mm a').format(event.dateTime.toDate())),
            if (event.isTaskRequired) ...[
              AppSpacing.h16,
              _buildTaskInfoSection(context),
            ],

            AppSpacing.h24,
            Text('Description', style: AppTypography.body1.copyWith(fontWeight: FontWeight.bold)),
            AppSpacing.h8,
            Text(event.description, style: AppTypography.body2.copyWith(color: AppColors.grey5E)),
            if (event.teacherRemarks != null && event.teacherRemarks!.isNotEmpty) ...[
              AppSpacing.h24,
              Text('Teacher Remarks', style: AppTypography.body1.copyWith(fontWeight: FontWeight.bold)),
              AppSpacing.h8,
              Text(event.teacherRemarks!, style: AppTypography.body2.copyWith(color: AppColors.grey5E)),
            ],
            if (event.attachmentUrl != null && event.attachmentUrl!.isNotEmpty) ...[
              AppSpacing.h24,
              Text('Attachment', style: AppTypography.body1.copyWith(fontWeight: FontWeight.bold)),
              AppSpacing.h8,
              InkWell(
                onTap: () => _launchURL(event.attachmentUrl!),
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: AppRadius.radiusM,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.attach_file, color: AppColors.primary),
                      AppSpacing.hs,
                      const Text('View Attachment', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
            AppSpacing.h32,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: AppColors.primary),
          AppSpacing.hs,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.caption.copyWith(color: AppColors.grey5E)),
              Text(value, style: AppTypography.body2.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskInfoSection(BuildContext context) {
    return Container(
      padding: AppPadding.pM,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: AppRadius.radiusM,
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_turned_in_outlined, color: AppColors.primary, size: 24.sp),
              AppSpacing.hs,
              Text(
                'Task / Requirement',
                style: AppTypography.body1.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
          AppSpacing.h12,
          Text(event.taskTitle ?? 'Task', style: AppTypography.body2.copyWith(fontWeight: FontWeight.bold)),
          if (event.taskAmount != null)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text('Amount: ₹${event.taskAmount}', style: AppTypography.body2),
            ),
          if (event.taskNote != null && event.taskNote!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text('Note: ${event.taskNote}', style: AppTypography.body2),
            ),
          AppSpacing.h16,
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                NavigationService.push(context, EventTaskTrackingScreen(event: event));
              },
              icon: const Icon(Icons.group_outlined, color: Colors.white),
              label: Text('Track Student Status', style: AppTypography.body2.copyWith(
                color: AppColors.white
              )),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusM),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      SnackbarService().showError('Could not launch URL');
    }
  }
}
