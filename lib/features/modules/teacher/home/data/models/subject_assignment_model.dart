import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectAssignmentModel {
  final String assignmentId;
  final String academicYearId;
  final String classId;
  final String className;
  final String divisionId;
  final String divisionName;
  final String subjectId;
  final String subjectName;
  final String teacherId;
  final String teacherName;
  final String type;
  final DateTime? updatedAt;

  SubjectAssignmentModel({
    required this.assignmentId,
    required this.academicYearId,
    required this.classId,
    required this.className,
    required this.divisionId,
    required this.divisionName,
    required this.subjectId,
    required this.subjectName,
    required this.teacherId,
    required this.teacherName,
    required this.type,
    this.updatedAt,
  });

  factory SubjectAssignmentModel.fromMap(Map<String, dynamic> map) {
    return SubjectAssignmentModel(
      assignmentId: map['assignment_id'] ?? '',
      academicYearId: map['academic_year_id'] ?? '',
      classId: map['class_id'] ?? '',
      className: map['class_name'] ?? '',
      divisionId: map['division_id'] ?? '',
      divisionName: map['division_name'] ?? '',
      subjectId: map['subject_id'] ?? '',
      subjectName: map['subject_name'] ?? '',
      teacherId: map['teacher_id'] ?? '',
      teacherName: map['teacher_name'] ?? '',
      type: map['type'] ?? '',
      updatedAt: map['updated_at'] != null 
          ? (map['updated_at'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'assignment_id': assignmentId,
      'academic_year_id': academicYearId,
      'class_id': classId,
      'class_name': className,
      'division_id': divisionId,
      'division_name': divisionName,
      'subject_id': subjectId,
      'subject_name': subjectName,
      'teacher_id': teacherId,
      'teacher_name': teacherName,
      'type': type,
      'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
