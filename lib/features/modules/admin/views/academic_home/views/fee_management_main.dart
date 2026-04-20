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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: feeProv.getDivisionsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                return GridView.builder(
                  padding: const EdgeInsets.all(25),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, crossAxisSpacing: 20, mainAxisSpacing: 20, childAspectRatio: 1.4,
                  ),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var div = snapshot.data!.docs[index];
                    return _DivisionTile(
                      id: div['division_id'],
                      name: "${div['class_name']} - ${div['division_name']}",
                      academicYearId: academicYearId, userId: userId, userName: userName,
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
  final String id, name, academicYearId,userId,userName;
  const _DivisionTile({required this.id, required this.name, required this.academicYearId,required this.userId,required this.userName});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => DivisionFeePage(divisionId: id, name: name, academicYearId: academicYearId, userId: userId, userName: userName,))),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFF1F5F9),
              child: Icon(Icons.class_outlined, color: Color(0xFF0F766E)),
            ),
            const SizedBox(height: 12),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}