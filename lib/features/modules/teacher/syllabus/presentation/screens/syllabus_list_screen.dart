import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/constants/app_padding.dart';
import '../../../../../../core/constants/app_radius.dart';
import '../../../../../../core/constants/app_spacing.dart';
import '../../../../../../core/utils/loader/customLoader.dart';
import '../provider/syllabus_provider.dart';
import 'upload_syllabus_screen.dart';
import 'syllabus_view_screen.dart';

class SyllabusListScreen extends StatefulWidget {
  const SyllabusListScreen({super.key});

  @override
  State<SyllabusListScreen> createState() => _SyllabusListScreenState();
}

class _SyllabusListScreenState extends State<SyllabusListScreen> {
  String? _classId;
  String? _className;
  String? _divisionId;
  String? _divisionName;

  @override
  void initState() {
    super.initState();
    _loadAndFetch();
  }

  Future<void> _loadAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _classId = prefs.getString("classId");
      _className = prefs.getString("className");
      _divisionId = prefs.getString("divisionId");
      _divisionName = prefs.getString("divisionName");
    });

    if (_classId != null && _divisionId != null) {
      context.read<SyllabusProvider>().fetchSyllabus(
        classId: _classId!,
        divisionId: _divisionId!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: Text('Syllabus Management',
            style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () => _loadAndFetch(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Consumer<SyllabusProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.syllabusList.isEmpty) {
                  return const Center(child: CustomLoader());
                }

                if (provider.syllabusList.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: AppPadding.pM,
                  itemCount: provider.syllabusList.length,
                  itemBuilder: (context, index) {
                    final syllabus = provider.syllabusList[index];
                    return _buildSyllabusCard(syllabus);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UploadSyllabusScreen()),
        ).then((_) => _loadAndFetch()),
        backgroundColor: AppColors.primary,
        label: Text('Upload Syllabus',
            style: AppTypography.body2.copyWith(color: AppColors.white)),
        icon: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16.w),
      color: AppColors.white,
      child: Row(
        children: [
          const Icon(Icons.class_outlined, color: AppColors.primary),
          AppSpacing.w12,
          Text(
            "${_className ?? 'N/A'} - ${_divisionName ?? 'N/A'}",
            style: AppTypography.body1.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSyllabusCard(syllabus) {
    return Card(
       color: AppColors.white,
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusM),
      elevation: 1,
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
        title: Text(syllabus.subject, style: AppTypography.body1.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(
          "Uploaded: ${DateFormat('dd MMM yyyy').format(syllabus.uploadedAt)}",
          style: AppTypography.caption.copyWith(color: AppColors.grey5E),
        ),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(
              icon: const Icon(Icons.open_in_browser, color: AppColors.primary),
              onPressed: () async {
                final uri = Uri.parse(syllabus.fileUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 64, color: AppColors.grey5E.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('No syllabus uploaded for this class',
              style: AppTypography.body2.copyWith(color: AppColors.grey5E)),
        ],
      ),
    );
  }
}
