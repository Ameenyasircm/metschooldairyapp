import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/router/app_navigation.dart';
import 'package:met_school/core/utils/navigation/navigation_helper.dart';
import 'package:met_school/features/modules/teacher/home/presentation/widgets/quick_action_card.dart';
import 'package:met_school/features/modules/teacher/students/presentation/screens/tech_student_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../attendance/presentation/screens/attendance_report_screen.dart';
import '../../../attendance/presentation/screens/attendance_screen.dart';
import '../../../punctuality/data/screens/students_list_punctuality.dart';
import '../../../students/presentation/provider/student_provider.dart';
import '../../../students/presentation/screens/my_students_screen.dart';
import '../../../timetable/presentation/screens/timetable_screen.dart';
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
                    NavigationService.push(context,  TimetableScreen(
                      standard: standard,
                      division: divisionName,
                    ));

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