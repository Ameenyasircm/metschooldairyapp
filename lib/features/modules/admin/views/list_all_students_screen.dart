import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:met_school/features/modules/admin/views/register_student_screen.dart';
import 'package:met_school/providers/academic_provider.dart';
import 'package:provider/provider.dart';
import '../../../../providers/admin_provider.dart';
import 'package:intl/intl.dart';

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

    Future.microtask(() async {
      await provider.fetchStudents();
      setState(() {
        filteredList = provider.studentsList;
      });
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        provider.fetchMoreStudents();
      }
    });
  }

  void _search(String value, List<DocumentSnapshot> list) {
    final query = value.toLowerCase();
    setState(() {
      filteredList = list.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final name = (data['name'] ?? "").toString().toLowerCase();
        final admission = (data['admissionId'] ?? "").toString().toLowerCase();
        final parent = (data['parentGuardian'] ?? "").toString().toLowerCase();
        return name.contains(query) || admission.contains(query) || parent.contains(query);
      }).toList();
    });
  }

  void _showDeleteDialog(BuildContext context, String docId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Archive Student"),
        content: Text("Move $name to the deleted archives? This will remove them from active lists."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, elevation: 0),
            onPressed: () async {
              await context.read<AcademicProvider>().deleteStudentWithLog(docId);
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Confirm Archive", style: TextStyle(color: Colors.white)),
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
      backgroundColor: const Color(0xFFF1F5F9), // Light Blue Gray
      body: Column(
        children: [
          _buildTopNavigationBar(context),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 5),

                  // Main Data Container
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 8))
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildFilterToolbar(provider),
                          _buildTableHeader(), // New dynamic header
                          const Divider(height: 1, color: Color(0xFFEDF2F7)),
                          Expanded(
                            child: _buildStudentListView(provider, students),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTopNavigationBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 50, 30, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.read<AdminProvider>().setIndex(0),
            icon: const Icon(Icons.grid_view_rounded, color: Color(0xFF64748B)),
          ),
          const SizedBox(width: 10),
          const Text(
            "Student Records",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          const Spacer(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F766E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            // onPressed: (){
            //   addRandomStudents(10);
            // },
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddStudentScreen())),
            icon: const Icon(Icons.person_add_rounded, size: 20),
            label: const Text("Add New Student", style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
  Future<void> addRandomStudents(int count) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final String adminUid = FirebaseAuth.instance.currentUser?.uid ?? "system";

    final List<String> names = ["Adhil", "Fathima", "Muhammed", "Aisha", "Zayan", "Rinshad", "Hadiya"];
    final List<Map<String, String>> classes = [
      {"id": "class10", "name": "10 A"},
      {"id": "class9", "name": "9 B"},
      {"id": "class8", "name": "8 C"},
    ];

    for (int i = 0; i < count; i++) {
      final batch = firestore.batch();
      final String name = names[i % names.length];
      final selectedClass = classes[i % classes.length];

      int parentGroup = (i / 2).floor();
      final String parentPhone = "971500000$parentGroup";

      final String docId = DateTime.now().millisecondsSinceEpoch.toString() + i.toString();
      final String finalAdmissionId = "ADM-2026-${100 + i}";

      // 1. Prepare base student data (isEnrolled: false as default for new registrations)
      Map<String, dynamic> studentData = {
        "id": docId,
        "name": "$name ${i + 1}",
        "admissionId": finalAdmissionId,
        "classId": selectedClass['id'],
        "className": selectedClass['name'],
        "parentGuardian": "Guardian of $name",
        "relation": "Father",
        "fatherProfession": "Engineer",
        "motherName": "Mother Name",
        "phone": parentPhone,
        "whatsapp": parentPhone,
        "aadhar": "[Aadhaar Redacted]",
        "dob": Timestamp.fromDate(DateTime(2012, 5, 20)),
        "age": "14",
        "religion": "Islam",
        "place": "Malappuram",
        "address": "Green Valley House, Kerala",
        "gender": i % 2 == 0 ? "Male" : "Female",
        "medium": "English",
        "prevSchool": "Local Public School",
        "tcNumber": "TC${100 + i}",
        "identificationMark": "Mole on neck",
        "updatedAt": FieldValue.serverTimestamp(),
        "isEnrolled": false, // Synchronized with your _saveStudent logic
      };

      var existingUserQuery = await firestore.collection("users")
          .where("phone", isEqualTo: parentPhone)
          .where("role", isEqualTo: "parent")
          .limit(1)
          .get();

      String parentUid;
      DocumentReference studentRef = firestore.collection("students").doc(docId);

      if (existingUserQuery.docs.isNotEmpty) {
        // --- SIBLING CASE ---
        parentUid = existingUserQuery.docs.first.id;
        studentData['parentId'] = parentUid; // Explicitly link parentId to student document

        batch.set(studentRef, studentData);

        // Update 'parents' collection
        batch.update(firestore.collection("parents").doc(parentUid), {
          "studentIds": FieldValue.arrayUnion([docId]),
          "updatedAt": FieldValue.serverTimestamp(),
        });

        // Update 'users' collection
        batch.update(firestore.collection("users").doc(parentUid), {
          "studentIds": FieldValue.arrayUnion([docId]),
        });

        print("Sibling added and linked to Parent UID: $parentUid");
      } else {
        // --- NEW PARENT CASE ---
        DocumentReference newUserRef = firestore.collection("users").doc();
        parentUid = newUserRef.id;
        studentData['parentId'] = parentUid; // Explicitly link parentId to student document

        batch.set(studentRef, studentData);

        // Create User Account in 'users'
        batch.set(newUserRef, {
          "uid": parentUid,
          "role": "parent",
          "name": "Guardian of $name",
          "phone": parentPhone,
          "user_name": parentPhone,
          "password": parentPhone,
          "studentIds": [docId],
          "createdAt": FieldValue.serverTimestamp(),
          "createdBy": adminUid,
        });

        // Create Parent Document in 'parents'
        batch.set(firestore.collection("parents").doc(parentUid), {
          "parentUid": parentUid,
          "studentIds": [docId],
          "parentName": "Guardian of $name",
          "phone": parentPhone,
          "updatedAt": FieldValue.serverTimestamp(),
        });
        print("New Parent/User created with UID: $parentUid");
      }

      await batch.commit();
    }
  }

  Widget _statItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterToolbar(AcademicProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: searchController,
                onChanged: (val) => _search(val, provider.studentsList),
                decoration: const InputDecoration(
                  hintText: "Search name, parent, or ID...",
                  prefixIcon: Icon(Icons.search_rounded, size: 20, color: Color(0xFF94A3B8)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          _actionIcon(Icons.tune_rounded),
          const SizedBox(width: 8),
          _actionIcon(Icons.download_rounded),
        ],
      ),
    );
  }

  Widget _actionIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Icon(icon, size: 20, color: const Color(0xFF64748B)),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      color: const Color(0xFFF8FAFC),
      child: Row(
        children: [
          Expanded(flex: 3, child: _headerCell("FULL NAME")),
          Expanded(flex: 2, child: _headerCell("ADMISSION ID")),
          Expanded(flex: 2, child: _headerCell("CLASS")),
          Expanded(flex: 2, child: _headerCell("PARENT NAME")),
          Expanded(flex: 2, child: _headerCell("PHONE NUMBER")),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _headerCell(String title) => Text(
    title,
    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF475569), letterSpacing: 0.5),
  );

  Widget _buildStudentListView(AcademicProvider provider, List<DocumentSnapshot> students) {
    if (provider.isStudentLoading) return const Center(child: CircularProgressIndicator());

    return ListView.separated(
      controller: _scrollController,
      padding: EdgeInsets.zero,
      itemCount: students.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
      itemBuilder: (context, index) {
        final data = students[index].data() as Map<String, dynamic>;
        final docId = students[index].id;
        return _buildDataRow(data, docId);
      },
    );
  }

  Widget _buildDataRow(Map<String, dynamic> data, String docId) {
    return InkWell(
      onTap: () => _showStudentDetails(data),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            // Name with Icon
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFF0F766E).withOpacity(0.1),
                    child: Text(data['name']?[0].toUpperCase() ?? "S", style: const TextStyle(color: Color(0xFF0F766E), fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(data['name'] ?? "N/A", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1E293B))),
                  ),
                ],
              ),
            ),
            // Admission ID
            Expanded(
              flex: 2,
              child: Text(data['admissionId'] ?? "N/A", style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
            ),
            // Class Badge
            Expanded(
              flex: 2,
              child: UnconstrainedBox(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                  child: Text(data['className'] ?? "-", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                ),
              ),
            ),
            // Parent Name
            Expanded(
              flex: 2,
              child: Text(data['parentGuardian'] ?? "N/A", style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B))),
            ),
            // Phone
            Expanded(
              flex: 2,
              child: Text(data['phone'] ?? "N/A", style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B))),
            ),
            // Action Menu
            // 🔹 1. Update the Action Menu to include the "View" option
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_horiz, color: Color(0xFF94A3B8)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners for menu
          onSelected: (val) {
            if (val == 'view') {
              _showStudentDetails(data);
            } else if (val == 'edit') {
              // Create a fresh map and explicitly ensure the docId and parentId are included
              Map<String, dynamic> editData = Map<String, dynamic>.from(data);
              editData['id'] = docId;
              // Note: ensure 'parentId' exists in data from your Firestore fetch

              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddStudentScreen(initialData: editData))
              );
            } else if (val == 'delete') {
              _showDeleteDialog(context, docId, data['name']);
            }
          },
          itemBuilder: (context) => [
            _buildMenuItem('view', Icons.visibility_outlined, "View Profile"),
            _buildMenuItem('edit', Icons.edit_outlined, "Edit Record"),
            const PopupMenuDivider(height: 1), // Separation for the delete action
            _buildMenuItem('delete', Icons.delete_outline_rounded, "Archive Student", isDelete: true),
          ],
        ),
          ],
        ),
      ),
    );
  }
  PopupMenuItem<String> _buildMenuItem(String value, IconData icon, String text, {bool isDelete = false}) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: isDelete ? Colors.red : const Color(0xFF64748B)),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
                fontSize: 14,
                color: isDelete ? Colors.red : const Color(0xFF1E293B),
                fontWeight: FontWeight.w500
            ),
          ),
        ],
      ),
    );
  }

  void _showStudentDetails(Map<String, dynamic> data) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.centerRight, // Slides in from right
          child: Material(
            elevation: 16,
            color: Colors.transparent,
            child: _buildSideDetailPanel(data),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(1, 0), end: const Offset(0, 0)).animate(anim1),
          child: child,
        );
      },
    );
  }
  Widget _buildSideDetailPanel(Map<String, dynamic> data) {
    final panelWidth = MediaQuery.of(context).size.width * 0.65; // Slightly wider for more data

    return Container(
      constraints: BoxConstraints(
        minWidth: 750,
        maxWidth: panelWidth,
      ),
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 30, offset: const Offset(-10, 0)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Top Header Actions ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _badge("STUDENT ID: ${data['id'] ?? 'N/A'}", Colors.blueGrey),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_fullscreen_rounded),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- Profile Header ---
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFF0F766E),
                  child: Text(data['name']?[0].toUpperCase() ?? "S",
                      style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['name'] ?? "N/A",
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                    const SizedBox(height: 4),
                    Text("${data['className']} | ${data['medium']} Medium",
                        style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                  ],
                ),
                const Spacer(),
                _badge("ADMISSION ID: ${data['admissionId']}", const Color(0xFF0F766E)),
              ],
            ),

            const SizedBox(height: 40),

            // --- Four-Column Data Layout ---
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Column 1: Academic & Registry
                  Expanded(
                    child: _buildVerticalDataGroup("ACADEMIC", [
                      _gridItem("Class Name", data['className']),
                      _gridItem("Medium", data['medium']),
                      _gridItem("Admission ID", data['admissionId']),
                      _gridItem("Prev. School", data['prevSchool']),
                      _gridItem("TC Number", data['tcNumber']),
                    ]),
                  ),
                  const VerticalDivider(width: 40, color: Color(0xFFF1F5F9)),

                  // Column 2: Personal
                  Expanded(
                    child: _buildVerticalDataGroup("PERSONAL", [
                      _gridItem("Gender", data['gender']),
                      _gridItem("Date of Birth", _formatDate(data['dob'])),
                      _gridItem("Age", data['age']),
                      _gridItem("Religion", data['religion']),
                      _gridItem("Aadhar Number", data['aadhar']),
                    ]),
                  ),
                  const VerticalDivider(width: 40, color: Color(0xFFF1F5F9)),

                  // Column 3: Family
                  Expanded(
                    child: _buildVerticalDataGroup("FAMILY", [
                      _gridItem("Parent/Guardian", data['parentGuardian']),
                      _gridItem("Relation", data['relation']),
                      _gridItem("Mother's Name", data['motherName']),
                      _gridItem("Father's Job", data['fatherProfession']),
                    ]),
                  ),
                  const VerticalDivider(width: 40, color: Color(0xFFF1F5F9)),

                  // Column 4: Contact & Identity
                  Expanded(
                    child: _buildVerticalDataGroup("CONTACT", [
                      _gridItem("Phone", data['phone']),
                      _gridItem("WhatsApp", data['whatsapp']),
                      _gridItem("Place", data['place']),
                      _gridItem("ID Mark", data['identificationMark']),
                    ]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- Address Footer ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("RESIDENTIAL ADDRESS",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                  const SizedBox(height: 6),
                  Text(data['address'] ?? "No address recorded.",
                      style: const TextStyle(fontSize: 14, color: Color(0xFF334155), fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// Update this helper to use less padding
  Widget _buildVerticalDataGroup(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF0F766E), letterSpacing: 1.2),
        ),
        const SizedBox(height: 16), // Reduced
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 16), // Reduced from 24
          child: item,
        )).toList(),
      ],
    );
  }


