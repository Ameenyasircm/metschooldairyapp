import 'package:flutter/material.dart';
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
      title: 'My Students',
      icon: Icons.group_rounded, // Changed
      color: AppColors.mint,
      onTap: () {},
    ),
    QuickAction(
      title: 'Punctuality Record',
      icon: Icons.timer_outlined, // Changed
      color: AppColors.greyGreen,
      onTap: () {},
    ),
    QuickAction(
      title: 'Add Attendance',
      icon: Icons.how_to_reg_rounded, // Changed
      color: AppColors.blueish,
      onTap: () {},
    ),
    QuickAction(
      title: 'Attendance\n Report',
      icon: Icons.analytics_outlined, // Changed
      color: AppColors.textTeal,
      onTap: () {},
    ),
    QuickAction(
      title: 'Add Exam',
      icon: Icons.quiz_outlined, // Changed
      color: AppColors.reddish,
      onTap: () {},
    ),
    QuickAction(
      title: 'Homework',
      icon: Icons.auto_stories_outlined, // Changed
      color: AppColors.successGreen,
      onTap: () {},
    ),
    QuickAction(
      title: 'Time Table',
      icon: Icons.grid_view_rounded, // Changed
      color: AppColors.blueish,
      onTap: () {},
    ),
    QuickAction(
      title: 'Parent\n Communication',
      icon: Icons.forum_outlined, // Changed
      color: AppColors.mint,
      onTap: () {},
    ),
    QuickAction(
      title: 'Rules & Regulations',
      icon: Icons.gavel_rounded, // Changed
      color: AppColors.blueish,
      onTap: () {},
    ),
    QuickAction(
      title: 'School Timing',
      icon: Icons.schedule_rounded, // Changed
      color: AppColors.reddish,
      onTap: () {},
    ),
    QuickAction(
      title: 'Leave Requests',
      icon: Icons.event_busy_rounded, // Changed
      color: AppColors.mint,
      onTap: () {},
    ),
    QuickAction(
      title: 'School Calendar',
      icon: Icons.calendar_today_rounded, // Changed
      color: AppColors.primaryBlue,
      onTap: () {},
    ),
    QuickAction(
      title: 'Syllabus',
      icon: Icons.import_contacts_rounded, // Changed
      color: AppColors.textTeal,
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
