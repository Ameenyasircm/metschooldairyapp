import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class MissionSection extends StatelessWidget {
  const MissionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("OUR PURPOSE", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          const Text(
            "The Mission of The Atelier",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.black),
          ),
          const SizedBox(height: 12),
          const Text(
            "We believe in a student-centric approach that fosters critical thinking and practical skills.",
            style: TextStyle(color: AppColors.grey5E, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildMissionCard(Icons.lightbulb_outline, "Motivation", "Encouraging curiosity in every student."),
              const SizedBox(width: 16),
              _buildMissionCard(Icons.people_outline, "Mentorship", "Guiding the next generation of leaders."),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard(IconData icon, String title, String desc) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.greenE1.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.black)),
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.grey5E)),
          ],
        ),
      ),
    );
  }
}