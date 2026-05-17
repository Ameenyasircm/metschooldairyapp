import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth/auth_io.dart'
as gapis;
import '../features/modules/admin/rules_timing/models/bell_timing_model.dart';
import '../features/modules/admin/school_calaender/models/school_event_model.dart';
import '../features/modules/admin/views/toast.dart';

class AdminProvider with ChangeNotifier {
  final FirebaseFirestore db = FirebaseFirestore.instance;
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

  List<Map<String, dynamic>> subjectsList = []; // Stores {id, name}
  List<Map<String, dynamic>> selectedSubjects = [];
  List<Map<String, dynamic>> allTeachers = [];
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
  final qualCtrl = TextEditingController();
  final expCtrl = TextEditingController();
  final subjectCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final TextEditingController aadharCtrl = TextEditingController();
  final TextEditingController ageCtrl = TextEditingController(); // Calculated automatically
  DateTime? dob;

  bool obscurePassword = true;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  // ================= DATA FETCHING =================

  Future<void> fetchSubjects() async {
    try {
      final snapshot = await fireStore.collection('subjects').get();
      // Store both ID and Name
      subjectsList = snapshot.docs.map((doc) => {
        "id": doc.id,
        "name": doc['name'].toString(),
      }).toList();
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
    required String classTeacherName,
    required String adminId,
    required String adminName,
    Map<String, String> subjectTeachers = const {},
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final batch = fireStore.batch();

      // 1. References
      DocumentReference divRef = fireStore.collection('divisions').doc();
      DocumentReference teacherRef = fireStore.collection('staff_profiles').doc(classTeacherId);
      DocumentReference userRef = fireStore.collection('users').doc(classTeacherId);
      DocumentReference logRef = fireStore.collection('activity_logs').doc();

      // --- DATA OBJECTS ---

      final divisionData = {
        'division_id': divRef.id,
        'academic_year_id': academicYearId,
        'class_id': classId,
        'class_name': className,
        'division_name': divisionName,
        'class_teacher_id': classTeacherId,
        'class_teacher_name': classTeacherName,
        'subject_teachers': subjectTeachers,
        'created_at': FieldValue.serverTimestamp(),
        'assigned_by_id': adminId,
        'assigned_by_name': adminName,
      };

      // Data to be merged into the Teacher's profile and User document
      final assignmentUpdate = {
        'current_assignment': {
          'class_id': classId,
          'class_name': className,
          'division_id': divRef.id,
          'division_name': divisionName,
        },
        'is_class_teacher': true,
        'last_assignment_date': FieldValue.serverTimestamp(),
      };

      final logData = {
        'action': 'ASSIGN_CLASS_TEACHER',
        'description': '$adminName assigned $classTeacherName to $className - $divisionName',
        'target_id': classTeacherId,
        'target_name': classTeacherName,
        'done_by_id': adminId,
        'done_by_name': adminName,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // --- EXECUTE BATCH ---

      // Create the new division document
      batch.set(divRef, divisionData);

      // Update existing teacher profile (Merge prevents deleting existing bio/phone/etc)
      batch.set(teacherRef, assignmentUpdate, SetOptions(merge: true));

      // Update existing user document (Merge prevents deleting login credentials)
      batch.set(userRef, assignmentUpdate, SetOptions(merge: true));

      // Create activity log
      batch.set(logRef, logData);

      await batch.commit();

      // Refresh UI list
      await fetchDivisions(classId, academicYearId);

    } catch (e) {
      debugPrint("❌ Error in assignment batch: $e");
      rethrow;
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

    final String phone = phoneCtrl.text.trim();

    try {
      // 1. Check for duplicate phone number
      final phoneCheck = await fireStore
          .collection('users')
          .where('phone', isEqualTo: phone)
          .get();

      // If a document exists and it's not the one we are currently editing
      if (phoneCheck.docs.isNotEmpty) {
        final existingUserId = phoneCheck.docs.first.id;
        if (docId == null || existingUserId != docId) {
          throw "The phone number $phone is already registered to another staff member.";
        }
      }

      isLoading = true;
      notifyListeners();

      final batch = fireStore.batch();
      final bool isEditing = docId != null;
      final String targetId = docId ?? "SF${DateTime.now().millisecondsSinceEpoch}";

      final userRef = fireStore.collection('users').doc(targetId);
      final profileRef = fireStore.collection('staff_profiles').doc(targetId);
      final logRef = fireStore.collection('activity_logs').doc();

      final userData = {
        "uid": targetId,
        "name": nameCtrl.text.trim(),
        "phone": phone,
        "role": selectedRole,
        "password": passwordCtrl.text.trim(),
        "status": status,

        if (selectedRole == 'teacher' && !isEditing) "is_class_teacher": false,
        if (selectedRole == 'teacher' && !isEditing) "is_teacher": true,
        "updatedAt": FieldValue.serverTimestamp(),
        if (!isEditing) ...{
          "createdAt": FieldValue.serverTimestamp(),
          "createdById": userId,
          "createdByName": userName,
        }
      };

      final profileData = {
        "uid": targetId,
        "name": nameCtrl.text.trim(),
        "phone": phone,
        "role": selectedRole,
        "password": passwordCtrl.text.trim(),
        "is_class_teacher": false,
        "gender": selectedGender,
        "qualification": selectedQual,
        "total_experience": int.tryParse(expCtrl.text) ?? 0,
        "joining_date": joiningDate,
        "dob": dob,
        "age": int.tryParse(ageCtrl.text) ?? 0,
        "aadhar": aadharCtrl.text.trim(),
        "address": addressCtrl.text.trim(),
        "status": status,
        "updatedAt": FieldValue.serverTimestamp(),
        if (selectedRole == 'teacher' && !isEditing) "is_class_teacher": false,
        if (!isEditing) "createdAt": FieldValue.serverTimestamp(),
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
      debugPrint("❌ Save Staff Error: $e");
      rethrow; // This allows the UI to catch the error and show the SnackBar
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
    qualCtrl.clear();
    expCtrl.clear();
    subjectCtrl.clear();
    addressCtrl.clear();

    selectedRole = null;
    selectedCategory = null;
    selectedGender = null;
    selectedDesignation = null;
    selectedQual = null;
    joiningDate = null;
    aadharCtrl.clear();
    ageCtrl.clear();
    dob = null;

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

  Future<void> fetchAllTeachers() async {
    try {
      isLoading = true;
      notifyListeners();

      // Only fetch teachers where is_class_teacher is NOT true (or doesn't exist)
      final snapshot = await FirebaseFirestore.instance
          .collection('staff_profiles')
          .where('role', isEqualTo: 'teacher')
      // Filter: only get teachers who haven't been assigned yet
          .where('is_class_teacher', isNotEqualTo: true)
          .get();

      allTeachers = snapshot.docs.map((doc) => {
        "uid": doc.id,
        "name": doc['name'] ?? 'Unknown',
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching available teachers: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteDivision({
    required String divisionId,
    required String classId,
    required String academicYearId,
    required String teacherId,
    required String adminId,
    required String adminName,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final batch = fireStore.batch();

      // 1. References
      DocumentReference divRef = fireStore.collection('divisions').doc(divisionId);
      DocumentReference teacherRef = fireStore.collection('staff_profiles').doc(teacherId);
      DocumentReference userRef = fireStore.collection('users').doc(teacherId); // 👈 Added
      DocumentReference logRef = fireStore.collection('activity_logs').doc();

      // --- DATA TO CLEAR ---
      final clearAssignment = {
        'current_assignment': FieldValue.delete(),
        'is_class_teacher': false,
        'division_id': FieldValue.delete(), // Clear any top-level IDs you added
      };

      // --- EXECUTE BATCH ---

      // Delete the division document
      batch.delete(divRef);

      // Reset teacher profile (Staff collection)
      batch.set(teacherRef, clearAssignment, SetOptions(merge: true));

      // Reset user document (Users collection) - 👈 Added for consistency
      batch.set(userRef, clearAssignment, SetOptions(merge: true));

      // Create Activity Log
      batch.set(logRef, {
        'action': 'DELETE_DIVISION',
        'description': '$adminName deleted a division. Teacher $teacherId was unassigned.',
        'done_by_id': adminId,
        'done_by_name': adminName,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      // Refresh the local list
      await fetchDivisions(classId, academicYearId);

    } catch (e) {
      debugPrint("❌ Error deleting division: $e");
      rethrow; // Rethrow so the UI can handle the error if needed
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  /// add school calender

  List<SchoolEventModel> eventList = [];

  TextEditingController titleCt = TextEditingController();
  TextEditingController descCt = TextEditingController();

  DateTime? selectedDate;

  void setDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  Future<void> fetchEvents() async {
    final snapshot =
    await db.collection("school_special_days").get();

    eventList = snapshot.docs
        .map((e) => SchoolEventModel.fromMap(e.data(), e.id))
        .toList();

    notifyListeners();
  }

  List<SchoolEventModel> getEventsByDate(DateTime date) {
    return eventList.where((e) =>
    e.date.year == date.year &&
        e.date.month == date.month &&
        e.date.day == date.day).toList();
  }

  Future<void> addEvent(BuildContext context) async {
    if (titleCt.text.isEmpty || selectedDate == null) return;

    isLoading = true;
    notifyListeners();

    await db.collection("school_special_days").add({
      "title": titleCt.text,
      "description": descCt.text,
      "date": selectedDate,
      "createdAt": FieldValue.serverTimestamp(),
    });

    titleCt.clear();
    descCt.clear();

    await fetchEvents(); // 🔥 refresh calendar instantly

    isLoading = false;
    notifyListeners();

    Navigator.pop(context);
  }

  Future<void> deleteEvent(BuildContext context, dynamic event) async {
    isLoading = true;
    notifyListeners();

    try {
      // Query to find the document matching title + date
      final snapshot = await db
          .collection("school_special_days")
          .where("title", isEqualTo: event.title)
          .where("date", isEqualTo: event.date)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      await fetchEvents(); // 🔥 refresh calendar instantly

    } catch (e) {
      debugPrint("Delete error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> toggleStaffStatus(String docId, bool currentStatus) async {
    final batch = db.batch();

    // Define the update data
    final statusUpdate = {'isActive': !currentStatus};

    // 1. Reference for Staff Profiles
    DocumentReference staffRef = db.collection('staff_profiles').doc(docId);
    // 2. Reference for Users
    DocumentReference userRef = db.collection('users').doc(docId);

    // Use set with merge: true to handle missing fields or missing documents safely
    batch.set(staffRef, statusUpdate, SetOptions(merge: true));
    batch.set(userRef, statusUpdate, SetOptions(merge: true));

    try {
      await batch.commit();
      debugPrint("Status updated to ${!currentStatus} for $docId");
    } catch (e) {
      debugPrint("❌ Error toggling status: $e");
      rethrow;
    }
  }



  List<BellTimingModel> regularList = [];
  List<BellTimingModel> fridayList = [];


  /// 🔹 FETCH DATA
  Future<void> fetchBellTiming() async {
    isLoading = true;
    notifyListeners();

    try {
      final doc =
      await db.collection("school_settings").doc("bell_timing").get();

      if (doc.exists) {
        regularList = (doc['regularDay'] as List)
            .map((e) => BellTimingModel.fromMap(e))
            .toList();

        fridayList = (doc['friday'] as List)
            .map((e) => BellTimingModel.fromMap(e))
            .toList();
      }
    } catch (e) {
      debugPrint("Error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  /// 🔹 ADD ROW
  void addRow({required bool isFriday}) {
    if (isFriday) {
      fridayList.add(BellTimingModel(title: "", time: ""));
    } else {
      regularList.add(BellTimingModel(title: "", time: ""));
    }
    notifyListeners();
  }

  /// 🔹 UPDATE FIELD
  void updateTitle(int index, String value, {required bool isFriday}) {
    if (isFriday) {
      fridayList[index].title = value;
    } else {
      regularList[index].title = value;
    }
    notifyListeners();
  }

  void updateTime(int index, String value, {required bool isFriday}) {
    if (isFriday) {
      fridayList[index].time = value;
    } else {
      regularList[index].time = value;
    }
    notifyListeners();
  }

  /// 🔹 DELETE ROW
  void deleteRow(int index, {required bool isFriday}) {
    if (isFriday) {
      fridayList.removeAt(index);
    } else {
      regularList.removeAt(index);
    }
    notifyListeners();
  }

  /// 🔹 SAVE TO FIRESTORE
  Future<void> saveBellTiming() async {
    isLoading = true;
    notifyListeners();

    try {
      await db.collection("school_settings").doc("bell_timing").set({
        "regularDay": regularList.map((e) => e.toMap()).toList(),
        "friday": fridayList.map((e) => e.toMap()).toList(),
      });
    } catch (e) {
      debugPrint("Save Error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  // ==========================================
  // RULES AND REGULATIONS LOGIC
  // ==========================================
  List<String> rulesList = [];

  /// 🔹 FETCH RULES FROM DB
  Future<void> fetchRules() async {
    isLoading = true;
    notifyListeners();

    try {
      final doc = await db.collection("school_settings").doc("rules_regulations").get();

      if (doc.exists && doc.data()!.containsKey('rules')) {
        // Load the array of rules from Firestore
        rulesList = List<String>.from(doc['rules']);
      }
    } catch (e) {
      debugPrint("Error fetching rules: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  /// 🔹 SAVE CURRENT LIST TO DB
  Future<void> saveRules() async {
    try {
      // Overwrites the document with the updated array
      await db.collection("school_settings").doc("rules_regulations").set({
        "rules": rulesList,
        "updatedAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Save Error: $e");
    }
  }

  /// 🔹 ADD NEW POINT TO DB
  Future<void> addRule(String rule) async {
    rulesList.add(rule);
    notifyListeners(); // Update UI immediately
    await saveRules(); // Sync to database
  }

  /// 🔹 EDIT CURRENT POINT IN DB
  Future<void> updateRule(int index, String newRule) async {
    rulesList[index] = newRule;
    notifyListeners(); // Update UI immediately
    await saveRules(); // Sync to database
  }

  /// 🔹 DELETE POINT FROM DB
  Future<void> deleteRule(int index) async {
    rulesList.removeAt(index);
    notifyListeners(); // Update UI immediately
    await saveRules(); // Sync to database
  }

  // ==========================================
  // INSTRUCTIONS TO PARENTS LOGIC
  // ==========================================
  List<String> parentInstructionsList = [];

  /// 🔹 FETCH PARENT INSTRUCTIONS FROM DB
  Future<void> fetchParentInstructions() async {
    isLoading = true;
    notifyListeners();

    try {
      final doc = await db.collection("school_settings").doc("parent_instructions").get();

      if (doc.exists && doc.data()!.containsKey('instructions')) {
        parentInstructionsList = List<String>.from(doc['instructions']);
      }
    } catch (e) {
      debugPrint("Error fetching parent instructions: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  /// 🔹 SAVE CURRENT LIST TO DB
  Future<void> saveParentInstructions() async {
    try {
      await db.collection("school_settings").doc("parent_instructions").set({
        "instructions": parentInstructionsList,
        "updatedAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Save Error: $e");
    }
  }

  /// 🔹 ADD NEW INSTRUCTION TO DB
  Future<void> addParentInstruction(String instruction) async {
    parentInstructionsList.add(instruction);
    notifyListeners(); // Update UI immediately
    await saveParentInstructions(); // Sync to database
  }

  /// 🔹 EDIT CURRENT INSTRUCTION IN DB
  Future<void> updateParentInstruction(int index, String newInstruction) async {
    parentInstructionsList[index] = newInstruction;
    notifyListeners(); // Update UI immediately
    await saveParentInstructions(); // Sync to database
  }

  /// 🔹 DELETE INSTRUCTION FROM DB
  Future<void> deleteParentInstruction(int index) async {
    parentInstructionsList.removeAt(index);
    notifyListeners(); // Update UI immediately
    await saveParentInstructions(); // Sync to database
  }

  /// 🔹 LOOP & SEED MALAYALAM TEXT FROM IMAGE



  final TextEditingController qualificationController =
  TextEditingController();

  bool qualificationLoading = false;

  Future<void> addQualification(BuildContext context) async {

    String qualification = qualificationController.text.trim();

    if (qualification.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter qualification")),
      );
      return;
    }

    try {

      qualificationLoading = true;
      notifyListeners();

      String id = DateTime.now().millisecondsSinceEpoch.toString();

      await db.collection('QUALIFICATIONS').doc(id).set({
        "id": id,
        "qualification": qualification,
        "createdAt": FieldValue.serverTimestamp(),
      });

      qualificationController.clear();

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Qualification Added")),
      );

    } catch (e) {

      debugPrint(e.toString());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error : $e")),
      );

    }

    qualificationLoading = false;
    notifyListeners();
  }

  List<Map<String, dynamic>> qualificationList = [];

  bool qualificationFetchLoading = false;

  Future<void> getQualifications() async {

    qualificationFetchLoading = true;
    notifyListeners();

    try {

      QuerySnapshot snapshot = await db
          .collection('QUALIFICATIONS')
          .orderBy('createdAt', descending: true)
          .get();

      qualificationList = snapshot.docs.map((e) {

        final data = e.data() as Map<String, dynamic>;

        return {
          "id": data['id'] ?? '',
          "qualification": data['qualification'] ?? '',
        };

      }).toList();

    } catch (e) {
      debugPrint(e.toString());
    }

    qualificationFetchLoading = false;
    notifyListeners();
  }


  /// ================================
  /// NOTIFICATION
  /// ================================

  final TextEditingController
  notificationTitleController =
  TextEditingController();

  final TextEditingController
  notificationMessageController =
  TextEditingController();

  String selectedNotificationRole =
      "PARENT";

  bool notificationLoading = false;

  /// SEND ADMIN NOTIFICATION
  Future<void> sendAdminNotification(
      BuildContext context) async {

    if (notificationTitleController.text
        .trim()
        .isEmpty) {

      showToast(
        "Enter notification title",
      );

      return;
    }

    if (notificationMessageController.text
        .trim()
        .isEmpty) {

      showToast(
        "Enter notification message",
      );

      return;
    }

    try {

      notificationLoading = true;
      notifyListeners();

      String notificationId =
      DateTime.now()
          .millisecondsSinceEpoch
          .toString();

      /// ====================================
      /// SAVE ADMIN NOTIFICATION
      /// ====================================

      await FirebaseFirestore.instance
          .collection("admin_notifications")
          .doc(notificationId)
          .set({

        "notificationId":
        notificationId,

        "title":
        notificationTitleController.text
            .trim(),

        "message":
        notificationMessageController.text
            .trim(),

        "role":
        selectedNotificationRole,

        "createdAt":
        FieldValue.serverTimestamp(),

        "dateMillis":
        DateTime.now()
            .millisecondsSinceEpoch,

        "isActive": true,
      });

      /// ====================================
      /// GET USERS
      /// ====================================

      QuerySnapshot userSnapshot;

      if (selectedNotificationRole ==
          "TEACHER") {

        userSnapshot =
        await FirebaseFirestore.instance
            .collection("users")
            .where(
          "is_teacher",
          isEqualTo: true,
        )
            .get();

      } else {

        userSnapshot =
        await FirebaseFirestore.instance
            .collection("users")
            .where(
          "is_parent",
          isEqualTo: true,
        )
            .get();
      }

      /// ====================================
      /// COLLECT TOKENS
      /// ====================================

      List<String> tokens = [];

      for (var doc in userSnapshot.docs) {

        final data =
        doc.data() as Map<String, dynamic>;

        String token =
            data['fcmId'] ?? "";

        if (token.isNotEmpty) {
          tokens.add(token);
        }
      }

      debugPrint(
          "TOTAL TOKENS : ${tokens.length}");

      /// ====================================
      /// SEND PUSH
      /// ====================================

      if (tokens.isNotEmpty) {

        await sendPushToDevices(
          tokens: tokens,
          title:
          notificationTitleController.text
              .trim(),
          body:
          notificationMessageController.text
              .trim(),
        );
      }

      showToast(
        "Notification sent successfully",
      );

      notificationTitleController.clear();
      notificationMessageController.clear();

    } catch (e) {

      debugPrint(
          "NOTIFICATION ERROR : $e");

      showToast(
        "Something went wrong",
        backgroundColor: Colors.red,
      );
    }

    notificationLoading = false;
    notifyListeners();
  }

  Future<void> sendPushToDevices({
    required List<String> tokens,
    required String title,
    required String body,
  }) async {

    try {

      final String response =
      await rootBundle.loadString(
        'assets/account.json',
      );

      final data = json.decode(response);

      final credentials =
      gapis.ServiceAccountCredentials
          .fromJson(data);

      final scopes = [
        'https://www.googleapis.com/auth/firebase.messaging'
      ];

      final client =
      await gapis.clientViaServiceAccount(
        credentials,
        scopes,
      );

      final String projectId =
      data['project_id'];

      final String url =
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

      for (String token in tokens) {

        final res = await client.post(
          Uri.parse(url),

          body: jsonEncode({

            'message': {

              'token': token,

              'notification': {
                'title': title,
                'body': body,
              },

              'android': {
                'priority': 'high',

                'notification': {
                  'channel_id':
                  'high_importance_channel',
                },
              },

              'data': {
                'click_action':
                'FLUTTER_NOTIFICATION_CLICK',
              }
            }
          }),
        );

        debugPrint(
          res.statusCode == 200
              ? "Notification Sent"
              : "Notification Failed ${res.body}",
        );
      }

      client.close();

    } catch (e) {

      debugPrint(
        "FCM SEND ERROR : $e",
      );
    }
  }
}