import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../datasource/student_firestore.dart';
import '../models/tech_student_model.dart';

class StudentRepository {
  final StudentFirestore firestore;

  StudentRepository(this.firestore);

  Future<QuerySnapshot> getStudents({
    DocumentSnapshot? lastDoc,
    int limit = 10,
    bool isMyStudents = false,
    String? classId,
  }) async {
    return await firestore.fetchCollection(
      collectionPath: isMyStudents ? 'enrollments' : 'students',
      limit: limit,
      startAfter: lastDoc,
      queryBuilder: (query) {
        var q = query.orderBy(isMyStudents ? 'student_name' : 'name');

        if (isMyStudents) {
          if (classId != null) {
            q = q.where('class_id', isEqualTo: classId);
          }
        } else {
          if (classId != null) {
            q = q.where('classId', isEqualTo: classId);
          }
          q = q.where('isEnrolled', isEqualTo: false);
        }

        return q;
      },
    );
  }

  Future<List<EnrollerModel>> getEnrollmentsByDivision(String divisionId) async {
    final snapshot = await firestore.fetchCollection(
      collectionPath: 'enrollments',
      limit: 100,
      queryBuilder: (query) => query.where('division_id', isEqualTo: divisionId).orderBy('roll_number'),
    );
    return snapshot.docs.map((doc) => EnrollerModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>?> getParentById(String parentId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .get();

      if (doc.exists) {
        return doc.data();
      }
    } catch (e) {
      debugPrint("Error fetching parent: $e");
    }
    return null;
  }

}
