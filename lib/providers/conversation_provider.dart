import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../features/conversation/models/message_model.dart';

class ConversationProvider extends ChangeNotifier{

  Future<String> getOrCreateConversation({
    required String studentId,
    required String parentId,
    required String teacherId,
  }) async {
    final query = await FirebaseFirestore.instance
        .collection('conversations')
        .where('studentId', isEqualTo: studentId)
        .where('parentId', isEqualTo: parentId)
        .where('teacherId', isEqualTo: teacherId)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.id;
    }

    final doc = await FirebaseFirestore.instance
        .collection('conversations')
        .add({
      'studentId': studentId,
      'parentId': parentId,
      'teacherId': teacherId,
      'lastMessage': '',
      'lastMessageTime': Timestamp.now(),
      'createdAt': Timestamp.now(),
    });

    return doc.id;
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderRole,
    required String text,
  }) async {
    final messageRef = FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationId)
        .collection('messages');

    await messageRef.add({
      'senderId': senderId,
      'senderRole': senderRole,
      'message': text,
      'createdAt': Timestamp.now(),
      'isRead': false,
    });

    await FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationId)
        .update({
      'lastMessage': text,
      'lastMessageTime': Timestamp.now(),
    });
  }

  Stream<List<MessageModel>> getMessages(String conversationId) {
    return FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((e) => MessageModel.fromDoc(e)).toList());
  }
  String? conversationId;

  Future<void> openConversation({
    required String studentId,
    required String parentId,
    required String teacherId,
  }) async {
    conversationId = await getOrCreateConversation(
      studentId: studentId,
      parentId: parentId,
      teacherId: teacherId,
    );
    notifyListeners();
  }

}