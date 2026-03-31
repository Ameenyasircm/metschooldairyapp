import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AcademicExcellenceSection extends StatelessWidget {
  const AcademicExcellenceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Academic Excellence",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.black),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
          child: Text(
            "We provide a world-class curriculum that focuses on your future.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.grey5E),
          ),
        ),
        const SizedBox(height: 20),
        _buildExcellenceTile("Modern Literacies", 0.7, AppColors.mint),
        _buildExcellenceTile("Global Perspectives", 0.9, AppColors.blueish),
        _buildExcellenceTile("Project Synergies", 0.5, AppColors.mint),
      ],
    );
  }

  Widget _buildExcellenceTile(String title, double progress, Color accentColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: accentColor.withOpacity(0.3), radius: 18, child: Icon(Icons.auto_awesome, size: 18, color: AppColors.primary)),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.greenE1,
              color: AppColors.primary,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}