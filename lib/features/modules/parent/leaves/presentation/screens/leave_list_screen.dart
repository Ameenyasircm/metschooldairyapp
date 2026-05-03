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
import 'leave_request_form_screen.dart';

class ParentLeaveListScreen extends StatefulWidget {
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
  State<ParentLeaveListScreen> createState() =>
      _ParentLeaveListScreenState();
}

class _ParentLeaveListScreenState extends State<ParentLeaveListScreen> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          "Leave Requests",
          style: AppTypography.h5.copyWith(color: AppColors.primary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(color: AppColors.primary),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () => setState(() {}),
          )
        ],
      ),

      body: Column(
        children: [
          /// 🔍 SEARCH BAR
          Padding(
            padding: AppPadding.pM,
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search by reason...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() => searchQuery = value.toLowerCase());
              },
            ),
          ),

          /// 📋 LIST
          Expanded(
            child: StreamBuilder<List<LeaveRequestModel>>(
              stream: context
                  .read<LeaveProvider>()
                  .getStudentLeavesStream(widget.studentId),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CustomLoader());
                }

                if (snapshot.hasError) {
                  return Center(
                      child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _emptyState();
                }

                final leaves = snapshot.data!
                    .where((leave) =>
                    leave.reason
                        .toLowerCase()
                        .contains(searchQuery))
                    .toList();

                if (leaves.isEmpty) {
                  return const Center(child: Text("No results found"));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: ListView.builder(
                    padding: AppPadding.pM,
                    itemCount: leaves.length,
                    itemBuilder: (context, index) {
                      final leave = leaves[index];

                      return _leaveCard(leave, index);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          callNext(
            LeaveRequestFormScreen(
              studentId: widget.studentId,
              studentName: widget.studentName,
              teacherId: widget.teacherId,
              academicYearId: widget.academicYearId,
              classId: widget.classId,
              className: widget.className,
            ),
            context,
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// 🎯 MODERN CARD UI
  Widget _leaveCard(LeaveRequestModel leave, int index) {
    final status = (leave.status ?? "").toLowerCase();

    final displayStatus = status.isEmpty
        ? "Approval Pending"
        : status;

    final color = status == "approved"
        ? Colors.green
        : status == "rejected"
        ? Colors.red
        : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// SL NO + STATUS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "SL NO: ${index + 1}",
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  displayStatus.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          AppSpacing.h8,

          /// REASON
          Text(
            leave.reason,
            style: AppTypography.body1.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          AppSpacing.h6,

          /// DATE RANGE
          Text(
            "${_formatDate(leave.startDate)} → ${_formatDate(leave.endDate)}",
            style: AppTypography.body2.copyWith(
              color: AppColors.grey5E,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy,
              size: 64.sp, color: Colors.grey.withOpacity(0.4)),
          AppSpacing.h16,
          Text(
            "No leave requests found",
            style: AppTypography.body1.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}