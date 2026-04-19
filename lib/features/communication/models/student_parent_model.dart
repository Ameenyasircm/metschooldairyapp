import 'package:cloud_firestore/cloud_firestore.dart';

class StudentWithParentModel {
  final String studentId;
  final String name;
  final String parentId;
  final String parentPhone;
  final String rollNumber;
  final String className;
  final String divisionName;
  final String parentName;

  StudentWithParentModel({
    required this.studentId,
    required this.name,
    required this.parentId,
    required this.parentPhone,
    required this.rollNumber,
    required this.className,
    required this.divisionName,
    required this.parentName,
  });

  factory StudentWithParentModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      throw ArgumentError('StudentWithParentModel map cannot be null');
    }

    return StudentWithParentModel(
      studentId: (map['student_id'] ?? '').toString(),
      name: (map['student_name'] ?? '').toString().trim(),
      parentId: (map['parent_id'] ?? '').toString(),
      parentPhone: (map['parent_phone'] ?? '').toString(),
      rollNumber: (map['roll_number'] ?? '').toString(),
      className: (map['class_name'] ?? '').toString(),
      divisionName: (map['division_name'] ?? '').toString(),
      parentName: (map['parentGuardian'] ?? '').toString().trim(),
    );
  }

  static Timestamp? _parseTimestamp(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) return value;

    if (value is DateTime) {
      return Timestamp.fromDate(value);
    }

    if (value is String) {
      try {
        return Timestamp.fromDate(DateTime.parse(value));
      } catch (_) {
        return null;
      }
    }

    return null;
  }
}