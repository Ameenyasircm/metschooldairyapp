import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import '../models/event_model.dart';
import '../../../students/data/models/tech_student_model.dart';

class EventService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _cloudName = 'dt9qsvvp2';
  static const String _uploadPreset = 'METSCHOOL';

  final CloudinaryPublic _cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);

  Future<String> uploadAttachment(File file) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: CloudinaryResourceType.Auto,
          folder: 'events',
        ),
      );
      return response.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload attachment to Cloudinary: $e');
    }
  }

  Future<void> saveEvent(EventModel event) async {
    await _db.collection('events').doc(event.id).set(event.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteEvent(String eventId) async {
    await _db.collection('events').doc(eventId).delete();
  }

  Future<QuerySnapshot> getEvents({
    DocumentSnapshot? lastDoc,
    String? classId,
    String? divisionId,
    String? academicYearId,
  }) async {
    Query query = _db.collection('events').orderBy('dateTime', descending: true);

    if (academicYearId != null && academicYearId.isNotEmpty) {
      query = query.where('academic_year_id', isEqualTo: academicYearId);
    }
    
    if (classId != null && classId.isNotEmpty) {
      query = query.where('class_id', isEqualTo: classId);
    }
    if (divisionId != null && divisionId.isNotEmpty) {
      query = query.where('division_id', isEqualTo: divisionId);
    }

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    return await query.limit(15).get();
  }

  Future<void> updateStudentTaskStatus(
    String eventId,
    StudentEventTaskModel task,
  ) async {
    await _db
        .collection('events')
        .doc(eventId)
        .collection('student_tasks')
        .doc(task.studentId)
        .set(task.toMap(), SetOptions(merge: true));
  }

  Stream<List<StudentEventTaskModel>> getStudentTasksStream(
    String eventId,
  ) {
    return _db
        .collection('events')
        .doc(eventId)
        .collection('student_tasks')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                StudentEventTaskModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<StudentEventTaskModel?> getStudentTask(
    String eventId,
    String studentId,
  ) async {
    final doc = await _db
        .collection('events')
        .doc(eventId)
        .collection('student_tasks')
        .doc(studentId)
        .get();

    if (doc.exists) {
      return StudentEventTaskModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<List<EnrollerModel>> getStudentsForClass(
    String classId,
    String divisionId,
  ) async {
    final snapshot = await _db
        .collection('enrollments')
        .where('class_id', isEqualTo: classId)
        .where('division_id', isEqualTo: divisionId)
        .orderBy('roll_number')
        .get();

    return snapshot.docs
        .map((doc) => EnrollerModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}
