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
  final _subjectController = TextEditingController();
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
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a due date')),
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
      subject: _subjectController.text.trim(),
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
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title:Text('Add Homework',style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600),),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding:AppPadding.pL,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: AppColors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusM),
                child: Padding(
                  padding:AppPadding.pM,
                  child: Column(
                    children: [
                      Text(
                        'Class: $_className - $_divisionName',
                        style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600),
                      ),
                      AppSpacing.h20,
                      AppTextField(
                        controller: _subjectController,
                        hintText: 'Subject (e.g., Mathematics)',
                        prefixIcon: Icons.book,
                      ),
                      AppSpacing.h16,
                      AppTextField(
                        controller: _titleController,
                        hintText: 'Homework Title',
                        prefixIcon: Icons.title,
                        validator: (v) => v!.isEmpty ? 'Enter title' : null,
                      ),
                      AppSpacing.h16,
                      AppTextField(
                        controller: _descriptionController,
                        hintText: 'Description',
                        prefixIcon: Icons.description,
                        // Removed maxLines as AppTextField doesn't seem to support it in the current definition
                      ),
                      AppSpacing.h16,
                      InkWell(
                        onTap: _pickDate,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 15..h),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Colors.blue),
                              AppSpacing.w12,
                              Text(
                                _selectedDate == null
                                    ? 'Select Due Date'
                                    : 'Due Date: ${DateFormat('dd MMM yyyy').format(_selectedDate!)}',
                                style: TextStyle(
                                  color: _selectedDate == null ? Colors.grey : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacing.h32,
              context.watch<HomeworkProvider>().isLoading
                  ? const Center(child: CustomLoader())
                  : gradientButton(
                      text: 'Create Homework',
                      onPressed: _saveHomework,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
