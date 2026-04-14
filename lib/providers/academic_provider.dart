import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AcademicProvider extends ChangeNotifier {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  List<Map<String, String>> formattedClasses = [];
  bool isClassLoading = false;

  // --- Class Fetching ---
  Future<void> fetchClasses({bool forceRefresh = false}) async {
    if (!forceRefresh && formattedClasses.isNotEmpty) return;

    isClassLoading = true;
    notifyListeners();

    try {
      final snapshot = await db.collection('classes').orderBy('name').get();
      formattedClasses = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          "id": (data['id'] ?? doc.id).toString(),
          "name": (data['name'] ?? "Unnamed Class").toString(),
        };
      }).toList();
    } catch (e) {
      debugPrint("Firestore fetch error: $e");
    } finally {
      isClassLoading = false;
      notifyListeners();
    }
  }

  /// 🔹 ADD STUDENT (Updated for Milliseconds ID)
  Future<void> addStudent({required Map<String, dynamic> studentData}) async {
    try {
      // Logic: Use Milliseconds as the actual Firestore Document ID
      String docId = DateTime.now().millisecondsSinceEpoch.toString();

      Map<String, dynamic> finalData = {
        ...studentData,
        "id": docId, // Keep the Document ID inside the fields for easy reference
        "createdAt": FieldValue.serverTimestamp(),
      };

      // Set document with the timestamp ID
      await db.collection("students").doc(docId).set(finalData);

      // Refresh list
      await fetchStudents();
    } catch (e) {
      debugPrint("Error adding student: $e");
      rethrow;
    }
  }

  /// 🔹 UPDATE STUDENT
  Future<void> updateStudent(String docId, Map<String, dynamic> updatedData) async {
    try {
      await db.collection("students").doc(docId).update(updatedData);

      // Refresh the local list to reflect changes immediately
      await fetchStudents();
    } catch (e) {
      debugPrint("Update Error: $e");
      rethrow;
    }
  }

  // --- Pagination & List Logic ---
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
          .orderBy("updatedAt", descending: true) // Using updatedAt so newly edited/added appear first
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
          .orderBy("updatedAt", descending: true)
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

  /// 🔹 GENERATE CONTINUOUS ADMISSION ID
  Future<String> generateAdmissionId(String classId) async {
    bool isKG = classId.toLowerCase().contains("kg");
    String counterDoc = isKG ? "kg_counter" : "std_counter";

    DocumentReference ref = db.collection("counters").doc(counterDoc);

    return await db.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(ref);

      if (!snapshot.exists) {
        int initialValue = isKG ? 1 : 1001;
        transaction.set(ref, {"last_val": initialValue});
        return isKG ? "KG ${initialValue.toString().padLeft(3, '0')}" : initialValue.toString();
      }

      int newVal = (snapshot.get("last_val") as int) + 1;
      transaction.update(ref, {"last_val": newVal});

      return isKG
          ? "KG ${newVal.toString().padLeft(3, '0')}"
          : newVal.toString().padLeft(4, '0');
    });
  }

  /// 🔹 SOFT DELETE
  Future<void> deleteStudentWithLog(String docId) async {
    try {
      DocumentSnapshot studentDoc = await db.collection("students").doc(docId).get();
      if (!studentDoc.exists) return;

      Map<String, dynamic> data = studentDoc.data() as Map<String, dynamic>;

      await db.collection("deleted_students").doc(docId).set({
        ...data,
        "deletedAt": FieldValue.serverTimestamp(),
        "status": "Archived",
      });

      await db.collection("students").doc(docId).delete();

      studentsList.removeWhere((doc) => doc.id == docId);
      notifyListeners();
    } catch (e) {
      debugPrint("Delete Log Error: $e");
    }
  }
}