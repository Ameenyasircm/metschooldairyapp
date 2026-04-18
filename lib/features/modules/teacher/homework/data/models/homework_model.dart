import 'package:cloud_firestore/cloud_firestore.dart';

class HomeworkModel {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final DateTime createdAt;
  final String classId;
  final String className;
  final String divisionId;
  final String divisionName;
  final String teacherId;
  final String teacherName;
  final List<String> attachments;
  final String? subject;
  final String academicYearId;

  HomeworkModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.createdAt,
    required this.classId,
    required this.className,
    required this.divisionId,
    required this.divisionName,
    required this.teacherId,
    required this.teacherName,
    this.attachments = const [],
    this.subject,
    required this.academicYearId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'classId': classId,
      'className': className,
      'divisionId': divisionId,
      'divisionName': divisionName,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'attachments': attachments,
      'subject': subject,
      'academic_year_id': academicYearId,
    };
  }

  factory HomeworkModel.fromMap(Map<String, dynamic> map, String docId) {
    return HomeworkModel(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      classId: map['classId'] ?? '',
      className: map['className'] ?? '',
      divisionId: map['divisionId'] ?? '',
      divisionName: map['divisionName'] ?? '',
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      attachments: List<String>.from(map['attachments'] ?? []),
      subject: map['subject']??'',
      academicYearId: map['academic_year_id']??'',
    );
  }
}

class HomeworkSubmissionModel {
  final String studentId;
  final String studentName;
  final String status; // 'completed' | 'pending'
  final DateTime updatedAt;
  final String? parentPhone;

  HomeworkSubmissionModel({
    required this.studentId,
    required this.studentName,
    required this.status,
    required this.updatedAt,
    this.parentPhone,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'status': status,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'parentPhone': parentPhone,
    };
  }

  factory HomeworkSubmissionModel.fromMap(Map<String, dynamic> map) {
    return HomeworkSubmissionModel(
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      status: map['status'] ?? 'pending',
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      parentPhone: map['parentPhone'],
    );
  }
}
