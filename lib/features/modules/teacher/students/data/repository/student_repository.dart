import '../datasource/student_firestore.dart';
import '../models/tech_student_model.dart';

class StudentRepository {
  final StudentFirestore firestore;

  StudentRepository(this.firestore);

  Future<List<TechStudentModel>> getStudents({
    String search = '',
    bool isFirst = false,
  }) async {
    final docs = await firestore.fetchStudents(
      search: search,
      isFirst: isFirst,
    );

    return docs
        .map((e) => TechStudentModel.fromMap(e.data() as Map<String, dynamic>))
        .toList();
  }

  void resetPagination() {
    firestore.reset();
  }
}