import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/router/app_navigation.dart';
import 'package:met_school/core/utils/navigation/navigation_helper.dart';
import 'package:met_school/features/modules/teacher/home/presentation/widgets/quick_action_card.dart';
import 'package:met_school/features/modules/teacher/students/presentation/screens/tech_student_list_screen.dart';
import 'package:met_school/providers/admin_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:met_school/features/modules/teacher/homework/presentation/screens/homework_list_screen.dart';
import 'package:met_school/features/modules/teacher/syllabus/presentation/screens/syllabus_list_screen.dart';
import '../../../../../communication/screens/students_parents_list_screen.dart';
import '../../../../../mobile_rules_regulations/screens/bellTiming_screen.dart';
import '../../../../../mobile_rules_regulations/screens/rules_list_screen.dart';
import '../../../attendance/presentation/screens/attendance_report_screen.dart';
import '../../../attendance/presentation/screens/attendance_screen.dart';
import '../../../exams/presentation/screens/exam_coming_soon_screen.dart';
import '../../../fee/views/fee_students_list.dart';
import '../../../punctuality/data/screens/students_list_punctuality.dart';
import '../../../school_calender/screens/school_calender_mobile_screen.dart';
import '../../../students/presentation/provider/student_provider.dart';
import '../../../students/presentation/screens/my_students_screen.dart';
import '../../../timetable/presentation/screens/timetable_screen.dart';
import '../../../leaves/presentation/screens/teacher_leave_management_screen.dart';
import '../../viewmodels/teacher_home_viewmodel.dart';

Widget buildQuickActions(BuildContext context) {
  final studentProvider = context.watch<StudentProvider>();
  return Consumer<TeacherHomeViewModel>(
    builder: (context4, vm, _) {
      return SliverPadding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 10.h),
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
                      final classId = prefs.getString("classId") ?? '';

                      final action = actions[index];
                      switch (action.title) {
                        case 'Notice':
                          break;
                        case 'Attendance':
                          NavigationService.push(context,
                              AttendanceScreen(
                                divisionId: divisionId,
                                divisionName: divisionName,
                                academicYearId: academicYearId,
                                teacherId: staffId, classId: classId,));
                          break;
                        case 'Homework':
                          NavigationService.push(context, const HomeworkListScreen());
                          break;
                        case 'Exams':
                          NavigationService.push(context, ExamComingSoonPage());
                          break;
                        case 'Leave Requests':
                          callNext(const TeacherLeaveManagementScreen(), context);
                          break;
                        case 'TimeTable':
                          NavigationService.push(
                              context,
                              TimetableScreen(
                                academicId: academicYearId,
                                standard: standard,
                                division: divisionName,
                              ));
                          break;
                        case 'Chat':
                          final provider = context.read<StudentProvider>();
                          provider.fetchMyStudentsInitial();
                          callNext(StudentsParentsListScreen(), context);
                          break;
                        case 'Calender':
                          callNext(const SchoolCalendarMobileScreen(), context);
                          break;
                        case 'Punctuality Record':
                          final studentProvider = context.read<StudentProvider>();
                          studentProvider.fetchMyStudentsInitial();
                          NavigationService.push(context, PunctualityStudentListScreen());
                          break;
                        case 'Syllabus':
                          NavigationService.push(context, const SyllabusListScreen());
                          break;
                        case 'Fee':
                          final academicYearId = prefs.getString("academicYearId") ?? '';
                          studentProvider.searchMyStdQuery = '';
                          studentProvider.fetchMyStudentsInitial();
                          NavigationService.push(context,  FeeStudentsListScreen(academicYearId:academicYearId ,));
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
      );
    },
  );
}