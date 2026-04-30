import 'package:cloud_firestore/cloud_firestore.dart';

class SyllabusModel {
  final String id;
  final String subject;
  final String classId;
  final String className;
  final String divisionId;
  final String divisionName;
  final String fileUrl;
  final DateTime uploadedAt;
  final String teacherId;

  SyllabusModel({
    required this.id,
    required this.subject,
    required this.classId,
    required this.className,
    required this.divisionId,
    required this.divisionName,
    required this.fileUrl,
    required this.uploadedAt,
    required this.teacherId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'classId': classId,
      'className': className,
      'divisionId': divisionId,
      'divisionName': divisionName,
      'fileUrl': fileUrl,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'teacherId': teacherId,
    };
  }

  factory SyllabusModel.fromMap(Map<String, dynamic> map, String docId) {
    return SyllabusModel(
      id: docId,
      subject: map['subject'] ?? '',
      classId: map['classId'] ?? '',
      className: map['className'] ?? '',
      divisionId: map['divisionId'] ?? '',
      divisionName: map['divisionName'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      uploadedAt: (map['uploadedAt'] as Timestamp).toDate(),
      teacherId: map['teacherId'] ?? '',
    );
  }
}
