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
    };
  }
}

class ParentRemarkModel {
  final String id;
  final String parentId;
  final String parentName;
  final String remark;
  final Timestamp updatedAt;

  ParentRemarkModel({
    required this.id,
    required this.parentId,
    required this.parentName,
    required this.remark,
    required this.updatedAt,
  });

  factory ParentRemarkModel.fromMap(Map<String, dynamic> map, String docId) {
    return ParentRemarkModel(
      id: docId,
      parentId: map['parentId'] ?? '',
      parentName: map['parentName'] ?? '',
      remark: map['remark'] ?? '',
      updatedAt: map['updatedAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'parentId': parentId,
      'parentName': parentName,
      'remark': remark,
      'updatedAt': updatedAt,
    };
  }
}
