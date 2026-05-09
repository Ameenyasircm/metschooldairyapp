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
  String rollNo = "";
  String studentImage = "";
  String parentName = "";
  String classId = "";

  Map<String, dynamic>? studentData;

  bool isLoading = false;

  Future<void> fetchStudent({
    required String studentId,
    required String academicYearId,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("enrollments")
          .where('academic_year_id', isEqualTo: academicYearId)
          .where('student_id', isEqualTo: studentId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        studentData = snapshot.docs.first.data();
        final data = studentData!;

        name = data['student_name']?.toString() ?? "";
        className = data['class_name']?.toString() ?? "";
        rollNo = data['roll_number']?.toString() ?? "";
        studentImage = data['photoUrl']?.toString() ?? "";
        parentName = data['parentGuardian']?.toString() ?? "";
        classId = data['class_id']?.toString() ?? "";
      } else {
        debugPrint("Student not found");

        name = "";
        className = "";
        rollNo = "";
        studentImage = "";
        parentName = "";
        classId = "";
      }
    } catch (e) {
      debugPrint("Error fetching student: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}