import 'package:flutter/material.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/utils/snackbarNotification/snackbar_notification.dart';

import '../../../../../../core/constants/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/widgets/buttons/action_button.dart';
import '../../../../../../core/widgets/custom_textfield.dart';

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
      backgroundColor: AppColors.white,
      title:  Text("Reject Leave Request",style: AppTypography.body1.copyWith(
          fontWeight: FontWeight.w600)
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            fillColor: AppColors.greyBFB,
            controller: _controller,
            hintText: 'Enter reason for rejection',
            maxLine: 2,
            validator: (v) => v!.isEmpty ? 'Enter title' : null,
          ),
          AppSpacing.vl,
          Row(
            children: [
              Expanded(
                child: ActionButtonsRow(
                  text: "Reject",
                  onCancel: () {
                    Navigator.of(context).pop(false);
                  },
                  onSave: () async {
                    if (_controller.text.trim().isEmpty) {
                      SnackbarService().showError('Please provide a reason');
                      return;
                    }
                    widget.onReject(_controller.text.trim());
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
          AppSpacing.h4,
        ],
      ),
    );
  }
}
