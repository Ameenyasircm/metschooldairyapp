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
import 'package:met_school/features/modules/teacher/home/presentation/screens/subject_mode/subject_class_division_selector.dart';
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
import '../../../../../../core/enums/app_enums.dart';
import '../../../../../../providers/teacher_provider.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final teacherProvider = context.read<TeacherProvider>();
      await teacherProvider.loadTeacherData();
      if (mounted) {
        context.read<TeacherHomeViewModel>().updateProvider(teacherProvider);
        context.read<TeacherHomeViewModel>().fetchTeacherDashboardData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherProvider>(
      builder: (context, teacherProvider, _) {
        return Scaffold(
          backgroundColor: AppColors.lightBackground,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeader(teacherProvider),
              if (teacherProvider.activeMode == TeacherMode.none)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyStateContent(),
                )
              else ...[
                if (teacherProvider.activeMode == TeacherMode.classTeacher) ...[
                  _buildStatsSection(),
                  buildQuickActions(context),
                  _buildMoreActionsList(),
                ],
                if (teacherProvider.activeMode == TeacherMode.subjectTeacher)
                  const SubjectClassDivisionSelector(),
                SliverToBoxAdapter(child: AppSpacing.vxl),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyStateContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_late_outlined, size: 64.sp, color: AppColors.grey5E),
          AppSpacing.v12,
          Text(
            "No classes assigned",
            style: AppTypography.h5.copyWith(color: AppColors.grey5E),
          ),
          AppSpacing.h8,
          Text(
            "Please contact the administrator.",
            style: AppTypography.body2.copyWith(color: AppColors.grey5E),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(TeacherProvider teacherProvider) {
    final bool canSwitch = teacherProvider.isClassTeacher && teacherProvider.subjectAssignments.isNotEmpty;

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
                  Row(
                    children: [

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

              if (canSwitch) ...[
                AppSpacing.h12,
                InkWell(
                  onTap: (){
                    _showModeSwitchDialog(context, teacherProvider);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          teacherProvider.activeMode == TeacherMode.classTeacher
                              ? "Class Teacher Mode"
                              : "Subject Teacher Mode",
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        AppSpacing.w2,
                        Icon(Icons.keyboard_arrow_down_outlined, color: AppColors.primary,size: 20,)
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showModeSwitchDialog(BuildContext context, TeacherProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: AppPadding.pM,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Switch Mode", style: AppTypography.h6),
              AppSpacing.vm,
              ListTile(
                tileColor: Colors.white,
                leading: Icon(Icons.school, color: AppColors.primary),
                title: Text("Class Teacher Mode",style: AppTypography.body2),
                trailing: provider.activeMode == TeacherMode.classTeacher
                    ? Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                onTap: () {
                  provider.setActiveMode(TeacherMode.classTeacher);
                  context.read<TeacherHomeViewModel>().fetchTeacherDashboardData();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.book, color: AppColors.primary),
                title:  Text("Subject Teacher Mode",style: AppTypography.body2,),
                trailing: provider.activeMode == TeacherMode.subjectTeacher
                    ? Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                onTap: () {
                  provider.setActiveMode(TeacherMode.subjectTeacher);
                  context.read<TeacherHomeViewModel>().fetchTeacherDashboardData();
                  Navigator.pop(context);
                },
              ),
              AppSpacing.vm,
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubjectAssignmentsSection(TeacherProvider provider) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Assigned Subjects",
              style: AppTypography.h6.copyWith(fontWeight: FontWeight.bold),
            ),
            AppSpacing.v12,
            ...provider.subjectAssignments.map((assignment) => Container(
              margin: EdgeInsets.only(bottom: 12.h),
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
              child: Row(
                children: [
                  Container(
                    padding: AppPadding.pS,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: AppRadius.radiusM,
                    ),
                    child: Icon(Icons.book, color: AppColors.primary, size: 24.sp),
                  ),
                  AppSpacing.w16,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment.subjectName,
                          style: AppTypography.body2.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${assignment.className} - ${assignment.divisionName}",
                          style: AppTypography.caption.copyWith(color: AppColors.grey5E),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
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
            final isSubjectMode = context.read<TeacherProvider>().activeMode == TeacherMode.subjectTeacher;
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
              child: Row(
                children: [
                  Container(
                    padding: AppPadding.pM,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: AppRadius.radiusM,
                    ),
                    child: Icon(
                      isSubjectMode ? Icons.auto_stories : Icons.group,
                      color: AppColors.primary,
                      size: 28.sp,
                    ),
                  ),
                  AppSpacing.w16,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vm.className.isNotEmpty ? "${vm.className} ${vm.divisionName}" : "N/A",
                        style: AppTypography.h6.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                      AppSpacing.vxs,
                      Text(
                        isSubjectMode
                            ? "${vm.studentCount} Classes Assigned"
                            : "${vm.studentCount} Students",
                        style: AppTypography.caption.copyWith(color: AppColors.grey5E),
                      ),
                    ],
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
                      final action = actions[index];

                      switch (action.title) {
                        case 'Rules & Regulations':
                          adminProvider.fetchRules();
                          callNext(RulesUserScreen(), context);
                          break;
                        case 'Attendance Report':
                          NavigationService.push(
                            context,
                            AttendanceReportScreen(
                              classId: classId,
                              divisionId: divisionId,
                              divisionName: divisionName,
                            ),
                          );
                          break;
                        case 'My Students':
                          studentProvider.searchMyStdQuery = '';
                          studentProvider.fetchMyStudentsInitial();
                          NavigationService.push(context, MyStudentsScreen());
                          break;
                        case 'Punctuality Record':
                          studentProvider.fetchMyStudentsInitial();
                          NavigationService.push(context, PunctualityStudentListScreen());
                          break;
                        case 'Events':
                          callNext(EventListScreen(), context);
                          break;
                        case 'School Timing':
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
