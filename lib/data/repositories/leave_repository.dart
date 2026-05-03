import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:met_school/core/models/leave_request_model.dart';
import 'dart:developer' as dev;

class LeaveRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Streams leave requests for a specific student.
  /// 
  /// COMPOSITE INDEX REQUIRED:
  /// Collection: leave_requests
  /// Fields: studentId (Ascending), createdAt (Descending)
  /// If you get a 'failed-precondition' error, follow the link in the logs to create the index.
  Stream<List<LeaveRequestModel>> streamStudentLeaves(String studentId) {
    return _firestore
        .collection("leave_requests")
        .where("studentId", isEqualTo: studentId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
          // Mapping happens here to keep the UI thread light
          return snapshot.docs.map((doc) {
            return LeaveRequestModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        })
        .handleError((error) {
          if (error is FirebaseException) {
            if (error.code == 'failed-precondition') {
              dev.log("FIREBASE INDEX MISSING: A composite index is required for this query. "
                  "Please create an index for 'leave_requests' collection with fields 'studentId: Ascending' "
                  "and 'createdAt: Descending'.", error: error, name: 'LeaveRepository');
            } else {
              dev.log("Firestore error in streamStudentLeaves: ${error.message}", 
                  error: error, name: 'LeaveRepository');
            }
          } else {
            dev.log("Unknown error in streamStudentLeaves", 
                error: error, name: 'LeaveRepository');
          }
          throw error;
        });
  }

  /// Streams leave requests for a teacher filtered by academic year, class, and status.
  /// 
  /// COMPOSITE INDEX REQUIRED:
  /// Collection: leave_requests
  /// Fields: academicYearId (Asc), classId (Asc), status (Asc), createdAt (Desc)
  Stream<List<LeaveRequestModel>> streamTeacherLeaves({
    required String academicYearId,
    required String classId,
    required String status,
  }) {
    return _firestore
        .collection("leave_requests")
        .where("academicYearId", isEqualTo: academicYearId)
        .where("classId", isEqualTo: classId)
        .where("status", isEqualTo: status)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return LeaveRequestModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        })
        .handleError((error) {
          if (error is FirebaseException) {
            if (error.code == 'failed-precondition') {
              dev.log("FIREBASE INDEX MISSING: Composite index required for teacher leaves: "
                  "academicYearId (Asc), classId (Asc), status (Asc), createdAt (Desc).",
                  error: error, name: 'LeaveRepository');
            } else {
              dev.log("Firestore error in streamTeacherLeaves: ${error.message}", 
                  error: error, name: 'LeaveRepository');
            }
          }
          throw error;
        });
  }

  Future<void> updateLeaveStatus(String docId, String status, {String? rejectionReason}) async {
    try {
      await _firestore.collection("leave_requests").doc(docId).update({
        'status': status,
        'rejectionReason': rejectionReason,
      });
    } catch (e) {
      dev.log("Error updating leave status", error: e, name: 'LeaveRepository');
      rethrow;
    }
  }

  Future<void> addLeaveRequest(LeaveRequestModel leaveRequest) async {
    try {
      await _firestore.collection("leave_requests").add(leaveRequest.toMap());
    } catch (e) {
      dev.log("Error adding leave request", error: e, name: 'LeaveRepository');
      rethrow;
    }
  }

  Future<void> deleteLeaveRequest(String docId) async {
    try {
      await _firestore.collection("leave_requests").doc(docId).delete();
    } catch (e) {
      dev.log("Error deleting leave request", error: e, name: 'LeaveRepository');
      rethrow;
    }
  }
}
