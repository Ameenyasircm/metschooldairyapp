import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import '../../../students/data/models/tech_student_model.dart';

class EventRepository {
  final EventService _service = EventService();

  Future<String> uploadAttachment(File file) => _service.uploadAttachment(file);

  Future<void> saveEvent(EventModel event) => _service.saveEvent(event);

  Future<void> deleteEvent(String eventId) => _service.deleteEvent(eventId);

  Future<QuerySnapshot> getEvents({
    DocumentSnapshot? lastDoc,
    String? classId,
    String? divisionId,
    String? academicYearId,
  }) => _service.getEvents(
        lastDoc: lastDoc,
        classId: classId,
        divisionId: divisionId,
        academicYearId: academicYearId,
      );

  Future<void> updateStudentTaskStatus(
    String eventId,
    StudentEventTaskModel task,
  ) =>
      _service.updateStudentTaskStatus(eventId, task);

  Stream<List<StudentEventTaskModel>> getStudentTasksStream(
    String eventId,
  ) =>
      _service.getStudentTasksStream(eventId);

  Future<StudentEventTaskModel?> getStudentTask(
    String eventId,
    String studentId,
  ) =>
      _service.getStudentTask(eventId, studentId);

  Future<List<EnrollerModel>> getStudentsForClass(
    String classId,
    String divisionId,
  ) =>
      _service.getStudentsForClass(classId, divisionId);
}
