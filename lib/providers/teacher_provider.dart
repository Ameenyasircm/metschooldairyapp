import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/enums/app_enums.dart';
import '../features/modules/teacher/home/data/models/subject_assignment_model.dart';

class TeacherProvider with ChangeNotifier {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final FirebaseDatabase realtime = FirebaseDatabase.instance;

  TeacherMode _activeMode = TeacherMode.none;
  List<SubjectAssignmentModel> _subjectAssignments = [];
  bool _isClassTeacher = false;
  Map<String, dynamic>? _currentAssignment;

  TeacherMode get activeMode => _activeMode;
  List<SubjectAssignmentModel> get subjectAssignments => _subjectAssignments;
  bool get isClassTeacher => _isClassTeacher;
  Map<String, dynamic>? get currentAssignment => _currentAssignment;

  void setActiveMode(TeacherMode mode) {
    _activeMode = mode;
    saveActiveMode(mode);
    notifyListeners();
  }

  Future<void> saveActiveMode(TeacherMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("teacherMode", mode.name);
  }

  Future<void> loadTeacherData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load active mode
    String? modeStr = prefs.getString("teacherMode");
    if (modeStr != null) {
      _activeMode = TeacherMode.values.firstWhere(
        (e) => e.name == modeStr,
        orElse: () => TeacherMode.none,
      );
    }

    _isClassTeacher = prefs.getBool("isClassTeacher") ?? false;
    
    // In a real app, you might want to fetch subject assignments from Firestore here
    // or load them from cache if they were saved during login.
    notifyListeners();
  }

  void setSubjectAssignments(List<SubjectAssignmentModel> assignments) {
    _subjectAssignments = assignments;
    notifyListeners();
  }

  void setClassTeacherStatus(bool status, Map<String, dynamic>? assignment) {
    _isClassTeacher = status;
    _currentAssignment = assignment;
    notifyListeners();
  }
}
