import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DivisionDashboard extends StatefulWidget {
  final String divisionId;
  final String divisionName;
  final String className;
  final String classId;
  final String academicYearId;
  final String classTeacherName;
  final String classTeacherId;

  const DivisionDashboard({
    super.key,
    required this.divisionId,
    required this.divisionName,
    required this.className,
    required this.classId,
    required this.academicYearId,
    required this.classTeacherName,
    required this.classTeacherId,
  });

  @override
  State<DivisionDashboard> createState() => _DivisionDashboardState();
}

class _DivisionDashboardState extends State<DivisionDashboard> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- BATCH ENROLLMENT ---
  Future<void> _bulkEnroll(List<String> selectedIds, List<Map<String, dynamic>> studentDetails) async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF0F766E))),
    );

    try {
      for (var student in studentDetails) {

        final String sId = student['id'];
        print(sId);

        final existing = await firestore
            .collection('enrollments')
            .where('student_id', isEqualTo: sId)
            .where('academic_year_id', isEqualTo: widget.academicYearId)
            .get();

        if (existing.docs.isNotEmpty) continue;

        DocumentReference enrollRef = firestore.collection('enrollments').doc();
        batch.set(enrollRef, {
          "student_id": sId,
          "student_name": student['name'],
          "academic_year_id": widget.academicYearId,
          "class_id": widget.classId,
          "class_name": widget.className,
          "division_id": widget.divisionId,
          "division_name": widget.divisionName,
          "enrollment_id": student['admissionId'] ?? "ENR-${DateTime.now().millisecondsSinceEpoch}",
          "parent_phone": student['phone'] ?? "",
          "parent_id": student['parentId'] ?? "",
          "roll_number": null,
          "status": "active",
          "createdAt": FieldValue.serverTimestamp(),
          "createdById": widget.classTeacherId,
          "createdByName": widget.classTeacherName,
        });

        DocumentReference studentRef = firestore.collection('students').doc(sId);
        batch.update(studentRef, {
          "isEnrolled": true,
          "current_academic_year": widget.academicYearId,
          "current_class_id": widget.classId,
          "enrollment_details": {
            "enrollment_doc_id": enrollRef.id,
            "enrolled_at": FieldValue.serverTimestamp(),
          }
        });
      }

      await batch.commit();
      if (mounted) {
        Navigator.pop(context); // Close progress loader
        Navigator.pop(context); // Close modal
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enrollment completed successfully!"), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // --- AUTO ASSIGN ROLL NUMBERS ---
  Future<void> autoAssignRollNumbers(String divisionId, String academicYearId) async {
    final firestore = FirebaseFirestore.instance;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF0F766E))),
    );

    try {
      final querySnapshot = await firestore.collection('enrollments')
          .where('division_id', isEqualTo: divisionId)
          .where('academic_year_id', isEqualTo: academicYearId)
          .get();

      List<Map<String, dynamic>> enrollmentList = [];

      for (var doc in querySnapshot.docs) {
        var studentDoc = await firestore.collection('students').doc(doc['student_id']).get();
        String name = (studentDoc.data() as Map<String, dynamic>?)?['name'] ?? "ZZZ";

        enrollmentList.add({
          'ref': doc.reference,
          'name': name.toLowerCase(),
        });
      }

      // Sort Alphabetically
      enrollmentList.sort((a, b) => a['name'].compareTo(b['name']));

      final batch = firestore.batch();
      for (int i = 0; i < enrollmentList.length; i++) {
        batch.update(enrollmentList[i]['ref'], {
          // CHANGED: Removed .padLeft(2, '0') to keep format as 1, 2, 3...
          'roll_number': (i + 1),
        });
      }

      await batch.commit();
      if (mounted) Navigator.pop(context); // Close loader
    } catch (e) {
      if (mounted) Navigator.pop(context);
      debugPrint("Sort Error: $e");
    }
  }

  Future<bool?> _showConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Assign Roll Numbers?"),
        content: const Text("This will sort all enrolled students alphabetically and assign roll numbers (01, 02, etc.)."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Assign", style: TextStyle(color: Color(0xFF0F766E), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- MODAL SELECTOR ---
  void _showEnrollmentSelector() {
    List<String> selectedStudentIds = [];
    List<Map<String, dynamic>> selectedDetails = [];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Select Students", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(height: 30),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('students')
                        .where('classId', isEqualTo: widget.classId)
                        .where('isEnrolled', isEqualTo: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final students = snapshot.data!.docs;
                      if (students.isEmpty) return const Center(child: Text("No students available for enrollment."));

                      return ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final s = students[index].data() as Map<String, dynamic>;
                          final sId = students[index].id;
                          final isSelected = selectedStudentIds.contains(sId);

                          return CheckboxListTile(
                            activeColor: const Color(0xFF0F766E),
                            title: Text(s['name'] ?? "Unknown"),
                            subtitle: Text("ADM: ${s['admissionId']}"),
                            value: isSelected,
                            onChanged: (bool? value) {
                              setModalState(() {
                                if (value == true) {
                                  selectedStudentIds.add(sId);
                                  selectedDetails.add({...s, 'id': sId});
                                } else {
                                  selectedStudentIds.remove(sId);
                                  selectedDetails.removeWhere((item) => item['id'] == sId);
                                }
                              });
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: selectedStudentIds.isEmpty ? null : () => _bulkEnroll(selectedStudentIds, selectedDetails),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F766E)),
                    child: const Text("Enroll Selected", style: TextStyle(color: Colors.white)),
                  ),
                )
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Division ${widget.divisionName}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            Text("Class: ${widget.className}", style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Assign Roll Numbers",
            icon: const Icon(Icons.sort_by_alpha, color: Color(0xFF0F766E)),
            onPressed: () async {
              bool? confirm = await _showConfirmDialog();
              if (confirm == true) {
                await autoAssignRollNumbers(widget.divisionId, widget.academicYearId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Roll numbers assigned alphabetically!"))
                  );
                }
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildHeaderSection(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('enrollments')
                  .where('academic_year_id', isEqualTo: widget.academicYearId)
                  .where('class_id', isEqualTo: widget.classId)
                  .where('division_id', isEqualTo: widget.divisionId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Error loading enrollments"));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                var docs = snapshot.data!.docs;
                if (_searchQuery.isNotEmpty) {
                  docs = docs.where((d) => d['enrollment_id'].toString().toLowerCase().contains(_searchQuery)).toList();
                }

                if (docs.isEmpty) return _emptyState();

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final enrollmentData = docs[index].data() as Map<String, dynamic>;
                    return _studentCard(enrollmentData);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Search ADM No...",
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              ),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: _showEnrollmentSelector,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: const Color(0xFF0F766E), borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.group_add_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text("Enroll", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _studentCard(Map<String, dynamic> enrollData) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('students').doc(enrollData['student_id']).get(),
      builder: (context, studentSnap) {
        String studentName = "Loading...";
        if (studentSnap.hasData && studentSnap.data!.exists) {
          studentName = (studentSnap.data!.data() as Map<String, dynamic>)['name'] ?? "No Name";
        }

        return Container(
          margin: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFF1F5F9),
              // The number will now show as 1, 2, 3 instead of 01, 02, 03
              child: Text(
                  enrollData['roll_number'].toString() ?? "-",
                  style: const TextStyle(
                      color: Color(0xFF0F766E),
                      fontWeight: FontWeight.bold,
                      fontSize: 14 // Slightly larger font for single digits
                  )
              ),
            ),
            title: Text(studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Text("ADM: ${enrollData['enrollment_id']}", style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            trailing: const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
          ),
        );
      },
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_off_rounded, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("No students enrolled in this division.", style: TextStyle(color: Color(0xFF64748B))),
        ],
      ),
    );
  }
}