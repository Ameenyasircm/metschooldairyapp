import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../features/modules/admin/rules_timing/models/bell_timing_model.dart';
import '../features/modules/admin/school_calaender/models/school_event_model.dart';

class AdminProvider with ChangeNotifier {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final FirebaseDatabase realtime = FirebaseDatabase.instance;

  AdminProvider() {
    fetchSubjects();
    fetchClasses();
    seedParentInstructionsFromImage();
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
    Map<String, String> subjectTeachers = const {}, // Added back
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
        'subject_teachers': subjectTeachers, // Included
        'created_at': FieldValue.serverTimestamp(),
        'assigned_by_id': adminId,
        'assigned_by_name': adminName,
        'is_class_teacher': true,

      };
      final usersData = {
        'division_id': divRef.id,
        'academic_year_id': academicYearId,
        'class_id': classId,
        'class_name': className,
        'division_name': divisionName,
        'subject_teachers': subjectTeachers, // Included
        'created_at': FieldValue.serverTimestamp(),
        'assigned_by_id': adminId,
        'assigned_by_name': adminName,
        'is_class_teacher': true,

      };

      final teacherUpdateData = {
        // Use a flattened structure for easy querying
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
      batch.set(divRef, divisionData);
      batch.update(teacherRef, teacherUpdateData);
      batch.set(logRef, logData);
      batch.set(userRef, usersData);

      await batch.commit();

      // Refresh UI list
      await fetchDivisions(classId, academicYearId);

    } catch (e) {
      debugPrint("❌ Error in assignment batch: $e");
      // Optionally: show a Toast or SnackBar here to inform the user
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
        "name": nameCtrl.text.trim(),
        "phone": phoneCtrl.text.trim(),
        "role": selectedRole,
        "password": passwordCtrl.text.trim(),
        "gender": selectedGender,
        "qualification": selectedQual,
        "total_experience": int.tryParse(expCtrl.text) ?? 0,
        "joining_date": joiningDate,
        "dob": dob,           // 👈 Added
        "age": int.tryParse(ageCtrl.text) ?? 0, // 👈 Added
        "aadhar": aadharCtrl.text.trim(),       // 👈 Added
        "address": addressCtrl.text.trim(),
        "status": status,
        "updatedAt": FieldValue.serverTimestamp(),
        if (!isEditing) "createdAt": FieldValue.serverTimestamp(),
        if (selectedRole == 'teacher') ...{
          "designation": selectedDesignation,
          "is_class_teacher":false,
          // Ensure this is being treated as a List of Maps
          "subjects": selectedSubjects.map((e) => {
            "id": e['id'],
            "name": e['name'],
          }).toList(),
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
    qualCtrl.clear();
    expCtrl.clear();
    subjectCtrl.clear();
    addressCtrl.clear();

    selectedRole = null;
    selectedCategory = null;
    selectedGender = null;
    selectedDesignation = null;
    selectedQual = null;
    selectedSubjects = [];
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
      // Note: Ensure collection name 'staff_profiles' matches your DB
      final snapshot = await FirebaseFirestore.instance
          .collection('staff_profiles')
          .where('role', isEqualTo: 'teacher')
          .get();

      allTeachers = snapshot.docs.map((doc) => {
        "uid": doc.id,
        "name": doc['name'] ?? 'Unknown',
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching teachers: $e");
    }
  }

  Future<void> deleteDivision({
    required String divisionId,
    required String classId,
    required String academicYearId,
    required String teacherId, // Added to clear teacher profile
    required String adminId,
    required String adminName,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final batch = fireStore.batch();

      // 1. Division Reference
      DocumentReference divRef = fireStore.collection('divisions').doc(divisionId);

      // 2. Teacher Reference
      DocumentReference teacherRef = fireStore.collection('staff_profiles').doc(teacherId);

      // 3. Log Reference
      DocumentReference logRef = fireStore.collection('activity_logs').doc();

      // --- EXECUTE BATCH ---
      batch.delete(divRef);

      // Reset teacher's assignment fields
      batch.update(teacherRef, {
        'current_assignment': FieldValue.delete(),
        'is_class_teacher': false,
      });

      // Create Log
      batch.set(logRef, {
        'action': 'DELETE_DIVISION',
        'description': '$adminName deleted a division. Teacher $teacherId unassigned.',
        'done_by_id': adminId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      // Refresh the local list
      await fetchDivisions(classId, academicYearId);

    } catch (e) {
      debugPrint("❌ Error deleting division: $e");
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
    await db.collection("SCHOOL_SPECIAL_DAYS").get();

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

    await db.collection("SCHOOL_SPECIAL_DAYS").add({
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
  Future<void> seedParentInstructionsFromImage() async {
    isLoading = true;
    notifyListeners();

    parentInstructionsList = [
      "പ്രിൻസിപ്പാൾ / മാനേജ്‌മെന്റ് വിദ്യാർത്ഥികളുടെ പഠന - പാഠ്യേതര പ്രവർത്തനങ്ങളുടെ മേന്മക്കായി നടപ്പിൽ വരുത്തുന്ന കാര്യങ്ങളുമായി സഹകരിക്കേണ്ടതാണ്.",
      "സ്കൂൾ ഡയറി എല്ലാദിവസവും പരിശോധിക്കുക.",
      "സ്കൂൾ പ്രവർത്തി ദിവസങ്ങളിൽ വിവാഹം വിരുന്ന് തുടങ്ങിയ കാര്യങ്ങളിൽ നിന്ന് കുട്ടികളെ പരമാവധി ഒഴിവാക്കുക.",
      "പൂർണ്ണമായും യൂണിഫോം ധരിപ്പിച്ച് മാത്രമേ കുട്ടികളെ സ്കൂളിൽ അയക്കാവൂ.",
      "ജനറൽ ബോഡി യോഗങ്ങളിലും, ക്ലാസ് പി.ടി.എ കളിലും രക്ഷിതാക്കൾ നിർബന്ധമായും പങ്കെടുക്കേണ്ടതാണ്.",
      "ട്യൂഷൻ ഫീ നിശ്ചയിക്കപ്പെട്ട ദിവസങ്ങളിൽ അടക്കേണ്ടതാണ്. അല്ലാത്തപക്ഷം ഫൈൻ ഉണ്ടായിരിക്കുന്നതാണ്.",
      "സ്കൂൾ വാഹനങ്ങളിൽ വരുന്ന വിദ്യാർത്ഥികൾ വാഹന ഫീസ് ഓരോ മാസവും ആദ്യ ആഴ്ചയിൽ തന്നെ അടക്കേണ്ടതാണ്.",
      "സ്കൂളിൽ നടക്കുന്ന കലാ-കായിക പരിശീലനങ്ങളിലും മത്സരങ്ങളിലും കുട്ടികൾ പങ്കെടുക്കേണ്ടതാണ്. പ്രത്യേക കാരണങ്ങളാൽ പങ്കെടുക്കാത്ത സാഹചര്യം രക്ഷിതാവ് ഹെഡ്മാസ്റ്ററെ മുൻകൂട്ടി അറിയിക്കേണ്ടതാണ്.",
      "സ്കൂളുമായി ബന്ധപ്പെട്ട ഡയറിയിൽ വിവരിച്ച നിർദ്ദേശങ്ങൾ കുട്ടിയും രക്ഷിതാവും വായിച്ച് ഒപ്പ് വെക്കേണ്ടതാണ്."
    ];

    await saveParentInstructions(); // Uploads to Firestore

    isLoading = false;
    notifyListeners();
  }


}