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
import '../../../punctuality/data/screens/students_list_punctuality.dart';
import '../../../school_calender/screens/school_calender_mobile_screen.dart';
import '../../../students/presentation/provider/student_provider.dart';
import '../../../students/presentation/screens/my_students_screen.dart';
import '../../../timetable/presentation/screens/timetable_screen.dart';
import '../../../leaves/presentation/screens/teacher_leave_management_screen.dart';
import '../../viewmodels/teacher_home_viewmodel.dart';

Widget buildQuickActions(BuildContext context) {
  return Consumer<TeacherHomeViewModel>(
    builder: (context4, vm, _) {
      return SliverPadding(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
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

                      switch (index) {
                        case 0:
                          break;
                        case 1:
                          NavigationService.push(context,
                              AttendanceScreen(
                                divisionId: divisionId,
                                divisionName: divisionName,
                                academicYearId: academicYearId,
                                teacherId: staffId, classId: classId,));
                          break;
                        case 2:
                          NavigationService.push(context, const HomeworkListScreen());
                          break;
                        case 3:
                          NavigationService.push(context, ExamComingSoonPage());
                          break;
                        case 4:
                          callNext(const TeacherLeaveManagementScreen(), context);
                          break;
                        case 5:
                          NavigationService.push(
                              context,
                              TimetableScreen(
                                academicId: academicYearId,
                                standard: standard,
                                division: divisionName,
                              ));
                          break;
                        case 6:
                          final provider = context.read<StudentProvider>();
                          provider.fetchMyStudentsInitial();
                          callNext(StudentsParentsListScreen(), context);
                        case 7:
                          callNext(const SchoolCalendarMobileScreen(), context);
                          break;
                        case 8:
                          NavigationService.push(context, const SyllabusListScreen());
                          break;
                        case 9:
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
      );
    },
  );
}