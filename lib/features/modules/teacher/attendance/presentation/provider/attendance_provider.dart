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
  List<StudentAttendance> get allStudents => _allStudents;

  AttendanceSession _selectedSession = AttendanceSession.morning;
  AttendanceSession get selectedSession => _selectedSession;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';

  void setSession(AttendanceSession session) {
    _selectedSession = session;
    notifyListeners();
  }

  void setDate(DateTime date) {
    _selectedDate = date;
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

  void updateStatus(String studentId, AttendanceStatus status, {String? reason}) {
    final index = _allStudents.indexWhere((s) => s.studentId == studentId);
    if (index != -1) {
      _allStudents[index].status = status;
      if (status == AttendanceStatus.late) {
        _allStudents[index].lateReason = reason;
      } else {
        _allStudents[index].lateReason = null;
      }
      _applySearch();
    }
  }

  void markAll(AttendanceStatus status) {
    for (var student in _allStudents) {
      student.status = status;
      student.lateReason = null;
    }
    _applySearch();
  }

  Future<void> saveAttendance() async {
    if (_allStudents.isEmpty) return;
    
    // Business Rule: Editing allowed only same day
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    
    if (selected.isBefore(today)) {
      throw Exception("Backdated attendance editing is not allowed. Please contact admin.");
    }
    if (selected.isAfter(today)) {
      throw Exception("Future attendance marking is not allowed.");
    }

    if (_allStudents.any((s) => s.status == AttendanceStatus.none)) {
      throw Exception("Please mark attendance (P/A/L) for all students before saving.");
    }

    _isLoading = true;
    notifyListeners();

    try {
      final db = FirebaseService.firestore;
      final prefs = await SharedPreferences.getInstance();
      final staffId = prefs.getString("staffId");
      
      final division = await repository.getTeacherClassDivision(teacherId: staffId ?? '');
      if (division == null) {
        throw Exception("You are not assigned as a Class Teacher for any division in the current academic year.");
      }

      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final batch = db.batch();

      for (var student in _allStudents) {
        final attendanceId = "ATT_${student.studentId}_${dateStr}_${_selectedSession.name}";
        final docRef = db.collection("attendance").doc(attendanceId);

        final data = {
          "attendance_id": attendanceId,
          "student_id": student.studentId,
          "student_name": student.studentName,
          "admission_number": student.admissionNumber,
          "date": dateStr,
          "timestamp": FieldValue.serverTimestamp(),
          "session": _selectedSession.name,
          "status": student.status.name,
          "late_reason": student.lateReason,
          "division_id": division.id,
          "academic_year_id": division.academicYearId,
          "marked_by": staffId,
        };

        batch.set(docRef, data, SetOptions(merge: true));
      }

      await batch.commit();
      debugPrint("Attendance saved successfully for $_selectedSession on $dateStr");
    } catch (e) {
      debugPrint("Error saving attendance: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAttendance(String? divisionId) async {
    if (divisionId == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final querySnapshot = await FirebaseService.firestore
          .collection("attendance")
          .where("division_id", isEqualTo: divisionId)
          .where("date", isEqualTo: dateStr)
          .where("session", isEqualTo: _selectedSession.name)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Map existing attendance to our local list
        final attendanceMap = {
          for (var doc in querySnapshot.docs)
            doc.data()['student_id'] as String: doc.data()
        };

        for (var student in _allStudents) {
          final record = attendanceMap[student.studentId];
          if (record != null) {
            student.status = AttendanceStatus.values.firstWhere(
              (e) => e.name == record['status'],
              orElse: () => AttendanceStatus.none,
            );
            student.lateReason = record['late_reason'];
          } else {
            student.status = AttendanceStatus.none;
            student.lateReason = null;
          }
        }
      } else {
        // Reset if no records found
        for (var student in _allStudents) {
          student.status = AttendanceStatus.none;
          student.lateReason = null;
        }
      }
      _applySearch();
    } catch (e) {
      debugPrint("Error fetching attendance: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
