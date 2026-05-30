import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:met_school/core/constants/app_assets.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/providers/teacher_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/enums/app_enums.dart';
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

  TeacherProvider? _teacherProvider;

  void updateProvider(TeacherProvider provider) {
    _teacherProvider = provider;
    notifyListeners();
  }

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
      if (_teacherProvider?.activeMode == TeacherMode.classTeacher) {
        final prefs = await SharedPreferences.getInstance();
        _divisionName = prefs.getString("divisionName");
        _className = prefs.getString("className");
        final divisionId = prefs.getString("divisionId");

        if (divisionId != null && divisionId.isNotEmpty) {
          final countQuery = FirebaseFirestore.instance
              .collection('enrollments')
              .where('division_id', isEqualTo: divisionId)
              .count();

          final snapshot = await countQuery.get();
          _studentCount = snapshot.count ?? 0;
        }
      } else if (_teacherProvider?.activeMode == TeacherMode.subjectTeacher) {
        _className = "Subject Teacher";
        _divisionName = "Mode";
        _studentCount = _teacherProvider?.subjectAssignments.length ?? 0;
      }
    } catch (e) {
      debugPrint("Error fetching teacher dashboard data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<QuickAction> get quickActions {
    final mode = _teacherProvider?.activeMode ?? TeacherMode.none;

    if (mode == TeacherMode.subjectTeacher) {
      return [
        QuickAction(
          title: 'Homework',
          icon: AppAssets.homeWork,
          onTap: () {},
        ),
        QuickAction(
          title: 'Punctuality Record',
          icon: AppAssets.punctuality,
          onTap: () {},
        ),
      ];
    }

    if (mode == TeacherMode.none) return [];

    return [
      QuickAction(
        title: 'Notice',
        icon: AppAssets.notification,
        onTap: () {},
      ),
      QuickAction(
        title: 'Attendance',
        icon: AppAssets.attendanceReport,
        onTap: () {},
      ),
      QuickAction(
        title: 'Homework',
        icon: AppAssets.homeWork,
        onTap: () {},
      ),
      QuickAction(
        title: 'Exams',
        icon: AppAssets.exams,
        onTap: () {},
      ),
      QuickAction(
        title: 'Leave Requests',
        icon: AppAssets.leaves,
        onTap: () {},
      ),
      QuickAction(
        title: 'TimeTable',
        icon: AppAssets.timetable,
        onTap: () {},
      ),
      QuickAction(
        title: 'Chat',
        icon: AppAssets.chat,
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
      QuickAction(
        title: 'Fee',
        icon: AppAssets.fees,
        onTap: () {},
      ),
      QuickAction(
        title: 'Lesson Plan',
        icon: AppAssets.attendanceReport,
        onTap: () {},
      ),
    ];
  }

  List<QuickAction> get listActions {
    final mode = _teacherProvider?.activeMode ?? TeacherMode.none;

    if (mode == TeacherMode.subjectTeacher) {
      return [];
    }

    if (mode == TeacherMode.none) return [];

    return [
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
      ),
      QuickAction(
        title: 'School Timing',
        icon: AppAssets.schoolTime,
        onTap: () {},
      ),
    ];
  }

  void setSelectedIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }
}

