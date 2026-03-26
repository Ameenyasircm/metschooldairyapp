import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../home_provider.dart';
// import '../home_provider.dart';

class WinnerCarousel extends StatelessWidget {
  const WinnerCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        if (provider.winners.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return SizedBox(
          height: 100, // Fixed height for the carousel
          child: PageView.builder(
            controller: provider.pageController,
            itemCount: provider.winners.length,
            itemBuilder: (context, index) {
              final achiever = provider.winners[index];
              return AnimatedBuilder(
                animation: provider.pageController,
                builder: (context, child) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          achiever.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(width: 60, height: 60, color: Colors.grey.shade300),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              achiever.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              achiever.aggregate,
                              style: const TextStyle(color: Color(0xff00796B), fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      // Optional Tag like "MATH PRI" from design
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xff00796B),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          achiever.tag,
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}