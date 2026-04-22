import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_typography.dart';
import 'package:met_school/core/constants/app_spacing.dart';
import 'package:met_school/core/constants/app_padding.dart';
import 'package:met_school/core/utils/navigation/navigation_helper.dart';
import 'package:met_school/core/models/leave_request_model.dart';
import 'package:met_school/core/utils/loader/customLoader.dart';
import 'package:met_school/providers/leave_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/parent_leave_card.dart';
import 'leave_request_form_screen.dart';

class ParentLeaveListScreen extends StatelessWidget {
  final String studentId;
  final String studentName;
  final String teacherId;
  final String academicYearId;
  final String classId;
  final String className;

  const ParentLeaveListScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.teacherId,
    required this.academicYearId,
    required this.classId,
    required this.className,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text("Leave Requests", style: AppTypography.h4.copyWith(color: AppColors.primary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<LeaveRequestModel>>(
        stream: context.read<LeaveProvider>().getStudentLeavesStream(studentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CustomLoader());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64.sp, color: Colors.grey),
                  AppSpacing.h16,
                  Text(
                    "No leave requests found",
                    style: AppTypography.body1.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final leaves = snapshot.data!;

          return ListView.builder(
            padding: AppPadding.pM,
            itemCount: leaves.length,
            itemBuilder: (context, index) {
              final leave = leaves[index];
              return ParentLeaveCard(leave: leave);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          callNext(
            LeaveRequestFormScreen(
              studentId: studentId,
              studentName: studentName,
              teacherId: teacherId,
              academicYearId: academicYearId,
              classId: classId,
              className: className,
            ),
            context,
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
