import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AdminProvider with ChangeNotifier {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final FirebaseDatabase realtime = FirebaseDatabase.instance;

  AdminProvider() {
    fetchSubjects();
    fetchClasses();
  }

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // ================= NEW STATE VARIABLES =================
  String? selectedRole;
  String? selectedGender;
  String? selectedCategory;
  String? selectedDesignation;
  String? selectedQual;

  List<String> subjectsList = [];
  List<String> selectedSubjects = [];
  List<String> classList = [];
  DateTime? joiningDate;
  String status = "active";
  bool isLoading = false;

  // ================= DIVISIONS STATE =================
  List<DocumentSnapshot> _divisionsList = [];
  List<DocumentSnapshot> get divisionsList => _divisionsList;

  // ================= CONTROLLERS =================
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final empIdCtrl = TextEditingController();
  final qualCtrl = TextEditingController();
  final expCtrl = TextEditingController();
  final subjectCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  // ================= DATA FETCHING =================

  Future<void> fetchSubjects() async {
    try {
      final snapshot = await fireStore.collection('subjects').get();
      subjectsList = snapshot.docs.map((e) => e['name'].toString()).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching subjects: $e");
    }
  }

  Future<void> fetchClasses() async {
    classList = List.generate(12, (index) => "${index + 1}");
    notifyListeners();
  }

  // ================= DIVISIONS LOGIC (NEW) =================

  /// 🔹 Fetch Divisions for a specific Class & Academic Year
  Future<void> fetchDivisions(String classId, String academicYearId) async {
    isLoading = true;
    notifyListeners();
    try {
      final snapshot = await fireStore
          .collection('divisions')
          .where('academic_year_id', isEqualTo: academicYearId)
          .where('class_id', isEqualTo: classId)
          .get();

      _divisionsList = snapshot.docs;
    } catch (e) {
      debugPrint("Error fetching divisions: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 🔹 Add a New Division to Firestore
  Future<void> addDivision({
    required String academicYearId,
    required String classId,
    required String className,
    required String divisionName,
    required String classTeacherId,
    required Map<String, String> subjectTeachers,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      DocumentReference docRef = fireStore.collection('divisions').doc();

      await docRef.set({
        'division_id': docRef.id,
        'academic_year_id': academicYearId,
        'class_id': classId,
        'class': className,
        'division_name': divisionName,
        'class_teacher_id': classTeacherId,
        'subject_teachers': subjectTeachers,
        'created_at': FieldValue.serverTimestamp(),
      });

      // Refresh list
      await fetchDivisions(classId, academicYearId);
    } catch (e) {
      debugPrint("Error adding division: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ================= STAFF SAVE LOGIC =================

  Future<void> saveStaffFull({
    String? docId,
    required String userId,
    required String userName,
  }) async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners();

    try {
      final batch = fireStore.batch();
      final bool isEditing = docId != null;
      final String targetId = docId ?? "SF${DateTime.now().millisecondsSinceEpoch}";

      final userRef = fireStore.collection('users').doc(targetId);
      final profileRef = fireStore.collection('staff_profiles').doc(targetId);
      final logRef = fireStore.collection('activity_logs').doc();

      final userData = {
        "uid": targetId,
        "name": nameCtrl.text.trim(),
        "phone": phoneCtrl.text.trim(),
        "email": emailCtrl.text.trim(),
        "username": usernameCtrl.text.trim().isNotEmpty ? usernameCtrl.text.trim() : phoneCtrl.text.trim(),
        "role": selectedRole,
        "password": passwordCtrl.text.trim(),
        "status": status,
        "updatedAt": FieldValue.serverTimestamp(),
        if (!isEditing) ...{
          "createdAt": FieldValue.serverTimestamp(),
          "createdById": userId,
          "createdByName": userName,
        }
      };

      final profileData = {
        "uid": targetId,
        "employee_id": empIdCtrl.text.trim(),
        "name": nameCtrl.text.trim(),
        "email": emailCtrl.text.trim(),
        "phone": phoneCtrl.text.trim(),
        "role": selectedRole,
        "password": passwordCtrl.text.trim(),
        "gender": selectedGender,
        "qualification": selectedQual,
        "total_experience": int.tryParse(expCtrl.text) ?? 0,
        "joining_date": joiningDate,
        "address": addressCtrl.text.trim(),
        "status": status,
        "updatedAt": FieldValue.serverTimestamp(),
        if (!isEditing) "createdAt": FieldValue.serverTimestamp(),
        if (selectedRole == 'teacher') ...{
          "designation": selectedDesignation,
          "subjects": List<String>.from(selectedSubjects),
        },
      };

      batch.set(userRef, userData, SetOptions(merge: true));
      batch.set(profileRef, profileData, SetOptions(merge: true));

      batch.set(logRef, {
        "action": isEditing ? "EDIT_STAFF" : "ADD_STAFF",
        "module": "STAFF_MANAGEMENT",
        "targetId": targetId,
        "targetName": nameCtrl.text.trim(),
        "doneBy": userName,
        "doneById": userId,
        "timestamp": FieldValue.serverTimestamp(),
        "description": isEditing
            ? "Updated profile details for ${nameCtrl.text.trim()}"
            : "Registered new staff member: ${nameCtrl.text.trim()}",
      });

      await batch.commit();
      clearStaffForm();

    } catch (e) {
      debugPrint("❌ Firestore Batch Error: $e");
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearStaffForm() {
    nameCtrl.clear();
    phoneCtrl.clear();
    usernameCtrl.clear();
    passwordCtrl.clear();
    emailCtrl.clear();
    empIdCtrl.clear();
    qualCtrl.clear();
    expCtrl.clear();
    subjectCtrl.clear();
    addressCtrl.clear();

    selectedRole = null;
    selectedCategory = null;
    selectedGender = null;
    selectedDesignation = null;
    selectedQual = null;
    selectedSubjects.clear();
    joiningDate = null;

    notifyListeners();
  }

  Stream<QuerySnapshot> getStaffStream() {
    return fireStore.collection('staff_profiles').orderBy('name').snapshots();
  }

  Future<void> removeStaff({
    required String docId,
    required String adminId,
    required String adminName
  }) async {
    try {
      final batch = fireStore.batch();
      final userRef = fireStore.collection('users').doc(docId);
      final profileRef = fireStore.collection('staff_profiles').doc(docId);
      final logRef = fireStore.collection('activity_logs').doc();

      batch.delete(userRef);
      batch.delete(profileRef);

      batch.set(logRef, {
        "action": "DELETE_STAFF",
        "module": "STAFF_MANAGEMENT",
        "targetId": docId,
        "doneBy": adminName,
        "doneById": adminId,
        "timestamp": FieldValue.serverTimestamp(),
        "description": "Permanently deleted staff record ",
      });

      await batch.commit();
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Delete Error: $e");
    }
  }

  // --- ACADEMIC YEAR LOGIC ---
  List<QueryDocumentSnapshot> academicYears = [];

  Future<void> fetchAcademicYears() async {
    isLoading = true;
    notifyListeners();
    try {
      final snapshot = await fireStore
          .collection("academic_years")
          .orderBy("start_date", descending: true)
          .get();
      academicYears = snapshot.docs;
    } catch (e) {
      debugPrint("Error fetching years: $e");
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> addAcademicYear({
    required String yearName,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final String docId = DateTime.now().millisecondsSinceEpoch.toString();

      await fireStore.collection("academic_years").doc(docId).set({
        "id": docId,
        "year_name": yearName,
        "is_current": false,
        "start_date": startDate,
        "end_date": endDate,
        "created_at": Timestamp.now(),
      });
      await fetchAcademicYears();
    } catch (e) {
      debugPrint("Error adding year: $e");
    }
  }

  Future<void> setCurrentYear(String docId) async {
    try {
      final snapshot = await fireStore.collection("academic_years").get();
      for (var doc in snapshot.docs) {
        await doc.reference.update({"is_current": false});
      }
      await fireStore.collection("academic_years").doc(docId).update({"is_current": true});
      await fetchAcademicYears();
    } catch (e) {
      debugPrint("Error setting current year: $e");
    }
  }

  // --- STUDENT LOGIC ---
  List<DocumentSnapshot> studentsList = [];
  bool isStudentLoading = false;

  Future<void> fetchStudents() async {
    isStudentLoading = true;
    notifyListeners();
    try {
      final snapshot = await fireStore.collection('students').get();
      studentsList = snapshot.docs;
    } catch (e) {
      debugPrint("Error fetching students: $e");
    }
    isStudentLoading = false;
    notifyListeners();
  }

  Future<void> addStudent(Map<String, dynamic> data) async {
    await fireStore.collection('students').add(data);
    fetchStudents();
  }
  // Inside AdminProvider
  Future<void> fetchDivisionsGlobally(String academicYearId) async {
    isLoading = true;
    notifyListeners();
    try {
      final snapshot = await fireStore
          .collection('divisions')
          .where('academic_year_id', isEqualTo: academicYearId)
          .get();
      _divisionsList = snapshot.docs;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}