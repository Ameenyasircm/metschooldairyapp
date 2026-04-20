import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../../providers/fee_provider.dart';

class DivisionFeePage extends StatefulWidget {
  final String divisionId, name, academicYearId, userId, userName; // Added user fields
  const DivisionFeePage({
    super.key,
    required this.divisionId,
    required this.name,
    required this.academicYearId,
    required this.userId,   // Initialize
    required this.userName, // Initialize
  });

  @override
  State<DivisionFeePage> createState() => _DivisionFeePageState();
}

class _DivisionFeePageState extends State<DivisionFeePage> {
  final List<String> installments = ["Inst 1", "Inst 2", "Inst 3", "Inst 4"];
  String filterStatus = "ALL";
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final feeProv = Provider.of<FeeProvider>(context);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9), // Modern Slate Background
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
          centerTitle: false,
          title: Text(
            widget.name,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
          ),
          bottom: TabBar(
            labelColor: const Color(0xFF0F766E),
            unselectedLabelColor:  Colors.blueAccent,
            indicatorColor: const Color(0xFF0F766E),
            indicatorWeight: 4,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: installments.map((inst) => Tab(text: inst)).toList(),
          ),
        ),
        body: Column(
          children: [
            _buildWebDashboardHeader(),
            Expanded(
              child: TabBarView(
                children: installments
                    .map((inst) => _buildStudentList(feeProv, inst))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebDashboardHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          // Search Bar
          SizedBox(
            width: 350,
            child: TextField(
              onChanged: (v) => setState(() => searchQuery = v),
              decoration: InputDecoration(
                hintText: "Search student name...",
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent, size: 20),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
          ),
          const Spacer(),
          // Custom Segmented Filter
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: ["ALL", "PAID", "PENDING"].map((status) {
                bool isSelected = filterStatus == status;
                return InkWell(
                  onTap: () => setState(() => filterStatus = status),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isSelected
                          ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]
                          : [],
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color(0xFF0F766E) : Colors.blueAccent,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList(FeeProvider prov, String currentInst) {
    return StreamBuilder<QuerySnapshot>(
      stream: prov.getEnrollmentsStream(widget.divisionId, widget.academicYearId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        var docs = snapshot.data!.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          Map fees = data['fees'] as Map? ?? {};
          bool isPaid = fees.containsKey(currentInst);
          bool matchesSearch = data['student_name']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase());

          if (filterStatus == "PAID") return matchesSearch && isPaid;
          if (filterStatus == "PENDING") return matchesSearch && !isPaid;
          return matchesSearch;
        }).toList();

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_search_outlined, size: 60, color:  Colors.blueAccent),
                const SizedBox(height: 10),
                const Text("No students found", style: TextStyle(color:  Colors.blueAccent)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          itemCount: docs.length,
          itemBuilder: (context, index) => _EnhancedStudentRow(
            docId: docs[index].id,
            data: docs[index].data() as Map<String, dynamic>,
            currentInst: currentInst, userName: widget.userName, userId: widget.userId,
          ),
        );
      },
    );
  }
}

class _EnhancedStudentRow extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;
  final String currentInst;
  final String userName;
  final String userId;

  const _EnhancedStudentRow({
    required this.docId,
    required this.data,
    required this.currentInst,
    required this.userName,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    Map fees = data['fees'] ?? {};
    bool isPaid = fees.containsKey(currentInst);
    var paymentDetails = fees[currentInst];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            // Student Name & ADM
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFFF1F5F9),
                    child: Text(
                      data['student_name']?[0] ?? "S",
                      style: const TextStyle(color: Color(0xFF0F766E), fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['student_name'] ?? "",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
                      ),
                      Text(
                        "ADM: ${data['enrollment_id'] ?? 'N/A'}",
                        style: const TextStyle(fontSize: 12, color: Colors.blueAccent),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Status Badge
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPaid ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPaid ? Icons.check_circle : Icons.error_outline,
                        size: 14,
                        color: isPaid ? const Color(0xFF166534) : const Color(0xFF991B1B),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isPaid ? "PAID" : "PENDING",
                        style: TextStyle(
                          color: isPaid ? const Color(0xFF166534) : const Color(0xFF991B1B),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Payment Info
            Expanded(
              flex: 3,
              child: isPaid
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Date: ${paymentDetails['date']}",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  if (paymentDetails['remark'] != "")
                    Text(
                      paymentDetails['remark'],
                      style: const TextStyle(fontSize: 11, color: Colors.blueAccent),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              )
                  : const Text("—", style: TextStyle(color:  Colors.blueAccent)),
            ),
            // Actions
            ElevatedButton(
              onPressed: () => _showPaymentModal(context, isPaid,userId,userName),
              style: ElevatedButton.styleFrom(
                backgroundColor: isPaid ? Colors.white : const Color(0xFF0F766E),
                foregroundColor: isPaid ? const Color(0xFF0F766E) : Colors.white,
                elevation: 0,
                side: isPaid ? const BorderSide(color: Color(0xFF0F766E)) : BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                isPaid ? "Manage" : "Collect Fee",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentModal(BuildContext context, bool isPaid,String userId,String userName) {
    DateTime selectedDate = DateTime.now();
    TextEditingController remarkCtrl = TextEditingController(
      text: isPaid ? data['fees'][currentInst]['remark'] : "",
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "$currentInst Collection",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Date of Payment", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(DateFormat('dd-MM-yyyy').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_month, color: Color(0xFF0F766E)),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2025),
                      lastDate: DateTime(2027),
                    );
                    if (picked != null) setDialogState(() => selectedDate = picked);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: remarkCtrl,
                  decoration: InputDecoration(
                    labelText: "Remarks / Reference",
                    hintText: "Receipt No, Mode, etc.",
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            if (isPaid)
              TextButton(
                onPressed: () {
                  Provider.of<FeeProvider>(context, listen: false).updateInstallment(
                    docId: docId,
                    installmentKey: currentInst,
                    isPaid: false,
                    paymentDate: selectedDate, userId:userId , userName: userName,
                  );
                  Navigator.pop(context);
                },
                child: const Text("Reset to Pending", style: TextStyle(color: Colors.red)),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Provider.of<FeeProvider>(context, listen: false).updateInstallment(
                  docId: docId,
                  installmentKey: currentInst,
                  isPaid: true,
                  paymentDate: selectedDate,
                  remark: remarkCtrl.text, userId: userId, userName: userName,
                );
                Navigator.pop(context);
              },
              child: const Text("Confirm Payment", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}