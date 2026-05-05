import 'package:flutter/material.dart';
import 'package:met_school/core/constants/app_assets.dart';
import 'package:met_school/core/theme/app_colors.dart';
import '../data/models/quick_action.dart';

class TeacherHomeViewModel extends ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  String get greetingText {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning,';
    } else if (hour < 17) {
      return 'Good Afternoon,';
    } else {
      return 'Good Evening,';
    }
  }


  List<QuickAction> get quickActions => [
    QuickAction(
      title: 'Notice',
      icon: AppAssets.notification, // Changed
      onTap: () {},
    ),
    QuickAction(
      title: 'Attendance',
      icon: AppAssets.attendanceReport, // Changed
      onTap: () {},
    ),
    QuickAction(
      title: 'Homework',
      icon: AppAssets.homeWork,
      onTap: () {},
    ),
    QuickAction(
      title: 'Exams',
      icon: AppAssets.exams ,
      onTap: () {},
    ),

    QuickAction(
      title: 'Leave Requests',
      icon: AppAssets.leaves,
      onTap: () {},
    ),
    QuickAction(
      title: 'TimeTable',
      icon:AppAssets.timetable,
      onTap: () {},
    ),
    QuickAction(
      title: 'Chat',
      icon:AppAssets.chat,
      onTap: () {},
    ),
    QuickAction(
      title: 'Calender',
      icon: AppAssets.calender,
      onTap: () {},
    ),
    QuickAction(
      title: 'Syllabus',
      icon: AppAssets.syllabus,
      onTap: () {},
    ),
  ];
  List<QuickAction> get listActions => [
    QuickAction(
      title: 'Rules & Regulations',
      icon: AppAssets.rules,
      onTap: () {},
    ),
    QuickAction(
      title: 'Attendance Report',
      icon: AppAssets.attendanceReport,
      onTap: () {},
    ),
    QuickAction(
      title: 'My Students',
      icon: AppAssets.myStudents,
      onTap: () {},
    ),
    QuickAction(
      title: 'Punctuality Record',
      icon: AppAssets.punctuality,
      onTap: () {},
    ),  QuickAction(
      title: 'School Timing',
      icon: AppAssets.schoolTime,
      onTap: () {},
    ),
  ];

  void setSelectedIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }
}
