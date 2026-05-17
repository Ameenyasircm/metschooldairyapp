import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../core/enums/app_enums.dart';
import '../features/modules/teacher/LessonPlan/models/lesson_plan_model.dart';
import '../features/modules/teacher/home/data/models/subject_assignment_model.dart';

class TeacherProvider with ChangeNotifier {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final FirebaseDatabase realtime = FirebaseDatabase.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;

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

  List<LessonPlanModel> lessonPlanList = [];

  /// CONTROLLERS

  final TextEditingController gradeController         = TextEditingController();
  final TextEditingController topicController         = TextEditingController();
  final TextEditingController durationController      = TextEditingController();
  final TextEditingController periodsController       = TextEditingController();
  final TextEditingController methodologiesController = TextEditingController();
  final TextEditingController activityController      = TextEditingController();
  final TextEditingController instructionalController = TextEditingController();
  final TextEditingController objectivesController    = TextEditingController();

// ── Subject ───────────────────────────────────────────────
  String? selectedSubjectId;
  String? selectedSubjectName;

  void setSelectedSubject({required String id, required String name}) {
    selectedSubjectId = id;
    selectedSubjectName = name;
    notifyListeners();
  }

// ── Clear ─────────────────────────────────────────────────
  void clearControllers() {
    gradeController.clear();
    topicController.clear();
    durationController.clear();
    periodsController.clear();
    methodologiesController.clear();
    activityController.clear();
    instructionalController.clear();
    objectivesController.clear();
    selectedSubjectId   = null;
    selectedSubjectName = null;
    notifyListeners();
  }

  @override
  void dispose() {
    gradeController.dispose();
    topicController.dispose();
    durationController.dispose();
    periodsController.dispose();
    methodologiesController.dispose();
    activityController.dispose();
    instructionalController.dispose();
    objectivesController.dispose();
    super.dispose();
  }
  /// SUBJECT


  /// FETCH LESSON PLANS

  Future<void> fetchLessonPlans(String teacherId) async {
    try {
      isLoading = true;
      notifyListeners();

      QuerySnapshot snapshot = await db
          .collection("lesson_plans")
          .where("TEACHER_ID", isEqualTo: teacherId)
          .orderBy("CREATED_AT", descending: true)
          .get();

      lessonPlanList = snapshot.docs.map((doc) {
        return LessonPlanModel.fromMap(
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    } catch (e) {
      debugPrint(e.toString());
    }

    isLoading = false;
    notifyListeners();
  }

  /// ADD ALLOWED ONLY SUNDAY & MONDAY

  bool isAllowedDay() {
    final now = DateTime.now();

    return now.weekday == DateTime.sunday ||
        now.weekday == DateTime.monday;
  }

  /// SUBMIT

  bool isLoading = false;
  Future<void> submitLessonPlan({
    required BuildContext context,
    required String teacherId,
    required String teacherName,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final id = const Uuid().v1();

      LessonPlanModel model = LessonPlanModel(
        id: id,

        teacherId: teacherId,

        teacherName: teacherName,

        subject: selectedSubjectName ?? "",

        grade: gradeController.text.trim(),

        topicName: topicController.text.trim(),

        duration: durationController.text.trim(),

        periodsAllotted:
        periodsController.text.trim(),

        methodologies:
        methodologiesController.text.trim(),

        activity: activityController.text.trim(),

        instructionalTools:
        instructionalController.text.trim(),

        learningObjectives:
        objectivesController.text.trim(),

        createdAt: DateTime.now(),

        status: "Pending",
      );

      await db
          .collection("lesson_plans")
          .doc(id)
          .set(model.toMap());

      await fetchLessonPlans(teacherId);

      clearControllers();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lesson Plan Submitted"),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }

    isLoading = false;
    notifyListeners();
  }


  Future<void> uploadLessonPlan({
    required LessonPlanModel model,
    required BuildContext context,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      await db
          .collection("lesson_plans")
          .doc(model.id)
          .set(model.toMap());

      await fetchLessonPlans(model.teacherId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lesson Plan Submitted Successfully"),
        ),
      );
    } catch (e) {
      debugPrint("UPLOAD LESSON PLAN ERROR : $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }

    isLoading = false;
    notifyListeners();
  }

  /// DELETE LESSON PLAN

  Future<void> deleteLessonPlan({
    required String lessonPlanId,
    required String teacherId,
    required BuildContext context,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      await db
          .collection("lesson_plans")
          .doc(lessonPlanId)
          .delete();

      await fetchLessonPlans(teacherId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lesson Plan Deleted"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      debugPrint("DELETE LESSON PLAN ERROR : $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    isLoading = false;
    notifyListeners();
  }
}
