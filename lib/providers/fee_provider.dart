import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeeProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Stream<QuerySnapshot> getDivisionsStream() {
    return _db.collection('divisions').orderBy('class_name').snapshots();
  }

  Stream<QuerySnapshot> getEnrollmentsStream(String divisionId, String academicYearId) {
    return _db.collection('enrollments')
        .where('division_id', isEqualTo: divisionId)
        .where('academic_year_id', isEqualTo: academicYearId)
        .snapshots();
  }

  Future<void> updateInstallment({
    required String docId,
    required String installmentKey,
    required bool isPaid,
    required DateTime paymentDate,
    required String userId,     // Pass current user ID
    required String userName,   // Pass current user Name
    String? remark,
  }) async {
    try {
      DocumentReference ref = _db.collection('enrollments').doc(docId);
      if (isPaid) {
        await ref.update({
          'fees.$installmentKey': {
            'status': 'PAID',
            'date': Timestamp.fromDate(paymentDate), // Now a proper Timestamp
            'remark': remark ?? '',
            'updated_by_id': userId,
            'updated_by_name': userName,
            'updated_at': FieldValue.serverTimestamp(), // Track when the change happened
          }
        });
      } else {
        await ref.update({'fees.$installmentKey': FieldValue.delete()});
      }
    } catch (e) {
      debugPrint("❌ Fee Update Error: $e");
    }
  }
}