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
import '../../../../../communication/screens/students_parents_list_screen.dart';
import '../../../../../mobile_rules_regulations/screens/bellTiming_screen.dart';
import '../../../../../mobile_rules_regulations/screens/rules_list_screen.dart';
import '../../../attendance/presentation/screens/attendance_report_screen.dart';
import '../../../attendance/presentation/screens/attendance_screen.dart';
import '../../../punctuality/data/screens/students_list_punctuality.dart';
import '../../../students/presentation/provider/student_provider.dart';
import '../../../students/presentation/screens/my_students_screen.dart';
import '../../../timetable/presentation/screens/timetable_screen.dart';
import '../../../leaves/presentation/screens/teacher_leave_management_screen.dart';
import '../../viewmodels/teacher_home_viewmodel.dart';

Widget buildQuickActions(BuildContext context) {
  return Consumer<TeacherHomeViewModel>(
    builder: (context, vm, _) {
      final actions = vm.quickActions;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
          childAspectRatio: 1.2,
        ),
        itemCount: actions.length,
        itemBuilder: (context65, index) {
          return InkWell(
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                final divisionId = prefs.getString("divisionId")??'';
                final divisionName = prefs.getString("divisionName")??'';
                final academicYearId = prefs.getString("academicYearId")??'';
                final staffId = prefs.getString("staffId")??'';
                final standard = prefs.getString("className") ?? '';
                switch(index){
                  case 0:
                    final provider = context.read<StudentProvider>();
                    provider. searchMyStdQuery = '';
                    NavigationService.push(context, MyStudentsScreen());
                    break;
                  case 1:
                      final provider = context.read<StudentProvider>();
                      provider.fetchMyStudentsInitial();
                    callNext(PunctualityStudentListScreen(), context);
                    break;
                  case 2:
                    NavigationService.push(context, AttendanceScreen(divisionId: divisionId, divisionName: divisionName, academicYearId:academicYearId, teacherId: staffId,));
                    break;
                  case 3:
                    NavigationService.push(context, AttendanceReportScreen(divisionId: divisionId, divisionName: divisionName,));
                    break;
                  case 5:
                    NavigationService.push(context, const HomeworkListScreen());
                    break;
                  case 6:
                    NavigationService.push(context,  TimetableScreen(
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
                  default:
                    break;

                }
              },
              child: QuickActionCard(action: actions[index]));
        },
      );
    },
  );
}