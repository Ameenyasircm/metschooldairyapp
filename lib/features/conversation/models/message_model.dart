import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String senderRole;
  final String message;
  final Timestamp createdAt;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderRole,
    required this.message,
    required this.createdAt,
    required this.isRead,
  });

  factory MessageModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MessageModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderRole: data['senderRole'] ?? '',
      message: data['message'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      isRead: data['isRead'] ?? false,
    );
  }
}