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


}
