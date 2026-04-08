import 'package:flutter/cupertino.dart';
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

class _DivisionDashboardState extends State<DivisionDashboard> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Overview, Students, Attendance, Teachers
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text("Class ${widget.className} - ${widget.divisionName}"),
          foregroundColor: const Color(0xFF1E293B),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Color(0xFF0F766E),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF0F766E),
            tabs: [
              Tab(text: "Overview", icon: Icon(Icons.dashboard_outlined)),
              Tab(text: "Students", icon: Icon(Icons.group_outlined)),
              Tab(text: "Attendance", icon: Icon(Icons.calendar_today_outlined)),
              Tab(text: "Teachers", icon: Icon(Icons.person_pin_outlined)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _overviewTab(),
            _studentsTab(),
            _attendanceTab(),
            _teachersTab(),
          ],
        ),
      ),
    );
  }

  /// ================= OVERVIEW TAB =================
  Widget _overviewTab() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Division Summary", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              _statCard("Total Students", "42", Icons.people, Colors.blue),
              _statCard("Today's Attendance", "95%", Icons.done_all, Colors.green),
              _statCard("Pending Fees", "5", Icons.account_balance_wallet, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  /// ================= STUDENTS TAB =================
  Widget _studentsTab() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Student List", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _showAddStudentDialog(),
                icon: const Icon(Icons.add),
                label: const Text("Add Student"),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F766E)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListView.separated(
                itemCount: 10, // Replace with dynamic data
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) => ListTile(
                  leading: const CircleAvatar(backgroundColor: Color(0xFFF1F5F9), child: Icon(Icons.person, color: Colors.grey)),
                  title: Text("Student Name ${index + 1}"),
                  subtitle: Text("Roll No: ${index + 101}"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= ATTENDANCE TAB =================
  Widget _attendanceTab() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Daily Attendance", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () {}, // Navigate to Mark Attendance Page
                icon: const Icon(Icons.edit_calendar),
                label: const Text("Mark Today's Attendance"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF0F766E)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Add a Calendar view or List of previous attendance logs here
        ],
      ),
    );
  }

  /// ================= TEACHERS TAB =================
  Widget _teachersTab() {
    return const Center(child: Text("Teacher Assignment details here"));
  }

  /// ================= HELPER WIDGETS =================
  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showAddStudentDialog() {
    // Implement your dialog here
  }
}