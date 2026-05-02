import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../core/service/firebase_service.dart';
import '../../../students/data/models/tech_student_model.dart';
import '../../../students/data/repository/student_repository.dart';
import '../../data/models/attendance_model.dart';
import '../../../../parent/notifications/data/services/parent_notification_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final StudentRepository repository;
  final ParentNotificationService _notificationService = ParentNotificationService();
  AttendanceProvider(this.repository);

  List<StudentAttendanceData> _allStudents = [];
  List<StudentAttendanceData> _filteredStudents = [];
  List<StudentAttendanceData> get students => _filteredStudents;
  List<StudentAttendanceData> get allStudents => _allStudents;

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

  void initializeStudents(List<EnrollerModel> enrollments) {
    _allStudents = enrollments.map((e) => StudentAttendanceData(
      studentId: e.studentId,
      name: e.name,
      rollNo: e.rollNumber,
      parentId: e.parentId,
      parentPhone: e.parentPhone,
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
        return s.name.toLowerCase().contains(query) ||
               s.rollNo.toString().contains(query);
      }).toList();
    }
    notifyListeners();
  }

  void updateStatus(String studentId, AttendanceStatus status, {String? reason}) {
    final index = _allStudents.indexWhere((s) => s.studentId == studentId);
    if (index != -1) {
      if (_selectedSession == AttendanceSession.morning) {
        _allStudents[index].morning = status;
        if (status == AttendanceStatus.late) {
          _allStudents[index].isLate = true;
          _allStudents[index].lateRemark = reason ?? '';
        } else {
          _allStudents[index].isLate = false;
          _allStudents[index].lateRemark = '';
        }
      } else {
        _allStudents[index].afternoon = status;
      }
      _applySearch();
    }
  }

  void markAll(AttendanceStatus status) {
    for (var student in _allStudents) {
      if (_selectedSession == AttendanceSession.morning) {
        student.morning = status;
        student.isLate = (status == AttendanceStatus.late);
        if (!student.isLate) student.lateRemark = '';
      } else {
        student.afternoon = status;
      }
    }
    _applySearch();
  }

  Future<void> saveAttendance() async {
    if (_allStudents.isEmpty) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final db = FirebaseService.firestore;
      final prefs = await SharedPreferences.getInstance();
      final staffId = prefs.getString("staffId") ?? '';
      final divisionId = prefs.getString("divisionId") ?? '';
      final academicYearId = prefs.getString("academicYearId") ?? '';

      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final docId = "${dateStr}_$divisionId";
      
      final Map<String, dynamic> studentsData = {};
      for (var s in _allStudents) {
        studentsData[s.studentId] = s.toMap();
      }

      await db.collection("attendance").doc(docId).set({
        "date": dateStr,
        "divisionId": divisionId,
        "academicYearId": academicYearId,
        "markedById": staffId,
        "lastUpdated": FieldValue.serverTimestamp(),
        "students": studentsData,
      }, SetOptions(merge: true));

      // Trigger Notifications for Late Students
      for (var s in _allStudents) {
        if (s.isLate && s.parentId.isNotEmpty) {
          await _notificationService.sendLateAttendanceNotification(
            parentId: s.parentId,
            studentName: s.name,
            studentId: s.studentId,
            date: dateStr,
          );
        }
      }

      debugPrint("Attendance saved successfully for $dateStr");
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
      final doc = await FirebaseService.firestore
          .collection("attendance")
          .doc("${dateStr}_$divisionId")
          .get();

      if (doc.exists) {
        final data = doc.data()!['students'] as Map<String, dynamic>;
        for (var student in _allStudents) {
          final record = data[student.studentId];
          if (record != null) {
            student.morning = _parseStatus(record['morning']);
            student.afternoon = _parseStatus(record['afternoon']);
            student.isLate = record['isLate'] ?? false;
            student.lateRemark = record['lateRemark'] ?? '';
          }
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

  AttendanceStatus _parseStatus(String? status) {
    switch (status) {
      case 'present': return AttendanceStatus.present;
      case 'absent': return AttendanceStatus.absent;
      case 'late': return AttendanceStatus.late;
      default: return AttendanceStatus.none;
    }
  }
}
