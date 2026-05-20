import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../../providers/fee_provider.dart';

class DivisionFeePage extends StatefulWidget {
  final String divisionId, name, academicYearId, userId, userName;
  const DivisionFeePage({
    super.key,
    required this.divisionId,
    required this.name,
    required this.academicYearId,
    required this.userId,
    required this.userName,
  });

  @override
  State<DivisionFeePage> createState() => _DivisionFeePageState();
}

class _DivisionFeePageState extends State<DivisionFeePage> {
  final List<String> installments = ["Inst 1", "Inst 2", "Inst 3", "Inst 4"];
  final List<String> months = [
    "June", "July", "August", "September", "October", "November",
    "December", "January", "February", "March", "April", "May"
  ];

  String selectedFeeStructure = "installment";
  String filterStatus = "ALL";
  String searchQuery = "";
  Color primaryBlue = const Color(0xFF031937);

  @override
  Widget build(BuildContext context) {
    final feeProv = Provider.of<FeeProvider>(context);
    final List<String> activeTabs = selectedFeeStructure == "installment" ? installments : months;

    return DefaultTabController(
      key: ValueKey(selectedFeeStructure),
      length: activeTabs.length,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC), // Brighter, modern structural background
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
          centerTitle: false,
          toolbarHeight: 80,

          title: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "Academic Year: ${widget.academicYearId}",
                      style: const TextStyle(fontSize: 11, color: Color(0xFF475569), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 45),

              // 1st Level Selection: Plan Mode Switcher
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _buildStructureModeToggle("installment", "Installment Plan"),
                    _buildStructureModeToggle("monthly", "Monthly Plan"),
                  ],
                ),
              ),
            ],
          ),
          // 2nd Level Selection: Nested Sub-tabs (Months or Installments) rendered below the type
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: primaryBlue,
            unselectedLabelColor: const Color(0xFF64748B),
            indicatorColor: primaryBlue,
            indicatorWeight: 3.5,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, fontFamily: 'sans-serif'),

            tabs: activeTabs.map((tabName) => Tab(text: tabName)).toList(),
          ),
        ),
        body: Column(
          children: [
            _buildWebDashboardHeader(),
            Expanded(
              child: TabBarView(
                children: activeTabs
                    .map((currentTab) => _buildStudentList(feeProv, currentTab))
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
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 340,
            height: 42,
            child: TextField(
              onChanged: (v) => setState(() => searchQuery = v),
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: "Search student by name...",
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 18),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: primaryBlue, width: 1.5),
                ),
              ),
            ),
          ),
          const Spacer(),
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
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isSelected
                          ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 2))]
                          : [],
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? primaryBlue : const Color(0xFF64748B),
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

  Widget _buildStructureModeToggle(String targetType, String labelText) {
    bool isCurrent = selectedFeeStructure == targetType;
    return InkWell(
      onTap: () => setState(() {
        selectedFeeStructure = targetType;
      }),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isCurrent ? primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          labelText,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
            color: isCurrent ? Colors.white : const Color(0xFF475569),
          ),
        ),
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

          // Exclude legacy unconfigured profiles entirely (prevents default leakage)
          if (!data.containsKey('fee_type') || data['fee_type'] == null) {
            return false;
          }

          String studentType = data['fee_type'].toString().toLowerCase();
          if (studentType != selectedFeeStructure) return false;

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
                Icon(Icons.folder_open_outlined, size: 64, color: Colors.blueAccent),
                const SizedBox(height: 16),
                Text(
                  "No records matched your selection structural filters.",
                  style: TextStyle(color: Colors.blueAccent, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          itemCount: docs.length,
          itemBuilder: (context, index) => _EnhancedStudentRow(
            docId: docs[index].id,
            data: docs[index].data() as Map<String, dynamic>,
            currentInst: currentInst,
            userName: widget.userName,
            userId: widget.userId,
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

  String _formatPaymentDate(dynamic rawDate) {
    if (rawDate == null) return "—";
    if (rawDate is Timestamp) {
      return DateFormat('dd MMM yyyy').format(rawDate.toDate());
    }
    return rawDate.toString();
  }

  @override
  Widget build(BuildContext context) {
    Color primaryBlue = const Color(0xFF031937);
    Map fees = data['fees'] ?? {};
    bool isPaid = fees.containsKey(currentInst);
    var paymentDetails = fees[currentInst];

    String displayType = data['fee_type'].toString().toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.015),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            // Student Profile Section
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFF1F5F9),
                    child: Text(
                      data['student_name']?[0] ?? "S",
                      style: const TextStyle(color: Color(0xFF031937), fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['student_name'] ?? "",
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF0F172A)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              "ID: ${data['enrollment_id'] ?? 'N/A'}",
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(4)
                              ),
                              child: Text(
                                displayType,
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1D4ED8),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Payment Status Pill
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPaid ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPaid ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                        size: 14,
                        color: isPaid ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isPaid ? "PAID" : "PENDING",
                        style: TextStyle(
                            color: isPaid ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Audit Data Log Field
            Expanded(
              flex: 4,
              child: isPaid
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatPaymentDate(paymentDetails['date']),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                  ),
                  if (paymentDetails['remark'] != null && paymentDetails['remark'] != "")
                    const SizedBox(height: 2),
                  if (paymentDetails['remark'] != null && paymentDetails['remark'] != "")
                    Text(
                      paymentDetails['remark'],
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              )
                  : const Text("—", style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
            ),

            // Operational Command Button
            ElevatedButton(
              onPressed: () => _showPaymentModal(context, isPaid, userId, userName),
              style: ElevatedButton.styleFrom(
                backgroundColor: isPaid ? Colors.white : primaryBlue,
                foregroundColor: isPaid ? primaryBlue : Colors.white,
                elevation: 0,
                side: BorderSide(color: isPaid ? const Color(0xFFCBD5E1) : Colors.transparent),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                isPaid ? "Manage Log" : "Collect Fee",
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentModal(BuildContext context, bool isPaid, String userId, String userName) {
    Color primaryBlue = const Color(0xFF031937);

    dynamic rawDate = isPaid ? data['fees'][currentInst]['date'] : null;
    DateTime initialDate = (rawDate is Timestamp) ? rawDate.toDate() : DateTime.now();
    DateTime selectedDate = initialDate;

    TextEditingController remarkCtrl = TextEditingController(
      text: isPaid ? data['fees'][currentInst]['remark'] : "",
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          titlePadding: const EdgeInsets.only(left: 24, top: 24, right: 24, bottom: 8),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          actionsPadding: const EdgeInsets.all(24),
          title: Text(
            "$currentInst Collection Registry",
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF0F172A)),
          ),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(color: Color(0xFFE2E8F0)),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2025),
                      lastDate: DateTime(2027),
                    );
                    if (picked != null) setDialogState(() => selectedDate = picked);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, color: Color(0xFF475569), size: 20),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Date of Collection", style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('dd MMMM yyyy').format(selectedDate),
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1E293B)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Remarks / Auditing Text", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                const SizedBox(height: 6),
                TextField(
                  controller: remarkCtrl,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: "E.g., Bank Ref ID, Receipt book voucher index...",
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
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
                    paymentDate: selectedDate,
                    userId: userId,
                    userName: userName,
                  );
                  Navigator.pop(context);
                },
                child: const Text("Reset to Pending", style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w700)),
              ),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Provider.of<FeeProvider>(context, listen: false).updateInstallment(
                  docId: docId,
                  installmentKey: currentInst,
                  isPaid: true,
                  paymentDate: selectedDate,
                  remark: remarkCtrl.text,
                  userId: userId,
                  userName: userName,
                );
                Navigator.pop(context);
              },
              child: const Text("Confirm Settlement", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}