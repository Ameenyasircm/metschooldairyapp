import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/constants/app_radius.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_typography.dart';
import 'package:met_school/core/constants/app_spacing.dart';
import 'package:met_school/core/constants/app_padding.dart';
import 'package:met_school/core/models/leave_request_model.dart';
import 'package:met_school/core/utils/loader/customLoader.dart';
import 'package:met_school/providers/leave_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/teacher_leave_card.dart';

class TeacherLeaveManagementScreen extends StatefulWidget {
  const TeacherLeaveManagementScreen({super.key});

  @override
  State<TeacherLeaveManagementScreen> createState() => _TeacherLeaveManagementScreenState();
}

class _TeacherLeaveManagementScreenState extends State<TeacherLeaveManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _teacherId;
  String? _academicYearId;
  String? _classId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTeacherData();
  }

  Future<void> _loadTeacherData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _teacherId = prefs.getString("staffId");
      _academicYearId = prefs.getString("academicYearId");
      _classId = prefs.getString("classId");
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_teacherId == null || _academicYearId == null || _classId == null) {
      return const Scaffold(body: Center(child: CustomLoader()));
    }

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text("Leave Management", style: AppTypography.h5.copyWith(color: AppColors.primary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.h),
          child: Container(
            margin:  EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: AppRadius.radiusM,
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle:  AppTypography.caption.copyWith(
                fontWeight: FontWeight.bold
              ),
              unselectedLabelStyle:  AppTypography.caption,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.radiusS,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              padding: AppPadding.pXs,
              tabs:  [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.hourglass_empty_rounded, size: 15),
                      AppSpacing.w4,
                      Text("Pending"),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 15),
                      AppSpacing.w4,
                      Text("Approved",),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cancel_outlined, size: 15),
                      AppSpacing.w4,
                      Text("Rejected"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeaveList('pending'),
          _buildLeaveList('approved'),
          _buildLeaveList('rejected'),
        ],
      ),
    );
  }

  Widget _buildLeaveList(String status) {
    return StreamBuilder<List<LeaveRequestModel>>(
      stream: context.read<LeaveProvider>().getTeacherLeavesStream(
            academicYearId: _academicYearId!,
            classId: _classId!,
            status: status,
          ),
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
                Icon(Icons.assignment_turned_in_outlined, size: 64.sp, color: Colors.grey),
                AppSpacing.h16,
                Text("No $status requests", style: AppTypography.body1.copyWith(color: Colors.grey)),
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
            return TeacherLeaveCard(
              leave: leave,
              onUpdateStatus: (newStatus, {reason}) => _updateStatus(leave.id!, newStatus, rejectionReason: reason),
            );
          },
        );
      },
    );
  }

  Future<void> _updateStatus(String docId, String status, {String? rejectionReason}) async {
    try {
      await context.read<LeaveProvider>().updateRequestStatus(docId, status, rejectionReason: rejectionReason);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Request $status successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating status: $e")),
        );
      }
    }
  }
}
