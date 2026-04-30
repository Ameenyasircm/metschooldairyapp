import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:met_school/core/constants/app_padding.dart';
import 'package:met_school/core/constants/app_radius.dart';
import 'package:met_school/core/constants/app_spacing.dart';
import 'package:met_school/core/utils/loader/customLoader.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/widgets/buttons/gradient_button.dart';
import '../../../../../../core/widgets/custom_textfield.dart';
import '../../data/models/homework_model.dart';
import '../provider/homework_provider.dart';

class AddHomeworkScreen extends StatefulWidget {
  const AddHomeworkScreen({super.key});

  @override
  State<AddHomeworkScreen> createState() => _AddHomeworkScreenState();
}

class _AddHomeworkScreenState extends State<AddHomeworkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedSubject;
  DateTime? _selectedDate;

  String? _classId;
  String? _className;
  String? _divisionId;
  String? _divisionName;
  String? _teacherId;
  String? _teacherName;
  String? _academicId;

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
    Future.microtask(() => context.read<HomeworkProvider>().fetchSubjects());
  }

  Future<void> _loadTeacherData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _classId = prefs.getString("classId");
      _className = prefs.getString("className");
      _divisionId = prefs.getString("divisionId");
      _divisionName = prefs.getString("divisionName");
      _teacherId = prefs.getString("staffId");
      _teacherName = prefs.getString("staffName");
      _academicId = prefs.getString("academicYearId");
    });
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
        builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)),
            child: child!
        )
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveHomework() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null || _selectedSubject == null) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a due date')),
        );
      }
      if (_selectedSubject == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a subject')),
        );
      }
      return;
    }

    final homework = HomeworkModel(
      id: '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: _selectedDate!,
      createdAt: DateTime.now(),
      classId: _classId ?? '',
      className: _className ?? '',
      divisionId: _divisionId ?? '',
      divisionName: _divisionName ?? '',
      teacherId: _teacherId ?? '',
      teacherName: _teacherName ?? '',
      subject: _selectedSubject,
      academicYearId: _academicId??'',
    );

    try {
      await context.read<HomeworkProvider>().addHomework(homework);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Homework added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeworkProvider = context.watch<HomeworkProvider>();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        centerTitle: true,
        leading: const BackButton(color: AppColors.black),
        title: Text(
          'Add Homework',
          style: AppTypography.body1.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: AppPadding.pL,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSpacing.h6,
                    Text("Homework Details",
                        style: AppTypography.body2.copyWith(fontWeight: FontWeight.bold, color: AppColors.grey5E)
                    ),
                    AppSpacing.h12,

                    // Subject Dropdown
                    Consumer<HomeworkProvider>(
                      builder: (context, provider, child) {
                        return _buildInputWrapper(
                          child: DropdownButtonFormField<String>(
                            value: _selectedSubject,
                            dropdownColor: Colors.white,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            decoration: InputDecoration(
                              hintText: 'Select Subject',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                            ),
                            items: provider.subjectsList.map((subject) {
                              return DropdownMenuItem<String>(
                                value: subject['name'],
                                child: Text(subject['name'] ?? ''),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _selectedSubject = value),
                            validator: (v) => v == null ? 'Please select a subject' : null,
                          ),
                        );
                      },
                    ),
                    AppSpacing.h16,

                    // Title Field
                    AppTextField(
                      prefixIcon: null,
                      controller: _titleController,
                      hintText: 'Homework Title',
                      fillColor: AppColors.white,
                      validator: (v) => v!.isEmpty ? 'Enter title' : null,
                    ),
                    AppSpacing.h16,

                    // Description Field
                    AppTextField(
                      fillColor: AppColors.white,
                      controller: _descriptionController,
                      hintText: 'Describe the assignment...',
                      maxLine: 3,
                    ),
                    AppSpacing.h16,

                    // Date Picker Field
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: AppRadius.radiusM,
                      child: _buildInputWrapper(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 4.w),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_month_outlined, color: AppColors.darkGreen, size: 20.sp),
                              AppSpacing.w12,
                              Text(
                                _selectedDate == null
                                    ? 'Select Due Date'
                                    : 'Due Date: ${DateFormat('dd MMM yyyy').format(_selectedDate!)}',
                                style: AppTypography.body1.copyWith(
                                  color: _selectedDate == null ? AppColors.grey5E.withValues(alpha: 0.6) : AppColors.black,
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.chevron_right, color: AppColors.grey5E),
                            ],
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.h32,
                  ],
                ),
              ),
            ),
          ),

          // --- Persistent Bottom Button ---
          Padding(
            padding: EdgeInsets.all(20.w),
            child: homeworkProvider.isLoading
                ? const Center(child: CustomLoader())
                : SizedBox(
              width: double.infinity,
              child: gradientButton(
                text: 'Create Homework',
                onPressed: _saveHomework,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to maintain consistent premium styling for inputs
  Widget _buildInputWrapper({required Widget child}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusM,
        border: Border.all(color: AppColors.grey5E.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }}
