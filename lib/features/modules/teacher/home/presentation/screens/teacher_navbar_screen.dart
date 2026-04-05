import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/features/modules/teacher/home/viewmodels/teacher_home_viewmodel.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'teacher_home_screen.dart';

class TeacherNavbarScreen extends StatelessWidget {
  final String staffName;
  const TeacherNavbarScreen({super.key,required this.staffName});

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherHomeViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          body: IndexedStack(
            index: vm.selectedIndex,
            children:[
              TeacherHomeScreen(staffName:staffName,),
              SizedBox(),
              SizedBox(),
              SizedBox(),
            ],
          ),

          bottomNavigationBar: const AppBottomNavBar(),
        );
      },
    );
  }
}
