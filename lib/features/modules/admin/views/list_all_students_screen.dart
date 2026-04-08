import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:met_school/features/modules/admin/views/register_student_screen.dart';
import 'package:met_school/providers/academic_provider.dart';
import 'package:provider/provider.dart';
import '../../../../providers/admin_provider.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<DocumentSnapshot> filteredList = [];

  @override
  void initState() {
    super.initState();
    final provider = context.read<AcademicProvider>();

    /// INITIAL FETCH
    Future.microtask(() async {
      await provider.fetchStudents();
      setState(() {
        filteredList = provider.studentsList;
      });
    });

    /// SCROLL LISTENER (PAGINATION)
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        provider.fetchMoreStudents();
      }
    });
  }

  /// ================= SEARCH LOGIC =================
  void _search(String value, List<DocumentSnapshot> list) {
    final query = value.toLowerCase();
    setState(() {
      filteredList = list.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final name = (data['name'] ?? "").toLowerCase();
        final admission = (data['admissionId'] ?? "").toLowerCase();
        return name.contains(query) || admission.contains(query);
      }).toList();
    });
  }

  /// ================= DELETE CONFIRMATION =================
  void _showDeleteDialog(BuildContext context, String docId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Deletion", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete student: $name? This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await context.read<AcademicProvider>().deleteStudent(docId);
              if (mounted) Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Student deleted successfully"), backgroundColor: Colors.red),
              );
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademicProvider>();
    final students = searchController.text.isEmpty ? provider.studentsList : filteredList;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          /// ================= HEADER =================
          _buildModernHeader(context),

          /// ================= BODY / DATA TABLE =================
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  /// TOOLBAR (Search & Actions)
                  _buildToolbar(provider),

                  const Divider(height: 1),

                  /// TABLE HEADER
                  _tableHeader(),

                  /// LIST CONTENT
                  Expanded(
                    child: provider.isStudentLoading
                        ? const Center(child: CircularProgressIndicator())
                        : students.isEmpty
                        ? const Center(child: Text("No Students Found", style: TextStyle(color: Colors.grey)))
                        : ListView.separated(
                      controller: _scrollController,
                      itemCount: students.length + 1,
                      separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      itemBuilder: (context, index) {
                        if (index == students.length) {
                          return provider.isMoreLoading
                              ? const Padding(
                            padding: EdgeInsets.all(15),
                            child: Center(child: CircularProgressIndicator()),
                          )
                              : const SizedBox(height: 50);
                        }

                        final doc = students[index];
                        final data = doc.data() as Map<String, dynamic>;
                        return _studentDataRow(data, doc.id);
                      },
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF0F766E), Color(0xFF14B8A6)]),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.read<AdminProvider>().setIndex(0),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          ),
          const Text(
            "Student Management",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const Spacer(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0F766E),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddStudentScreen())),
            icon: const Icon(Icons.person_add_alt_1, size: 18),
            label: const Text("Enroll Student"),
          )
        ],
      ),
    );
  }

  Widget _buildToolbar(AcademicProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: searchController,
                onChanged: (val) => _search(val, provider.studentsList),
                decoration: const InputDecoration(
                  hintText: "Search by name or admission number...",
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, size: 18, color: Color(0xFF0F766E)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          _toolbarAction(Icons.filter_list, "Filter"),
          const SizedBox(width: 8),
          _toolbarAction(Icons.file_download_outlined, "Export"),
        ],
      ),
    );
  }

  Widget _toolbarAction(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF64748B)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: const Color(0xFFF8FAFC),
      child: Row(
        children:  [
          Expanded(flex: 3, child: _headerTitle("STUDENT NAME")),
          Expanded(flex: 2, child: _headerTitle("ADMISSION ID")),
          Expanded(flex: 2, child: _headerTitle("CLASS")),
          Expanded(flex: 2, child: _headerTitle("PHONE")),
          SizedBox(width: 100, child: _headerTitle("ACTIONS")),
        ],
      ),
    );
  }

  static Widget _headerTitle(String title) => Text(
    title,
    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
  );

  Widget _studentDataRow(Map<String, dynamic> data, String docId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          // Name with Avatar
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF0F766E).withOpacity(0.1),
                  child: Text(data['name']?[0].toUpperCase() ?? "S",
                      style: const TextStyle(color: Color(0xFF0F766E), fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['name'] ?? "", style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                      Text("Guardian: ${data['parentGuardian'] ?? ""}", style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Admission ID
          Expanded(flex: 2, child: Text(data['admissionId'] ?? "---", style: const TextStyle(color: Color(0xFF475569)))),
          // Class
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                child: Text(data['className'] ?? data['class'] ?? "---", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
              ),
            ),
          ),
          // Contact
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['phone'] ?? "---", style: const TextStyle(fontSize: 13)),
                if (data['whatsapp'] != null && data['whatsapp'] != "")
                  const Text("WhatsApp Active", style: TextStyle(fontSize: 9, color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // Actions
          SizedBox(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddStudentScreen(initialData: data)),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () => _showDeleteDialog(context, docId, data['name'] ?? "Student"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}