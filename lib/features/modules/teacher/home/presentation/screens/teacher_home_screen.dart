import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/constants/app_assets.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_padding.dart';
import 'package:met_school/core/theme/app_radius.dart';
import 'package:met_school/core/theme/app_spacing.dart';
import 'package:met_school/core/theme/app_typography.dart';
import 'package:met_school/core/utils/navigation/navigation_helper.dart';
import 'package:met_school/features/modules/teacher/home/presentation/widgets/teacher_quick_actions.dart';
import 'package:met_school/features/modules/teacher/home/viewmodels/teacher_home_viewmodel.dart';
import 'package:met_school/features/modules/teacher/profile/presentation/screens/teacher_profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../core/router/app_navigation.dart';
import '../../../../../../core/widgets/dialogs/logout_alert.dart';
import '../../../../../../providers/admin_provider.dart';
import '../../../../../communication/screens/students_parents_list_screen.dart';
import '../../../../../mobile_rules_regulations/screens/bellTiming_screen.dart';
import '../../../../../mobile_rules_regulations/screens/rules_list_screen.dart';
import '../../../attendance/presentation/screens/attendance_report_screen.dart';
import '../../../attendance/presentation/screens/attendance_screen.dart';
import '../../../events/presentation/screens/event_list_screen.dart';
import '../../../punctuality/data/screens/students_list_punctuality.dart';
import '../../../students/presentation/provider/student_provider.dart';
import '../../../students/presentation/screens/my_students_screen.dart';
import '../widgets/quick_action_card.dart';

class TeacherHomeScreen extends StatefulWidget {
  final String staffName;
  const TeacherHomeScreen({super.key, required this.staffName});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherHomeViewModel>().fetchTeacherDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(),
          _buildStatsSection(),
          buildQuickActions(context),
          _buildMoreActionsList(),
          SliverToBoxAdapter(child: AppSpacing.vxl),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32.r),
            bottomRight: Radius.circular(32.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(AppAssets.metLogo, width: 44.w, height: 44.h),
                      AppSpacing.w12,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "MET Public School",
                            style: AppTypography.h6.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Payyanad",
                            style: AppTypography.h6.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => NavigationService.push(context, const TeacherProfileScreen()),
                    child: Container(
                      padding: EdgeInsets.all(2.r),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 22.r,
                        backgroundColor: AppColors.greyE0,
                        backgroundImage: const AssetImage(AppAssets.profile),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
        child: Consumer<TeacherHomeViewModel>(
          builder: (context8, vm, _) {
            return Container(
              padding: AppPadding.pM,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.radiusL,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    vm.className.isNotEmpty ? "${vm.className} (${vm.divisionName})" : "N/A",
                    style: AppTypography.h5.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                  AppSpacing.vxs,
                  Text(
                    "${vm.studentCount} students",
                    style: AppTypography.caption.copyWith(color: AppColors.grey5E),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMoreActionsList() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      sliver: Consumer<TeacherHomeViewModel>(
        builder: (context, vm, _) {
          final actions = vm.listActions;
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: InkWell(
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final divisionId = prefs.getString("divisionId") ?? '';
                      final divisionName = prefs.getString("divisionName") ?? '';
                      final classId = prefs.getString("classId") ?? '';
                      if (!context.mounted) return;
                      
                      final studentProvider = context.read<StudentProvider>();
                      final adminProvider = context.read<AdminProvider>();

                      switch (index) {
                        case 0: // Rules
                          adminProvider.fetchRules();
                          callNext(RulesUserScreen(), context);
                          break;
                        case 1: // Attendance Report
                          NavigationService.push(
                            context,
                            AttendanceReportScreen(
                              classId: classId,
                              divisionId: divisionId,
                              divisionName: divisionName,
                            ),
                          );
                          break;
                        case 2: // My Students
                          studentProvider.searchMyStdQuery = '';
                          studentProvider.fetchMyStudentsInitial();
                          NavigationService.push(context, MyStudentsScreen());
                          break;
                        case 3: // Punctuality
                          studentProvider.fetchMyStudentsInitial();
                          NavigationService.push(context, PunctualityStudentListScreen());
                          break;
                        case 4: // Events
                          callNext(EventListScreen(), context);
                          break;
                        case 5: // Bell Timing
                          adminProvider.fetchBellTiming();
                          callNext(BellTimingUserScreen(), context);
                          break;
                      }
                    },
                    child: QuickListActionCard(
                      action: actions[index],
                    ),
                  ),
                );
              },
              childCount: actions.length,
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPadding.pM,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusL,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: AppPadding.pS,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: AppRadius.radiusM,
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          AppSpacing.v12,
          Text(
            value,
            style: AppTypography.h4.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: AppTypography.caption.copyWith(color: AppColors.grey5E),
          ),
        ],
      ),
    );
  }
}
