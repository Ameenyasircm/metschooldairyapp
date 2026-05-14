import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DivisionDashboard extends StatefulWidget {
  final String divisionId;
  final String divisionName;
  final String className;
  final String classId;
  final String academicYearId;
  final String classTeacherName;
  final String classTeacherId;

  const DivisionDashboard({
    super.key,
    required this.divisionId,
    required this.divisionName,
    required this.className,
    required this.classId,
    required this.academicYearId,
    required this.classTeacherName,
    required this.classTeacherId,
  });

  @override
  State<DivisionDashboard> createState() => _DivisionDashboardState();
}

class _DivisionDashboardState extends State<DivisionDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Dropdown States
  String? selectedTeacherId;
  String? selectedTeacherName;
  String? selectedSubject;

  // Modern Web Palette
  final Color primaryDark = const Color(0xFF0F172A); // Slate 900
  final Color accentBlue = const Color(0xFF2563EB); // Blue 600
  final Color bgSlate = const Color(0xFFF8FAFC);   // Slate 50
  final Color borderGray = const Color(0xFFE2E8F0); // Slate 200

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- PRESERVED LOGIC: SUBJECT TEACHER ASSIGNMENT ---
  Future<void> _assignTeacherToSubject({bool isEdit = false}) async {
    if (selectedTeacherId == null || selectedSubject == null) return;
    try {
      final subjectSnap = await FirebaseFirestore.instance
          .collection('subjects')
          .where('name', isEqualTo: selectedSubject)
          .limit(1)
          .get();

      if (subjectSnap.docs.isEmpty) {
        _showSnackBar("Subject details not found in master list", Colors.red);
        return;
      }

      final String subjectId = subjectSnap.docs.first.id;
      final String assignmentKey = "${widget.divisionId}_$subjectId";

      final divDoc = await FirebaseFirestore.instance.collection('divisions').doc(widget.divisionId).get();
      final existingTeachers = (divDoc.data() as Map<String, dynamic>)['subject_teachers'] ?? {};

      if (!isEdit && existingTeachers.containsKey(selectedSubject)) {
        _showSnackBar("$selectedSubject is already assigned", Colors.orange);
        return;
      }

      final batch = FirebaseFirestore.instance.batch();
      DocumentReference divRef = FirebaseFirestore.instance.collection('divisions').doc(widget.divisionId);
      DocumentReference assignRef = FirebaseFirestore.instance.collection('subject_assignments').doc(assignmentKey);

      batch.update(divRef, {
        'subject_teachers.$selectedSubject': {
          'teacher_id': selectedTeacherId,
          'teacher_name': selectedTeacherName,
          'subject_id': subjectId,
          'assigned_at': FieldValue.serverTimestamp(),
        }
      });

      batch.set(assignRef, {
        'assignment_id': assignmentKey,
        'teacher_id': selectedTeacherId,
        'teacher_name': selectedTeacherName,
        'subject_id': subjectId,
        'subject_name': selectedSubject,
        'division_id': widget.divisionId,
        'division_name': widget.divisionName,
        'class_id': widget.classId,
        'academic_year_id': widget.academicYearId,
        'type': 'subject_teacher',
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await batch.commit();
      if (mounted) Navigator.pop(context);
      _showSnackBar("Assignment Successful", Colors.green);
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  // --- PRESERVED LOGIC: REMOVE SUBJECT TEACHER ---
  Future<void> _removeSubjectTeacher(String subjectName, String teacherId) async {
    try {
      final subjectSnap = await FirebaseFirestore.instance
          .collection('subjects')
          .where('name', isEqualTo: subjectName)
          .limit(1)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      batch.update(FirebaseFirestore.instance.collection('divisions').doc(widget.divisionId), {
        'subject_teachers.$subjectName': FieldValue.delete()
      });

      if (subjectSnap.docs.isNotEmpty) {
        String subId = subjectSnap.docs.first.id;
        batch.delete(FirebaseFirestore.instance.collection('subject_assignments').doc("${widget.divisionId}_$subId"));
      }

      await batch.commit();
      _showSnackBar("Assignment removed", Colors.blueGrey);
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  // --- PRESERVED LOGIC: UPDATE CLASS TEACHER ---
  Future<void> _updateClassTeacher(String newTeacherId, String newTeacherName) async {
    try {
      final divSnap = await FirebaseFirestore.instance.collection('divisions').doc(widget.divisionId).get();
      final String oldTeacherId = divSnap.get('class_teacher_id');
      final batch = FirebaseFirestore.instance.batch();

      batch.update(FirebaseFirestore.instance.collection('divisions').doc(widget.divisionId), {
        'class_teacher_id': newTeacherId,
        'class_teacher_name': newTeacherName,
      });

      final removeFlag = {'current_assignment': FieldValue.delete(), 'is_class_teacher': false};
      batch.set(FirebaseFirestore.instance.collection('staff_profiles').doc(oldTeacherId), removeFlag, SetOptions(merge: true));
      batch.set(FirebaseFirestore.instance.collection('users').doc(oldTeacherId), removeFlag, SetOptions(merge: true));

      final addFlag = {
        'current_assignment': {
          'class_id': widget.classId,
          'class_name': widget.className,
          'division_id': widget.divisionId,
          'division_name': widget.divisionName,
        },
        'is_class_teacher': true,
      };
      batch.set(FirebaseFirestore.instance.collection('staff_profiles').doc(newTeacherId), addFlag, SetOptions(merge: true));
      batch.set(FirebaseFirestore.instance.collection('users').doc(newTeacherId), addFlag, SetOptions(merge: true));

      await batch.commit();
      _showSnackBar("Class Teacher Updated", Colors.green);
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: bgSlate,
      appBar: _buildWebAppBar(),
      body: Column(
        children: [
          _buildNavigationHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStudentSection(isWeb),
                _buildManagementSection(isWeb),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildWebAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(icon: Icon(Icons.arrow_back, color: primaryDark), onPressed: () => Navigator.pop(context)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${widget.className} - ${widget.divisionName}",
              style: TextStyle(color: primaryDark, fontWeight: FontWeight.bold, fontSize: 18)),
          Text("Academic Period: ${widget.academicYearId}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),

    );
  }

  Widget _buildNavigationHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: borderGray)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: accentBlue,
        unselectedLabelColor: Colors.blueAccent,
        indicatorColor: accentBlue,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: "STUDENTS"),
          Tab(text: "FACULTY & SUBJECTS"),
        ],
      ),
    );
  }

  // --- ENHANCED STUDENT VIEW ---
  Widget _buildStudentSection(bool isWeb) {
    return Padding(
      padding: EdgeInsets.all(isWeb ? 30 : 15),
      child: Column(
        children: [
          _buildSearchAndActionHeader(),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderGray),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('enrollments').where('division_id', isEqualTo: widget.divisionId).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  var docs = snapshot.data!.docs.where((d) {
                    final name = d['student_name'].toString().toLowerCase();
                    final enroll = d['enrollment_id'].toString().toLowerCase();
                    return name.contains(_searchQuery) || enroll.contains(_searchQuery);
                  }).toList();

                  if (docs.isEmpty) return _buildEmptyState("No students found in this division");

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: docs.length,
                    separatorBuilder: (context, index) => Divider(height: 1, color: borderGray),
                    itemBuilder: (context, i) {
                      var d = docs[i].data() as Map<String, dynamic>;
                      return ListTile(
                        leading: CircleAvatar(backgroundColor: bgSlate, child: Text("${i+1}", style: TextStyle(color: accentBlue, fontSize: 12))),
                        title: Text(d['student_name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text("Enrollment ID: ${d['enrollment_id']}"),
                        trailing: Text("Roll: ${d['roll_number'] ?? '-'}", style: TextStyle(color: accentBlue, fontWeight: FontWeight.bold)),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndActionHeader() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: borderGray)),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: const InputDecoration(hintText: "Search students...", prefixIcon: Icon(Icons.search, size: 20), border: InputBorder.none),
            ),
          ),
        ),
        const SizedBox(width: 15),

      ],
    );
  }

  // --- ENHANCED MANAGEMENT SECTION ---
  Widget _buildManagementSection(bool isWeb) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('divisions').doc(widget.divisionId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var data = snapshot.data!.data() as Map<String, dynamic>;
        Map<String, dynamic> subjectMap = data['subject_teachers'] ?? {};

        return SingleChildScrollView(
          padding: EdgeInsets.all(isWeb ? 30 : 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isWeb) _buildWebSidebar(data),
              if (isWeb) const SizedBox(width: 30),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isWeb) _buildMobileTeacherCard(data),
                    const SizedBox(height: 10),
                    _buildSectionTitle("Subject Specialists", () => _showSubjectDialog()),
                    const SizedBox(height: 15),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isWeb ? 3 : 1,
                        childAspectRatio: isWeb ? 2.5 : 4,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                      ),
                      itemCount: subjectMap.length,
                      itemBuilder: (context, index) {
                        String key = subjectMap.keys.elementAt(index);
                        return _buildSubjectGridItem(key, subjectMap[key]);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWebSidebar(Map<String, dynamic> data) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: primaryDark, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          const CircleAvatar(radius: 35, backgroundColor: Colors.white10, child: Icon(Icons.person, color: Colors.white, size: 30)),
          const SizedBox(height: 15),
          Text(data['class_teacher_name'] ?? "-", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const Text("Primary Class Teacher", style: TextStyle(color: Colors.white60, fontSize: 12)),


          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => _showClassTeacherPicker(),
            style: ElevatedButton.styleFrom(backgroundColor: accentBlue, minimumSize: const Size(double.infinity, 45), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text("Replace Teacher", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildMobileTeacherCard(Map<String, dynamic> data) {
    return Card(
      color: primaryDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(data['class_teacher_name'] ?? "-", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: const Text("Class Teacher", style: TextStyle(color: Colors.white70)),
        trailing: IconButton(icon: const Icon(Icons.edit, color: Colors.white), onPressed: () => _showClassTeacherPicker()),
      ),
    );
  }

  Widget _buildSubjectGridItem(String subject, dynamic details) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderGray)),
      child: Row(
        children: [
          Container(height: 40, width: 40, decoration: BoxDecoration(color: bgSlate, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.book_outlined, color: accentBlue, size: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(details['teacher_name'], style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_horiz, size: 20),
            itemBuilder: (context) => [
              PopupMenuItem(child: const Text("Edit"), onTap: () => Future.delayed(Duration.zero, () => _showSubjectDialog(editSub: subject, editId: details['teacher_id']))),
              PopupMenuItem(child: const Text("Remove", style: TextStyle(color: Colors.red)), onTap: () => _removeSubjectTeacher(subject, details['teacher_id'])),
            ],
          )
        ],
      ),
    );
  }

  // --- HELPERS ---
  Widget _buildSectionTitle(String title, VoidCallback onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: primaryDark, fontWeight: FontWeight.bold, fontSize: 18)),
        TextButton.icon(onPressed: onAdd, icon: const Icon(Icons.add_circle_outline, size: 20), label: const Text("Assign New"))
      ],
    );
  }

  Widget _sidebarInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [Icon(icon, color: Colors.white38, size: 16), const SizedBox(width: 10), Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13))]),
    );
  }

  Widget _buildEmptyState(String msg) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.folder_open, size: 50, color: borderGray), const SizedBox(height: 10), Text(msg, style: TextStyle(color: Colors.grey.shade400))]));

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating));
  }

  // --- REUSED DIALOGS ---
  void _showSubjectDialog({String? editSub, String? editId}) {
    selectedSubject = editSub;
    selectedTeacherId = editId;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setST) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(editSub == null ? "Assign Specialist" : "Edit $editSub Instructor"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('staff_profiles').where('role', isEqualTo: 'teacher').snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) return const LinearProgressIndicator();
                  return DropdownButtonFormField<String>(
                    value: selectedTeacherId,
                    decoration: const InputDecoration(labelText: "Select Teacher"),
                    items: snap.data!.docs.map((d) => DropdownMenuItem(value: d.id, child: Text(d['name']))).toList(),
                    onChanged: (v) => setST(() {
                      selectedTeacherId = v;
                      selectedTeacherName = snap.data!.docs.firstWhere((d) => d.id == v)['name'];
                    }),
                  );
                },
              ),
              const SizedBox(height: 15),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('subjects').snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) return const LinearProgressIndicator();
                  return DropdownButtonFormField<String>(
                    value: selectedSubject,
                    decoration: const InputDecoration(labelText: "Select Subject"),
                    items: snap.data!.docs.map((d) => DropdownMenuItem(value: d['name'].toString(), child: Text(d['name']))).toList(),
                    onChanged: editSub != null ? null : (v) => setST(() => selectedSubject = v),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(onPressed: () => _assignTeacherToSubject(isEdit: editSub != null), child: const Text("Save Assignment")),
          ],
        ),
      ),
    );
  }

  void _showClassTeacherPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.all(20), child: Text("Promote New Class Teacher", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('staff_profiles').where('role', isEqualTo: 'teacher').snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  return ListView(
                    children: snap.data!.docs.map((d) => ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(d['name']),
                      onTap: () { _updateClassTeacher(d.id, d['name']); Navigator.pop(context); },
                    )).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}