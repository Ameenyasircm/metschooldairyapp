import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AcademicGalleryScreen extends StatelessWidget {
  const AcademicGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Icon(Icons.school, color: AppColors.primary),
        ),
        title: Text(
          "Academic Atelier",
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: Colors.black54)),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage('https://picsum.photos/id/237/200/200'),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtitle
            Text(
              "OUR CAMPUS JOURNEY",
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12),
            ),
            const SizedBox(height: 8),
            // Main Title
            const Text(
              "Academic Gallery",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 12),
            // Description
            const Text(
              "Explore the vibrant life at Academic Atelier, from state-of-the-art laboratories to our creative studios.",
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Filter Chips (Scrollable Row)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip("All Moments", isSelected: true),
                  _buildFilterChip("Sports"),
                  _buildFilterChip("Arts"),
                  _buildFilterChip("Labs"),
                  _buildFilterChip("Campus Life"),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Gallery Vertical Cards
            _buildGalleryCard(
              imageUrl: 'https://picsum.photos/id/26/600/400',
              tag: "SPORTS & WELLNESS",
              title: "Inter-School Championship Finals",
              desc: "Our varsity team securing the regional trophy in a thrilling performance.",
              color: const Color(0xFF1B2C3B),
            ),
            _buildGalleryCard(
              imageUrl: 'https://picsum.photos/id/674/600/400',
              tag: "INNOVATION LABS",
              title: "Advanced Chemistry Symposium",
              desc: "Students exploring molecular structures in our new research facility.",
              color: const Color(0xFF0F172A),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {},
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
        backgroundColor: Colors.grey[100],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildGalleryCard({
    required String imageUrl,
    required String tag,
    required String title,
    required String desc,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // Image Area
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Image.network(
              imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          // Content Area
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(tag, style: const TextStyle(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(desc, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}