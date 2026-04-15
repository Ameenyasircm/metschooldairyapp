import 'package:cloud_firestore/cloud_firestore.dart';

class TechStudentModel {
  final String studentId;
  final String name;
  final String parentId;
  final String parentPhone;
  final Timestamp? dob;
  final String bloodGroup;
  final String address;
  final String admissionId;

  TechStudentModel({
    required this.studentId,
    required this.name,
    required this.parentId,
    required this.parentPhone,
    required this.dob,
    required this.bloodGroup,
    required this.address,
    required this.admissionId,
  });

  factory TechStudentModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      throw ArgumentError('TechStudentModel map cannot be null');
    }

    return TechStudentModel(
      studentId: (map['id'] as String?)?.trim() ?? '',
      name: (map['name'] as String?)?.trim() ?? '',
      parentId: (map['parentId'] as String?)?.trim() ?? '',
      parentPhone: (map['phone'] as String?)?.trim() ?? '',
      dob: _parseTimestamp(map['dob']),
      bloodGroup: (map['blood_group'] as String?)?.trim() ?? '',
      address: (map['address'] as String?)?.trim() ?? '',
      admissionId: (map['admissionId'] as String?)?.trim() ?? '',
    );
  }

  static Timestamp? _parseTimestamp(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) return value;

    if (value is DateTime) {
      return Timestamp.fromDate(value);
    }

    // Optional: handle string dates if your DB is messy
    if (value is String) {
      try {
        return Timestamp.fromDate(DateTime.parse(value));
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': studentId,
      'name': name,
      'phone': parentPhone,
      'dob': dob,
      'blood_group': bloodGroup,
      'address': address,
      'admissionId': admissionId,
    };
  }
}
class EnrollerModel {
  final String studentId;
  final String name;
  final String parentId;
  final String parentPhone;
  final String rollNumber;
  final String className;
  final String divisionName;

  EnrollerModel({
    required this.studentId,
    required this.name,
    required this.parentId,
    required this.parentPhone,
    required this.rollNumber,
    required this.className,
    required this.divisionName,
  });

  factory EnrollerModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      throw ArgumentError('TechStudentModel map cannot be null');
    }

    return EnrollerModel(
      studentId: (map['student_id'] as String?)?.trim() ?? '',
      name: (map['student_name'] as String?)?.trim() ?? '',
      parentId: (map['parent_id'] as String?)?.trim() ?? '',
      parentPhone: (map['parent_phone'] as String?)?.trim() ?? '',
      rollNumber: (map['roll_number'] as String?)?.trim() ?? '',
      className: (map['class_name'] as String?)?.trim() ?? '',
      divisionName: (map['division_name'] as String?)?.trim() ?? '',
    );
  }

  static Timestamp? _parseTimestamp(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) return value;

    if (value is DateTime) {
      return Timestamp.fromDate(value);
    }

    // Optional: handle string dates if your DB is messy
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