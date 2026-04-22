import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveRequestModel {
  final String? id;
  final String studentId;
  final String studentName;
  final String teacherId;
  final String academicYearId;
  final String classId;
  final String className;
  final String reason;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'pending', 'approved', 'rejected'
  final String? rejectionReason;
  final DateTime createdAt;

  LeaveRequestModel({
    this.id,
    required this.studentId,
    required this.studentName,
    required this.teacherId,
    required this.academicYearId,
    required this.classId,
    required this.className,
    required this.reason,
    required this.startDate,
    required this.endDate,
    this.status = 'pending',
    this.rejectionReason,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'teacherId': teacherId,
      'academicYearId': academicYearId,
      'classId': classId,
      'className': className,
      'reason': reason,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'status': status,
      'rejectionReason': rejectionReason,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory LeaveRequestModel.fromMap(Map<String, dynamic> map, String docId) {
    return LeaveRequestModel(
      id: docId,
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      teacherId: map['teacherId'] ?? '',
      academicYearId: map['academicYearId'] ?? '',
      classId: map['classId'] ?? '',
      className: map['className'] ?? '',
      reason: map['reason'] ?? '',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      status: map['status'] ?? 'pending',
      rejectionReason: map['rejectionReason'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
