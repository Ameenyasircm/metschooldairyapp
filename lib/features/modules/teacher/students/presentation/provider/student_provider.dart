import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../core/service/firebase_service.dart';
import '../../../punctuality/data/models/PunctualityModel.dart';
import '../../data/models/tech_division_model.dart';
import '../../data/models/tech_student_model.dart';
import '../../data/repository/student_repository.dart';

class StudentProvider extends ChangeNotifier {
  final StudentRepository repository;
  StudentProvider(this.repository);
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // --- All Students State ---
  List<TechStudentModel> allStudents = []; 
  List<TechStudentModel> students = [];    
  DocumentSnapshot? lastDoc;
  bool hasMore = true;
  String searchQuery = '';
  bool isInitialLoading = false;
  bool isLoadingMore = false;

  // --- My Students State ---
  List<EnrollerModel> myAllStudents = [];
  List<EnrollerModel> myStudents = [];
  DocumentSnapshot? myLastDoc;
  bool hasMyStdMore = true;
  String searchMyStdQuery = '';
  bool isInitialMyStdLoading = false;
  bool isLoadingMyStdMore = false;

  bool isAddingStudents = false;
  Set<String> selectedStudentIds = {};

  DivisionModel? _assignedDivision;
  DivisionModel? get assignedDivision => _assignedDivision;

  Timer? _debounce;

  // ---------------- FETCH ALL STUDENTS ----------------

