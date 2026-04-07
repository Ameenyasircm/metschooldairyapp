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


  /// OPTIONAL (for your navigation)
  int selectedIndex = 0;

  void setIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }


  List<DocumentSnapshot> studentsList = [];

  bool isStudentLoading = false;
  bool isMoreLoading = false;

  DocumentSnapshot? lastDocument;
  bool hasMoreData = true;

  final int limit = 15;

  /// ================= INITIAL FETCH =================
  Future<void> fetchStudents() async {
    try {
      isStudentLoading = true;
      notifyListeners();

      final snapshot = await db
          .collection("students")
          .orderBy("createdAt", descending: true)
          .limit(limit)
          .get();

      studentsList = snapshot.docs;

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
      }

      hasMoreData = snapshot.docs.length == limit;

      isStudentLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint("Error: $e");
      isStudentLoading = false;
      notifyListeners();
    }
  }

  /// ================= LOAD MORE =================
  Future<void> fetchMoreStudents() async {
    if (!hasMoreData || isMoreLoading || lastDocument == null) return;

    try {
      isMoreLoading = true;
      notifyListeners();

      final snapshot = await db
          .collection("students")
          .orderBy("createdAt", descending: true)
          .startAfterDocument(lastDocument!)
          .limit(limit)
          .get();

      if (snapshot.docs.isNotEmpty) {
        studentsList.addAll(snapshot.docs);
        lastDocument = snapshot.docs.last;
      }

      hasMoreData = snapshot.docs.length == limit;

      isMoreLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint("Pagination Error: $e");
      isMoreLoading = false;
      notifyListeners();
    }
  }


}