enum AttendanceStatus { present, absent, none }

class StudentAttendance {
  final String studentId;
  final String studentName;
  final String admissionNumber;
  AttendanceStatus status;

  StudentAttendance({
    required this.studentId,
    required this.studentName,
    required this.admissionNumber,
    this.status = AttendanceStatus.none,
  });
}

enum AttendanceSession { morning, afternoon }
