import 'package:cloud_firestore/cloud_firestore.dart';
import '../datasource/student_firestore.dart';
import '../models/tech_division_model.dart';
import '../models/tech_student_model.dart';

class StudentRepository {
  final StudentFirestore firestore;

  StudentRepository(this.firestore);

  Future<QuerySnapshot> getStudents({
    DocumentSnapshot? lastDoc,
    int limit = 10,
    bool isMyStudents = false,
    String? divisionId,
  }) async {
    return await firestore.fetchCollection(
      collectionPath: isMyStudents ? 'enrollments' : 'students',
      limit: limit,
      startAfter: lastDoc,
      queryBuilder: (query) {
        var q = query.orderBy('name');
        if (isMyStudents && divisionId != null) {
          q = q.where('division_id', isEqualTo: divisionId);
        }
        return q;
      },
    );
  }

  Future<DivisionModel?> getTeacherClassDivision({required String teacherId}) async {
    return await firestore.getTeacherClass(teacherId: teacherId);
  }
}
