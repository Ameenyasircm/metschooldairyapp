import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/features/modules/teacher/students/presentation/screens/tech_student_list_screen.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/app_padding.dart';
import '../../../../../../core/constants/app_radius.dart';
import '../../../../../../core/constants/app_spacing.dart';
import '../../../../../../core/router/app_navigation.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/utils/loader/customLoader.dart';
import '../../../../../../core/widgets/buttons/gradient_button.dart';
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
      ),
      body: Column(
        children: [
          AppSpacing.h12,
          _buildSearchField(context),
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
                  child: provider.myStudents.isEmpty
                      ? buildEmptyState()
                      : _buildStudentList(provider),
                );
              },
            ),
          )
        ],
      ),
      bottomNavigationBar:SafeArea(
        bottom: true,
        child: Padding(
          padding: AppPadding.pM,
          child: gradientButton(
            text: "Add Student",
            onPressed: () {
              final provider = context.read<StudentProvider>();
              provider.clearSelection();
              provider.fetchInitial();
              NavigationService.push(context, const TechStudentListScreen());
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context,) {
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
            return StudentTile(student: provider.myStudents[index]);
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


}
