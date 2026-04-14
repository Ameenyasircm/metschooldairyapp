import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParentMasterDirectory extends StatelessWidget {
  const ParentMasterDirectory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("PARENT-STUDENT MAPPING",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('parents').orderBy('updatedAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final parentDocs = snapshot.data!.docs;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
              ),
              child: DataTable(
                headingRowHeight: 60,
                dataRowMaxHeight: 120, // Increased for multiple sibling rows
                horizontalMargin: 20,
                columnSpacing: 40,
                columns: const [
                  DataColumn(label: Text("GUARDIAN DETAILS", style: _headerStyle)),
                  DataColumn(label: Text("LINKED STUDENTS", style: _headerStyle)),
                  DataColumn(label: Text("CONNECT", style: _headerStyle)),
                ],
                rows: parentDocs.map((doc) {
                  final parentData = doc.data() as Map<String, dynamic>;
                  final List studentIds = parentData['studentIds'] ?? [];

                  return DataRow(cells: [
                    // --- COLUMN 1: PARENT DATA ---
                    DataCell(Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(parentData['parentName'] ?? "N/A",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                          const SizedBox(height: 4),
                          Text("UID: ${parentData['parentUid']}",
                              style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontFamily: 'monospace')),
                        ],
                      ),
                    )),

                    // --- COLUMN 2: STUDENT DATA (DETAILED) ---
                    DataCell(SizedBox(
                      width: 450,
                      child: _buildStudentDetailRows(studentIds),
                    )),

                    // --- COLUMN 3: PHONE / LOGIN ---
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Text(parentData['phone'] ?? "N/A",
                          style: const TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.w700, fontSize: 13)),
                    )),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  // Build vertical rows for students belonging to the same parent
  Widget _buildStudentDetailRows(List ids) {
    if (ids.isEmpty) return const Text("No children linked", style: TextStyle(color: Colors.grey, fontSize: 12));

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ids.map((id) => FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('students').doc(id).get(),
        builder: (context, snap) {
          if (!snap.hasData) return const LinearProgressIndicator(minHeight: 1);
          final s = snap.data!.data() as Map<String, dynamic>?;
          if (s == null) return const SizedBox();

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFCBD5E1), width: 0.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.school, size: 14, color: Color(0xFF0F766E)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(s['name'] ?? "N/A",
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ),
                _miniBadge("ADM: ${s['admissionId']}", Colors.orange.shade800),
                const SizedBox(width: 8),
                _miniBadge("ID: $id", Colors.blue.shade800),
              ],
            ),
          );
        },
      )).toList(),
    );
  }

  Widget _miniBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color, fontFamily: 'monospace')),
    );
  }

  static const _headerStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w900,
      color: Color(0xFF475569),
      letterSpacing: 1
  );
}