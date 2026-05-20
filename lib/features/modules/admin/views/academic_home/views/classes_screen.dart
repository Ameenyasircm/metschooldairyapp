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
  Color primaryBlue = const Color(0xFF031937);
  Color secondaryBlue = const Color(0xFF003865);
  Color bgColor = const Color(0xFFF8FAFC); // Brighter slate for a premium interface backdrop

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AcademicProvider>().fetchClasses();
    });
  }

  /// Helper to show delete confirmation for a division
  void _showDeleteConfirmation(Map<String, dynamic> divData) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Delete Division ${divData['division_name']}?",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),
            Text(
              "This will unassign ${divData['class_teacher_name']} and remove this division from className. This action cannot be undone.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 24),
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
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Delete Division", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Keep Division", style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w600)),
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
      backgroundColor: bgColor,
      body: Column(
        children: [
          /// HEADER
          Container(
            height: 80, // Optimized tracking size
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryBlue, const Color(0xFF0F2942)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Classes & Divisions Directory",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5),
                ),
                const Spacer(),
              ],
            ),
          ),

          /// BODY
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: academicProv.isClassLoading || adminProv.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                itemCount: academicProv.formattedClasses.length,
                // Grid sizing constraint optimization payload
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 260, // Reduced from 300 to shrink card sizes beautifully
                  mainAxisExtent: 155,     // Tailored down from 180 to keep alignment compact
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final classMap = academicProv.formattedClasses[index];
                  final String classId = classMap['id'] ?? "";
                  final String className = classMap['name'] ?? "";

                  final classDivs = adminProv.divisionsList.where((d) {
                    final dData = d.data() as Map<String, dynamic>;
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.school_rounded, color: primaryBlue, size: 14),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  className,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          const Text("ACTIVE DIVISIONS", style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          const SizedBox(height: 10),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ...classDivs.map((div) {
                  final divData = div.data() as Map<String, dynamic>;
                  return _divisionBadge(divData, className);
                }),

                if (classDivs.length < 4)
                  InkWell(
                    onTap: () {
                      context.read<AdminProvider>().fetchAllTeachers();
                      _showAddDivisionDialog(classId, className);
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.add_rounded, size: 14, color: Color(0xFF64748B)),
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
      onTap: () {
        callNext(
          DivisionDashboard(
            divisionId: divData['division_id'],
            divisionName: divData['division_name'],
            className: className,
            academicYearId: widget.academicYearId,
            classTeacherName: divData['class_teacher_name'],
            classTeacherId: divData['class_teacher_id'],
            classId: divData['class_id'],
          ),
          context,
        );
      },
      onLongPress: () => _showDeleteConfirmation(divData),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Text(
          "Div ${divData['division_name']}",
          style: TextStyle(
            color: primaryBlue,
            fontSize: 11,
            fontWeight: FontWeight.w800,
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
            title: Text(
              "Add Division to $className",
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF0F172A)),
            ),
            content: SizedBox(
              width: 380,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 12),
                  const Text("Division Identifier Tag", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameCtrl,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "e.g., A, B, or C",
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.all(12),
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (val) => setDialogState(() {}),
                  ),
                  const SizedBox(height: 16),
                  const Text("Assign Classroom Teacher", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                  const SizedBox(height: 6),
                  if (prov.allTeachers.isEmpty && prov.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    )
                  else if (prov.allTeachers.isEmpty)
                    const Text(
                      "No teachers found. Add staff first.",
                      style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500),
                    )
                  else
                    DropdownButtonFormField<String>(
                      value: selectedTeacherId,
                      isExpanded: true,
                      style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                      hint: const Text("Select Teacher", style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8))),
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
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              ),
              ElevatedButton(
                onPressed: (selectedTeacherId == null || nameCtrl.text.trim().isEmpty)
                    ? null
                    : () async {
                  await prov.addDivision(
                    academicYearId: widget.academicYearId,
                    classId: classId,
                    className: className,
                    divisionName: nameCtrl.text.trim().toUpperCase(),
                    classTeacherId: selectedTeacherId!,
                    classTeacherName: selectedTeacherName!,
                    adminId: widget.userId,
                    adminName: widget.userName,
                    subjectTeachers: const {},
                  );

                  if (!mounted) return;
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: const Text("Create Division", style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          );
        },
      ),
    );
  }
}