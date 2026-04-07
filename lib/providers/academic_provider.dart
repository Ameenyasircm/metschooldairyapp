import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class AcademicProvider extends ChangeNotifier{
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
  }}