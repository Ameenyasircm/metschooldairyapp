import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../core/service/firebase_service.dart';
import '../../data/models/tech_student_model.dart';
import '../../data/repository/student_repository.dart';

class StudentProvider extends ChangeNotifier {
  final StudentRepository repository;
  StudentProvider(this.repository);

  // --- All Students State ---
  List<TechStudentModel> allStudents = []; 
  List<TechStudentModel> students = [];    
  DocumentSnapshot? lastDoc;
  bool hasMore = true;
  String searchQuery = '';
  bool isInitialLoading = false;
  bool isLoadingMore = false;

  // --- My Students State ---
  List<TechStudentModel> myAllStudents = []; 
  List<TechStudentModel> myStudents = [];    
  DocumentSnapshot? myLastDoc;
  bool hasMyStdMore = true;
  String searchMyStdQuery = '';
  bool isInitialMyStdLoading = false;
  bool isLoadingMyStdMore = false;

  bool isAddingStudents = false;
  Set<String> selectedStudentIds = {};

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
    final division = await repository.getTeacherClassDivision(teacherId: staffId ?? '');

    final result = await repository.getStudents(
      lastDoc: myLastDoc,
      isMyStudents: true,
      divisionId: division?.id,
    );

    if (result.docs.isEmpty) {
      hasMyStdMore = false;
    } else {
      myLastDoc = result.docs.last;
      final newItems = result.docs
          .map((e) => TechStudentModel.fromMap(e.data() as Map<String, dynamic>))
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
               student.admissionNumber.toLowerCase().contains(query);
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
               student.admissionNumber.toLowerCase().contains(query);
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

  Future<void> addClassTeacherStudents() async {
    if (selectedStudentIds.isEmpty) throw Exception("Please select at least one student.");
    if (isAddingStudents) return;

    isAddingStudents = true;
    notifyListeners();

    try {
      final db = FirebaseService.firestore;
      
      // Get selected data from allStudents
      final selectedData = allStudents
          .where((s) => selectedStudentIds.contains(s.studentId))
          .toList();

      if (selectedData.isEmpty) {
        throw Exception("Selected student data not found in cache. Please refresh.");
      }

      // Context checks
      final prefs = await SharedPreferences.getInstance();
      final staffId = prefs.getString("staffId");
      if (staffId == null || staffId.isEmpty) {
        throw Exception("Staff ID not found. Please log in again.");
      }

      final division = await repository.getTeacherClassDivision(teacherId: staffId);
      if (division == null) {
        throw Exception("No class division found for you in the current academic year.");
      }

      // Execute in batches (Firestore limit is 500)
      for (var i = 0; i < selectedData.length; i += 500) {
        final batch = db.batch();
        final end = (i + 500 < selectedData.length) ? i + 500 : selectedData.length;
        final chunk = selectedData.sublist(i, end);

        for (var student in chunk) {
          final enrollmentId = "ENR_${student.studentId}_${division.academicYearId}";
          final docRef = db.collection("enrollments").doc(enrollmentId);
          
          batch.set(docRef, {
            "enrollment_id": enrollmentId,
            "student_id": student.studentId,
            "name": student.name,
            "admission_number": student.admissionNumber,
            "address": student.address,
            "blood_group": student.bloodGroup,
            "academic_year_id": division.academicYearId,
            "division_id": division.id,
            "parent_phone": student.parentPhone,
            "enrolled_date": FieldValue.serverTimestamp(),
            "status": "active",
          }, SetOptions(merge: true));
        }
        await batch.commit();
      }

      // Cleanup
      selectedStudentIds.clear();
      
      // Refresh 'My Students' in background so UI can navigate immediately
      fetchMyStudentsInitial().catchError((e) => debugPrint("Background refresh error: $e"));
      
    } catch (e) {
      debugPrint("addClassTeacherStudents Error: $e");
      rethrow;
    } finally {
      isAddingStudents = false;
      notifyListeners();
    }
  }
}
