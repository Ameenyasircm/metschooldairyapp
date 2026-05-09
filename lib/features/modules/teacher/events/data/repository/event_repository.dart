import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

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

  Future<void> updateParentRemark(String eventId, ParentRemarkModel remark) =>
      _service.updateParentRemark(eventId, remark);

  Stream<List<ParentRemarkModel>> getRemarksStream(String eventId) =>
      _service.getRemarksStream(eventId);
}
