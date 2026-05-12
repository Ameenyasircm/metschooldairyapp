import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final Timestamp dateTime;
  final String? attachmentUrl;
  final String status; // 'pending', 'completed', 'cancelled'
  final String? teacherRemarks;
  final String createdById;
  final String createdByName;
  final String? academicYearId;
  final String? classId;
  final String? divisionId;
  final Timestamp createdAt;
  
  // New Generic Task Fields
  final bool isTaskRequired;
  final String? taskTitle; // e.g. "Sports Day Contribution", "Notebook Submission"
  final double? taskAmount; // optional amount
  final String? taskNote; // optional instructions

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.attachmentUrl,
    required this.status,
    this.teacherRemarks,
    required this.createdById,
    required this.createdByName,
    this.academicYearId,
    this.classId,
    this.divisionId,
    required this.createdAt,
    this.isTaskRequired = false,
    this.taskTitle,
    this.taskAmount,
    this.taskNote,
  });

  factory EventModel.fromMap(Map<String, dynamic> map, String docId) {
    return EventModel(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dateTime: map['dateTime'] as Timestamp? ?? Timestamp.now(),
      attachmentUrl: map['attachmentUrl'],
      status: map['status'] ?? 'pending',
      teacherRemarks: map['teacherRemarks'],
      createdById: map['createdById'] ?? '',
      createdByName: map['createdByName'] ?? '',
      academicYearId: map['academic_year_id'],
      classId: map['class_id'],
      divisionId: map['division_id'],
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
      isTaskRequired: map['isTaskRequired'] ?? false,
      taskTitle: map['taskTitle'],
      taskAmount: (map['taskAmount'] as num?)?.toDouble(),
      taskNote: map['taskNote'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dateTime': dateTime,
      'attachmentUrl': attachmentUrl,
      'status': status,
      'teacherRemarks': teacherRemarks,
      'createdById': createdById,
      'createdByName': createdByName,
      'academic_year_id': academicYearId,
      'class_id': classId,
      'division_id': divisionId,
      'createdAt': createdAt,
      'isTaskRequired': isTaskRequired,
      'taskTitle': taskTitle,
      'taskAmount': taskAmount,
      'taskNote': taskNote,
    };
  }
}

class StudentEventTaskModel {
  final String studentId;
  final String studentName;
  final String status; // 'Pending', 'Completed', 'Not Completed'
  final String? remark;
  final Timestamp updatedAt;

  StudentEventTaskModel({
    required this.studentId,
    required this.studentName,
    required this.status,
    this.remark,
    required this.updatedAt,
  });

  factory StudentEventTaskModel.fromMap(Map<String, dynamic> map, String id) {
    return StudentEventTaskModel(
      studentId: id,
      studentName: map['studentName'] ?? '',
      status: map['status'] ?? 'Pending',
      remark: map['remark'],
      updatedAt: map['updatedAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentName': studentName,
      'status': status,
      'remark': remark,
      'updatedAt': updatedAt,
    };
  }
}
