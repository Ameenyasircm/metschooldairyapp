import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/constants/app_spacing.dart';
import 'package:met_school/core/widgets/buttons/gradient_button.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/app_padding.dart';
import '../../../../../../core/constants/app_radius.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/utils/loader/customLoader.dart';
import '../provider/student_provider.dart';
import '../widgets/student_shimmer.dart';
import '../widgets/student_tile.dart';

class TechStudentListScreen extends StatelessWidget {
  const TechStudentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentProvider>();
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        automaticallyImplyLeading: false,
        title: Text("Students List",style: AppTypography.body1.copyWith(
            fontWeight: FontWeight.w600
        ),),
        leading: const BackButton(),
        elevation: 0,
      ),
      body: Padding(
        padding:AppPadding.phS,
        child: Column(
          children: [
            AppSpacing.h12,
            Container(
              margin: AppPadding.phM,
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 4.h,
              ),
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
                decoration:  InputDecoration(
                  hintText: "Search by Name/Admission No.",
                  hintStyle: AppTypography.body2.copyWith(
                    color: AppColors.greyB2,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                ),

                onChanged: (value) {
                  provider.searchWithDebounce(value);
                },
              ),
            ),
            Expanded(
              child: provider.isInitialLoading
                  ? const StudentShimmer()
                  : RefreshIndicator(
                backgroundColor: AppColors.white,
                color: AppColors.primary,
                onRefresh: () async {
                  await provider.fetchInitial();
                },
                child: provider.students.isEmpty
                    ? ListView(
                  children: [
                    SizedBox(height: 200.h),
                    Center(child: Text("No students found",style: AppTypography.body1,)),
                  ],
                )
                    : NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent - 200) {
                      if (!provider.isLoadingMore && provider.hasMore) {
                        provider.fetchMore();
                      }
                    }
                    return false;
                  },
                  child: ListView.builder(
                    padding: AppPadding.pvM,
                    itemCount: provider.students.length +
                        (provider.hasMore && provider.searchQuery.isEmpty ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < provider.students.length) {
                        final student = provider.students[index];
                        return StudentTile(
                          student: student,
                          isSelected: provider.isSelected(student.studentId),
                          isSelectable: provider.isClassTeacher,
                          onTap: () {
                            context.read<StudentProvider>()
                                .toggleSelection(student.studentId);
                          },
                        );
                      }
                      else {
                        return Padding(
                          padding: AppPadding.pM,
                          child: Center(child: CustomLoader()),
                        );
                      }
                    },
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: provider.selectedStudentIds.isNotEmpty
          ? Padding(
        padding: AppPadding.p12,
        child: gradientButton(
          onPressed: (){

          },
            text:"Assign (${provider.selectedStudentIds.length}) Students"),
      ): null,

    );
  }
}


