import 'package:flutter/material.dart';

class QuickAction {
  final String title;
  final IconData icon;
  final Color color; // The color of the icon container
  final VoidCallback onTap;

  const QuickAction({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
