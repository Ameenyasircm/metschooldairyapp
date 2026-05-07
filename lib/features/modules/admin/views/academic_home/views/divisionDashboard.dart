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

  // Theme Colors
  final Color primaryBlue = const Color(0xFF031937);
  final Color secondaryBlue = const Color(0xFF003865);
  final Color bgColor = const Color(0xFFF8FAFC);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- LOGIC PRESERVED ---
  Future<void> _bulkEnroll(List<String> selectedIds, List<Map<String, dynamic>> studentDetails) async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator(color: primaryBlue)),
    );

    try {
      for (var student in studentDetails) {
        final String sId = student['id'];
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
        Navigator.pop(context);
        Navigator.pop(context);
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

  Future<void> autoAssignRollNumbers(String divisionId, String academicYearId) async {
    final firestore = FirebaseFirestore.instance;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator(color: primaryBlue)),
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
        enrollmentList.add({'ref': doc.reference, 'name': name.toLowerCase()});
      }

      enrollmentList.sort((a, b) => a['name'].compareTo(b['name']));

      final batch = firestore.batch();
      for (int i = 0; i < enrollmentList.length; i++) {
        batch.update(enrollmentList[i]['ref'], {'roll_number': (i + 1)});
      }

      await batch.commit();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) Navigator.pop(context);
    }
  }

  void _showEnrollmentSelector() {
    List<String> selectedStudentIds = [];
    List<Map<String, dynamic>> selectedDetails = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.all(24),
          child: StatefulBuilder(builder: (context, setModalState) {
            return Column(
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 20),
                const Text("Enroll Students", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
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
                      if (students.isEmpty) return const Center(child: Text("All students are enrolled."));

                      return ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final s = students[index].data() as Map<String, dynamic>;
                          final sId = students[index].id;
                          final isSelected = selectedStudentIds.contains(sId);

                          return CheckboxListTile(
                            activeColor: secondaryBlue,
                            title: Text(s['name'] ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.w600)),
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
                  height: 55,
                  child: ElevatedButton(
                    onPressed: selectedStudentIds.isEmpty ? null : () => _bulkEnroll(selectedStudentIds, selectedDetails),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text("Enroll Selected", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            );
          }),
        );
      },
    );
  }

  // --- UI BUILDING ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Division ${widget.divisionName}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: primaryBlue)),
            Text("Class: ${widget.className}", style: TextStyle(fontSize: 12, color: primaryBlue.withOpacity(0.6))),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Auto-Assign Roll Numbers",
            icon: Icon(Icons.sort_by_alpha_rounded, color: primaryBlue),
            onPressed: () async {
              bool? confirm = await _showConfirmDialog();
              if (confirm == true) {
                await autoAssignRollNumbers(widget.divisionId, widget.academicYearId);
              }
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          _buildActionHeader(),
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
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
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

  Widget _buildActionHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Search Admission No...",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                filled: true,
                fillColor: bgColor,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: _showEnrollmentSelector,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: secondaryBlue,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: secondaryBlue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: const Row(
                children: [
                  Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text("Enroll", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        String studentName = studentSnap.hasData && studentSnap.data!.exists
            ? (studentSnap.data!.data() as Map<String, dynamic>)['name'] ?? "No Name"
            : "Loading...";

        return Container(
          margin: const EdgeInsets.only(top: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: secondaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                enrollData['roll_number']?.toString() ?? "-",
                style: TextStyle(color: secondaryBlue, fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ),
            title: Text(studentName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryBlue)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text("ADM: ${enrollData['enrollment_id']}", style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
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
          Icon(Icons.folder_open_rounded, size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text("No students found", style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Assign Roll Numbers?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("This will sort all enrolled students alphabetically and assign sequence numbers (1, 2, 3...)."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Assign", style: TextStyle(color: secondaryBlue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}