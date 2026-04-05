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
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        automaticallyImplyLeading: false,
        title: Text(
          "Students List",
          style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600),
        ),
        leading: const BackButton(),
        elevation: 0,
      ),
      body: Padding(
        padding: AppPadding.phS,
        child: Column(
          children: [
            AppSpacing.h12,
            _buildSearchField(context),
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
          hintText: "Search by Name/Admission No.",
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
              isSelected: provider.isSelected(student.studentId),
              isSelectable: true,
              onTap: () {
                provider.toggleSelection(student.studentId);
              },
            );
          } else {
            return  Padding(
              padding: AppPadding.pM,
              child: Center(child: CupertinoActivityIndicator()),
            );
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
                  await provider.addClassTeacherStudents();
                  if (context.mounted) {
                    SnackbarService().showSuccess("Students assigned successfully");
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    SnackbarService().showError(e.toString().replaceAll("Exception: ", ""));
                  }
                }
              },
        text: "Assign (${provider.selectedStudentIds.length}) Students",
      ),
    );
  }
}
