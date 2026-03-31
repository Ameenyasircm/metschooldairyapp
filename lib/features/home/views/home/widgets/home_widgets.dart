import 'package:flutter/material.dart';

import '../../../../../data/models/winner_model.dart';


class QuickActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap; // 👈 add this

  const QuickActionIcon({super.key, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector( // 👈 wrap with GestureDetector
      onTap: onTap,child:
    Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xffE0F2F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xff00796B)),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final SchoolEvent event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffF5FBF9),
        borderRadius: BorderRadius.circular(15),
        // Adding a very subtle border to match the premium "Atelier" look
        border: Border.all(color: const Color(0xffE0F2F1), width: 1),
      ),
      child: Row(
        children: [
          // Date Box
          SizedBox(
            width: 45, // Fixed width keeps the layout aligned
            child: Column(
              children: [
                Text(
                  event.day,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff00796B),
                  ),
                ),
                Text(
                  event.month.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // Vertical Divider decoration
          Container(
            height: 30,
            width: 1,
            color: Colors.grey.withOpacity(0.2),
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),

          // Event Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xff2A3532), // Dark green text
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      "${event.time} • ${event.location}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Icon(
            Icons.arrow_forward_ios,
            color: Color(0xff00796B),
            size: 14,
          ),
        ],
      ),
    );
  }
}