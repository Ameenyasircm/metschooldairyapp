import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/constants/app_radius.dart';
import '../../data/models/syllabus_model.dart';
import '../screens/syllabus_view_screen.dart';

class SyllabusCard extends StatelessWidget {
  final SyllabusModel syllabus;

  const SyllabusCard({super.key, required this.syllabus});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusM),
      elevation: 0,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.picture_as_pdf, color: Colors.red),
        ),
        title: Text(syllabus.subject, style: AppTypography.body2.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(
          "Uploaded: ${DateFormat('dd MMM yyyy').format(syllabus.uploadedAt)}",
          style: AppTypography.caption.copyWith(color: AppColors.grey5E),
        ),
        trailing: Wrap(
          spacing: 8,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SyllabusViewScreen(
                    url: syllabus.fileUrl,
                    title: syllabus.subject,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text("View", style: AppTypography.body2.copyWith(color: AppColors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
