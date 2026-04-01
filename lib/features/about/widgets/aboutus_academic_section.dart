import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AcademicExcellenceSection extends StatelessWidget {
  const AcademicExcellenceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Academic Excellence", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Our curriculum focused on your future success.", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          _buildProgressTile("Modern Literacies", 0.7),
          _buildProgressTile("Global Perspectives", 0.9),
          _buildProgressTile("Project Synergies", 0.5),
        ],
      ),
    );
  }

  Widget _buildProgressTile(String title, double progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text("${(progress * 100).toInt()}%", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.greenE1,
              color: AppColors.primary,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}