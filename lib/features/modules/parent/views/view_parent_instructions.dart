import 'package:flutter/material.dart';
import 'package:met_school/providers/admin_provider.dart';
import 'package:provider/provider.dart';
// TODO: Import your specific provider here
// import 'package:met_school/providers/parent_provider.dart';

class ParentInstructionsScreen extends StatefulWidget {
  const ParentInstructionsScreen({Key? key}) : super(key: key);

  @override
  State<ParentInstructionsScreen> createState() => _ParentInstructionsScreenState();
}

class _ParentInstructionsScreenState extends State<ParentInstructionsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Replace 'ParentProvider' with whatever provider you use on the parent side
      context.read<AdminProvider>().fetchParentInstructions();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Replace 'ParentProvider' here as well
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("Instructions to Parents"),
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F766E)))
          : provider.parentInstructionsList.isEmpty
          ? _buildEmptyState()
          : _buildInstructionsList(provider.parentInstructionsList),
    );
  }

  /// 🔹 Empty State (In case the admin hasn't added anything yet)
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No instructions available yet.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// 🔹 The Mobile List View
  Widget _buildInstructionsList(List<String> instructions) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F766E).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              children: [
                Text(
                  "രക്ഷിതാക്കളോട്",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Important Instructions for Parents",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Instructions List
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(), // Let the SingleChildScrollView handle scrolling
              shrinkWrap: true,
              padding: const EdgeInsets.all(16),
              itemCount: instructions.length,
              separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Divider(color: Colors.grey.shade200, height: 1),
              ),
              itemBuilder: (context, index) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Number Bubble
                    Container(
                      margin: const EdgeInsets.only(top: 2, right: 16),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F766E).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F766E),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    // Malayalam Text
                    Expanded(
                      child: Text(
                        instructions[index],
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.6, // Good line height for easy Malayalam reading
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 30), // Bottom padding
        ],
      ),
    );
  }
}