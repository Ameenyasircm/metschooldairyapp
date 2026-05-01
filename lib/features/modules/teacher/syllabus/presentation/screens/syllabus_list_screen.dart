import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/constants/app_padding.dart';
import '../../../../../../core/constants/app_spacing.dart';
import '../../../../../../core/utils/loader/customLoader.dart';
import '../provider/syllabus_provider.dart';
import '../widgets/syllabus_card.dart';
import 'upload_syllabus_screen.dart';

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
        backgroundColor: AppColors.lightBackground,
        title: Text('Syllabus Management',
            style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600,color: AppColors.primary,),),
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
                    return SyllabusCard(syllabus: syllabus);
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
            style: AppTypography.body2.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
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
