import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../providers/conversation_provider.dart';
import '../models/message_model.dart';

class MessageScreen extends StatefulWidget {
  final String conversationId;
  final String currentUserId;
  final String role;
  final String senderName;

  const MessageScreen({
    required this.conversationId,
    required this.currentUserId,
    required this.role,
    required this.senderName,
  });

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _showTitleField = false;
  final Set<int> _expandedMessages = {};

  static const _primaryBlue = Color(0xFF1A3557);
  static const _accentBlue = Color(0xFF2563EB);
  static const _softBg = Color(0xFFF4F6FA);
  static const _cardBg = Colors.white;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _formatTime(Timestamp time) =>
      DateFormat('hh:mm a · MMM d').format(time.toDate());

  String _roleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'teacher':
        return 'Teacher';
      case 'parent':
        return 'Parent';
      default:
        return role;
    }
  }

  Color _roleColor(String role) {
    switch (role.toLowerCase()) {
      case 'teacher':
        return const Color(0xFF1A3557);
      case 'parent':
        return const Color(0xFF065F46);
      default:
        return Colors.blueGrey;
    }
  }

  Widget _buildRoleBadge(String role) {
    final color = _roleColor(role);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        _roleLabel(role).toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildMessageCard(MessageModel msg, bool isMe, int index) {
    final bool isLong = msg.description.length > 200;
    final bool isExpanded = _expandedMessages.contains(index);
    final displayText = isLong && !isExpanded
        ? '${msg.description.substring(0, 200)}...'
        : msg.description;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: _roleColor(msg.senderRole).withOpacity(0.12),
              child: Text(
                _roleLabel(msg.senderRole)[0],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _roleColor(msg.senderRole),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 300),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFFEBF2FF) : _cardBg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(isMe ? 12 : 2),
                  bottomRight: Radius.circular(isMe ? 2 : 12),
                ),
                border: Border.all(
                  color: isMe
                      ? const Color(0xFFBFD4F7)
                      : Colors.grey.shade200,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header strip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isMe
                          ? const Color(0xFFD6E8FF)
                          : Colors.grey.shade50,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildRoleBadge(msg.senderRole),
                        Text(
                          _formatTime(msg.createdAt),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Optional title
                  if (msg.title != null && msg.title!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                      child: Text(
                        msg.title!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _primaryBlue,
                        ),
                      ),
                    ),

                  // ── Message body
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayText,
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.55,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        if (isLong) ...[
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () => setState(() => isExpanded
                                ? _expandedMessages.remove(index)
                                : _expandedMessages.add(index)),
                            child: Text(
                              isExpanded ? 'Show less ▲' : 'Read more ▼',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: _accentBlue,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: _roleColor(msg.senderRole).withOpacity(0.12),
              child: Text(
                _roleLabel(msg.senderRole)[0],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _roleColor(msg.senderRole),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea(ConversationProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Toggle title field
          GestureDetector(
            onTap: () => setState(() => _showTitleField = !_showTitleField),
            child: Row(
              children: [
                Icon(
                  _showTitleField
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Text(
                  _showTitleField ? 'Hide subject' : 'Add subject (optional)',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          if (_showTitleField) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Subject / Topic',
                hintStyle:
                TextStyle(fontSize: 13, color: Colors.grey.shade400),
                filled: true,
                fillColor: _softBg,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                  const BorderSide(color: _accentBlue, width: 1.5),
                ),
              ),
            ),
          ],

          const SizedBox(height: 8),

          // ── Message + Send row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 140),
                  child: TextField(
                    controller: _descController,
                    focusNode: _focusNode,
                    minLines: 1,
                    maxLines: 6,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(fontSize: 13.5, height: 1.5),
                    decoration: InputDecoration(
                      hintText: 'Write your message...',
                      hintStyle: TextStyle(
                          fontSize: 13, color: Colors.grey.shade400),
                      filled: true,
                      fillColor: _softBg,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: _accentBlue, width: 1.5),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _SendButton(onSend: () async {
                if (_descController.text.trim().isEmpty) return;
                print('${widget.senderName} sender..');
                await provider.sendMessage(
                  conversationId: widget.conversationId,
                  senderId: widget.currentUserId,
                  senderRole: widget.role,
                  senderName: widget.senderName, // 🔥 replace with real parent name
                  title: _titleController.text.trim(),
                  description: _descController.text.trim(),
                );
                _titleController.clear();
                _descController.clear();
                _showTitleField = false;
                setState(() {});
              }),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ConversationProvider>();

    return Scaffold(
      backgroundColor: _softBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.school_rounded,
                  size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'School Communication',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Logged in as ${_roleLabel(widget.role)}',
                  style: const TextStyle(
                      fontSize: 10.5,
                      color: Colors.white70,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF4ADE80),
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text('Active',
                      style:
                      TextStyle(fontSize: 11, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // ── Conversation context banner
          Container(
            width: double.infinity,
            color: const Color(0xFFEBF2FF),
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 14, color: _accentBlue),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'This is a confidential channel between the teacher and parent.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blueGrey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Messages
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: provider.getMessages(widget.conversationId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: _accentBlue),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mark_chat_unread_outlined,
                            size: 40, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Start the conversation below.',
                          style: TextStyle(
                              color: Colors.grey.shade400, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data!;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(
                        _scrollController.position.maxScrollExtent);
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == widget.currentUserId;
                    return _buildMessageCard(msg, isMe, index);
                  },
                );
              },
            ),
          ),

          _buildInputArea(provider),
        ],
      ),
    );
  }
}

// ── Animated send button extracted for clarity
class _SendButton extends StatelessWidget {
  final VoidCallback onSend;
  const _SendButton({required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1A3557),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onSend,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          child: const Icon(Icons.send_rounded,
              color: Colors.white, size: 18),
        ),
      ),
    );
  }
}