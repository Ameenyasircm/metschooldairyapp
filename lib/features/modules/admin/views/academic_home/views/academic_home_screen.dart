import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:met_school/providers/academic_provider.dart';
import 'package:met_school/providers/academic_provider.dart';
import 'package:met_school/providers/academic_provider.dart';
import 'package:provider/provider.dart';

import '../../../../../../providers/admin_provider.dart';
import 'classes_screen.dart';

class AcademicYearHomeScreen extends StatelessWidget {
  final String academicYearId;
  final String yearName;

  const AcademicYearHomeScreen({
    super.key,
    required this.academicYearId,
    required this.yearName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: Column(
        children: [

          /// HEADER
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
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back,
                      color: Colors.white),
                ),

                const SizedBox(width: 10),

                Text(
                  yearName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          /// BODY
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 25,
                mainAxisSpacing: 25,
                childAspectRatio: 2.5,
                children: [

                  _moduleCard(
                    context,
                    title: "Classes",
                    icon: Icons.class_,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClassesScreen(
                            academicYearId: academicYearId,
                          ),
                        ),
                      );
                    },
                  ),

                  _moduleCard(
                    context,
                    title: "Students",
                    icon: Icons.school,
                    color: Colors.green,
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) => const StudentListScreen(),
                      //   ),
                      // );
                    },
                  ),

                  _moduleCard(
                    context,
                    title: "Teachers",
                    icon: Icons.people,
                    color: Colors.orange,
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) => const TeacherListScreen(),
                      //   ),
                      // );
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _moduleCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: color),
            const Spacer(),
            Text(title,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text("Manage $title",
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}