import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/constants/app_assets.dart';
import 'package:provider/provider.dart';
import 'package:met_school/core/constants/app_padding.dart';
import 'package:met_school/core/constants/app_radius.dart';
import 'package:met_school/core/constants/app_spacing.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_typography.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../core/router/app_navigation.dart';
import '../../../../../../core/utils/navigation/navigation_helper.dart';
import '../../../../../../providers/admin_provider.dart';
import '../../../../../communication/screens/students_parents_list_screen.dart';
import '../../../../../homework/screens/homework_list_screen.dart';
import '../../../../../mobile_rules_regulations/screens/bellTiming_screen.dart';
import '../../../../../mobile_rules_regulations/screens/rules_list_screen.dart';
import '../../../attendance/presentation/screens/attendance_report_screen.dart';
import '../../../attendance/presentation/screens/attendance_screen.dart';
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

class TeacherHomeScreen extends StatelessWidget {
  final String staffName;
  const TeacherHomeScreen({super.key, required this.staffName});

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


          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 30.h),
            sliver: Consumer<TeacherHomeViewModel>(
              builder: (context, vm, _) {
                final actions = vm.quickActions;
                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 9.w,
                    mainAxisSpacing: 12.h,

                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return InkWell(
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();
                          final divisionId = prefs.getString("divisionId") ?? '';
                          final divisionName = prefs.getString("divisionName") ?? '';
                          final academicYearId = prefs.getString("academicYearId") ?? '';
                          final staffId = prefs.getString("staffId") ?? '';
                          final staffName = prefs.getString("staffName") ?? '';
                          final standard = prefs.getString("className") ?? '';

                          switch (index) {
                            case 0:
                              final provider = context.read<StudentProvider>();
                              provider.searchMyStdQuery = '';
                              context.read<StudentProvider>().fetchMyStudentsInitial();
                              NavigationService.push(context, MyStudentsScreen());
                              break;
                            case 1:
                              final provider = context.read<StudentProvider>();
                              provider.fetchMyStudentsInitial();
                              NavigationService.push(context, PunctualityStudentListScreen());
                              break;
                            case 2:
                              NavigationService.push(context,
                                  AttendanceScreen(
                                    divisionId: divisionId,
                                    divisionName: divisionName,
                                    academicYearId: academicYearId,
                                    teacherId: staffId,
                                  ));
                              break;
                            case 3:
                              NavigationService.push(
                                  context,
                                  AttendanceReportScreen(
                                    divisionId: divisionId,
                                    divisionName: divisionName,
                                  ));
                              break;
                            case 4:
                              NavigationService.push(context, ExamComingSoonPage());
                              break;
                            case 5:
                              NavigationService.push(context, const HomeworkListScreen());
                              break;
                            case 6:
                              NavigationService.push(
                                  context,
                                  TimetableScreen(
                                    academicId: academicYearId,
                                    standard: standard,
                                    division: divisionName,
                                  ));

                            case 7:
                              final provider = context.read<StudentProvider>();
                              provider.fetchMyStudentsInitial();
                              callNext(StudentsParentsListScreen(), context);

                              break;

                            case 8:
                              final provider = context.read<AdminProvider>();
                              provider.fetchRules();
                              callNext(RulesUserScreen(), context);
                              break;
                            case 9:
                              final provider = context.read<AdminProvider>();
                              provider.fetchBellTiming();
                              callNext(BellTimingUserScreen(), context);
                              break;
                            case 10:
                              callNext(const TeacherLeaveManagementScreen(), context);
                              break;
                            case 11:
                              callNext(const SchoolCalendarMobileScreen(), context);
                              break;
                            case 12:
                              NavigationService.push(context, const SyllabusListScreen());
                              break;
                            default:
                              break;
                          }
                        },
                        child: QuickActionCard(
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

  Widget _buildQuickStats() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded,
              color: AppColors.mint, size: 18),
          SizedBox(width: 12.w),
          Text(
            "Today: 4 Classes | 2 Exams Scheduled",
            style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
