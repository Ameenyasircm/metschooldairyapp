import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkGreen,
        image: const DecorationImage(
          image: AssetImage('assets/background_pattern.png'), // Add your overlay pattern here
          opacity: 0.1,
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.2),
              children: [
                TextSpan(text: "Crafting the\nFuture of\n", style: TextStyle(color: AppColors.white)),
                TextSpan(text: "Learning.", style: TextStyle(color: AppColors.mint)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Welcome to the Atelier, where we nurture innovation and creativity to prepare for the modern world.",
            style: TextStyle(color: AppColors.greenE1, fontSize: 14),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}