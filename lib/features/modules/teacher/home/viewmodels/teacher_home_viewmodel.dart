import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:met_school/core/constants/app_assets.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/quick_action.dart';

class TeacherHomeViewModel extends ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  String? _divisionName;
  String? _className;
  int _studentCount = 0;
  bool _isLoading = false;

  String get divisionName => _divisionName ?? '';
  String get className => _className ?? '';
  int get studentCount => _studentCount;
  bool get isLoading => _isLoading;

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

  Future<void> fetchTeacherDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _divisionName = prefs.getString("divisionName");
      _className = prefs.getString("className");
      final divisionId = prefs.getString("divisionId");

      if (divisionId != null && divisionId.isNotEmpty) {
        final countQuery = FirebaseFirestore.instance
            .collection('enrollments')
            .where('class_name', isEqualTo: _className)
            .where('division_id', isEqualTo: divisionId)
            .count();

        final snapshot = await countQuery.get();
        _studentCount = snapshot.count ?? 0;
      }
    } catch (e) {
      debugPrint("Error fetching teacher dashboard data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String getStandardText(dynamic standard) {
    if (standard == null) return '';
    // Handle LKG & UKG first
    if (standard == "LKG" || standard == "UKG") {
      return standard;
    }

    // Convert to int safely
    int? std;
    if (standard is int) {
      std = standard;
    } else {
      std = int.tryParse(standard.toString());
    }

    if (std == null) return standard.toString();

    if (std >= 11 && std <= 13) {
      return "${std}th";
    }

    switch (std % 10) {
      case 1:
        return "${std}st";
      case 2:
        return "${std}nd";
      case 3:
        return "${std}rd";
      default:
        return "${std}th";
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
    ),
    QuickAction(
      title: 'Events',
      icon: AppAssets.event,
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
