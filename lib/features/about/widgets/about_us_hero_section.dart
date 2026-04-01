import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.darkGreen,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.darkGreen.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "The Atelier",
            style: TextStyle(color: AppColors.mint, fontWeight: FontWeight.bold, letterSpacing: 1.1),
          ),
          const SizedBox(height: 8),
          const Text(
            "Crafting the Future\nof Learning",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, height: 1.1),
          ),
          const SizedBox(height: 12),
          Text(
            "Nurturing innovation and creativity in a modern world.",
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
          ),
        ],
      ),
    );
  }
}