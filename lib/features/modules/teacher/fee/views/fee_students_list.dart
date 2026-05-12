import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/utils/snackbarNotification/snackbar_notification.dart';
import 'package:met_school/features/modules/teacher/students/presentation/screens/tech_student_list_screen.dart';
import 'package:provider/provider.dart';

import 'package:met_school/core/theme/app_padding.dart';
import 'package:met_school/core/theme/app_radius.dart';
import 'package:met_school/core/theme/app_spacing.dart';
import 'package:met_school/core/router/app_navigation.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_typography.dart';
import 'package:met_school/core/widgets/buttons/gradient_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/utils/navigation/navigation_helper.dart';
import '../../../parent/fee/screens/parent_view_fee.dart';
import '../../attendance/presentation/screens/student_attendance_history_screen.dart';
import '../../students/presentation/provider/student_provider.dart';
import '../../students/presentation/widgets/empty_state.dart';
import '../../students/presentation/widgets/student_shimmer.dart';
import '../../students/presentation/widgets/student_tile.dart';
class FeeStudentsListScreen extends StatelessWidget {
  final String academicYearId;

  const FeeStudentsListScreen({
    super.key,
    required this.academicYearId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        toolbarHeight: 80.h,
        backgroundColor: AppColors.lightBackground,
        automaticallyImplyLeading: false,
        title: Text(
          "Students Fee Details",
          style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600,color: AppColors.primary),
        ),
        leading: const BackButton(color: AppColors.primary),
        elevation: 0,
        actions: [
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
          prefixIcon: Icon(Icons.search,color: AppColors.greyB2,size: 19,),
          hintText: "Search name,Admission No.",
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
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final divisionId = prefs.getString("divisionId") ?? '';
                  final divisionName = prefs.getString("divisionName") ?? '';
                  callNext(
                      ParentFeeScreen(
                        studentName: item.name,
                        studentId: item.studentId,
                        divisionName: divisionName,
                        divisionId: divisionId,
                        academicYearId: academicYearId ?? '',
                      ),
                      context);
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