// Optimized Grid Item for Horizontal View
  Widget _gridItem(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(
          value ?? "N/A",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
        ),
      ],
    );
  }
// Support Method for Horizontal Layout
  Widget _buildHorizontalGridSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 1),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 30,
          runSpacing: 20,
          children: items.map((item) => SizedBox(width: 140, child: item)).toList(),
        ),
      ],
    );
  }



// Helper for horizontal grid
  Widget _horizontalInfoGrid(String section, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(section, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
        const Divider(),
        const SizedBox(height: 10),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: items.map((item) => SizedBox(width: 150, child: item)).toList(),
        ),
      ],
    );
  }


  String _formatDate(dynamic date) {
    if (date == null) return "N/A";
    if (date is Timestamp) {
      // Converts Firestore Timestamp to 'dd MMM yyyy' (e.g., 14 Apr 2026)
      return DateFormat('dd MMM yyyy').format(date.toDate());
    }
    return date.toString(); // Fallback if it's already a string
  }
  Widget _buildDetailSheet(Map<String, dynamic> data) {
    return Container(
      // Removing fixed height and using padding to let it breathe
      padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView( // Keeps it usable on smaller screens

        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Elegant Handle Bar
            Center(
              child: Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 25),

            // --- Profile Header Card ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Hero(
                    tag: data['admissionId'] ?? 'profile',
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: const Color(0xFF0F766E),
                      child: Text(
                        data['name']?[0].toUpperCase() ?? "S",
                        style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['name'] ?? "N/A",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _badge("ID: ${data['admissionId']}", Colors.blueGrey),
                            const SizedBox(width: 8),
                            _badge("CLASS ${data['className']}", const Color(0xFF0F766E)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- Information Sections ---
            _buildInfoSection(
              title: "Academic Records",
              icon: Icons.school_outlined,
              children: [
                _rowItem("Roll Number", data['rollNo'] ?? "Not Assigned"),
                _rowItem("Admission Date", _formatDate(data['admissionDate'])),
                _rowItem("Academic Status", "Active", isStatus: true),
              ],
            ),

            _buildInfoSection(
              title: "Personal Profile",
              icon: Icons.person_outline_rounded,
              children: [
                _rowItem("Date of Birth", _formatDate(data['dob'])),
                _rowItem("Gender", data['gender']),
                _rowItem("Blood Group", data['bloodGroup']),
              ],
            ),

            _buildInfoSection(
              title: "Guardian Details",
              icon: Icons.family_restroom_outlined,
              children: [
                _rowItem("Parent Name", data['parentGuardian']),
                _rowItem("Relationship", data['relation']),
                _rowItem("Primary Phone", data['phone']),
                _rowItem("WhatsApp", data['whatsapp']),
              ],
            ),

            _buildInfoSection(
              title: "Residential Address",
              icon: Icons.home_outlined,
              isLast: true,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    data['address'] ?? "No address provided.",
                    style: const TextStyle(color: Color(0xFF475569), height: 1.5, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

// --- Modern UI Components ---

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color),
      ),
    );
  }

  Widget _buildInfoSection({required String title, required IconData icon, required List<Widget> children, bool isLast = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF64748B)),
            const SizedBox(width: 10),
            Text(
              title.toUpperCase(),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 1.2),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
        if (!isLast) ...[
          const SizedBox(height: 24),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _rowItem(String label, String? value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8))),
          if (isStatus)
            _badge("ACTIVE", Colors.green)
          else
            Text(
              value ?? "N/A",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
            ),
        ],
      ),
    );
  }

  // --- Helper Widgets for UI Consistency ---

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 1)),
    );
  }

  Widget _infoGrid(List<Widget> children) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: children.map((w) => SizedBox(width: (MediaQuery.of(context).size.width / 2) - 40, child: w)).toList(),
    );
  }

  Widget _infoTile(String label, String? value, {bool isStatus = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        isStatus
            ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
          child: const Text("ACTIVE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
        )
            : Text(value ?? "N/A", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
      ],
    );
  }
  Widget _detailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
          Text(value ?? "Not Provided", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}