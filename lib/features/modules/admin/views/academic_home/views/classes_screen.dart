// ClassesScreen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/utils/navigation/navigation_helper.dart';
import '../../../../../../providers/academic_provider.dart';
import '../../../../../../providers/admin_provider.dart';
import 'divisionDashboard.dart';

class ClassesScreen extends StatefulWidget {
  final String academicYearId;
  final String academicYear;

  const ClassesScreen({super.key, required this.academicYearId, required this.academicYear});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  final TextEditingController classController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AcademicProvider>().fetchClasses());
  }

  @override
  Widget build(BuildContext context) {
    final academicProv = context.watch<AcademicProvider>();
    final adminProv = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          /// HEADER
          Container(
            height: 90,
            padding: const EdgeInsets.symmetric(horizontal: 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF0F766E), Color(0xFF14B8A6)]),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Classes & Divisions",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Spacer(),
              ],
            ),
          ),

          /// BODY
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: academicProv.isClassLoading || adminProv.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                itemCount: academicProv.classesList.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  mainAxisExtent: 180, // Increased height to show divisions
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemBuilder: (context, index) {
                  final doc = academicProv.classesList[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final String classId = doc.id;
                  final String className = data['name'] ?? "";

                  // Filter divisions for this specific class
                  final classDivs = adminProv.divisionsList.where((d) {
                    final dData = d.data() as Map<String, dynamic>;
                    return dData['class_id'] == classId;
                  }).toList();

                  return _buildActionableClassCard(classId, className, classDivs);
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionableClassCard(String classId, String className, List<dynamic> classDivs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.class_, color: Color(0xFF0F766E), size: 18),
              const SizedBox(width: 8),
              Text(className, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 24),
          const Text("Divisions", style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // List existing divisions
                ...classDivs.map((div) {
                  final divData = div.data() as Map<String, dynamic>;
                  return _divisionBadge(divData, className);
                }),

                // Add Division Button (if less than 2 divisions for small school)
                if (classDivs.length < 2)
                  InkWell(
                    onTap: () => _showAddDivisionDialog(classId, className),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.add, size: 16, color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divisionBadge(Map<String, dynamic> divData, String className) {
    return InkWell(
      onTap: () {
        callNext(
          DivisionDashboard(
            divisionId: divData['division_id'],
            divisionName: divData['division_name'],
            className: className,
            academicYearId: widget.academicYearId,
          ),
          context,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF0F766E).withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF0F766E).withOpacity(0.2)),
        ),
        child: Text(
          "Div ${divData['division_name']}",
          style: const TextStyle(color: Color(0xFF0F766E), fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showAddDivisionDialog(String classId, String className) {
    final nameCtrl = TextEditingController();
    final teacherIdCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Division to $className"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Division Name (A, B...)")),
            TextField(controller: teacherIdCtrl, decoration: const InputDecoration(labelText: "Class Teacher UID")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              context.read<AdminProvider>().addDivision(
                academicYearId: widget.academicYearId,
                classId: classId,
                className: className,
                divisionName: nameCtrl.text.trim(),
                classTeacherId: teacherIdCtrl.text.trim(),
                subjectTeachers: {},
              );
              Navigator.pop(context);
            },
            child: const Text("Create"),
          )
        ],
      ),
    );
  }
}