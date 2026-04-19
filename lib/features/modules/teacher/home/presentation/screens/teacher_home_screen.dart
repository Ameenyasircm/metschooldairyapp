import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:met_school/core/constants/app_padding.dart';
import 'package:met_school/core/constants/app_radius.dart';
import 'package:met_school/core/constants/app_spacing.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_typography.dart';
import '../../viewmodels/teacher_home_viewmodel.dart';

import '../widgets/header_t.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/section_title_t.dart';
import '../widgets/student_progress_card.dart';
import '../widgets/attendance_card.dart';
import '../widgets/grade_overview_card.dart';
import '../widgets/teacher_quick_actions.dart';

class TeacherHomeScreen extends StatelessWidget {
  final String staffName;
  const TeacherHomeScreen({super.key,required this.staffName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppPadding.pL,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildHeaderT(context,staffName),
              AppSpacing.vl,
              buildSectionTitle('Quick Actions'),
              AppSpacing.vm,
              buildQuickActions(context),
              AppSpacing.vxl,
              buildSectionTitleWithAction('Insights & Reports', 'View All Archives'),
              AppSpacing.vm,
              const StudentProgressCard(),
              AppSpacing.vl,
              const AttendanceCard(),
              AppSpacing.vl,
              const GradeOverviewCard(),
              AppSpacing.h100,
            ],
          ),
        ),

      ),

    );
  }



  Widget _buildGreeting(BuildContext context) {
    return Consumer<TeacherHomeViewModel>(
      builder: (context, vm, _) {
        final greeting = '${vm.greetingText}';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: AppTypography.h5.copyWith(color: AppColors.darkGreen, height: 1.2),
            ),
            AppSpacing.vs,
            Text(
              "Your workspace is organized and ready for today's sessions.",
              style: AppTypography.body2.copyWith(color: AppColors.grey5E),
            ),
          ],
        );
      },
    );
  }


}
