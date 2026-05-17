/// admin_lesson_plan_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../providers/admin_provider.dart';

class AdminLessonPlanScreen extends StatefulWidget {
  const AdminLessonPlanScreen({super.key});

  @override
  State<AdminLessonPlanScreen> createState() =>
      _AdminLessonPlanScreenState();
}

class _AdminLessonPlanScreenState
    extends State<AdminLessonPlanScreen> {
  static const Color primaryBlue   = Color(0xFF031937);
  static const Color secondaryBlue = Color(0xFF003865);

  @override
  void dispose() {
    // clear selection when leaving screen
    context.read<AdminProvider>().setSelectedLessonPlan(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: context
                  .read<AdminProvider>()
                  .fetchLessonPlansStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return _emptyWidget();
                }

                final filtered = provider.filteredLessonPlans;

                return Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    // ── Left: List ────────────────────
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          _buildFilterRow(
                              context, filtered.length),
                          Expanded(
                            child: ListView.builder(
                              padding:
                              const EdgeInsets.all(30),
                              itemCount: filtered.length,
                              itemBuilder: (ctx, i) =>
                                  _buildPlanCard(
                                    context,
                                    filtered[i],
                                    provider,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Right: Detail Panel ───────────
                    if (provider.selectedLessonPlan != null)
                      _buildDetailPanel(
                        context,
                        provider.selectedLessonPlan!,
                        provider,
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 100,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue, secondaryBlue],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () =>
                context.read<AdminProvider>().setIndex(0),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white70,
            ),
            tooltip: "Back to Dashboard",
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.menu_book_outlined,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 14),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Lesson Plans",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Review and approve teacher lesson plans",
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Filter row ─────────────────────────────────────────────
  Widget _buildFilterRow(BuildContext context, int count) {
    final provider = context.watch<AdminProvider>();

    return Container(
      padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
      child: Row(
        children: [
          Text(
            "$count Plan${count == 1 ? '' : 's'}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
          const Spacer(),
          Row(
            children:
            provider.lessonPlanFilters.map((f) {
              final selected =
                  provider.lessonPlanFilter == f;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ChoiceChip(
                  label: Text(f),
                  selected: selected,
                  onSelected: (_) => context
                      .read<AdminProvider>()
                      .setLessonPlanFilter(f),
                  selectedColor: primaryBlue,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: selected
                        ? Colors.white
                        : Colors.blueGrey,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(30),
                    side: BorderSide(
                      color: selected
                          ? primaryBlue
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Plan card ──────────────────────────────────────────────
  Widget _buildPlanCard(
      BuildContext context,
      Map<String, dynamic> plan,
      AdminProvider provider,
      ) {
    final bool isApproved =
        (plan['STATUS'] ?? '').toString().toLowerCase() ==
            "approved";

    final bool isSelected =
        provider.selectedLessonPlan?['ID'] == plan['ID'];

    final createdAt =
    (plan['CREATED_AT'] as Timestamp?)?.toDate();

    final approvedAt =
    (plan['APPROVED_AT'] as Timestamp?)?.toDate();

    return GestureDetector(
      onTap: () => context
          .read<AdminProvider>()
          .setSelectedLessonPlan(plan),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? primaryBlue
                : Colors.grey.shade100,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan['TOPIC_NAME'] ?? '-',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                ),
                _statusBadge(isApproved),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              "${plan['SUBJECT'] ?? '-'}  •  Grade ${plan['GRADE'] ?? '-'}",
              style: const TextStyle(
                color: Colors.blueGrey,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              "Teacher : ${plan['TEACHER_NAME'] ?? '-'}",
              style: const TextStyle(
                color: Colors.blueGrey,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            Row(
              children: [
                _dateChip(
                  Icons.calendar_today_outlined,
                  "Added",
                  createdAt,
                  Colors.blueGrey,
                ),
                if (isApproved && approvedAt != null) ...[
                  const SizedBox(width: 14),
                  _dateChip(
                    Icons.check_circle_outline_rounded,
                    "Approved",
                    approvedAt,
                    Colors.green,
                  ),
                ],
                const Spacer(),

                // ── Approve button ───────────────────
                if (!isApproved)
                  provider.lessonPlanLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.teal,
                    ),
                  )
                      : ElevatedButton.icon(
                    onPressed: () => _confirmApprove(
                      context,
                      plan,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(
                      Icons.check_rounded,
                      size: 16,
                    ),
                    label: const Text(
                      "Approve",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Detail side panel ──────────────────────────────────────
  Widget _buildDetailPanel(
      BuildContext context,
      Map<String, dynamic> plan,
      AdminProvider provider,
      ) {
    final bool isApproved =
        (plan['STATUS'] ?? '').toString().toLowerCase() ==
            "approved";

    final createdAt =
    (plan['CREATED_AT'] as Timestamp?)?.toDate();
    final approvedAt =
    (plan['APPROVED_AT'] as Timestamp?)?.toDate();

    return Container(
      width: 380,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: Column(
        children: [
          // ── Panel header ──────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(
                20, 20, 12, 20),
            color: primaryBlue,
            child: Row(
              children: [
                const Icon(
                  Icons.description_outlined,
                  color: Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "Plan Details",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => context
                      .read<AdminProvider>()
                      .setSelectedLessonPlan(null),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),

          // ── Content ───────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  _statusBadge(isApproved),
                  const SizedBox(height: 20),

                  _detailRow("Topic",      plan['TOPIC_NAME']),
                  _detailRow("Subject",    plan['SUBJECT']),
                  _detailRow("Grade",      plan['GRADE']),
                  _detailRow("Teacher",    plan['TEACHER_NAME']),
                  _detailRow("Duration",   plan['DURATION']),
                  _detailRow("Periods",    plan['PERIODS_ALLOTTED']),
                  _detailRow("Methodologies",      plan['METHODOLOGIES']),
                  _detailRow("Activity",           plan['ACTIVITY']),
                  _detailRow("Instructional Tools",plan['INSTRUCTIONAL_TOOLS']),
                  _detailRow("Learning Objectives",plan['LEARNING_OBJECTIVES']),

                  const Divider(height: 32),

                  if (createdAt != null)
                    _detailRow(
                      "Added On",
                      DateFormat("dd MMM yyyy, hh:mm a")
                          .format(createdAt),
                    ),

                  if (isApproved && approvedAt != null)
                    _detailRow(
                      "Approved On",
                      DateFormat("dd MMM yyyy, hh:mm a")
                          .format(approvedAt),
                    ),

                  const SizedBox(height: 20),

                  if (!isApproved)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                        provider.lessonPlanLoading
                            ? null
                            : () => _confirmApprove(
                          context,
                          plan,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding:
                          const EdgeInsets.symmetric(
                              vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(10),
                          ),
                        ),
                        icon: provider.lessonPlanLoading
                            ? const SizedBox(
                          width: 16,
                          height: 16,
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Icon(
                            Icons.check_rounded),
                        label: const Text(
                          "Approve This Plan",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
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

  // ── Confirm dialog ─────────────────────────────────────────
  Future<void> _confirmApprove(
      BuildContext context,
      Map<String, dynamic> plan,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.teal,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Approve Lesson Plan?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "You are about to approve\n\"${plan['TOPIC_NAME']}\"",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        padding:
                        const EdgeInsets.symmetric(
                            vertical: 14),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding:
                        const EdgeInsets.symmetric(
                            vertical: 14),
                      ),
                      child: const Text(
                        "Yes, Approve",
                        style: TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AdminProvider>().approveLessonPlan(
        context: context,
        plan: plan,
      );
    }
  }

  // ── Helpers ────────────────────────────────────────────────
  Widget _statusBadge(bool isApproved) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: isApproved
            ? Colors.green.shade50
            : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isApproved
              ? Colors.green.shade200
              : Colors.orange.shade200,
        ),
      ),
      child: Text(
        isApproved ? "Approved" : "Pending",
        style: TextStyle(
          color:
          isApproved ? Colors.green : Colors.orange,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _dateChip(
      IconData icon,
      String label,
      DateTime? date,
      Color color,
      ) {
    if (date == null) return const SizedBox();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          "$label : ${DateFormat("dd MMM yyyy").format(date)}",
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.blueGrey,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value?.toString().isNotEmpty == true
                ? value.toString()
                : "—",
            style: const TextStyle(
              fontSize: 14,
              color: primaryBlue,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 64,
            color: Colors.blueGrey,
          ),
          SizedBox(height: 16),
          Text(
            "No Lesson Plans Submitted Yet",
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}