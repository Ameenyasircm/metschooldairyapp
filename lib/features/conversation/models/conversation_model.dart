import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel {
  final String id;
  final String studentId;
  final String parentId;
  final String teacherId;
  final String lastMessage;
  final Timestamp? lastMessageTime;

  ConversationModel({
    required this.id,
    required this.studentId,
    required this.parentId,
    required this.teacherId,
    required this.lastMessage,
    required this.lastMessageTime,
  });

  factory ConversationModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ConversationModel(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      parentId: data['parentId'] ?? '',
      teacherId: data['teacherId'] ?? '',
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: data['lastMessageTime'],
    );
  }
}