import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../../providers/fee_provider.dart';
import 'division_fee_page.dart';

class FeeManagementMain extends StatelessWidget {
  final String academicYearId, academicYear, userId, userName;

  const FeeManagementMain({
    super.key,
    required this.academicYearId,
    required this.academicYear,
    required this.userName,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final feeProv = Provider.of<FeeProvider>(context);
    const Color primaryBlue = Color(0xFF031937);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Fee Management", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,

      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            color: Colors.white,
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text("Session: $academicYear", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 25, top: 25, right: 25),
            child: Text(
              "Divisions List",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryBlue),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: feeProv.getDivisionsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                return GridView.builder(
                  padding: const EdgeInsets.all(25),
                  // Grid sizing is reduced beautifully here by capping maximum card width width
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 260,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.6,
                  ),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var div = snapshot.data!.docs[index];
                    return _DivisionTile(
                      id: div['division_id'],
                      name: "${div['class_name']} - ${div['division_name']}",
                      academicYearId: academicYearId,
                      userId: userId,
                      userName: userName,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DivisionTile extends StatelessWidget {
  final String id, name, academicYearId, userId, userName;
  const _DivisionTile({
    required this.id,
    required this.name,
    required this.academicYearId,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF031937);

    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))]
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => DivisionFeePage(
                divisionId: id,
                name: name,
                academicYearId: academicYearId,
                userId: userId,
                userName: userName,
              ))),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.class_outlined, color: Color(0xFF0F766E), size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primaryBlue),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Collect Fees",
                        style: TextStyle(fontSize: 11, color: Colors.blueAccent, fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF94A3B8)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}