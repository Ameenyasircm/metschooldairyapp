import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:met_school/features/modules/parent/views/parent_home.dart';
import 'package:met_school/features/modules/parent/views/parent_profile_screen.dart';

import '../../../../core/theme/app_colors.dart';

class ParentMainScreen extends StatefulWidget {
  final String studentId;
  final String academicYearID;
  final String teacherName;
  final String teacherID;
  final String parentName;

  const ParentMainScreen({
    super.key,
    required this.studentId,
    required this.academicYearID,
    required this.teacherName,
    required this.teacherID,
    required this.parentName,
  });

  @override
  State<ParentMainScreen> createState() => _ParentMainScreenState();
}

class _ParentMainScreenState extends State<ParentMainScreen> {
  int currentIndex = 0;

  late List<Widget> screens;

  @override
  void initState() {
    super.initState();

    screens = [
      ParentHomeScreen(
        studentId: widget.studentId,
        academicYearID: widget.academicYearID,
        teacherName: widget.teacherName,
        teacherID: widget.teacherID,
        parentName: widget.parentName,
      ),
      const ParentProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}