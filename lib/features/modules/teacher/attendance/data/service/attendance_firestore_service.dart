import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../../../core/service/firebase_service.dart';
import '../models/attendance_model.dart';

class AttendanceFirestoreService {
  final FirebaseFirestore _db = FirebaseService.firestore;
  final String _collection = 'attendance';

  Future<void> saveAttendance(DailyAttendanceModel attendance, AttendanceSession session) async {
    final docId = "${attendance.date}_${attendance.classId}_${attendance.divisionId}";
    
    final WriteBatch batch = _db.batch();
    
    // 1. Save to main attendance collection
    batch.set(_db.collection(_collection).doc(docId), attendance.toMap(), SetOptions(merge: true));

    // 2. Update individual student enrollments for fast access in Parent Home
    final String sessionSuffix = session == AttendanceSession.morning ? 'M' : 'A';
    final DateTime parsedDate = DateTime.parse(attendance.date);
    final String formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);
    final String attendanceKey = "${formattedDate}_$sessionSuffix";

    attendance.students.forEach((studentId, data) {
      final status = session == AttendanceSession.morning ? data.morning : data.afternoon;
      
      // Use the actual Firestore document ID (enrollmentDocId) for the update
      final docRef = _db.collection('enrollments').doc(data.enrollmentDocId);
      
      // Update specific key inside a nested 'daily_attendance' map
      batch.update(docRef, {
        'daily_attendance.$attendanceKey': status.name,
      });
    });

    await batch.commit();
  }

  Future<DailyAttendanceModel?> fetchAttendanceByDate(String date, String classId,String divisionId) async {
    final docId = "${date}_${classId}_$divisionId";
    final doc = await _db.collection(_collection).doc(docId).get();
    if (doc.exists) {
      return DailyAttendanceModel.fromFirestore(doc);
    }
    return null;
  }
  Future<List<DailyAttendanceModel>> fetchMonthlyAttendance(String classId,String divisionId, String monthYear) async {
    // monthYear format: "yyyy-MM"
    final snapshot = await _db.collection(_collection)
        .where('classId', isEqualTo: classId)
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

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => DailyAttendanceModel.fromFirestore(doc))
        .where((model) => model.students.containsKey(studentId))
        .toList();
  }
}
