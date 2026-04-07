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
    fetchClasses(); // Logic to load Kerala school classes
  }

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // ================= NEW STATE VARIABLES =================
  String? selectedRole;         // admin | staff | teacher
  String? selectedGender;
  String? selectedCategory;// Male | Female | Other
  String? selectedDesignation;  // teacher | class teacher

  String? selectedQual;         // Qualification Dropdown (B.Ed, M.Ed, etc.)

  List<String> subjectsList = [];
  List<String> selectedSubjects = [];
  List<String> classList = [];
  DateTime? joiningDate;
  String status = "active";
  bool isLoading = false;

  // ================= EXISTING & NEW CONTROLLERS =================
  final nameCtrl = TextEditingController();      // First Name
  final phoneCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  final empIdCtrl = TextEditingController();
  final qualCtrl = TextEditingController();      // Kept for custom input if needed
  final expCtrl = TextEditingController();
  final subjectCtrl = TextEditingController();   // Existing
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
    // Standard Kerala Classes 1 to 12
    classList = List.generate(12, (index) => "${index + 1}");
    notifyListeners();
  }

  // ================= UPDATED SAVE LOGIC =================

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

      // 🛡️ Log Reference
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

      // 🔹 Apply Data Changes
      batch.set(userRef, userData, SetOptions(merge: true));
      batch.set(profileRef, profileData, SetOptions(merge: true));

      // 📝 🔹 ADD LOG ENTRY
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

  // ================= EXISTING LOGIC (PRESERVED) =================

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

      // 1. References to delete
      final userRef = fireStore.collection('users').doc(docId);
      final profileRef = fireStore.collection('staff_profiles').doc(docId);

      // 2. Reference for the log
      final logRef = fireStore.collection('activity_logs').doc();

      batch.delete(userRef);
      batch.delete(profileRef);

      // 📝 3. Log the Deletion
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

  // --- ACADEMIC YEAR LOGIC (UNTOUCHED) ---
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