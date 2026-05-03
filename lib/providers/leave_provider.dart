import 'package:flutter/foundation.dart';
import 'package:met_school/core/models/leave_request_model.dart';
import 'package:met_school/data/repositories/leave_repository.dart';

class LeaveProvider with ChangeNotifier {
  final LeaveRepository _repository;

  LeaveProvider(this._repository);

  // Memoization of streams to prevent recreation on every widget rebuild
  final Map<String, Stream<List<LeaveRequestModel>>> _studentLeavesCache = {};
  final Map<String, Stream<List<LeaveRequestModel>>> _teacherLeavesCache = {};

  /// Exposes a stream of leaves for a specific student.
  /// Uses memoization to ensure the same stream instance is returned for the same studentId.
  Stream<List<LeaveRequestModel>> getStudentLeavesStream(String studentId) {
    if (!_studentLeavesCache.containsKey(studentId)) {
      _studentLeavesCache[studentId] = _repository.streamStudentLeaves(studentId);
    }
    return _studentLeavesCache[studentId]!;
  }

  /// Exposes a stream of leaves for a teacher filtered by status, academic year, and class.
  Stream<List<LeaveRequestModel>> getTeacherLeavesStream({
    required String academicYearId,
    required String classId,
    required String status,
  }) {

    final cacheKey = "${academicYearId}_${classId}_$status";
    if (!_teacherLeavesCache.containsKey(cacheKey)) {
      _teacherLeavesCache[cacheKey] = _repository.streamTeacherLeaves(
        academicYearId: academicYearId,
        classId: classId,
        status: status,
      );
    }
    return _teacherLeavesCache[cacheKey]!;
  }

  /// Handles leave request submission
  Future<void> submitLeaveRequest(LeaveRequestModel leaveRequest) async {
    await _repository.addLeaveRequest(leaveRequest);
    notifyListeners();
  }

  /// Handles status update for a leave request
  Future<void> updateRequestStatus(String docId, String status, {String? rejectionReason}) async {
    await _repository.updateLeaveStatus(docId, status, rejectionReason: rejectionReason);
    notifyListeners();
  }

  /// Handles deletion of a leave request
  Future<void> deleteLeaveRequest(String docId) async {
    await _repository.deleteLeaveRequest(docId);
    notifyListeners();
  }

  /// Clears cached streams (useful on logout)
  void clearCache() {
    _studentLeavesCache.clear();
    _teacherLeavesCache.clear();
  }
}
