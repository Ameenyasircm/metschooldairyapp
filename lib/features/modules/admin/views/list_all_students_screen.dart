import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:met_school/features/modules/admin/views/register_student_screen.dart';
import 'package:met_school/providers/academic_provider.dart';
import 'package:provider/provider.dart';

import '../../../../providers/admin_provider.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() =>
      _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final TextEditingController searchController =
  TextEditingController();

  final ScrollController _scrollController = ScrollController();

  List<DocumentSnapshot> filteredList = [];

  @override
  void initState() {
    super.initState();

    final provider = context.read<AcademicProvider>();

    /// INITIAL FETCH
    Future.microtask(() async {
      await provider.fetchStudents();
      filteredList = provider.studentsList;
      setState(() {});
    });

    /// SCROLL LISTENER (PAGINATION)
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        provider.fetchMoreStudents();
      }
    });
  }

  /// ================= SEARCH =================
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademicProvider>();

    final students = searchController.text.isEmpty
        ? provider.studentsList
        : filteredList;

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
                    context.read<AdminProvider>().setIndex(0);
                  },
                  icon: const Icon(Icons.arrow_back,
                      color: Colors.white),
                ),
                const Text(
                  "Students",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const Spacer(),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const AddStudentScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add,
                      color: Color(0xFF0F766E)),
                  label: const Text(
                    "Add Student",
                    style:
                    TextStyle(color: Color(0xFF0F766E)),
                  ),
                )
              ],
            ),
          ),

          /// ================= BODY =================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [

                  /// SEARCH BAR
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (val) =>
                          _search(val, provider.studentsList),
                      decoration: const InputDecoration(
                        hintText: "Search student...",
                        border: InputBorder.none,
                        icon: Icon(Icons.search),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// TABLE HEADER
                  _tableHeader(),

                  const SizedBox(height: 10),

                  /// LIST WITH PAGINATION
                  Expanded(
                    child: provider.isStudentLoading
                        ? const Center(
                        child: CircularProgressIndicator())
                        : students.isEmpty
                        ? const Center(
                        child: Text("No Students Found"))
                        : ListView.builder(
                      controller: _scrollController,
                      itemCount: students.length + 1,
                      itemBuilder: (context, index) {

                        /// 🔥 BOTTOM LOADER
                        if (index == students.length) {
                          return provider.isMoreLoading
                              ? const Padding(
                            padding: EdgeInsets.all(15),
                            child: Center(
                                child:
                                CircularProgressIndicator()),
                          )
                              : const SizedBox();
                        }

                        final doc = students[index];
                        final data =
                        doc.data() as Map<String, dynamic>;

                        return _studentRow(data);
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

  /// ================= HEADER ROW =================
  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Expanded(flex: 2, child: Text("Name")),
          Expanded(child: Text("Admission ID")),
          Expanded(child: Text("Class")),
          Expanded(child: Text("Phone")),
        ],
      ),
    );
  }

  /// ================= STUDENT ROW =================
  Widget _studentRow(Map<String, dynamic> data) {
    return InkWell(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(
            horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border:
          Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Expanded(
                flex: 2,
                child: Text(data['name'] ?? "")),
            Expanded(
                child: Text(data['admissionId'] ?? "")),
            Expanded(child: Text(data['class'] ?? "")),
            Expanded(child: Text(data['phone'] ?? "")),
          ],
        ),
      ),
    );
  }
}