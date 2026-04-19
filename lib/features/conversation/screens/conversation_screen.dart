import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../providers/conversation_provider.dart';
import '../models/message_model.dart';

class MessageScreen extends StatelessWidget {
  final String conversationId;
  final String currentUserId;
  final String role;

  MessageScreen({
    required this.conversationId,
    required this.currentUserId,
    required this.role,
  });

  final TextEditingController controller = TextEditingController();

  String formatTime(Timestamp time) {
    return DateFormat('hh:mm a').format(time.toDate());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ConversationProvider>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      /// 🔹 HEADER
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Communication",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              role.toUpperCase(),
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),

      body: Column(
        children: [

          /// 🔹 MESSAGES LIST
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: provider.getMessages(conversationId),
              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      "No messages yet",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final messages = snapshot.data!;

                return ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == currentUserId;

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [

                          /// 🔹 ROLE LABEL
                          Text(
                            msg.senderRole.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),

                          SizedBox(height: 2),

                          /// 🔹 MESSAGE BUBBLE
                          Container(
                            constraints: BoxConstraints(maxWidth: 280),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? Colors.green.shade50
                                  : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                                bottomLeft: Radius.circular(isMe ? 12 : 0),
                                bottomRight: Radius.circular(isMe ? 0 : 12),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg.message,
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(height: 6),

                                /// 🔹 TIME
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    formatTime(msg.createdAt),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          /// 🔹 INPUT FIELD
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Write a message...",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 6),

                /// 🔹 SEND BUTTON
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.green,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: () async {
                      if (controller.text.trim().isEmpty) return;

                      await provider.sendMessage(
                        conversationId: conversationId,
                        senderId: currentUserId,
                        senderRole: role,
                        text: controller.text.trim(),
                      );

                      controller.clear();
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}