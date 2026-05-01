import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/constants/app_spacing.dart';
import 'package:met_school/core/widgets/buttons/gradient_button.dart';
import 'package:met_school/core/utils/snackbarNotification/snackbar_notification.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/app_padding.dart';
import '../../../../../../core/constants/app_radius.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../provider/student_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/student_shimmer.dart';
import '../widgets/student_tile.dart';

class TechStudentListScreen extends StatelessWidget {
  const TechStudentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        automaticallyImplyLeading: false,
        title: Text(
          "Students List",
          style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600,color: AppColors.primary),
        ),
        leading: const BackButton(color: AppColors.primary),
        elevation: 0,

      ),
      body: Padding(
        padding: AppPadding.phS,
        child: Column(
          children: [
            AppSpacing.h12,
            Row(
              children: [
                Expanded(child: _buildSearchField(context)),
                // Consumer<StudentProvider>(
                //   builder: (context, provider, child) {
                //     if (provider.students.isEmpty) return const SizedBox.shrink();
                //     return Row(
                //       children: [
                //         Checkbox(
                //           value: provider.isAllSelected,
                //           onChanged: (_) => provider.toggleSelectAll(),
                //           activeColor: AppColors.primary,
                //         ),
                //         Text(
                //           "All",
                //           style: AppTypography.body2.copyWith(fontWeight: FontWeight.w500),
                //         ),
                //         AppSpacing.w8,
                //       ],
                //     );
                //   },
                // ),
              ],
            ),
            Expanded(
              child: Consumer<StudentProvider>(
                builder: (context, provider, child) {
                  // 1. Initial Loading State
                  if (provider.isInitialLoading) {
                    return const StudentShimmer();
                  }

                  // 2. Refresh Indicator with List or Empty State
                  return RefreshIndicator(
                    backgroundColor: AppColors.white,
                    color: AppColors.primary,
                    onRefresh: () async {
                      await provider.fetchInitial();
                    },
                    child: provider.students.isEmpty
                        ? buildEmptyState()
                        : _buildStudentList(provider),
                  );
                },
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      margin: AppPadding.phM,
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
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search,color: AppColors.greyB2,size: 19,),
          hintText: "Search name,Admission No.",
          hintStyle: AppTypography.body2.copyWith(color: AppColors.greyB2),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        ),
        onChanged: (value) {
          context.read<StudentProvider>().searchWithDebounce(value);
        },
      ),
    );
  }

  Widget _buildStudentList(StudentProvider provider) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
          provider.fetchMore();
        }
        return false;
      },
      child: ListView.builder(
        padding: AppPadding.pvM,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: provider.students.length + (provider.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < provider.students.length) {
            final student = provider.students[index];
            return StudentTile(
              student: student,
              isSelected: provider.selectedStudentIds.contains(student.studentId),
              isSelectable: true,
              onTap: () {
                provider.toggleSelection(student.studentId);
              },
            );
          } else {
            return provider.isLoadingMore
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

  Widget _buildBottomNav(BuildContext context) {
    final provider = context.watch<StudentProvider>();
    if (provider.selectedStudentIds.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: AppPadding.p12,
      child: gradientButton(
        isLoading: provider.isAddingStudents,
        onPressed: provider.isAddingStudents
            ? null
            : () async {
                try {
                  await provider.bulkEnroll();
                  if (context.mounted) {
                    await provider.fetchMyStudentsInitial();
                    SnackbarService().showSuccess("Students enrolled successfully!");
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    SnackbarService().showError(e.toString().replaceAll("Exception: ", ""));
                  }
                }
              },
        text: "Enroll (${provider.selectedStudentIds.length}) Students",
      ),
    );
  }
}
