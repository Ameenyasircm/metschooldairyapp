import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../../core/service/firebase_service.dart';

class StudentFirestore {
  final _db = FirebaseService.firestore;

  DocumentSnapshot? lastDoc;

  Future<List<QueryDocumentSnapshot>> fetchStudents({
    int limit = 10,
    String search = '',
    bool isFirst = false,
  }) async {
    Query query = _db.collection('students');

    query = query.orderBy('name');

    query = query.limit(limit);

    if (!isFirst && lastDoc != null) {
      query = query.startAfterDocument(lastDoc!);
    }

    final snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      lastDoc = snapshot.docs.last;
    }

    return snapshot.docs;
  }

  void reset() {
    lastDoc = null;
  }
}