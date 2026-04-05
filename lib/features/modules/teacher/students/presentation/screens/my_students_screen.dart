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
import '../../../../../../core/widgets/buttons/gradient_button.dart';
import '../provider/student_provider.dart';

class MyStudentsScreen extends StatelessWidget {
  const MyStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        automaticallyImplyLeading: false,
        title: Text("My Students",style: AppTypography.body1.copyWith(
            fontWeight: FontWeight.w600
        ),),
        leading: const BackButton(),
        elevation: 0,
      ),
      body: Column(
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
                hintText: "Search by name/Admission No.",
                hintStyle: AppTypography.body2.copyWith(
                  color: AppColors.greyB2,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),

              onChanged: (value) {
                // provider.searchWithDebounce(value);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar:SafeArea(
        bottom: true,
        child: Padding(
          padding: AppPadding.pM,
          child: gradientButton(
            text: "Add Student",
            onPressed:() {
              final provider = context.read<StudentProvider>();
              provider. searchQuery = '';
              provider.fetchInitial();
              NavigationService.push(context, TechStudentListScreen());

            },
          ),
        ),
      ),
    );
  }
}
