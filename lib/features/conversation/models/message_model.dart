import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderName;
  final String senderId;
  final String senderRole;
  final String title;
  final String description;
  final Timestamp createdAt;

  MessageModel({
    required this.id,
    required this.senderName,
    required this.senderId,
    required this.senderRole,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  factory MessageModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MessageModel(
      id: doc.id,
      senderName: data['senderName'] ?? '',
      senderId: data['senderId'] ?? '',
      senderRole: data['senderRole'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}