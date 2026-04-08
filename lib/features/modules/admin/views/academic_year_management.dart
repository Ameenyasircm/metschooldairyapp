import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/navigation/navigation_helper.dart';
import '../../../../providers/admin_provider.dart';
import 'academic_home/views/academic_home_screen.dart';

class AcademicYearScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const AcademicYearScreen({super.key, required this.userName,required this.userId});

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
    Future.microtask(() => context.read<AdminProvider>().fetchAcademicYears());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Modern grey-blue tint
      body: Column(
        children: [
          /// ================= WEB HEADER =================
          _buildHeader(context),

          /// ================= MAIN CONTENT =================
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : provider.academicYears.isEmpty
                ? _emptyState()
                : _buildGrid(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.read<AdminProvider>().setIndex(0),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF64748B)),
          ),
          const SizedBox(width: 20),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Academic Sessions",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF1E293B), letterSpacing: -0.5),
              ),
              Text("Manage school years and current active session", style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
            ],
          ),
          const Spacer(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F766E),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _openAddDialog,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text("Create New Year", style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildGrid(AdminProvider provider) {
    return GridView.builder(
      padding: const EdgeInsets.all(40),
      itemCount: provider.academicYears.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 450, // Ensures cards look good on any screen width
        crossAxisSpacing: 25,
        mainAxisSpacing: 25,
        mainAxisExtent: 210, // Fixed height for visual consistency
      ),
      itemBuilder: (context, index) {
        final doc = provider.academicYears[index];
        final data = doc.data() as Map<String, dynamic>;
        return _yearCard(doc.id, data);
      },
    );
  }

  Widget _yearCard(String id, Map<String, dynamic> data) {
    final isCurrent = data['is_current'] == true;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () => callNext(AcademicYearHomeScreen(academicYearId: id, yearName: data['year_name'], userName: widget.userName, userId:  widget.userId,), context),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isCurrent ? const Color(0xFF14B8A6) : Colors.transparent, width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.calendar_month_rounded, color: Color(0xFF0F766E), size: 22),
                  ),
                  if (isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(30)),
                      child: const Text("ACTIVE", style: TextStyle(color: Color(0xFF166534), fontWeight: FontWeight.w900, fontSize: 10)),
                    )
                ],
              ),
              const Spacer(),
              Text(data['year_name'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.schedule_rounded, size: 14, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 8),
                  Text("${_formatDate(data['start_date'])} — ${_formatDate(data['end_date'])}", style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                ],
              ),
              const Spacer(),
              if (!isCurrent)
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton.icon(
                    onPressed: () => context.read<AdminProvider>().setCurrentYear(id),
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                    label: const Text("Set Active Session"),
                    style: TextButton.styleFrom(foregroundColor:  Color(0xFF0F766E), ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  void _openAddDialog() {
    DateTime? localStartDate = startDate;
    DateTime? localEndDate = endDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("Add Academic Year", style: TextStyle(fontWeight: FontWeight.w900)),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: yearController,
                  decoration: _inputDecoration("Year Name (e.g., 2026-27)"),
                ),
                const SizedBox(height: 16),
                _dateFieldWeb("Start Date", localStartDate, () async {
                  final picked = await _pickDate(context);
                  if (picked != null) setStateDialog(() => localStartDate = picked);
                }),
                const SizedBox(height: 16),
                _dateFieldWeb("End Date", localEndDate, () async {
                  final picked = await _pickDate(context);
                  if (picked != null) setStateDialog(() => localEndDate = picked);
                }),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.all(20),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F766E), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () {
                if (yearController.text.isNotEmpty && localStartDate != null && localEndDate != null) {
                  context.read<AdminProvider>().addAcademicYear(yearName: yearController.text.trim(), startDate: localStartDate!, endDate: localEndDate!);
                  yearController.clear();
                  Navigator.pop(context);
                }
              },
              child: const Text("Confirm"),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0F766E), width: 2)),
  );

  Widget _dateFieldWeb(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF64748B)),
            const SizedBox(width: 12),
            Text(date == null ? label : DateFormat('dd MMM yyyy').format(date), style: TextStyle(color: date == null ? const Color(0xFF64748B) : Colors.black, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() => const Center(child: Text("No academic years found. Click the button to add one.", style: TextStyle(color: Color(0xFF94A3B8))));

  Future<DateTime?> _pickDate(BuildContext context) async => await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100));

  String _formatDate(Timestamp timestamp) => DateFormat('dd MMM yyyy').format(timestamp.toDate());
}