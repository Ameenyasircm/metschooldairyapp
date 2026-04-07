import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../../core/service/firebase_service.dart';
import '../models/tech_division_model.dart';

class StudentFirestore {
  final _db = FirebaseService.firestore;

  Future<QuerySnapshot> fetchCollection({
    required String collectionPath,
    int limit = 10,
    DocumentSnapshot? startAfter,
    Query Function(Query)? queryBuilder,
  }) async {
    Query query = _db.collection(collectionPath);
    
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return await query.limit(limit).get();
  }

  Future<String?> currentAcademicYearId() async {
    final query = await _db
        .collection('academic_years')
        .where('is_current', isEqualTo: true)
        .limit(1)
        .get();

    return query.docs.isNotEmpty ? query.docs.first.id : null;
  }

  Future<DivisionModel?> getTeacherClass({required String teacherId}) async {
    try {
      final academicId = await currentAcademicYearId();
      if (academicId == null) return null;
      final query = await _db
          .collection('divisions')
          .where('class_teacher_id', isEqualTo: teacherId)
          .where('academic_year_id', isEqualTo: academicId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      return DivisionModel.fromDoc(query.docs.first);
    } catch (e) {
      return null;
    }
  }
}