  Future<void> fetchInitial() async {
    allStudents.clear();
    students.clear();
    lastDoc = null;
    hasMore = true;
    isInitialLoading = true;
    notifyListeners();

    try {
      await _fetchStudentsPage();
    } catch (e) {
      debugPrint("Error fetching initial students: $e");
    } finally {
      isInitialLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMore() async {
    if (isLoadingMore || !hasMore) return;
    isLoadingMore = true;
    notifyListeners();

    try {
      await _fetchStudentsPage();
    } catch (e) {
      debugPrint("Error fetching more students: $e");
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> _fetchStudentsPage() async {
    final result = await repository.getStudents(
      lastDoc: lastDoc,
      isMyStudents: false,
    );

    if (result.docs.isEmpty) {
      hasMore = false;
    } else {
      lastDoc = result.docs.last;
      final newItems = result.docs
          .map((e) => TechStudentModel.fromMap(e.data() as Map<String, dynamic>))
          .toList();
      allStudents.addAll(newItems);
      _applyLocalSearch();
    }
  }

  // ---------------- FETCH MY STUDENTS ----------------

  Future<void> fetchMyStudentsInitial() async {
    myAllStudents.clear();
    myStudents.clear();
    myLastDoc = null;
    hasMyStdMore = true;
    isInitialMyStdLoading = true;
    notifyListeners();

    try {
      await _fetchMyStudentsPage();
    } catch (e) {
      debugPrint("Error fetching my students: $e");
    } finally {
      isInitialMyStdLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyStudentsMore() async {
    if (isLoadingMyStdMore || !hasMyStdMore) return;
    isLoadingMyStdMore = true;
    notifyListeners();

    try {
      await _fetchMyStudentsPage();
    } catch (e) {
      debugPrint("Error fetching more my students: $e");
    } finally {
      isLoadingMyStdMore = false;
      notifyListeners();
    }
  }

  Future<void> _fetchMyStudentsPage() async {
    final prefs = await SharedPreferences.getInstance();
    final staffId = prefs.getString("staffId");
    final classId = prefs.getString("classId");

    final result = await repository.getStudents(
      lastDoc: myLastDoc,
      isMyStudents: true,
      classId: classId,
    );

    if (result.docs.isEmpty) {
      hasMyStdMore = false;
    } else {
      myLastDoc = result.docs.last;
      final newItems = result.docs
          .map((e) => EnrollerModel.fromMap(e.data() as Map<String, dynamic>))
          .toList();
      myAllStudents.addAll(newItems);
      _applyMyStdSearch();
    }
  }

  // ---------------- SEARCH LOGIC ----------------

  void searchWithDebounce(String value) {
    searchQuery = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _applyLocalSearch);
  }

  void _applyLocalSearch() {
    if (searchQuery.isEmpty) {
      students = List.from(allStudents);
    } else {
      final query = searchQuery.toLowerCase();
      students = allStudents.where((student) {
        return student.name.toLowerCase().contains(query) || 
               student.admissionId.toLowerCase().contains(query);
      }).toList();
    }
    notifyListeners();
  }

  void searchMyStd(String value) {
    searchMyStdQuery = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _applyMyStdSearch);
  }

  void _applyMyStdSearch() {
    if (searchMyStdQuery.isEmpty) {
      myStudents = List.from(myAllStudents);
    } else {
      final query = searchMyStdQuery.toLowerCase();
      myStudents = myAllStudents.where((student) {
        return student.name.toLowerCase().contains(query) || 
               student.rollNumber.toLowerCase().contains(query);
      }).toList();
    }
    notifyListeners();
  }

  // ---------------- SELECTION & ACTIONS ----------------

  void toggleSelection(String id) {
    selectedStudentIds.contains(id) ? selectedStudentIds.remove(id) : selectedStudentIds.add(id);
    notifyListeners();
  }

  bool isSelected(String id) => selectedStudentIds.contains(id);

  void clearSelection() {
    selectedStudentIds.clear();
    notifyListeners();
  }

  void selectAll() {
    for (var student in students) {
      selectedStudentIds.add(student.studentId);
    }
    notifyListeners();
  }

  void toggleSelectAll() {
    if (selectedStudentIds.length == students.length && students.isNotEmpty) {
      selectedStudentIds.clear();
    } else {
      for (var student in students) {
        selectedStudentIds.add(student.studentId);
      }
    }
    notifyListeners();
  }

  bool get isAllSelected => students.isNotEmpty && selectedStudentIds.length == students.length;


  Future<void> bulkEnroll() async {
    if (selectedStudentIds.isEmpty) throw Exception("Please select at least one student.");
    if (isAddingStudents) return;

    final selectedData = allStudents
        .where((s) => selectedStudentIds.contains(s.studentId))
        .toList();

    if (selectedData.isEmpty) {
      throw Exception("Selected student data not found in cache. Please refresh.");
    }

    isAddingStudents = true;
    notifyListeners();

    try {
      final firestore = FirebaseFirestore.instance;
      final prefs = await SharedPreferences.getInstance();

      final staffId = prefs.getString("staffId");
      final staffName = prefs.getString("staffName");
      final divisionName = prefs.getString("divisionName");
      final divisionId = prefs.getString("divisionId");
      final className = prefs.getString("className");
      final classId = prefs.getString("classId");
      final academicYearId = prefs.getString("academicYearId");

      // 1. Fetch Existing Enrollments Efficiently (Avoid N+1)
      Set<String> alreadyEnrolledIds = {};
      for (var i = 0; i < selectedData.length; i += 30) {
        final chunk = selectedData.skip(i).take(30).map((s) => s.studentId).toList();

        final existingDocs = await firestore
            .collection('enrollments')
            .where('academic_year_id', isEqualTo: academicYearId)
            .where('student_id', whereIn: chunk)
            .get();

        for (var doc in existingDocs.docs) {
          alreadyEnrolledIds.add(doc['student_id'] as String);
        }
      }

      // 2. Prepare Batches with Limit Handling
      WriteBatch batch = firestore.batch();
      int operationCount = 0;

      for (var student in selectedData) {
        final String sId = student.studentId;

        if (alreadyEnrolledIds.contains(sId)) continue;

        DocumentReference enrollRef = firestore.collection('enrollments').doc();

        batch.set(enrollRef, {
          "student_id": sId,
          "student_name": student.name,
          "academic_year_id": academicYearId,
          "class_id": classId,
          "class_name": className,
          "division_id": divisionId,
          "division_name": divisionName,
          "enrollment_id": student.admissionId,
          "parent_phone": student.parentPhone ?? "",
          "parent_id": student.parentId ?? "",
          "roll_number": null,
          "status": "active",
          "createdAt": FieldValue.serverTimestamp(),
          "createdById": staffId,
          "createdByName": staffName,
        });
        operationCount++;

        DocumentReference studentRef = firestore.collection('students').doc(sId);
        batch.update(studentRef, {
          "isEnrolled": true,
          "current_academic_year": academicYearId,
          "current_class_id": classId,
          "enrollment_details": {
            "enrollment_doc_id": enrollRef.id,
            "enrolled_at": FieldValue.serverTimestamp(),
          }
        });
        operationCount++;

        if (operationCount >= 498) {
          await batch.commit();
          batch = firestore.batch();
          operationCount = 0;
        }
      }

      if (operationCount > 0) {
        await batch.commit();
      }
    } catch (e) {
      rethrow;
    } finally {
      isAddingStudents = false;
      notifyListeners();
    }
  }


  List<PunctualityRecordModel> records = [];

  /// 🔽 Fetch for one student
  Future<void> fetchStudentRecords(String studentId) async {
    final snap = await db
        .collection('students')
        .doc(studentId)
        .collection('punctuality_records')
        .orderBy('date', descending: true)
        .get();

    records = snap.docs
        .map((e) => PunctualityRecordModel.fromMap(e.id, e.data()))
        .toList();

    notifyListeners();
  }

  /// 🔥 Add record (DUAL WRITE)
  Future<void> addRecord({
    required EnrollerModel student,
    required String code,
    required String remark,
    required DateTime date,
  }) async {
    final recordId = DateTime.now().millisecondsSinceEpoch.toString();

    final data = {
      "id": recordId,
      "studentId": student.studentId,
      "studentName": student.name,
      "className": student.className,
      "divisionName": student.divisionName,
      "code": code,
      "remark": remark,
      "date": Timestamp.fromDate(date),
      "createdAt": Timestamp.now(),
    };

    final batch = db.batch();

    /// 1️⃣ Subcollection
    final studentRef = db
        .collection('students')
        .doc(student.studentId)
        .collection('punctuality_records')
        .doc(recordId);

    /// 2️⃣ Global collection
    final globalRef =
    db.collection('punctuality_records').doc(recordId);

    batch.set(studentRef, data);
    batch.set(globalRef, data);

    await batch.commit();

    await fetchStudentRecords(student.studentId);
  }

}
