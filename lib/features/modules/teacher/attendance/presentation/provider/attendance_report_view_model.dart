import 'package:flutter/material.dart';
import '../../data/models/attendance_model.dart';
import '../../data/service/attendance_firestore_service.dart';

class AttendanceReportViewModel extends ChangeNotifier {
  final AttendanceFirestoreService _service;

  AttendanceReportViewModel(this._service);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Monthly Report Data
  List<DailyAttendanceModel> _monthlyData = [];
  Map<String, StudentStats> _studentStats = {};
  Map<String, StudentStats> get studentStats => _studentStats;

  // Student-wise History
  List<DailyAttendanceModel> _studentHistory = [];
  List<DailyAttendanceModel> get studentHistory => _studentHistory;

  Future<void> loadMonthlyReport(String divisionId, String monthYear) async {
    _isLoading = true;
    notifyListeners();

    try {
      _monthlyData = await _service.fetchMonthlyAttendance(divisionId, monthYear);
      _aggregateMonthlyStats();
    } catch (e) {
      debugPrint("Error loading monthly report: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _aggregateMonthlyStats() {
    final stats = <String, StudentStats>{};

    for (var daily in _monthlyData) {
      daily.students.forEach((studentId, data) {
        if (!stats.containsKey(studentId)) {
          stats[studentId] = StudentStats(name: data.name, rollNo: data.rollNo);
        }
        
        final studentStat = stats[studentId]!;
        
        // Morning Session
        if (data.morning == AttendanceStatus.present) studentStat.present++;
        else if (data.morning == AttendanceStatus.absent) studentStat.absent++;
        else if (data.morning == AttendanceStatus.late) studentStat.late++;

        // Afternoon Session
        if (data.afternoon == AttendanceStatus.present) studentStat.present++;
        else if (data.afternoon == AttendanceStatus.absent) studentStat.absent++;
      });
    }

    // Sort by roll number
    _studentStats = Map.fromEntries(
      stats.entries.toList()..sort((a, b) {
        int rollA = int.tryParse(a.value.rollNo) ?? 0;
        int rollB = int.tryParse(b.value.rollNo) ?? 0;
        return rollA.compareTo(rollB);
      })
    );
  }

  Future<void> loadStudentHistory(String studentId, {DateTime? start, DateTime? end}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final startDateStr = start?.toIso8601String().split('T')[0];
      final endDateStr = end?.toIso8601String().split('T')[0];
      
      _studentHistory = await _service.fetchStudentAttendanceHistory(
        studentId, 
        startDate: startDateStr, 
        endDate: endDateStr
      );
      
      // Sort history by date descending
      _studentHistory.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      debugPrint("Error loading student history: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class StudentStats {
  final String name;
  final String rollNo;
  int present = 0;
  int absent = 0;
  int late = 0;

  StudentStats({required this.name, required this.rollNo});

  int get totalSessions => present + absent + late;
  double get attendancePercentage => totalSessions == 0 ? 0 : (present / totalSessions) * 100;
}
