import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../providers/admin_provider.dart';

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
      backgroundColor: const Color(0xFFF3F4F6),

      body: Column(
        children: [

          /// 🔥 HEADER (MATCH LOGIN THEME)
          Container(
            height: 120,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Academic Year Management",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          /// BODY
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// ================= LEFT (FORM) =================
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      decoration: _cardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Add Academic Year",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),

                          /// YEAR NAME
                          TextField(
                            controller: yearController,
                            decoration: InputDecoration(
                              labelText: "Year Name",
                              hintText: "e.g. 2026-27",
                              border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(10),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// START DATE
                          _dateField(
                            label: "Start Date",
                            date: startDate,
                            onTap: () async {
                              startDate = await _pickDate(context);
                              setState(() {});
                            },
                          ),

                          const SizedBox(height: 20),

                          /// END DATE
                          _dateField(
                            label: "End Date",
                            date: endDate,
                            onTap: () async {
                              endDate = await _pickDate(context);
                              setState(() {});
                            },
                          ),

                          const SizedBox(height: 30),

                          /// ADD BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                const Color(0xFF0F766E),
                              ),
                              onPressed: () {
                                if (yearController.text.isEmpty ||
                                    startDate == null ||
                                    endDate == null) return;

                                context
                                    .read<AdminProvider>()
                                    .addAcademicYear(
                                  yearName:
                                  yearController.text.trim(),
                                  startDate: startDate!,
                                  endDate: endDate!,
                                );

                                yearController.clear();
                                startDate = null;
                                endDate = null;
                                setState(() {});
                              },
                              child: const Text("Add Year",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 30),

                  /// ================= RIGHT (LIST) =================
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      decoration: _cardDecoration(),
                      child: provider.isLoading
                          ? const Center(
                          child: CircularProgressIndicator())
                          : ListView.builder(
                        itemCount:
                        provider.academicYears.length,
                        itemBuilder: (context, index) {
                          final doc =
                          provider.academicYears[index];
                          final data =
                          doc.data() as Map<String, dynamic>;

                          return Container(
                            margin:
                            const EdgeInsets.only(bottom: 15),
                            padding:
                            const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius:
                              BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.grey.shade200),
                            ),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['year_name'],
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight:
                                          FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "${_formatDate(data['start_date'])} - ${_formatDate(data['end_date'])}",
                                      style: const TextStyle(
                                          color: Colors.grey),
                                    ),
                                  ],
                                ),

                                /// RIGHT ACTION
                                data['is_current'] == true
                                    ? const Chip(
                                  label: Text("Current"),
                                  backgroundColor:
                                  Colors.green,
                                )
                                    : ElevatedButton(
                                  style:
                                  ElevatedButton.styleFrom(
                                    backgroundColor:
                                    const Color(0xFF14B8A6),
                                  ),
                                  onPressed: () {
                                    context
                                        .read<AdminProvider>()
                                        .setCurrentYear(
                                        doc.id);
                                  },
                                  child: const Text(
                                      "Set Current",
                                      style: TextStyle(
                                          color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= COMMON UI =================
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 15,
          offset: const Offset(0, 8),
        )
      ],
    );
  }

  Widget _dateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          date == null
              ? "Select Date"
              : DateFormat('dd MMM yyyy').format(date),
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
    return DateFormat('dd MMM yyyy').format(timestamp.toDate());
  }
}