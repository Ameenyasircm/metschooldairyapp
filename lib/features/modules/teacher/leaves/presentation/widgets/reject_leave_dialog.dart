import 'package:flutter/material.dart';

class RejectLeaveDialog extends StatefulWidget {
  final Function(String reason) onReject;

  const RejectLeaveDialog({super.key, required this.onReject});

  @override
  State<RejectLeaveDialog> createState() => _RejectLeaveDialogState();
}

class _RejectLeaveDialogState extends State<RejectLeaveDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Reject Leave Request"),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: "Enter reason for rejection",
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please provide a reason")),
              );
              return;
            }
            widget.onReject(_controller.text.trim());
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text("Reject", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
