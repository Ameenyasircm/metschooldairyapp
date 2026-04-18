import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_padding.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons/gradient_button.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../../../../core/utils/loader/customLoader.dart';
import '../providers/homework_provider.dart';

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

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a due date')),
      );
      return;
    }

    try {
      await context.read<HomeworkProvider>().addHomework(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            subject: _subjectController.text.trim(),
            dueDate: _selectedDate!,
          );
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
    final provider = context.watch<HomeworkProvider>();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: Text('Add Homework',
            style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: AppPadding.pL,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInfoSection(provider),
              AppSpacing.h20,
              _buildFormFields(),
              AppSpacing.h32,
              provider.isLoading
                  ? const Center(child: CustomLoader())
                  : gradientButton(
                      text: 'Create Homework',
                      onPressed: _submit,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(HomeworkProvider provider) {
    return Container(
      padding: AppPadding.pM,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: AppRadius.radiusM,
      ),
      child: Text(
        'Class: ${provider.className ?? "-"} - ${provider.divisionName ?? "-"}',
        style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
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
        ),
        AppSpacing.h16,
        _buildDatePicker(),
      ],
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _pickDate,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 15.h),
        decoration: BoxDecoration(
          color: AppColors.greenE1,
          borderRadius: AppRadius.radiusS,
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.primary, size: 20.sp),
            AppSpacing.w12,
            Text(
              _selectedDate == null
                  ? 'Select Due Date'
                  : 'Due Date: ${DateFormat('dd MMM yyyy').format(_selectedDate!)}',
              style: AppTypography.body1.copyWith(
                color: _selectedDate == null ? AppColors.grey5E.withOpacity(0.5) : AppColors.darkGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
