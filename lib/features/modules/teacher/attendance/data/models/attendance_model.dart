enum AttendanceStatus { present, absent, late, none }

class StudentAttendance {
  final String studentId;
  final String studentName;
  final String admissionNumber;
  AttendanceStatus status;
  String? lateReason;

  StudentAttendance({
    required this.studentId,
    required this.studentName,
    required this.admissionNumber,
    this.status = AttendanceStatus.none,
    this.lateReason,
  });
}

enum AttendanceSession { morning, afternoon }
