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
import '../../../../teacher/events/data/models/event_model.dart';
import '../../../../teacher/events/presentation/provider/event_provider.dart';
import '../../../../teacher/events/presentation/widgets/event_status_chip.dart';

class ParentEventDetailScreen extends StatefulWidget {
  final EventModel event;
  const ParentEventDetailScreen({super.key, required this.event});

  @override
  State<ParentEventDetailScreen> createState() => _ParentEventDetailScreenState();
}

class _ParentEventDetailScreenState extends State<ParentEventDetailScreen> {
  final _remarkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text('Event Details', style: AppTypography.h6.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
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
                    widget.event.title,
                    style: AppTypography.h5.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                EventStatusChip(status: widget.event.status),
              ],
            ),
            AppSpacing.h16,
            _buildInfoRow(Icons.calendar_today, 'Date & Time', DateFormat('dd MMM yyyy, hh:mm a').format(widget.event.dateTime.toDate())),
            _buildInfoRow(Icons.person, 'Posted by', widget.event.createdByName),
            AppSpacing.h24,
            Text('Description', style: AppTypography.body1.copyWith(fontWeight: FontWeight.bold)),
            AppSpacing.h8,
            Text(widget.event.description, style: AppTypography.body2.copyWith(color: AppColors.grey5E)),
            if (widget.event.teacherRemarks != null && widget.event.teacherRemarks!.isNotEmpty) ...[
              AppSpacing.h24,
              Text('Teacher Remarks', style: AppTypography.body1.copyWith(fontWeight: FontWeight.bold)),
              AppSpacing.h8,
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: AppRadius.radiusM,
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Text(widget.event.teacherRemarks!, style: AppTypography.body2.copyWith(color: AppColors.grey5E)),
              ),
            ],
            if (widget.event.attachmentUrl != null && widget.event.attachmentUrl!.isNotEmpty) ...[
              AppSpacing.h24,
              Text('Attachment', style: AppTypography.body1.copyWith(fontWeight: FontWeight.bold)),
              AppSpacing.h8,
              InkWell(
                onTap: () => _launchURL(widget.event.attachmentUrl!),
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
            Text('Your Remarks', style: AppTypography.body1.copyWith(fontWeight: FontWeight.bold)),
            AppSpacing.h8,
            _buildMyRemarkSection(),
            AppSpacing.h24,
            Text('Other Parent Remarks', style: AppTypography.body1.copyWith(fontWeight: FontWeight.bold)),
            AppSpacing.h8,
            _buildOtherParentRemarks(),
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

  Widget _buildMyRemarkSection() {
    return Column(
      children: [
        TextField(
          controller: _remarkController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Add your comment/remark...',
            border: OutlineInputBorder(borderRadius: AppRadius.radiusM),
            contentPadding: EdgeInsets.all(12.w),
          ),
        ),
        AppSpacing.h8,
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: _submitRemark,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Submit Remark', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildOtherParentRemarks() {
    return StreamBuilder<List<ParentRemarkModel>>(
      stream: context.read<EventProvider>().getRemarks(widget.event.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No remarks yet.', style: AppTypography.caption.copyWith(fontStyle: FontStyle.italic));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final remark = snapshot.data![index];
            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.greyE0.withOpacity(0.1),
                borderRadius: AppRadius.radiusM,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(remark.parentName, style: AppTypography.body2.copyWith(fontWeight: FontWeight.bold)),
                      Text(DateFormat('dd/MM HH:mm').format(remark.updatedAt.toDate()), style: AppTypography.caption),
                    ],
                  ),
                  AppSpacing.h4,
                  Text(remark.remark, style: AppTypography.body2),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submitRemark() async {
    if (_remarkController.text.trim().isEmpty) return;
    
    final success = await context.read<EventProvider>().addParentRemark(widget.event.id, _remarkController.text.trim());
    if (success) {
      _remarkController.clear();
      SnackbarService().showSuccess('Remark added');
      FocusScope.of(context).unfocus();
    } else {
      SnackbarService().showError('Failed to add remark');
    }
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
