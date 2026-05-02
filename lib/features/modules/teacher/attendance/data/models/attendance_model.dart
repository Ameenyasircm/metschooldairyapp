import 'package:cloud_firestore/cloud_firestore.dart';

enum AttendanceStatus { present, absent, late, none }

enum AttendanceSession { morning, afternoon }

class StudentAttendanceData {
  final String studentId;
  final String name;
  final int rollNo;
  final String parentPhone;
  final String parentId;
  AttendanceStatus morning;
  AttendanceStatus afternoon;
  bool isLate;
  String lateRemark;
  int lateDurationMinutes;
  String morningAbsentRemark;
  String afternoonAbsentRemark;

  StudentAttendanceData({
    required this.studentId,
    required this.name,
    required this.rollNo,
    this.parentPhone = '',
    this.parentId = '',
    this.morning = AttendanceStatus.none,
    this.afternoon = AttendanceStatus.none,
    this.isLate = false,
    this.lateRemark = '',
    this.lateDurationMinutes = 0,
    this.morningAbsentRemark = '',
    this.afternoonAbsentRemark = '',
  });

  factory StudentAttendanceData.fromMap(String id, Map<String, dynamic> map) {
    return StudentAttendanceData(
      studentId: id,
      name: map['name'] ?? '',
      rollNo: map['rollNo'] ?? 0,
      parentPhone: map['parentPhone'] ?? '',
      parentId: map['parentId'] ?? '',
      morning: _parseStatus(map['morning']),
      afternoon: _parseStatus(map['afternoon']),
      isLate: map['isLate'] ?? false,
      lateRemark: map['lateRemark'] ?? '',
      lateDurationMinutes: map['lateDurationMinutes'] ?? 0,
      morningAbsentRemark: map['morningAbsentRemark'] ?? '',
      afternoonAbsentRemark: map['afternoonAbsentRemark'] ?? '',
    );
  }

  static AttendanceStatus _parseStatus(String? status) {
    switch (status) {
      case 'present': return AttendanceStatus.present;
      case 'absent': return AttendanceStatus.absent;
      case 'late': return AttendanceStatus.late;
      default: return AttendanceStatus.none;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'rollNo': rollNo,
      'parentPhone': parentPhone,
      'parentId': parentId,
      'morning': morning.name,
      'afternoon': afternoon.name,
      'isLate': isLate,
      'lateRemark': lateRemark,
      'lateDurationMinutes': lateDurationMinutes,
      'morningAbsentRemark': morningAbsentRemark,
      'afternoonAbsentRemark': afternoonAbsentRemark,
    };
  }
}

class DailyAttendanceModel {
  final String date;
  final String divisionId;
  final String academicYearId;
  final String markedById;
  final DateTime lastUpdated;
  final Map<String, StudentAttendanceData> students;

  DailyAttendanceModel({
    required this.date,
    required this.divisionId,
    required this.academicYearId,
    required this.markedById,
    required this.lastUpdated,
    required this.students,
  });

  factory DailyAttendanceModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Map<String, dynamic> studentsMap = data['students'] ?? {};
    
    return DailyAttendanceModel(
      date: data['date'] ?? '',
      divisionId: data['divisionId'] ?? '',
      academicYearId: data['academicYearId'] ?? '',
      markedById: data['markedById'] ?? '',
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
      students: studentsMap.map((key, value) => MapEntry(key, StudentAttendanceData.fromMap(key, value))),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'divisionId': divisionId,
      'academicYearId': academicYearId,
      'markedById': markedById,
      'lastUpdated': FieldValue.serverTimestamp(),
      'students': students.map((key, value) => MapEntry(key, value.toMap())),
    };
  }
}
