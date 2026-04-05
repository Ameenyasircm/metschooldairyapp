import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AdminProvider with ChangeNotifier {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final FirebaseDatabase realtime = FirebaseDatabase.instance;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // --- STAFF LOGIC ---

  // Stream for Real-time List
  Stream<QuerySnapshot> getStaffStream() {
    return fireStore.collection('staff_profiles').orderBy('name').snapshots();
  }

  Future<void> saveStaffFull({
    String? docId,
    required Map<String, dynamic> userData,
    required Map<String, dynamic> profileData,
  }) async {
    final batch = fireStore.batch();

    // If docId is null, we generate a new one
    DocumentReference userRef = docId == null ? fireStore.collection('users').doc() : fireStore.collection('users').doc(docId);

    DocumentReference profileRef = fireStore.collection('staff_profiles').doc(userRef.id);

    batch.set(userRef, userData, SetOptions(merge: true));
    batch.set(profileRef, profileData, SetOptions(merge: true));

    await batch.commit();
  }

  // Delete Staff
  Future<void> removeStaff(String docId) async {
    await fireStore.collection('staff_profiles').doc(docId).delete();
  }

  List<QueryDocumentSnapshot> academicYears = [];
  bool isLoading = false;

  /// ================= FETCH =================
  Future<void> fetchAcademicYears() async {
    isLoading = true;
    notifyListeners();

    try {
      final snapshot = await fireStore
          .collection("academic_years")
          .orderBy("start_date", descending: true)
          .get();

      academicYears = snapshot.docs;
    } catch (e) {
      debugPrint("Error fetching years: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  /// ================= ADD =================
  Future<void> addAcademicYear({
    required String yearName,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      await fireStore.collection("academic_years").add({
        "year_name": yearName,
        "is_current": false,
        "start_date": startDate,
        "end_date": endDate,
      });

      await fetchAcademicYears();
    } catch (e) {
      debugPrint("Error adding year: $e");
    }
  }

  /// ================= SET CURRENT =================
  Future<void> setCurrentYear(String docId) async {
    try {
      /// 🔥 Make all false first
      final snapshot = await fireStore.collection("academic_years").get();

      for (var doc in snapshot.docs) {
        await doc.reference.update({"is_current": false});
      }

      /// ✅ Set selected one true
      await fireStore
          .collection("academic_years")
          .doc(docId)
          .update({"is_current": true});

      await fetchAcademicYears();
    } catch (e) {
      debugPrint("Error setting current year: $e");
    }
  }

}