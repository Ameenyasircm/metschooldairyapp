import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AcademicProvider extends ChangeNotifier {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  List<Map<String, String>> formattedClasses = [];
  bool isClassLoading = false;

  Future<void> fetchClasses({bool forceRefresh = false}) async {
    // Return early only if we aren't forcing a refresh and data exists
    if (!forceRefresh && formattedClasses.isNotEmpty) return;

    isClassLoading = true;
    notifyListeners();

    try {
      final snapshot = await db.collection('classes').orderBy('name').get();

      // Clear and map to ensure no "ghost" duplicates exist
      formattedClasses = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          "id": (data['id'] ?? doc.id).toString(),
          "name": (data['name'] ?? "Unnamed Class").toString(),
        };
      }).toList();

      debugPrint("Successfully loaded ${formattedClasses.length} unique classes.");
    } catch (e) {
      debugPrint("Firestore fetch error: $e");
    } finally {
      isClassLoading = false;
      notifyListeners();
    }
  }

  /// 🔹 ADD STUDENT
  Future<void> addStudent({required Map<String, dynamic> studentData}) async {
    try {
      String docId = DateTime.now().millisecondsSinceEpoch.toString();
      Map<String, dynamic> finalData = {
        ...studentData,
        "id": docId,
        "createdAt": FieldValue.serverTimestamp(),
      };
      await db.collection("students").doc(docId).set(finalData);
      await fetchStudents(); // Refresh the first page
    } catch (e) {
      debugPrint("Error adding student: $e");
    }
  }

  /// 🔹 UPDATE STUDENT
  Future<void> updateStudent(String docId, Map<String, dynamic> updatedData) async {
    try {
      await db.collection("students").doc(docId).update(updatedData);
      // Manually update the local list to reflect changes immediately without a full refetch
      int index = studentsList.indexWhere((doc) => doc.id == docId);
      if (index != -1) {
        await fetchStudents();
      }
    } catch (e) {
      debugPrint("Update Error: $e");
    }
  }

  /// 🔹 DELETE STUDENT
  Future<void> deleteStudent(String docId) async {
    try {
      await db.collection("students").doc(docId).delete();
      studentsList.removeWhere((doc) => doc.id == docId);
      notifyListeners();
    } catch (e) {
      debugPrint("Delete Error: $e");
    }
  }

  // --- Pagination Logic ---
  List<DocumentSnapshot> studentsList = [];
  bool isStudentLoading = false;
  bool isMoreLoading = false;
  DocumentSnapshot? lastDocument;
  bool hasMoreData = true;
  final int limit = 15;

  Future<void> fetchStudents() async {
    try {
      isStudentLoading = true;
      notifyListeners();

      final snapshot = await db.collection("students")
          .orderBy("createdAt", descending: true)
          .limit(limit)
          .get();

      studentsList = snapshot.docs;
      lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      hasMoreData = snapshot.docs.length == limit;
    } catch (e) {
      debugPrint("Fetch Students Error: $e");
    } finally {
      isStudentLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMoreStudents() async {
    if (!hasMoreData || isMoreLoading || lastDocument == null) return;
    try {
      isMoreLoading = true;
      notifyListeners();

      final snapshot = await db.collection("students")
          .orderBy("createdAt", descending: true)
          .startAfterDocument(lastDocument!)
          .limit(limit)
          .get();

      if (snapshot.docs.isNotEmpty) {
        studentsList.addAll(snapshot.docs);
        lastDocument = snapshot.docs.last;
      }
      hasMoreData = snapshot.docs.length == limit;
    } catch (e) {
      debugPrint("Fetch More Error: $e");
    } finally {
      isMoreLoading = false;
      notifyListeners();
    }
  }
}