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
  final String userId;
  final String userName;

  const ClassesScreen({
    super.key,
    required this.academicYearId,
    required this.academicYear,
    required this.userName,
    required this.userId
  });

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  final TextEditingController classController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AcademicProvider>().fetchClasses();
      // Fetch initial divisions to ensure the grid is populated
      // Assuming fetchDivisions exists or divisions are loaded via a stream/listener
    });
  }

  /// Helper to show delete confirmation for a division
  void _showDeleteConfirmation(Map<String, dynamic> divData) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar for better UX
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              "Delete Division ${divData['division_name']}?",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            Text(
              "This will unassign ${divData['class_teacher_name']} and remove this division from className. This action cannot be undone.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 32),

            // Primary Action: Delete (TextButton for a cleaner look)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<AdminProvider>().deleteDivision(
                    divisionId: divData['division_id'],
                    classId: divData['class_id'],
                    academicYearId: widget.academicYearId,
                    teacherId: divData['class_teacher_id'],
                    adminId: widget.userId,
                    adminName: widget.userName,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Delete Division", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 8),

            // Secondary Action: Cancel
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text("Keep Division", style: TextStyle(color: Colors.grey.shade700)),
              ),
            ),
          ],
        ),
      ),
    );
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
                // Use the new formatted list
                itemCount: academicProv.formattedClasses.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  mainAxisExtent: 180,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemBuilder: (context, index) {
                  // Access the Map directly
                  final classMap = academicProv.formattedClasses[index];
                  final String classId = classMap['id'] ?? "";
                  final String className = classMap['name'] ?? "";

                  // Filter divisions using the classId
                  // Note: Ensure adminProv.divisionsList still uses DocumentSnapshots
                  // or update it similarly to formattedClasses for consistency.
                  final classDivs = adminProv.divisionsList.where((d) {
                    final dData = d.data() as Map<String, dynamic>;
                    // Use .toString() to ensure comparison works even if types vary
                    return dData['class_id'].toString() == classId;
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

                // Add Division Button (if less than 2 divisions)
                if (classDivs.length < 2)
                  InkWell(
                    onTap: () {
                      context.read<AdminProvider>().fetchAllTeachers();
                      _showAddDivisionDialog(classId, className);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.add, size: 16, color: Colors.grey),
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divisionBadge(Map<String, dynamic> divData, String className) {
    return InkWell(
      // Navigate on Tap - Passing all relevant data
      onTap: () {
        callNext(
          DivisionDashboard(
            divisionId: divData['division_id'],
            divisionName: divData['division_name'],
            className: className,
            academicYearId: widget.academicYearId,
            classTeacherName: divData['class_teacher_name'],
            classTeacherId: divData['class_teacher_id'],
          ),
          context,
        );
      },
      // Delete functionality on Long Press
      onLongPress: () => _showDeleteConfirmation(divData),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF0F766E).withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF0F766E).withOpacity(0.2)),
        ),
        child: Text(
          "Div ${divData['division_name']}",
          style: const TextStyle(
              color: Color(0xFF0F766E),
              fontSize: 12,
              fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }

  void _showAddDivisionDialog(String classId, String className) {
    final nameCtrl = TextEditingController();
    String? selectedTeacherId;
    String? selectedTeacherName;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final prov = context.watch<AdminProvider>();

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text("Add Division to $className",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Division Name",
                    hintText: "e.g., A, B, or C",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (val) => setDialogState(() {}),
                ),
                const SizedBox(height: 20),
                if (prov.allTeachers.isEmpty && prov.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                  )
                else if (prov.allTeachers.isEmpty)
                  const Text(
                    "No teachers found. Add staff first.",
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  )
                else
                  DropdownButtonFormField<String>(
                    value: selectedTeacherId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: "Select Class Teacher",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    hint: const Text("Select Teacher", style: TextStyle(fontSize: 14)),
                    items: prov.allTeachers.map((t) {
                      return DropdownMenuItem(
                        value: t['uid'].toString(),
                        child: Text(t['name'], style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setDialogState(() {
                        selectedTeacherId = val;
                        selectedTeacherName = prov.allTeachers
                            .firstWhere((t) => t['uid'] == val)['name'];
                      });
                    },
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: (selectedTeacherId == null || nameCtrl.text.trim().isEmpty)
                    ? null
                    : () async {
                  // 1. Create the division and wait for completion
                  await prov.addDivision(
                    academicYearId: widget.academicYearId,
                    classId: classId,
                    className: className,
                    divisionName: nameCtrl.text.trim().toUpperCase(),
                    classTeacherId: selectedTeacherId!,
                    classTeacherName: selectedTeacherName!,
                    adminId: widget.userId,
                    adminName: widget.userName,
                    subjectTeachers: {},
                  );

                  if (!mounted) return;
                  Navigator.pop(context); // Close Dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Create Division"),
              ),
            ],
          );
        },
      ),
    );
  }
}