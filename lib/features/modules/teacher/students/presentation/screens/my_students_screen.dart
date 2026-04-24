import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/utils/snackbarNotification/snackbar_notification.dart';
import 'package:met_school/features/modules/teacher/students/presentation/screens/tech_student_list_screen.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/app_padding.dart';
import '../../../../../../core/constants/app_radius.dart';
import '../../../../../../core/constants/app_spacing.dart';
import '../../../../../../core/router/app_navigation.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/widgets/buttons/gradient_button.dart';
import '../../../attendance/presentation/screens/attendance_report_screen.dart';
import '../../../attendance/presentation/screens/student_attendance_history_screen.dart';
import '../provider/student_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/student_shimmer.dart';
import '../widgets/student_tile.dart';

class MyStudentsScreen extends StatelessWidget {
  const MyStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        automaticallyImplyLeading: false,
        title: Text(
          "My Students",
          style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600),
        ),
        leading: const BackButton(),
        elevation: 0,
        actions: [
          Padding(
            padding: AppPadding.pM,
            child: Consumer<StudentProvider>(
              builder: (context, provider, child) {
                if (provider.isAssigningRollNumbers) {
                  return const Center(child: CupertinoActivityIndicator());
                }
                return IconButton(
                  tooltip: "Assign Roll Numbers",
                  icon:Icon(Icons.sort_by_alpha, color: AppColors.primary,size: 22,),
                  onPressed: () async {
                    bool? confirm = await _showConfirmDialog(context);
                    if (confirm == true) {
                      try {
                        await provider.autoAssignRollNumbers();
                        if (context.mounted) {
                          SnackbarService().showSuccess("Roll numbers assigned alphabetically!");
                        }
                      } catch (e) {
                        if (context.mounted) {
                          SnackbarService().showError("Error: $e");
                        }
                      }
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          AppSpacing.h12,
          SizedBox(
             height: 48.h,
            child: Row(
              children: [
                Flexible(
                  flex: 2,
                    child: _buildSearchField(context)),
                Flexible(
                  child: Padding(
                    padding:EdgeInsets.only(right: 6.w),
                    child: gradientButton(
                      text: "Enroll",
                      onPressed: () {
                        final provider = context.read<StudentProvider>();
                        provider.clearSelection();
                        provider.fetchInitial();
                        NavigationService.push(context, const TechStudentListScreen());
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Consumer<StudentProvider>(
              builder: (context, provider, child) {
                // 1. Initial Loading State
                if (provider.isInitialMyStdLoading) {
                  return const StudentShimmer();
                }

                // 2. Refresh Indicator with List or Empty State
                return RefreshIndicator(
                  backgroundColor: AppColors.white,
                  color: AppColors.primary,
                  onRefresh: () async {
                    await provider.fetchMyStudentsInitial();
                  },
                  child: provider.myAllStudents.isEmpty
                      ? buildEmptyState()
                      : _buildStudentList(provider),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context,) {
    return Container(
      margin: AppPadding.phM,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
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
        decoration: InputDecoration(
          hintText: "Search by name/Admission No.",
          hintStyle: AppTypography.body2.copyWith(color: AppColors.greyB2),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        ),
        onChanged: (value) {
          context.read<StudentProvider>().searchMyStd(value);
        },
      ),
    );
  }

  Widget _buildStudentList(StudentProvider provider) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
          provider.fetchMyStudentsMore();
        }
        return false;
      },
      child: ListView.builder(
        padding: AppPadding.pvM,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: provider.myStudents.length + (provider.hasMyStdMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < provider.myStudents.length) {
            var item = provider.myStudents[index];
            return InkWell(
                onTap: () {
                  NavigationService.push(
                      context,
                      StudentAttendanceHistoryScreen(
                        studentId: item.studentId,
                        studentName: item.name,
                      ));
                },
                child: MyStudentTile(student: item));
          } else {
            return provider.isLoadingMyStdMore
                ? Padding(
                    padding: AppPadding.pM,
                    child: Center(child: CupertinoActivityIndicator()),
                  )
                : const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Future<bool?> _showConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusM),
        title: Text(
          "Assign Roll Numbers?",
          style: AppTypography.h5,
        ),
        content: Text(
          "This will sort all enrolled students alphabetically and assign roll numbers.",
          style: AppTypography.body2.copyWith(color: AppColors.grey5E),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Cancel",
              style: AppTypography.label.copyWith(color: AppColors.grey5E),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "Assign",
              style: AppTypography.label.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
