import 'package:cloud_firestore/cloud_firestore.dart';

class ParentNotificationModel {
  final String id;
  final String title;
  final String body;
  final String? studentId;
  final String? date;
  final String? remark;
  final bool isSeen;
  final DateTime createdAt;

  ParentNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.studentId,
    this.date,
    this.remark,
    this.isSeen = false,
    required this.createdAt,
  });

  factory ParentNotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ParentNotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      studentId: data['studentId'],
      date: data['date'],
      remark: data['remark'],
      isSeen: data['isSeen'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'studentId': studentId,
      'date': date,
      'remark': remark,
      'isSeen': isSeen,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
