import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import '../models/event_model.dart';

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
    
    // If we want events for a specific class/division, or general events (where classId is null)
    // For now, let's filter by class/division if provided.
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

  Future<void> updateParentRemark(String eventId, ParentRemarkModel remark) async {
    await _db
        .collection('events')
        .doc(eventId)
        .collection('parent_remarks')
        .doc(remark.parentId)
        .set(remark.toMap());
  }

  Stream<List<ParentRemarkModel>> getRemarksStream(String eventId) {
    return _db
        .collection('events')
        .doc(eventId)
        .collection('parent_remarks')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ParentRemarkModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
