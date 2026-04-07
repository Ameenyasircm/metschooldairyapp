import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/utils/navigation/navigation_helper.dart';
import '../../../../../../providers/admin_provider.dart';
import 'divisionDashboard.dart';

class ClassDivisionsScreen extends StatefulWidget {
  final String classId;
  final String className;
  final String academicYear;
  final String academicYearId;

  const ClassDivisionsScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.academicYear,
    required this.academicYearId,
  });

  @override
  State<ClassDivisionsScreen> createState() => _ClassDivisionsScreenState();
}

class _ClassDivisionsScreenState extends State<ClassDivisionsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch divisions specific to this class and academic year
    Future.microtask(() => context.read<AdminProvider>().fetchDivisions(
      widget.classId,
      widget.academicYearId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Class ${widget.className} - Divisions",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Academic Year: ${widget.academicYear}",
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20, top: 8, bottom: 8),
            child: ElevatedButton.icon(
              onPressed: () => _showAddDivisionDialog(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Create Division"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(40),
        child: provider.divisionsList.isEmpty
            ? _buildEmptyState()
            : GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 350,
            mainAxisExtent: 160,
            crossAxisSpacing: 25,
            mainAxisSpacing: 25,
          ),
          itemCount: provider.divisionsList.length,
          itemBuilder: (context, index) {
            final doc = provider.divisionsList[index];
            final data = doc.data() as Map<String, dynamic>;

            return _buildDivisionCard(data);
          },
        ),
      ),
    );
  }

  Widget _buildDivisionCard(Map<String, dynamic> data) {
    return InkWell(
      onTap: (){
        callNext(
          DivisionDashboard(
            divisionId: data['division_id'],
            divisionName: data['division_name'],
            className: widget.className,
            academicYearId: widget.academicYearId,
          ),
          context,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Division ${data['division_name']}",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const Icon(Icons.more_vert, color: Colors.grey, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 14, color: Colors.blueGrey),
                const SizedBox(width: 6),
                Text("Teacher ID: ${data['class_teacher_id'] ?? 'Not Set'}",
                    style: const TextStyle(fontSize: 13, color: Colors.blueGrey)),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
              child: Text(
                "${(data['subject_teachers'] as Map? ?? {}).length} Subjects Assigned",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F766E)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.layers_clear_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("No Divisions Found", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text("Add a division to start managing subjects and teachers."),
        ],
      ),
    );
  }

  /// ================= ADD DIVISION DIALOG =================
  void _showAddDivisionDialog(BuildContext context) {
    final nameController = TextEditingController();
    final teacherIdController = TextEditingController();

    // For subject_teachers map
    final subjectNameController = TextEditingController();
    final subjectTeacherIdController = TextEditingController();
    Map<String, String> tempSubjectMap = {};

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Create New Division", style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _dialogTextField("Division Name (e.g., A)", nameController),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _dialogTextField("Class Teacher UID", teacherIdController),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(),
                  ),
                  const Text("Assign Subject Teachers", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 10),

                  // Subject Adding Row
                  Row(
                    children: [
                      Expanded(child: _dialogTextField("Subject", subjectNameController)),
                      const SizedBox(width: 10),
                      Expanded(child: _dialogTextField("Teacher UID", subjectTeacherIdController)),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () {
                          if (subjectNameController.text.isNotEmpty) {
                            setDialogState(() {
                              tempSubjectMap[subjectNameController.text.trim()] =
                                  subjectTeacherIdController.text.trim();
                              subjectNameController.clear();
                              subjectTeacherIdController.clear();
                            });
                          }
                        },
                        icon: const Icon(Icons.add_circle, color: Color(0xFF0F766E)),
                      )
                    ],
                  ),

                  const SizedBox(height: 15),

                  // Display added subjects as Chips
                  Wrap(
                    spacing: 8,
                    children: tempSubjectMap.entries.map((entry) {
                      return Chip(
                        label: Text("${entry.key}: ${entry.value}"),
                        backgroundColor: const Color(0xFFF1F5F9),
                        onDeleted: () => setDialogState(() => tempSubjectMap.remove(entry.key)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F766E), foregroundColor: Colors.white),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  context.read<AdminProvider>().addDivision(
                    academicYearId: widget.academicYearId,
                    classId: widget.classId,
                    className: widget.className,
                    divisionName: nameController.text.trim(),
                    classTeacherId: teacherIdController.text.trim(),
                    subjectTeachers: tempSubjectMap,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text("Save Division"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}