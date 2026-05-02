import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class ParentProvider with ChangeNotifier {

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final FirebaseDatabase realtime = FirebaseDatabase.instance;

  String stdID = "";
  String name = "";
  String className = "";
  String parentName = "";
  String classId = "";

  bool isLoading = false;

  Future<void> fetchStudent(String studentId) async {
    isLoading = true;
    notifyListeners();

    try {
      final doc = await FirebaseFirestore.instance
          .collection("students")
          .doc(studentId)
          .get();

      if (doc.exists) {
        final data = doc.data() ?? {};

        name = data['name'] ?? "";
        className = data['className'] ?? "";
        parentName = data['parentGuardian'] ?? "";
        classId = data['current_class_id'] ?? "";
      }
    } catch (e) {
      debugPrint("Error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

}