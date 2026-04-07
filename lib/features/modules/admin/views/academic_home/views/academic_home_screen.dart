import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:met_school/providers/academic_provider.dart';
import 'package:met_school/providers/academic_provider.dart';
import 'package:met_school/providers/academic_provider.dart';
import 'package:provider/provider.dart';

import '../../../../../../providers/admin_provider.dart';


class AcademicYearHomeScreen extends StatefulWidget {
  final String academicYearId;
  final String yearName;

  const AcademicYearHomeScreen({
    super.key,
    required this.academicYearId,
    required this.yearName,
  });

  @override
  State<AcademicYearHomeScreen> createState() =>
      _AcademicYearHomeScreenState();
}

class _AcademicYearHomeScreenState
    extends State<AcademicYearHomeScreen> {
  final TextEditingController classController =
  TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
            () => context.read<AcademicProvider>().fetchClasses());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademicProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: Column(
        children: [

          /// ================= HEADER =================
          Container(
            height: 90,
            padding: const EdgeInsets.symmetric(horizontal: 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    context.read<AdminProvider>().setIndex(0); // 🔥 FIX
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),

                const SizedBox(width: 10),

                Text(
                  widget.yearName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(width: 10),

                const Text(
                  "• Classes",
                  style: TextStyle(color: Colors.white70),
                ),

                const Spacer(),

                /// ADD CLASS
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  onPressed: _openAddClassDialog,
                  icon: const Icon(Icons.add,
                      color: Color(0xFF0F766E)),
                  label: const Text(
                    "Add Class",
                    style:
                    TextStyle(color: Color(0xFF0F766E)),
                  ),
                )
              ],
            ),
          ),

          /// ================= BODY =================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30),

              child: provider.isClassLoading
                  ? const Center(
                  child: CircularProgressIndicator())
                  : provider.classesList.isEmpty
                  ? const Center(
                  child: Text("No Classes Found"))
                  : GridView.builder(
                itemCount:
                provider.classesList.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5, // 🔥 more compact
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.5,
                ),
                itemBuilder: (context, index) {
                  final doc =
                  provider.classesList[index];
                  final data =
                  doc.data() as Map<String, dynamic>;

                  return _classCard(data);
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  /// ================= CLASS CARD =================
  Widget _classCard(Map<String, dynamic> data) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        /// 👉 Next: Sections / Students screen
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border:
          Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),

        child: Row(
          children: [
            Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                color: const Color(0xFF14B8A6)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.class_,
                  color: Color(0xFF0F766E), size: 18),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                data['name'] ?? "",
                style: const TextStyle(
                    fontWeight: FontWeight.w600,color: Colors.black),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// ================= ADD CLASS DIALOG =================
  void _openAddClassDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Class"),
          content: TextField(
            controller: classController,
            decoration:
            const InputDecoration(labelText: "Class Name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (classController.text.isEmpty) return;

                context.read<AcademicProvider>().addClass(
                  classController.text.trim(),
                );

                classController.clear();
                Navigator.pop(context);
              },
              child: const Text("Add"),
            )
          ],
        );
      },
    );
  }
}