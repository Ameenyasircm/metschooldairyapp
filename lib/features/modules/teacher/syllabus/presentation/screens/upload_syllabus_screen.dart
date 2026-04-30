import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/constants/app_padding.dart';
import '../../../../../../core/constants/app_radius.dart';
import '../../../../../../core/constants/app_spacing.dart';
import '../../../../../../core/utils/loader/customLoader.dart';
import '../../../../../../core/widgets/buttons/gradient_button.dart';
import '../../../../../../core/utils/snackbarNotification/snackbar_notification.dart';
import '../provider/syllabus_provider.dart';

class UploadSyllabusScreen extends StatefulWidget {
  const UploadSyllabusScreen({super.key});

  @override
  State<UploadSyllabusScreen> createState() => _UploadSyllabusScreenState();
}

class _UploadSyllabusScreenState extends State<UploadSyllabusScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedSubject;
  File? _selectedFile;
  String? _fileName;

  String? _classId;
  String? _className;
  String? _divisionId;
  String? _divisionName;
  String? _teacherId;

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
    // Use provider to fetch subjects
    Future.microtask(() => context.read<SyllabusProvider>().fetchSubjects());
  }

  Future<void> _loadTeacherData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _classId = prefs.getString("classId");
      _className = prefs.getString("className");
      _divisionId = prefs.getString("divisionId");
      _divisionName = prefs.getString("divisionName");
      _teacherId = prefs.getString("staffId");
    });
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      int fileSizeInBytes = await file.length();
      double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

      if (fileSizeInMB > 10) {
        if (mounted) {
          SnackbarService().showError('File size must be less than 10MB');
        }
        return;
      }

      setState(() {
        _selectedFile = file;
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _uploadSyllabus() async {
    if (_selectedSubject == null) {
      SnackbarService().showError('Please select a subject');
      return;
    }

    if (_selectedFile == null) {
      SnackbarService().showError('Please select a PDF file');
      return;
    }

    final success = await context.read<SyllabusProvider>().uploadSyllabus(
      file: _selectedFile!,
      subject: _selectedSubject!,
      classId: _classId ?? '',
      className: _className ?? '',
      divisionId: _divisionId ?? '',
      divisionName: _divisionName ?? '',
      teacherId: _teacherId ?? '',
    );

    if (success && mounted) {
      Navigator.pop(context);
      SnackbarService().showSuccess('Syllabus uploaded successfully');
    } else if (mounted) {
      final error = context.read<SyllabusProvider>().errorMessage;
      SnackbarService().showError(error ?? 'Upload failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final syllabusProvider = context.watch<SyllabusProvider>();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        centerTitle: true,
        leading: const BackButton(color: AppColors.black),
        title: Text(
          'Upload Syllabus',
          style: AppTypography.body1.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: AppPadding.pL,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.h16,
              Text("Class: ${_className ?? 'N/A'} - ${_divisionName ?? 'N/A'}", 
                style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600)),
              AppSpacing.h24,
              
              Text("Subject", style: AppTypography.body2.copyWith(fontWeight: FontWeight.bold, color: AppColors.grey5E)),
              AppSpacing.h8,
              _buildInputWrapper(
                child: DropdownButtonFormField<String>(
                  value: _selectedSubject,
                  dropdownColor: Colors.white,
                  hint: const Text("Select Subject"),
                  decoration: const InputDecoration(border: InputBorder.none),
                  items: syllabusProvider.subjectsList.map((subject) {
                    return DropdownMenuItem<String>(
                      value: subject['name'],
                      child: Text(subject['name'] ?? ''),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedSubject = value),
                ),
              ),
              AppSpacing.h24,

              Text("Syllabus PDF", style: AppTypography.body2.copyWith(fontWeight: FontWeight.bold, color: AppColors.grey5E)),
              AppSpacing.h8,
              InkWell(
                onTap: _pickFile,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppColors.greyE0.withOpacity(0.2),
                    borderRadius: AppRadius.radiusM,
                    border: Border.all(color: AppColors.greyE0, style: BorderStyle.solid),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.upload_file, size: 40.sp, color: AppColors.primary),
                      AppSpacing.h8,
                      Text(
                        _fileName ?? "Tap to select PDF (Max 10MB)",
                        style: AppTypography.body2.copyWith(color: AppColors.grey5E),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              syllabusProvider.isLoading
                ? const Center(child: CustomLoader())
                : SizedBox(
                    width: double.infinity,
                    child: gradientButton(
                      text: 'Upload Syllabus',
                      onPressed: _uploadSyllabus,
                    ),
                  ),
              AppSpacing.h24,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputWrapper({required Widget child}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusM,
        border: Border.all(color: AppColors.grey5E.withValues(alpha: 0.15)),
      ),
      child: child,
    );
  }
}
