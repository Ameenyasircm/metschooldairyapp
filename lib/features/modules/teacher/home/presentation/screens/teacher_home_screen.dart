import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/constants/app_assets.dart';
import 'package:provider/provider.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_typography.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../core/router/app_navigation.dart';
import '../../../../../../core/theme/app_padding.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/utils/navigation/navigation_helper.dart';
import '../../../../../../core/widgets/dialogs/logout_alert.dart';
import '../../../../../../providers/admin_provider.dart';
import '../../../../../auth/presentation/screens/login_screen.dart';
import '../../../../../communication/screens/students_parents_list_screen.dart';
import '../../../../../homework/screens/homework_list_screen.dart';
import '../../../../../mobile_rules_regulations/screens/bellTiming_screen.dart';
import '../../../../../mobile_rules_regulations/screens/rules_list_screen.dart';
import '../../../attendance/presentation/screens/attendance_report_screen.dart';
import '../../../attendance/presentation/screens/attendance_screen.dart';
import '../../../events/presentation/screens/event_list_screen.dart';
import '../../../exams/presentation/screens/exam_coming_soon_screen.dart';
import '../../../leaves/presentation/screens/teacher_leave_management_screen.dart';
import '../../../profile/presentation/screens/teacher_profile_screen.dart';
import '../../../punctuality/data/screens/students_list_punctuality.dart';
import '../../../school_calender/screens/school_calender_mobile_screen.dart';
import '../../../students/presentation/provider/student_provider.dart';
import '../../../students/presentation/screens/my_students_screen.dart';
import '../../../syllabus/presentation/screens/syllabus_list_screen.dart';
import '../../../timetable/presentation/screens/timetable_screen.dart';
import '../../viewmodels/teacher_home_viewmodel.dart';

import '../widgets/header_t.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/section_title_t.dart';
import '../widgets/student_progress_card.dart';
import '../widgets/attendance_card.dart';
import '../widgets/grade_overview_card.dart';
import '../widgets/teacher_quick_actions.dart';

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
      backgroundColor: AppColors.lightBackground, // Ultra light slate
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
           color: AppColors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50.r),
                  bottomRight: Radius.circular(50.r),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 28.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 Top Row: Profile & Notifications
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Profile Section
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Image.asset(AppAssets.metLogo,width:52.w,height: 52.h,),
                              ),
                              SizedBox(width: 12.w),
                          Text(
                  'MET Public School\nPayyanad', // Passing from constructor
                  style: AppTypography.h6.copyWith(
                    fontWeight: FontWeight.w600
                  ),
                ),
                            ],
                          ),
                          InkWell(
                            onTap: (){
                              NavigationService.push(context,TeacherProfileScreen());
                            }, child: Image.asset(AppAssets.profile, width: 50.w,height: 50.h,)),
                        ],
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: AppSpacing.h12,
          ),
          SliverToBoxAdapter(
            child: Consumer<TeacherHomeViewModel>(
              builder: (context, vm, _) {
                return Container(
                  padding: AppPadding.pS,
                  margin: AppPadding.phL,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.radiusM,
                  ),
                  child: Column(
                    children: [
                      Text("${vm.getStandardText(vm.className)}(${vm.divisionName})",style:AppTypography.h5,),
                      AppSpacing.h4,
                      Text("${vm.studentCount} Students",style:AppTypography.body2.copyWith(
                        color: AppColors.grey4E
                      ),),
                    ],
                  ),
                );
              }
            ),
          ),
          buildQuickActions(context),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 0.h, 20.w, 30.h),
            sliver: Consumer<TeacherHomeViewModel>(
              builder: (context, vm, _) {
                final actions = vm.listActions;
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return InkWell(
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();
                          final divisionId = prefs.getString("divisionId") ?? '';
                          final divisionName = prefs.getString("divisionName") ?? '';
                          final classId = prefs.getString("classId") ?? '';
                          if (!context.mounted) return;
                          final provider = context.read<StudentProvider>();
                        switch (index) {
                          case 0:
                            final provider = context.read<AdminProvider>();
                            provider.fetchRules();
                            callNext(RulesUserScreen(), context);
                            break;
                            case 1:
                              NavigationService.push(
                                  context, AttendanceReportScreen(classId: classId,divisionId: divisionId,divisionName: divisionName,));
                            break;
                            case 2:
                              provider.searchMyStdQuery = '';
                              context.read<StudentProvider>().fetchMyStudentsInitial();
                              NavigationService.push(context, MyStudentsScreen());
                            break;
                          case 3:
                            final provider = context.read<StudentProvider>();
                            provider.fetchMyStudentsInitial();
                            NavigationService.push(context, PunctualityStudentListScreen());
                            break;
                          case 4:

                            callNext(EventListScreen(), context);
                            break;
                            case 5:
                            final provider = context.read<AdminProvider>();
                            provider.fetchBellTiming();
                            callNext(BellTimingUserScreen(), context);
                            break;
                          case 6:
                            print(' FKNRKF ');
                            final shouldLogout = await showLogoutDialog(context);
                            if (shouldLogout == true) {
                              final prefs = await SharedPreferences.getInstance();
                              /// Clear saved data
                              await prefs.clear();
                              NavigationService.pushAndRemoveUntil(
                                context,
                                LoginScreen(),
                              );
                            }
                            break;
                          default:
                            break;
                            }


                        },
                        child: QuickListActionCard(
                          action: actions[index],
                        ),
                      );
                    },
                    childCount: actions.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}
