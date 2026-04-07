import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:met_school/core/utils/navigation/navigation_helper.dart';
import 'package:provider/provider.dart';

import '../../../../providers/admin_provider.dart';
import 'academic_home/views/academic_home_screen.dart';

class AcademicYearScreen extends StatefulWidget {
  const AcademicYearScreen({super.key});

  @override
  State<AcademicYearScreen> createState() => _AcademicYearScreenState();
}

class _AcademicYearScreenState extends State<AcademicYearScreen> {
  final TextEditingController yearController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<AdminProvider>().fetchAcademicYears());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: Column(
        children: [

          /// ================= HEADER =================
          Container(
            height: 90,
            padding: const EdgeInsets.symmetric(horizontal: 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    context.read<AdminProvider>().setIndex(0); // 🔥 FIX
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 10),

                const Text(
                  "Academic Years",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const Spacer(),

                /// ✅ ADD BUTTON
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _openAddDialog,
                  icon: const Icon(Icons.add,
                      color: Color(0xFF0F766E)),
                  label: const Text(
                    "Add Academic Year",
                    style: TextStyle(
                        color: Color(0xFF0F766E),
                        fontWeight: FontWeight.w600),
                  ),
                )
              ],
            ),
          ),

          /// ================= BODY =================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30),

              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.academicYears.isEmpty
                  ? _emptyState()
                  : GridView.builder(
                itemCount:
                provider.academicYears.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 🔥 web layout
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 3,
                ),
                itemBuilder: (context, index) {
                  final doc =
                  provider.academicYears[index];
                  final data =
                  doc.data() as Map<String, dynamic>;

                  return _yearCard(doc.id, data);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= CARD =================
  Widget _yearCard(String id, Map<String, dynamic> data) {
    final isCurrent = data['is_current'] == true;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        callNext(AcademicYearHomeScreen(academicYearId: id,
          yearName: data['year_name'],), context);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isCurrent
                  ? const Color(0xFF14B8A6)
                  : Colors.grey.shade200,
              width: isCurrent ? 2 : 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 6),
            )
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// TOP ROW
            Row(
              children: [
                Expanded(
                  child: Text(
                    data['year_name'],
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),

                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Current",
                      style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                          fontSize: 12),
                    ),
                  )
              ],
            ),

            const SizedBox(height: 15),

            /// DATES
            Row(
              children: [
                const Icon(Icons.date_range,
                    size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${_formatDate(data['start_date'])} → ${_formatDate(data['end_date'])}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),

            const Spacer(),

            /// ACTION
            Align(
              alignment: Alignment.bottomRight,
              child: isCurrent
                  ? const SizedBox()
                  : TextButton(
                onPressed: () {
                  context
                      .read<AdminProvider>()
                      .setCurrentYear(id);
                },
                child: const Text("Set Current"),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// ================= ADD DIALOG =================
  void _openAddDialog() {
    DateTime? localStartDate = startDate;
    DateTime? localEndDate = endDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Container(
                padding: const EdgeInsets.all(25),
                width: 420,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// TITLE
                    const Text(
                      "Add Academic Year",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 20),

                    /// YEAR
                    TextField(
                      controller: yearController,
                      decoration: InputDecoration(
                        labelText: "Year Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// START DATE
                    _dateField(
                      label: "Start Date",
                      date: localStartDate,
                      onTap: () async {
                        final picked = await _pickDate(context);
                        if (picked != null) {
                          setStateDialog(() {
                            localStartDate = picked;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 15),

                    /// END DATE
                    _dateField(
                      label: "End Date",
                      date: localEndDate,
                      onTap: () async {
                        final picked = await _pickDate(context);
                        if (picked != null) {
                          setStateDialog(() {
                            localEndDate = picked;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 25),

                    /// ACTIONS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),

                        const SizedBox(width: 10),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F766E),
                          ),
                          onPressed: () {
                            if (yearController.text.isEmpty ||
                                localStartDate == null ||
                                localEndDate == null) return;

                            context.read<AdminProvider>().addAcademicYear(
                              yearName: yearController.text.trim(),
                              startDate: localStartDate!,
                              endDate: localEndDate!,
                            );

                            yearController.clear();
                            startDate = null;
                            endDate = null;

                            Navigator.pop(context);
                          },
                          child: const Text("Add",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  /// ================= EMPTY =================
  Widget _emptyState() {
    return const Center(
      child: Text(
        "No Academic Years Found",
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  Widget _dateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today,
                size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                date == null
                    ? label
                    : DateFormat('dd MMM yyyy').format(date),
                style: TextStyle(
                  color: date == null
                      ? Colors.grey
                      : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<DateTime?> _pickDate(BuildContext context) async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
  }

  String _formatDate(Timestamp timestamp) {
    return DateFormat('dd MMM yyyy')
        .format(timestamp.toDate());
  }
}