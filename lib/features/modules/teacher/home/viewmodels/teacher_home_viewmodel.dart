import 'package:flutter/material.dart';
import 'package:met_school/core/theme/app_colors.dart';
import '../data/models/quick_action.dart';

class TeacherHomeViewModel extends ChangeNotifier {
  int _selectedIndex = 0;
  final String teacherName = "Professor Sarah";

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
          title: 'Add Students',
          icon: Icons.person_add_alt_1_outlined,
          color: AppColors.mint,
          onTap: () {
            debugPrint("Tapped Add Students");
          },
        ),
        QuickAction(
          title: 'Add Marks',
          icon: Icons.edit_note_outlined,
          color: AppColors.greyGreen,
          onTap: () {
            debugPrint("Tapped Add Marks");
          },
        ),
        QuickAction(
          title: 'Add Attendance',
          icon: Icons.calendar_month_outlined,
          color: AppColors.blueish,
          onTap: () {
            debugPrint("Tapped Add Attendance");
          },
        ),
        QuickAction(
          title: 'Add Exam',
          icon: Icons.assignment_outlined,
          color: AppColors.reddish,
          onTap: () {
            debugPrint("Tapped Add Exam");
          },
        ),
      ];

  void setSelectedIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }
}
