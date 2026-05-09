import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
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

class EventDetailScreen extends StatelessWidget {
  final EventModel event;
  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text('Event Details', style: AppTypography.h6.copyWith(fontWeight: FontWeight.bold)),
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
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteConfirmation(context),
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
            _buildInfoRow(Icons.person, 'Created By', event.createdByName),
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
            const Divider(),
            AppSpacing.h16,
            Text('Parent Remarks', style: AppTypography.body1.copyWith(fontWeight: FontWeight.bold)),
            AppSpacing.h8,
            _buildParentRemarks(context),
            AppSpacing.h32,
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAction(context),
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

  Widget _buildParentRemarks(BuildContext context) {
    return StreamBuilder<List<ParentRemarkModel>>(
      stream: context.read<EventProvider>().getRemarks(event.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No parent remarks yet.', style: AppTypography.caption.copyWith(fontStyle: FontStyle.italic));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final remark = snapshot.data![index];
            return Card(
              margin: EdgeInsets.only(bottom: 8.h),
              child: ListTile(
                title: Text(remark.parentName, style: AppTypography.body2.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text(remark.remark, style: AppTypography.caption),
                trailing: Text(DateFormat('dd/MM').format(remark.updatedAt.toDate()), style: AppTypography.caption),
              ),
            );
          },
        );
      },
    );
  }

  Widget? _buildBottomAction(BuildContext context) {
    if (event.status == 'completed' || event.status == 'cancelled') return null;

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _updateStatus(context, 'cancelled'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
              child: const Text('Cancel Event'),
            ),
          ),
          AppSpacing.hs,
          Expanded(
            child: ElevatedButton(
              onPressed: () => _updateStatus(context, 'completed'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Mark Completed', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, String status) async {
    final remarksController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Status to ${status.toUpperCase()}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add optional remarks:'),
            AppSpacing.h8,
            TextField(controller: remarksController, decoration: const InputDecoration(hintText: 'Remarks')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirm')),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await context.read<EventProvider>().updateStatus(event.id, status, remarks: remarksController.text);
      if (success) {
        SnackbarService().showSuccess('Event updated');
        Navigator.pop(context);
      }
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await context.read<EventProvider>().deleteEvent(event.id);
      if (success) {
        SnackbarService().showSuccess('Event deleted');
        Navigator.pop(context);
      }
    }
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
