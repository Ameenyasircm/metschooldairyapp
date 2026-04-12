import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:met_school/core/constants/app_padding.dart';
import 'package:met_school/core/constants/app_radius.dart';
import 'package:met_school/core/constants/app_spacing.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_typography.dart';
import 'package:met_school/core/utils/loader/customLoader.dart';
import 'package:met_school/core/utils/snackbarNotification/snackbar_notification.dart';
import 'package:provider/provider.dart';
import '../../../students/presentation/provider/student_provider.dart';
import '../provider/attendance_provider.dart';
import '../../data/models/attendance_model.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final studentProvider = context.read<StudentProvider>();
      final attendanceProvider = context.read<AttendanceProvider>();
      
      if (studentProvider.myAllStudents.isEmpty) {
        studentProvider.fetchMyStudentsInitial().then((_) {
          attendanceProvider.initializeStudents(studentProvider.myAllStudents);
          attendanceProvider.fetchAttendance(studentProvider.assignedDivision?.id);
        });
      } else {
        attendanceProvider.initializeStudents(studentProvider.myAllStudents);
        attendanceProvider.fetchAttendance(studentProvider.assignedDivision?.id);
      }
    });
  }

  void _onFilterChanged() {
    final studentProvider = context.read<StudentProvider>();
    final attendanceProvider = context.read<AttendanceProvider>();
    attendanceProvider.fetchAttendance(studentProvider.assignedDivision?.id);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'Add Attendance',
          style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchField(),
          _buildBulkActions(),
          Expanded(child: _buildStudentList()),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer2<StudentProvider, AttendanceProvider>(
      builder: (context, studentProvider, attendanceProvider, _) {
        final division = studentProvider.assignedDivision;
        return Padding(
          padding: AppPadding.phM,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        division?.name ?? "No Class Assigned",
                        style: AppTypography.body1.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        DateFormat('EEEE, dd MMM yyyy').format(attendanceProvider.selectedDate),
                        style: AppTypography.caption.copyWith(color: AppColors.greyB2),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today, color: AppColors.primary),
                    onPressed: () => _selectDate(context, attendanceProvider),
                  ),
                ],
              ),
              AppSpacing.vs,
              _buildSessionToggle(attendanceProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchField() {
    return Container(
      margin: AppPadding.phM.copyWith(bottom: 8.h, top: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusM,
        boxShadow: [
          BoxShadow(
            color: Colors.black87.withOpacity(.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search by name/Admission No.",
          hintStyle: AppTypography.body2.copyWith(color: AppColors.greyB2),
          border: InputBorder.none,
          isDense: true,
          prefixIcon: const Icon(Icons.search, color: AppColors.greyB2),
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        ),
        onChanged: (value) {
          context.read<AttendanceProvider>().searchStudents(value);
        },
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, AttendanceProvider provider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      provider.setDate(picked);
      _onFilterChanged();
    }
  }

  Widget _buildSessionToggle(AttendanceProvider provider) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.greyB2.withOpacity(0.2),
        borderRadius: AppRadius.radiusM,
      ),
      child: Row(
        children: [
          _buildToggleButton(
            title: 'Morning (FN)',
            isSelected: provider.selectedSession == AttendanceSession.morning,
            onTap: () {
              provider.setSession(AttendanceSession.morning);
              _onFilterChanged();
            },
          ),
          _buildToggleButton(
            title: 'Afternoon (AN)',
            isSelected: provider.selectedSession == AttendanceSession.afternoon,
            onTap: () {
              provider.setSession(AttendanceSession.afternoon);
              _onFilterChanged();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: AppRadius.radiusM,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.body2.copyWith(
              color: AppColors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBulkActions() {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: AppPadding.phM,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => provider.markAll(AttendanceStatus.present),
                  icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                  label: const Text('All Present', style: TextStyle(color: Colors.green)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.green),
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusS),
                  ),
                ),
              ),
              AppSpacing.hm,
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => provider.markAll(AttendanceStatus.absent),
                  icon: const Icon(Icons.highlight_off, color: Colors.red, size: 18),
                  label: const Text('All Absent', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusS),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStudentList() {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, _) {
        if (provider.students.isEmpty) {
          return const Center(child: Text('No students found.'));
        }
        return ListView.separated(
          padding: AppPadding.pM,
          itemCount: provider.students.length,
          separatorBuilder: (_, __) => AppSpacing.vs,
          itemBuilder: (context, index) {
            final student = provider.students[index];
            return Container(
              padding: AppPadding.pM,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.radiusM,
                border: Border.all(
                  color: student.status == AttendanceStatus.present
                      ? Colors.green.withOpacity(0.3)
                      : student.status == AttendanceStatus.absent
                          ? Colors.red.withOpacity(0.3)
                          : student.status == AttendanceStatus.late
                              ? Colors.orange.withOpacity(0.3)
                              : AppColors.grey5E,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(student.studentName,
                                style: AppTypography.body1.copyWith(fontWeight: FontWeight.w500)),
                            Text('Adm: ${student.admissionNumber}',
                                style: AppTypography.caption.copyWith(color: AppColors.greyB2)),
                          ],
                        ),
                      ),
                      _buildStatusSelector(student, provider),
                    ],
                  ),
                  if (student.status == AttendanceStatus.late && student.lateReason != null)
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Text(
                        "Reason: ${student.lateReason}",
                        style: AppTypography.caption.copyWith(color: Colors.orange, fontStyle: FontStyle.italic),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusSelector(StudentAttendance student, AttendanceProvider provider) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatusButton(
          label: 'P',
          isSelected: student.status == AttendanceStatus.present,
          activeColor: Colors.green,
          onTap: () => provider.updateStatus(student.studentId, AttendanceStatus.present),
        ),
        AppSpacing.hs,
        _buildStatusButton(
          label: 'A',
          isSelected: student.status == AttendanceStatus.absent,
          activeColor: Colors.red,
          onTap: () => provider.updateStatus(student.studentId, AttendanceStatus.absent),
        ),
        AppSpacing.hs,
        _buildStatusButton(
          label: 'L',
          isSelected: student.status == AttendanceStatus.late,
          activeColor: Colors.orange,
          onTap: () => _showLateReasonDialog(context, student, provider),
        ),
      ],
    );
  }

  void _showLateReasonDialog(BuildContext context, StudentAttendance student, AttendanceProvider provider) {
    final TextEditingController reasonController = TextEditingController(text: student.lateReason);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Late Reason for ${student.studentName}", style: AppTypography.body1),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(hintText: "Enter reason (e.g., Bus delay)"),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              provider.updateStatus(student.studentId, AttendanceStatus.late, reason: reasonController.text);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton({
    required String label,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: isSelected ? activeColor : AppColors.greyB2,
          borderRadius: AppRadius.radiusS,
          border: Border.all(
            color: isSelected ? activeColor : AppColors.greyB2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.body2.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: AppPadding.pM,
          child: SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: provider.isLoading ? null : () async {
                try {
                  await provider.saveAttendance();
                  if (mounted) {
                    SnackbarService().showSuccess("Attendance saved successfully!");
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (mounted) {
                    SnackbarService().showError(e.toString().replaceAll("Exception: ", ""));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusL),
                elevation: 0,
              ),
              child: provider.isLoading
                  ? const CustomLoader()
                  : Text(
                      'Save ${provider.selectedSession == AttendanceSession.morning ? 'Morning' : 'Afternoon'}',
                      style: AppTypography.body2.copyWith(color: AppColors.white),
                    ),
            ),
          ),
        );
      },
    );
  }
}
