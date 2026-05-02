import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    AppColors.primary,
                    const Color(0xFF002D62),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 3,
                    offset: const Offset(0, 4),
                  ),
                ],
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
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.mint.withOpacity(0.5), width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 22.r,
                                  backgroundColor: Colors.white10,
                                  child: Icon(Icons.person_rounded, color: Colors.white, size: 28.sp),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Welcome back,",
                                    style: TextStyle(color: Colors.white60, fontSize: 12.sp, fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    staffName, // Passing from constructor
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Badge(
                              backgroundColor: AppColors.mint,
                              smallSize: 8,
                              child: Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22.sp),
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. QUICK ACTIONS SECTION
          SliverPadding(
            padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 10.h),
            sliver: SliverToBoxAdapter(
              child: Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 30.h),
            sliver: Consumer<TeacherHomeViewModel>(
              builder: (context, vm, _) {
                final actions = vm.quickActions;
                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                    childAspectRatio: 1.15,
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
