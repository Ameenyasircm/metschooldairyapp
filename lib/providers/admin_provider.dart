import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AdminProvider with ChangeNotifier {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final FirebaseDatabase realtime = FirebaseDatabase.instance;

  AdminProvider(){
    fetchSubjects();
  }

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // --- STAFF LOGIC ---

  // Stream for Real-time List
  Stream<QuerySnapshot> getStaffStream() {
    return fireStore.collection('staff_profiles').orderBy('name').snapshots();
  }

  // ================= CONTROLLERS =================
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  /// teacher
  final empIdCtrl = TextEditingController();
  final qualCtrl = TextEditingController();
  final expCtrl = TextEditingController();
  final subjectCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  String? selectedRole;
  String? selectedCategory;

// ================= CLEAR =================
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
    selectedGender = null; // ✅ ADD THIS
    selectedSubjects.clear();
    joiningDate = null;

    notifyListeners();
  }

  List<String> subjectsList = [];
  List<String> selectedSubjects = [];

  DateTime? joiningDate;
  Future<void> fetchSubjects() async {
    final snapshot = await fireStore.collection('subjects').get();

    subjectsList = snapshot.docs
        .map((e) => e['name'].toString())
        .toList();

    notifyListeners();
  }

  final emailCtrl = TextEditingController();
  final gender = "Male"; // or String? selectedGender
  String status = "active";
  String? selectedGender;

  Future<void> saveStaffFull({
    String? docId,
    required String userId,
    required String userName,
  }) async {
    final batch = fireStore.batch();

    /// 🔥 UID
    final newId = "SF${DateTime.now().millisecondsSinceEpoch}";

    final userRef = fireStore.collection('users').doc(newId);
    final profileRef = fireStore.collection('staff_profiles').doc(newId);

    /// 🔥 FORMAT DATE
    final joiningDateStr = joiningDate != null
        ? "${joiningDate!.year}-${joiningDate!.month.toString().padLeft(2, '0')}-${joiningDate!.day.toString().padLeft(2, '0')}"
        : "";

    /// 🔹 USERS COLLECTION
    final userData = {
      "uid": newId,
      "name": nameCtrl.text,
      "phone": phoneCtrl.text,
      "email": emailCtrl.text,
      "role": selectedRole,
      "password": passwordCtrl.text,
      "status": status,
      "createdAt": FieldValue.serverTimestamp(),
      "createdById": userId,
      "createdByName": userName,
    };

    batch.set(userRef, userData, SetOptions(merge: true));

    /// 🔹 STAFF PROFILE COLLECTION
    final profileData = {
      "uid": newId,
      "employee_id": empIdCtrl.text, // e.g. MET-002
      "designation": selectedRole,
      "category": selectedCategory,
      "gender": selectedGender,
      "subjects": selectedSubjects,
      "qualification": qualCtrl.text,
      "address": addressCtrl.text,
      "joining_date": joiningDateStr,
      "total_experience": int.tryParse(expCtrl.text) ?? 0,
      "status": status,
      "createdAt": FieldValue.serverTimestamp(),
    };

    batch.set(profileRef, profileData, SetOptions(merge: true));

    await batch.commit();

    clearStaffForm();
  }

  String generateStaffId() {
    return "SF${DateTime.now().millisecondsSinceEpoch}";
  }

  // Delete Staff
  Future<void> removeStaff(String docId) async {
    await fireStore.collection('staff_profiles').doc(docId).delete();
  }

  List<QueryDocumentSnapshot> academicYears = [];
  bool isLoading = false;

  /// ================= FETCH =================
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

  /// ================= ADD =================
  Future<void> addAcademicYear({
    required String yearName,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final String docId =
      DateTime.now().millisecondsSinceEpoch.toString();

      await fireStore
          .collection("academic_years")
          .doc(docId)
          .set({
        "id": docId, // optional but useful
        "year_name": yearName,
        "is_current": false,
        "start_date": startDate,
        "end_date": endDate,
        "created_at": Timestamp.now(), // good practice
      });

      await fetchAcademicYears();
    } catch (e) {
      debugPrint("Error adding year: $e");
    }
  }
  /// ================= SET CURRENT =================
  Future<void> setCurrentYear(String docId) async {
    try {
      /// 🔥 Make all false first
      final snapshot = await fireStore.collection("academic_years").get();

      for (var doc in snapshot.docs) {
        await doc.reference.update({"is_current": false});
      }

      /// ✅ Set selected one true
      await fireStore
          .collection("academic_years")
          .doc(docId)
          .update({"is_current": true});

      await fetchAcademicYears();
    } catch (e) {
      debugPrint("Error setting current year: $e");
    }
  }

  List<DocumentSnapshot> studentsList = [];
  bool isStudentLoading = false;

  Future<void> fetchStudents() async {
    isStudentLoading = true;
    notifyListeners();

    try {
      final snapshot =
      await FirebaseFirestore.instance.collection('students').get();

      studentsList = snapshot.docs;
    } catch (e) {
      debugPrint("Error fetching students: $e");
    }

    isStudentLoading = false;
    notifyListeners();
  }

  Future<void> addStudent(Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection('students').add(data);
    fetchStudents();
  }
}