import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/homework_model.dart';

class HomeworkService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<HomeworkModel>> getHomeworkList({
    required String classId,
    required String divisionId,
  }) async {
    final snapshot = await _db
        .collection('homework')
        .where('classId', isEqualTo: classId)
        .where('divisionId', isEqualTo: divisionId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => HomeworkModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<String> addHomework(HomeworkModel homework) async {
    final docRef = _db.collection('homework').doc();
    final homeworkData = homework.toMap();
    homeworkData['id'] = docRef.id;
    await docRef.set(homeworkData);
    return docRef.id;
  }

  Future<void> initializeSubmissions({
    required String homeworkId,
    required String classId,
    required String divisionId,
  }) async {
    final studentsSnapshot = await _db
        .collection('enrollments')
        .where('class_id', isEqualTo: classId)
        .where('division_id', isEqualTo: divisionId)
        .where('status', isEqualTo: 'active')
        .get();

    final batch = _db.batch();
    for (var doc in studentsSnapshot.docs) {
      final data = doc.data();
      final submissionRef = _db
          .collection('homework')
          .doc(homeworkId)
          .collection('submissions')
          .doc(data['student_id']);

      batch.set(submissionRef, {
        'studentId': data['student_id'],
        'studentName': data['student_name'],
        'status': 'pending',
        'updatedAt': FieldValue.serverTimestamp(),
        'parentPhone': data['parent_phone'],
      });
    }
    await batch.commit();
  }

  Future<List<HomeworkSubmissionModel>> getSubmissions(String homeworkId) async {
    final snapshot = await _db
        .collection('homework')
        .doc(homeworkId)
        .collection('submissions')
        .get();

    return snapshot.docs
        .map((doc) => HomeworkSubmissionModel.fromMap(doc.data()))
        .toList();
  }

  Future<void> updateSubmissionStatus({
    required String homeworkId,
    required String studentId,
    required String status,
  }) async {
    await _db
        .collection('homework')
        .doc(homeworkId)
        .collection('submissions')
        .doc(studentId)
        .update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
