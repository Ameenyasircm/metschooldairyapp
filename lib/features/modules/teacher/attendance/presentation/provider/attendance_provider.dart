import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../core/service/firebase_service.dart';
import '../../../students/data/models/tech_student_model.dart';
import '../../../students/data/repository/student_repository.dart';
import '../../data/models/attendance_model.dart';

class AttendanceProvider extends ChangeNotifier {
  final StudentRepository repository;
  AttendanceProvider(this.repository);

  List<StudentAttendance> _allStudents = [];
  List<StudentAttendance> _filteredStudents = [];
  List<StudentAttendance> get students => _filteredStudents;

  AttendanceSession _selectedSession = AttendanceSession.morning;
  AttendanceSession get selectedSession => _selectedSession;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';

  void setSession(AttendanceSession session) {
    _selectedSession = session;
    notifyListeners();
  }

  void initializeStudents(List<TechStudentModel> techStudents) {
    _allStudents = techStudents.map((s) => StudentAttendance(
      studentId: s.studentId,
      studentName: s.name,
      admissionNumber: s.admissionNumber,
    )).toList();
    _applySearch();
  }

  void searchStudents(String query) {
    _searchQuery = query;
    _applySearch();
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredStudents = List.from(_allStudents);
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredStudents = _allStudents.where((s) {
        return s.studentName.toLowerCase().contains(query) ||
               s.admissionNumber.toLowerCase().contains(query);
      }).toList();
    }
    notifyListeners();
  }

  void updateStatus(String studentId, AttendanceStatus status) {
    final index = _allStudents.indexWhere((s) => s.studentId == studentId);
    if (index != -1) {
      _allStudents[index].status = status;
      _applySearch();
    }
  }

  void markAll(AttendanceStatus status) {
    for (var student in _allStudents) {
      student.status = status;
    }
    _applySearch();
  }

  Future<void> saveAttendance() async {
    if (_allStudents.isEmpty) return;
    
    if (_allStudents.any((s) => s.status == AttendanceStatus.none)) {
      throw Exception("Please mark attendance (P/A) for all students before saving.");
    }

    _isLoading = true;
    notifyListeners();

    try {
      final db = FirebaseService.firestore;
      final prefs = await SharedPreferences.getInstance();
      final staffId = prefs.getString("staffId");
      
      final division = await repository.getTeacherClassDivision(teacherId: staffId ?? '');
      if (division == null) {
        throw Exception("You are not assigned as a Class Teacher for any division in the current academic year. Attendance cannot be saved.");
      }

      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final batch = db.batch();

      for (var student in _allStudents) {
        final attendanceId = "ATT_${student.studentId}_${dateStr}_${_selectedSession.name}";
        final docRef = db.collection("attendance").doc(attendanceId);

        batch.set(docRef, {
          "attendance_id": attendanceId,
          "student_id": student.studentId,
          "student_name": student.studentName,
          "admission_number": student.admissionNumber,
          "date": dateStr,
          "timestamp": FieldValue.serverTimestamp(),
          "session": _selectedSession.name,
          "status": student.status.name,
          "division_id": division.id,
          "academic_year_id": division.academicYearId,
          "marked_by": staffId,
        }, SetOptions(merge: true));
      }

      await batch.commit();
      debugPrint("Attendance saved successfully for $_selectedSession");
    } catch (e) {
      debugPrint("Error saving attendance: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
