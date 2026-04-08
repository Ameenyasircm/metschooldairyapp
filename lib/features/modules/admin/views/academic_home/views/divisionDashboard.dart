// DivisionDashboard.dart

import 'package:flutter/material.dart';

class DivisionDashboard extends StatefulWidget {
  final String divisionId;
  final String divisionName;
  final String className;
  final String academicYearId;
  final String classTeacherName;
  final String classTeacherId;

  const DivisionDashboard({
    super.key,
    required this.divisionId,
    required this.divisionName,
    required this.className,
    required this.academicYearId,
    required this.classTeacherName,
    required this.classTeacherId,
  });

  @override
  State<DivisionDashboard> createState() => _DivisionDashboardState();
}

class _DivisionDashboardState extends State<DivisionDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate 100
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF1E293B)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Class ${widget.className} - Division ${widget.divisionName}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            Text(
              "Class Teacher: ${widget.classTeacherName}",
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFF0F766E),
          unselectedLabelColor: const Color(0xFF94A3B8),
          indicatorColor: const Color(0xFF0F766E),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          tabs: const [
            Tab(text: "Overview"),
            Tab(text: "Students"),
            Tab(text: "Attendance"),
            Tab(text: "Teacher Info"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _overviewTab(),
          _studentsTab(),
          _attendanceTab(),
          _teachersTab(),
        ],
      ),
    );
  }

  /// ================= OVERVIEW TAB =================
  Widget _overviewTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Top Stats Row
        Row(
          children: [
            _statCard("Students", "42", Icons.people_rounded, Colors.indigo),
            const SizedBox(width: 16),
            _statCard("Attendance", "95%", Icons.verified_user_rounded, Colors.teal),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _statCard("Performance", "B+", Icons.auto_graph_rounded, Colors.amber.shade700),
            const SizedBox(width: 16),
            _statCard("Activities", "04", Icons.star_rounded, Colors.purple),
          ],
        ),
        const SizedBox(height: 32),

        // Quick Actions Section
        const Text("Quick Management", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _quickActionTile("Generate Progress Report", "Analyze class performance", Icons.analytics_outlined, Colors.blue),
        _quickActionTile("Bulk Message Parents", "Send notification to all", Icons.message_outlined, Colors.green),
        _quickActionTile("Schedule Class Test", "Manage upcoming assessments", Icons.event_note_outlined, Colors.orange),
      ],
    );
  }

  /// ================= STUDENTS TAB =================
  Widget _studentsTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Search & Add Header
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search student...",
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F766E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // List
          Expanded(
            child: ListView.builder(
              itemCount: 15,
              itemBuilder: (context, index) => _studentListItem(index),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= TEACHERS TAB =================
  Widget _teachersTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _teacherProfileCard(widget.classTeacherName, "Class Teacher", true),
        const SizedBox(height: 24),
        const Text("Subject Teachers", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _teacherProfileCard("Mr. John Doe", "Mathematics", false),
        _teacherProfileCard("Ms. Sarah Smith", "Science", false),
      ],
    );
  }

  /// ================= COMPONENT WIDGETS =================

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 16),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _quickActionTile(String title, String sub, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, size: 18),
      ),
    );
  }

  Widget _studentListItem(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: Colors.blueGrey.shade50,
          child: Text("${index + 1}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        title: Text("Student Name ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: const Text("ID: #20240012", style: TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.more_vert, size: 20),
      ),
    );
  }

  Widget _teacherProfileCard(String name, String role, bool isClassTeacher) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isClassTeacher ? const Color(0xFF0F766E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: isClassTeacher ? Colors.white24 : const Color(0xFFF1F5F9),
            child: Icon(Icons.person, color: isClassTeacher ? Colors.white : Colors.grey),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: isClassTeacher ? Colors.white : Colors.black)),
              Text(role, style: TextStyle(fontSize: 12, color: isClassTeacher ? Colors.white70 : Colors.grey)),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.mail_outline, color: isClassTeacher ? Colors.white : Colors.grey),
          )
        ],
      ),
    );
  }

  Widget _attendanceTab() => const Center(child: Text("Attendance Chart/Log Here"));
}