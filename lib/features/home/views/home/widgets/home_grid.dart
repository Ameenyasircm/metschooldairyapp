import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class SchoolHighlights extends StatelessWidget {
  const SchoolHighlights({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data - usually this would come from your Provider/Firestore
    final highlights = [
      {'title': 'Modern Labs', 'sub': 'Innovation first', 'img': 'https://www.gstatic.com/webp/gallery/1.jpg'},
      {'title': 'Athletics', 'sub': '', 'img': 'https://www.gstatic.com/webp/gallery/4.webp'},
      {'title': 'Fine Arts', 'sub': '', 'img': 'https://www.gstatic.com/webp/gallery/5.webp'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "School Life Highlights",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        GridView.custom(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverQuiltedGridDelegate(
            crossAxisCount: 2, // 2 columns
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            repeatPattern: QuiltedGridRepeatPattern.inverted,
            pattern: [
              const QuiltedGridTile(2, 1), // Tall: 2 rows high, 1 col wide (Modern Labs)
              const QuiltedGridTile(1, 1), // Square: 1 row high, 1 col wide (Athletics)
              const QuiltedGridTile(1, 1), // Square: 1 row high, 1 col wide (Fine Arts)
            ],
          ),
          childrenDelegate: SliverChildBuilderDelegate(
                (context, index) {
              final item = highlights[index];
              return HighlightTile(
                title: item['title']!,
                subtitle: item['sub']!,
                imageUrl: item['img']!,
              );
            },
            childCount: highlights.length,
          ),
        ),
      ],
    );
  }
}

class HighlightTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;

  const HighlightTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}