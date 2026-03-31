import 'package:flutter/material.dart';
import 'package:met_school/features/about/widgets/about_us_hero_section.dart';
import 'package:met_school/features/about/widgets/aboutus_academic_section.dart';
import 'package:met_school/features/about/widgets/aboutus_mission_screen.dart';

import '../../core/theme/app_colors.dart';


class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(Icons.apps, color: AppColors.primary),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: AppColors.black)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Portal", style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: const [
            HeroSection(),
            MissionSection(),
            SizedBox(height: 40),
            AcademicExcellenceSection(),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}