import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/attendance_model.dart';
import '../../data/service/attendance_firestore_service.dart';
import '../../../students/data/repository/student_repository.dart';
import '../../../../parent/notifications/data/services/parent_notification_service.dart';

class AttendanceViewModel extends ChangeNotifier {
  final AttendanceFirestoreService _service;
  final StudentRepository _studentRepo;
  final ParentNotificationService _notificationService = ParentNotificationService();

  AttendanceViewModel(this._service, this._studentRepo);

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  AttendanceSession _selectedSession = AttendanceSession.morning;
  AttendanceSession get selectedSession => _selectedSession;

  Map<String, StudentAttendanceData> _attendanceMap = {};
  Map<String, StudentAttendanceData> get attendanceMap => _attendanceMap;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _divisionId;
  String? _academicYearId;
  String? _teacherId;

  void init(String divisionId, String academicYearId, String teacherId) {
    _divisionId = divisionId;
    _academicYearId = academicYearId;
    _teacherId = teacherId;
    _selectedDate = DateTime.now(); // Reset to current date on init
    loadAttendance();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    loadAttendance();
    notifyListeners();
  }

  void setSelectedSession(AttendanceSession session) {
    _selectedSession = session;
    notifyListeners();
  }

  Future<void> loadAttendance() async {
    if (_divisionId == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      
      // Always fetch current enrollments to ensure new students are included
      final enrollments = await _studentRepo.getEnrollmentsByDivision(_divisionId!);
      
      final existingAttendance = await _service.fetchAttendanceByDate(dateStr, _divisionId!);

      Map<String, StudentAttendanceData> newAttendanceMap = {};

      // 1. Initialize map with all current enrollments
      for (var e in enrollments) {
        newAttendanceMap[e.studentId] = StudentAttendanceData(
          studentId: e.studentId,
          name: e.name,
          rollNo: e.rollNumber,
          parentPhone: e.parentPhone,
          parentId: e.parentId,
        );
      }

      // 2. If attendance was already marked, merge the saved data
      if (existingAttendance != null) {
        existingAttendance.students.forEach((id, savedData) {
          if (newAttendanceMap.containsKey(id)) {
            // Update the existing entry with saved attendance status
            newAttendanceMap[id]!.morning = savedData.morning;
            newAttendanceMap[id]!.afternoon = savedData.afternoon;
            newAttendanceMap[id]!.isLate = savedData.isLate;
            newAttendanceMap[id]!.lateRemark = savedData.lateRemark;
            newAttendanceMap[id]!.lateDurationMinutes = savedData.lateDurationMinutes;
            newAttendanceMap[id]!.morningAbsentRemark = savedData.morningAbsentRemark;
            newAttendanceMap[id]!.afternoonAbsentRemark = savedData.afternoonAbsentRemark;
          }
        });
      }
      
      _attendanceMap = newAttendanceMap;
    } catch (e) {
      debugPrint("Error loading attendance: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void markSingleStudent(String studentId, AttendanceStatus status, {String? remark, int? lateDuration, String? absentRemark}) {
    final data = _attendanceMap[studentId];
    if (data != null) {
      if (_selectedSession == AttendanceSession.morning) {
        data.morning = status;
        if (status == AttendanceStatus.late) {
          data.isLate = true;
          if (remark != null) data.lateRemark = remark;
          if (lateDuration != null) data.lateDurationMinutes = lateDuration;
        } else {
          data.isLate = false;
          data.lateRemark = '';
          data.lateDurationMinutes = 0;
        }

        if (status == AttendanceStatus.absent) {
          if (absentRemark != null) data.morningAbsentRemark = absentRemark;
        } else {
          data.morningAbsentRemark = '';
        }
      } else {
        data.afternoon = status;
        if (status == AttendanceStatus.absent) {
          if (absentRemark != null) data.afternoonAbsentRemark = absentRemark;
        } else {
          data.afternoonAbsentRemark = '';
        }
      }
      notifyListeners();
    }
  }

  void markAll(AttendanceStatus status) {
    _attendanceMap.forEach((id, data) {
      if (_selectedSession == AttendanceSession.morning) {
        data.morning = status;
        data.isLate = (status == AttendanceStatus.late);
        if (!data.isLate) data.lateRemark = '';
        if (status != AttendanceStatus.absent) data.morningAbsentRemark = '';
      } else {
        // Afternoon doesn't have "late" according to requirements, but handle just in case
        data.afternoon = (status == AttendanceStatus.late) ? AttendanceStatus.present : status;
        if (status != AttendanceStatus.absent) data.afternoonAbsentRemark = '';
      }
    });
    notifyListeners();
  }

  bool get isValid {
    if (_attendanceMap.isEmpty) return false;
    
    for (var data in _attendanceMap.values) {
      final status = _selectedSession == AttendanceSession.morning ? data.morning : data.afternoon;
      
      // Every student must have a status selected (not AttendanceStatus.none)
      if (status == AttendanceStatus.none) return false;
      
      // If late, remark is mandatory
      if (_selectedSession == AttendanceSession.morning && 
          status == AttendanceStatus.late && 
          data.lateRemark.trim().isEmpty) {
        return false;
      }
    }
    return true;
  }

  String? get validationMessage {
    if (_attendanceMap.isEmpty) return "No students available to mark attendance.";
    
    for (var data in _attendanceMap.values) {
      final status = _selectedSession == AttendanceSession.morning ? data.morning : data.afternoon;
      
      if (status == AttendanceStatus.none) {
        return "Please select attendance for all students.";
      }
      
      if (_selectedSession == AttendanceSession.morning && 
          status == AttendanceStatus.late && 
          data.lateRemark.trim().isEmpty) {
        return "Late remark is mandatory for ${data.name}.";
      }
    }
    return null;
  }

  Future<bool> saveAttendance() async {
    if (!isValid) return false;
    if (_divisionId == null || _academicYearId == null || _teacherId == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      
      // Check for duplicate or rather we are updating. 
      // Requirement says "Prevent duplicate attendance for same date + division", 
      // but also says "Allow update if already exists".
      // Our Firestore service uses .set(..., SetOptions(merge: true)) which handles updates.

      final model = DailyAttendanceModel(
        date: dateStr,
        divisionId: _divisionId!,
        academicYearId: _academicYearId!,
        markedById: _teacherId!,
        lastUpdated: DateTime.now(),
        students: _attendanceMap,
      );

      await _service.saveAttendance(model);
      
      // Trigger notifications for late students
      for (var data in _attendanceMap.values) {
        if (data.morning == AttendanceStatus.late && data.parentId.isNotEmpty) {
           await _notificationService.sendLateAttendanceNotification(
             parentId: data.parentId,
             studentName: data.name,
             studentId: data.studentId,
             date: dateStr,
             remark: data.lateRemark,
           );
        }
      }

      return true;
    } catch (e) {
      debugPrint("Error saving attendance: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _sendLateNotification(String phone, String name, String remark) {
    debugPrint("NOTIFY: Student $name was late. Remark: $remark. Sent to $phone");
  }

  Future<void> refresh() async {
    await loadAttendance();
  }
}
