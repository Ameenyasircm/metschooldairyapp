import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../../core/service/firebase_service.dart';
import '../models/attendance_model.dart';

class AttendanceFirestoreService {
  final FirebaseFirestore _db = FirebaseService.firestore;
  final String _collection = 'attendance';

  Future<void> saveAttendance(DailyAttendanceModel attendance) async {
    final docId = "${attendance.date}_${attendance.divisionId}";
    await _db.collection(_collection).doc(docId).set(attendance.toMap(), SetOptions(merge: true));
  }

  Future<DailyAttendanceModel?> fetchAttendanceByDate(String date, String divisionId) async {
    final docId = "${date}_${divisionId}";
    final doc = await _db.collection(_collection).doc(docId).get();
    if (doc.exists) {
      return DailyAttendanceModel.fromFirestore(doc);
    }
    return null;
  }

  Future<List<DailyAttendanceModel>> fetchMonthlyAttendance(String divisionId, String monthYear) async {
    // monthYear format: "yyyy-MM"
    final snapshot = await _db.collection(_collection)
        .where('divisionId', isEqualTo: divisionId)
        .where('date', isGreaterThanOrEqualTo: "$monthYear-01")
        .where('date', isLessThanOrEqualTo: "$monthYear-31")
        .get();

    return snapshot.docs.map((doc) => DailyAttendanceModel.fromFirestore(doc)).toList();
  }

  Future<List<DailyAttendanceModel>> fetchStudentAttendanceHistory(String studentId, {String? startDate, String? endDate}) async {
    Query query = _db.collection(_collection);

    if (startDate != null) {
      query = query.where('date', isGreaterThanOrEqualTo: startDate);
    }
    if (endDate != null) {
      query = query.where('date', isLessThanOrEqualTo: endDate);
    }

    // Since Firestore doesn't support array-contains style queries on nested maps efficiently 
    // for every possible studentId key without indexing each studentId, 
    // we might need to restructure or fetch more and filter in-memory if the collection is small,
    // OR use a more optimized schema for student-specific queries.
    // For now, we'll fetch based on date range and filter in-memory.
    
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => DailyAttendanceModel.fromFirestore(doc))
        .where((model) => model.students.containsKey(studentId))
        .toList();
  }
}
