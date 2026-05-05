import 'package:flutter/material.dart';

class QuickAction {
  final String title;
  final String icon;
  final Color? color; // The color of the icon container
  final VoidCallback onTap;

  const QuickAction({
    required this.title,
    required this.icon,
    this.color,
    required this.onTap,
  });
}
