import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class AcademicProvider extends ChangeNotifier{
  final FirebaseFirestore db = FirebaseFirestore.instance;

  List<DocumentSnapshot> classesList = [];
  bool isClassLoading = false;

  /// 🔹 FETCH CLASSES
  Future<void> fetchClasses() async {
    isClassLoading = true;
    notifyListeners();

    try {
      final snapshot =
      await FirebaseFirestore.instance.collection('classes').get();

      classesList = snapshot.docs;
    } catch (e) {
      debugPrint("Error fetching classes: $e");
    }

    isClassLoading = false;
    notifyListeners();
  }

  /// 🔹 ADD CLASS
  Future<void> addClass(String className) async {
    try {
      final String docId = DateTime.now().millisecondsSinceEpoch.toString();

      await FirebaseFirestore.instance
          .collection('classes')
          .doc(docId)
          .set({
        "id": docId, // optional but recommended
        "name": className,
        "createdAt": Timestamp.now(),
      });

      fetchClasses(); // refresh
    } catch (e) {
      debugPrint("Error adding class: $e");
    }
  }


  List<DocumentSnapshot> studentsList = [];
  bool isStudentLoading = false;

  /// ================= ADD STUDENT =================
  Future<void> addStudent({
    required String name,
    required String admissionId,
    required String studentClass,
    required String gender,
    required DateTime? dob,
    required String phone,
    required String address,
  }) async {
    try {
      String docId = DateTime.now().millisecondsSinceEpoch.toString();

      await db.collection("students").doc(docId).set({
        "id": docId,
        "name": name,
        "admissionId": admissionId,
        "class": studentClass,
        "gender": gender,
        "dob": dob,
        "phone": phone,
        "address": address,
        "createdAt": FieldValue.serverTimestamp(),
      });

      await fetchStudents(); // refresh list
    } catch (e) {
      debugPrint("Error adding student: $e");
    }
  }

  /// ================= FETCH STUDENTS =================
  Future<void> fetchStudents() async {
    try {
      isStudentLoading = true;
      notifyListeners();

      final snapshot = await db
          .collection("students")
          .orderBy("createdAt", descending: true)
          .get();

      studentsList = snapshot.docs;

      isStudentLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching students: $e");
      isStudentLoading = false;
      notifyListeners();
    }
  }

  /// OPTIONAL (for your navigation)
  int selectedIndex = 0;

  void setIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }


}