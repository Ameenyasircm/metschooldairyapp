import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_padding.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/utils/loader/customLoader.dart';
import '../../../../../../core/utils/snackbarNotification/snackbar_notification.dart';
import '../../../../../../core/widgets/inputs/app_textfield.dart';
import '../../data/models/event_model.dart';
import '../provider/event_provider.dart';
import '../../../students/data/models/tech_student_model.dart';

class EventTaskTrackingScreen extends StatefulWidget {
  final EventModel event;
  const EventTaskTrackingScreen({super.key, required this.event});

  @override
  State<EventTaskTrackingScreen> createState() => _EventTaskTrackingScreenState();
}

class _EventTaskTrackingScreenState extends State<EventTaskTrackingScreen> {
  List<EnrollerModel>? _students;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    final students = await context.read<EventProvider>().getStudentsForEvent(widget.event.id);
    if (mounted) {
      setState(() {
        _students = students;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text('Task Tracking', style: AppTypography.h6.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CustomLoader())
          : Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: StreamBuilder<List<StudentEventTaskModel>>(
                    stream: context.read<EventProvider>().getStudentTasks(widget.event.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                        return const Center(child: CustomLoader());
                      }

                      final tasks = snapshot.data ?? [];
                      final taskMap = {for (var t in tasks) t.studentId: t};

                      if (_students == null || _students!.isEmpty) {
                        return const Center(child: Text('No students found for this class.'));
                      }

                      return ListView.builder(
                        padding: AppPadding.pM,
                        itemCount: _students!.length,
                        itemBuilder: (context, index) {
                          final student = _students![index];
                          final task = taskMap[student.studentId];

                          return _buildStudentCard(student, task);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: AppPadding.pM,
      color: AppColors.primary.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.event.taskTitle ?? widget.event.title, style: AppTypography.body1.copyWith(fontWeight: FontWeight.bold)),
          AppSpacing.h4,
          Text(
            '${widget.event.taskAmount != null ? "Amount: ₹${widget.event.taskAmount} | " : ""}${widget.event.taskNote ?? ""}',
            style: AppTypography.caption.copyWith(color: AppColors.grey5E),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(EnrollerModel student, StudentEventTaskModel? task) {
    final status = task?.status ?? 'Pending';
    Color statusColor;
    switch (status) {
      case 'Completed':
        statusColor = Colors.green;
        break;
      case 'Not Completed':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: EdgeInsets.only(bottom: 10.h),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusM),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        title: Text(
            student.name,
            style: AppTypography.body2.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Roll No: ${student.rollNumber}', style: AppTypography.caption),
            if (task?.remark != null && task!.remark!.isNotEmpty)
              Text('Remark: ${task.remark}', style: AppTypography.caption.copyWith(fontStyle: FontStyle.italic)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status,
                style: AppTypography.caption.copyWith(color: statusColor, fontWeight: FontWeight.bold),
              ),
            ),
            AppSpacing.h4,
            const Icon(Icons.mode_edit_outline_outlined, size: 20, color: AppColors.grey5E),
          ],
        ),
        onTap: () => _showUpdateStatusDialog(student, task),
      ),
    );
  }

  Future<void> _showUpdateStatusDialog(
    EnrollerModel student,
    StudentEventTaskModel? task,
  ) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return _UpdateStatusDialog(
          event: widget.event,
          student: student,
          task: task,
        );
      },
    );
  }
}

class _UpdateStatusDialog extends StatefulWidget {
  final EventModel event;
  final EnrollerModel student;
  final StudentEventTaskModel? task;

  const _UpdateStatusDialog({
    required this.event,
    required this.student,
    this.task,
  });

  @override
  State<_UpdateStatusDialog> createState() => _UpdateStatusDialogState();
}

class _UpdateStatusDialogState extends State<_UpdateStatusDialog> {
  late TextEditingController _remarkController;
  late String _selectedStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _remarkController = TextEditingController(text: widget.task?.remark ?? '');
    _selectedStatus = widget.task?.status ?? 'Pending';
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final remark = _remarkController.text.trim();

    final success = await context.read<EventProvider>().updateStudentTaskStatus(
          eventId: widget.event.id,
          studentId: widget.student.studentId,
          studentName: widget.student.name,
          status: _selectedStatus,
          remark: remark.isEmpty ? null : remark,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context);
      SnackbarService().showSuccess('Status updated successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_isLoading,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.task_alt_rounded,
                          color: AppColors.primary,
                          size: 22.sp,
                        ),
                      ),
                      AppSpacing.w12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Update Status",
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            AppSpacing.h4,
                            Text(
                              widget.student.name,
                              style: AppTypography.captionL.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  AppSpacing.h24,

                  /// Status Title
                  Text(
                    "Select Status",
                    style: AppTypography.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  AppSpacing.h12,

                  /// Status Dropdown
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedStatus,
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(16.r),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.primary,
                        ),
                        style: AppTypography.body2.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        dropdownColor: Colors.white,
                        items: [
                          _buildDropdownItem("Pending", Icons.schedule_rounded, Colors.orange),
                          _buildDropdownItem("Completed", Icons.check_circle_rounded, Colors.green),
                          _buildDropdownItem("Not Completed", Icons.cancel_rounded, Colors.red),
                        ],
                        onChanged: _isLoading
                            ? null
                            : (value) {
                                if (value == null) return;
                                setState(() => _selectedStatus = value);
                              },
                      ),
                    ),
                  ),

                  AppSpacing.h20,

                  /// Remark
                  AppTextField(
                    controller: _remarkController,
                    hintText: "Add optional remark",
                    labelText: "Remark",
                    fillColor: Colors.grey.shade50,
                    maxLine: 3,
                  ),

                  AppSpacing.h24,

                  /// Actions
                  Row(
                    children: [
                      /// Cancel
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: 14.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                14.r,
                              ),
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: AppTypography.body2,
                          ),
                        ),
                      ),

                      AppSpacing.w12,

                      /// Update
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleUpdate,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(
                              vertical: 14.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                14.r,
                              ),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 18.h,
                                  width: 18.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  "Update",
                                  style: AppTypography.body2.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  DropdownMenuItem<String> _buildDropdownItem(String value, IconData icon, Color color) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20.sp,
          ),
          AppSpacing.w12,
          Text(value, style: AppTypography.caption),
        ],
      ),
    );
  }


}
