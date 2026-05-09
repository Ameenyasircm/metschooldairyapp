import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_padding.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/widgets/buttons/gradient_button.dart';
import '../../../../../../core/utils/snackbarNotification/snackbar_notification.dart';
import '../../../../../../core/utils/loader/customLoader.dart';
import '../../../../../../core/widgets/inputs/app_textfield.dart';
import '../../data/models/event_model.dart';
import '../provider/event_provider.dart';

class AddEditEventScreen extends StatefulWidget {
  final EventModel? event;
  const AddEditEventScreen({super.key, this.event});

  @override
  State<AddEditEventScreen> createState() => _AddEditEventScreenState();
}

class _AddEditEventScreenState extends State<AddEditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _remarksController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  File? _selectedFile;
  String? _fileName;
  String _status = 'pending';

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _titleController.text = widget.event!.title;
      _descriptionController.text = widget.event!.description;
      _remarksController.text = widget.event!.teacherRemarks ?? '';
      _selectedDate = widget.event!.dateTime.toDate();
      _selectedTime = TimeOfDay.fromDateTime(widget.event!.dateTime.toDate());
      _status = widget.event!.status;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
        builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)),
            child: child!
        )
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      SnackbarService().showError('Please select date and time');
      return;
    }

    final combinedDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final success = await context.read<EventProvider>().createOrUpdateEvent(
          id: widget.event?.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dateTime: combinedDateTime,
          attachmentFile: _selectedFile,
          status: _status,
          teacherRemarks: _remarksController.text.trim(),
        );

    if (success && mounted) {
      SnackbarService().showSuccess(widget.event == null ? 'Event created' : 'Event updated');
      Navigator.pop(context);
    } else if (mounted) {
      SnackbarService().showError(context.read<EventProvider>().errorMessage ?? 'Operation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventProvider>();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(widget.event == null ? 'Add Event' : 'Edit Event',
            style: AppTypography.h6.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: provider.isLoading
          ? const Center(child: CustomLoader())
          : SingleChildScrollView(
              padding: AppPadding.pL,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Title'),
                    AppTextField(
                      controller: _titleController,
                      hintText: "",
                      labelText: "Enter event title",
                      prefixIcon: Icons.event,
                      fillColor: Colors.white,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter event title";
                        }
                        return null;
                      },
                    ),
                    AppSpacing.h16,
                    _buildLabel('Description'),
                    AppTextField(
                      controller: _descriptionController,
                      hintText: "",
                      labelText: "Enter description",
                      prefixIcon: Icons.description,
                      fillColor: Colors.white,
                      maxLine: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter description";
                        }
                        return null;
                      },
                    ),
                    AppSpacing.h16,
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Date'),
                              _buildPickerButton(
                                icon: Icons.calendar_today,
                                text: _selectedDate == null ? 'Select Date' : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                                onTap: _pickDate,
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.hs,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Time'),
                              _buildPickerButton(
                                icon: Icons.access_time,
                                text: _selectedTime == null ? 'Select Time' : _selectedTime!.format(context),
                                onTap: _pickTime,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    AppSpacing.h16,
                    _buildLabel('Status'),
                    _buildDropdown(),
                    AppSpacing.h16,
                    _buildLabel('Teacher Remarks (Optional)'),
                    AppTextField(
                      controller: _remarksController,
                      hintText: "",
                      labelText: "Enter remarks",
                      prefixIcon: Icons.wysiwyg_rounded,
                      fillColor: Colors.white,
                      maxLine: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter remarks";
                        }
                        return null;
                      },
                    ),
                    AppSpacing.h16,
                    _buildLabel('Attachment (Optional)'),
                    _buildFilePicker(),
                    AppSpacing.h32,
                    SizedBox(
                      width: double.infinity,
                      child: gradientButton(
                        text: widget.event == null ? 'Create Event' : 'Update Event',
                        onPressed: _save,
                      ),
                    ),
                    AppSpacing.h32,
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(text, style: AppTypography.body2.copyWith(fontWeight: FontWeight.bold, color: AppColors.grey5E)),
    );
  }


  Widget _buildPickerButton({required IconData icon, required String text, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.greyE0),
          borderRadius: AppRadius.radiusM,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: AppColors.primary),
            AppSpacing.hs,
            Text(text, style: AppTypography.body2),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greyE0),
        borderRadius: AppRadius.radiusM,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _status,
          isExpanded: true,
          items: ['pending', 'completed', 'cancelled'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value.toUpperCase()),
            );
          }).toList(),
          onChanged: (val) => setState(() => _status = val!),
        ),
      ),
    );
  }

  Widget _buildFilePicker() {
    return InkWell(
      onTap: _pickFile,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.greyE0, style: BorderStyle.solid),
          borderRadius: AppRadius.radiusM,
          color: AppColors.greyE0.withOpacity(0.1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload_file, color: AppColors.primary),
            AppSpacing.hs,
            Expanded(child: Text(_fileName ?? 'Select attachment', style: AppTypography.body2)),
          ],
        ),
      ),
    );
  }
}
