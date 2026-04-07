import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/router/app_navigation.dart';
import 'package:met_school/features/modules/teacher/home/presentation/widgets/quick_action_card.dart';
import 'package:met_school/features/modules/teacher/students/presentation/screens/tech_student_list_screen.dart';
import 'package:provider/provider.dart';

import '../../../attendance/presentation/screens/attendance_screen.dart';
import '../../../students/presentation/provider/student_provider.dart';
import '../../../students/presentation/screens/my_students_screen.dart';
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
          childAspectRatio: 1.4,
        ),
        itemCount: actions.length,
        itemBuilder: (context65, index) {
          return InkWell(
              onTap: (){
                switch(index){
                  case 0:
                    final provider = context.read<StudentProvider>();
                    provider. searchMyStdQuery = '';
                    provider.fetchMyStudentsInitial();
                    NavigationService.push(context, MyStudentsScreen());
                    break;
                  case 1:
                    break;
                  case 2:

                    NavigationService.push(context, const AttendanceScreen());
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