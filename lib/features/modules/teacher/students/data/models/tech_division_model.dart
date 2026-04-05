import 'package:cloud_firestore/cloud_firestore.dart';

class DivisionModel {
  final String id;
  final String name;
  final String academicYearId;

  DivisionModel({
    required this.id,
    required this.name,
    required this.academicYearId,
  });

  factory DivisionModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return DivisionModel(
      id: data['division_id'] ?? '',
      name: data['division_name'] ?? '',
      academicYearId: data['academic_year_id'] ?? '',
    );
  }
}