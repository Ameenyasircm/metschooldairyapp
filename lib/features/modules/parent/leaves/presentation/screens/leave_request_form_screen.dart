import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_typography.dart';
import 'package:met_school/core/constants/app_spacing.dart';
import 'package:met_school/core/constants/app_padding.dart';
import 'package:met_school/core/constants/app_radius.dart';
import 'package:met_school/core/models/leave_request_model.dart';
import 'package:met_school/providers/leave_provider.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/utils/snackbarNotification/snackbar_notification.dart';

class LeaveRequestFormScreen extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String teacherId;
  final String academicYearId;
  final String classId;
  final String className;

  const LeaveRequestFormScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.teacherId,
    required this.academicYearId,
    required this.classId,
    required this.className,
  });

  @override
  State<LeaveRequestFormScreen> createState() => _LeaveRequestFormScreenState();
}

class _LeaveRequestFormScreenState extends State<LeaveRequestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      SnackbarService().showError("Please select a date range");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final leaveRequest = LeaveRequestModel(
        studentId: widget.studentId,
        studentName: widget.studentName,
        teacherId: widget.teacherId,
        academicYearId: widget.academicYearId,
        classId: widget.classId,
        className: widget.className,
        reason: _reasonController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        createdAt: DateTime.now(),
      );

      await context.read<LeaveProvider>().submitLeaveRequest(leaveRequest);

      if (mounted) {
        Navigator.pop(context);
        SnackbarService().showSuccess("Leave request submitted successfully");
      }
    } catch (e) {
      if (mounted) {
        SnackbarService().showError("Error submitting request: $e");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text("Request Leave", style: AppTypography.h4.copyWith(color: AppColors.primary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppPadding.pL,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Select Dates", style: AppTypography.h6),
              AppSpacing.h8,
              InkWell(
                onTap: () => _selectDateRange(context),
                child: Container(
                  padding: AppPadding.pM,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.radiusM,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: AppColors.primary),
                      AppSpacing.w12,
                      Text(
                        _startDate == null
                            ? "Tap to select date range"
                            : "${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}",
                        style: AppTypography.body1,
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacing.h24,
              Text("Reason for Leave", style: AppTypography.h6),
              AppSpacing.h8,
              TextFormField(
                controller: _reasonController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Enter the reason for leave...",
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.radiusM,
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.radiusM,
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter a reason";
                  }
                  return null;
                },
              ),
              AppSpacing.h32,
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.radiusM,
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Submit Request",
                          style: AppTypography.h6.copyWith(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
