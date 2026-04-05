import 'package:flutter/material.dart';

class SnackbarService {
  static final SnackbarService _instance = SnackbarService._internal();

  factory SnackbarService() => _instance;

  SnackbarService._internal();

  final GlobalKey<ScaffoldMessengerState> messengerKey =
  GlobalKey<ScaffoldMessengerState>();

  void showSuccess(String message) {
    _show(message, Colors.green);
  }

  void showError(String message) {
    _show(message, Colors.red);
  }

  void showInfo(String message) {
    _show(message, Colors.blue);
  }

  void showNormal(String message) {
    _show(message, Colors.black);
  }

  void _show(String message, Color color) {
    final messenger = messengerKey.currentState;
    if (messenger == null) return;

    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}