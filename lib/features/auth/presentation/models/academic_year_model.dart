import 'package:cloud_firestore/cloud_firestore.dart';

class AcademicYearModel {
  String id;
  String yearName;
  DateTime startDate;
  DateTime endDate;
  DateTime createdAt;
  bool isCurrent;

  AcademicYearModel({
    required this.id,
    required this.yearName,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.isCurrent,
  });

  factory AcademicYearModel.fromMap(Map<String, dynamic> map) {
    return AcademicYearModel(
      id: map['id'] ?? '',
      yearName: map['year_name'] ?? '',
      startDate: (map['start_date'] as Timestamp).toDate(),
      endDate: (map['end_date'] as Timestamp).toDate(),
      createdAt: (map['created_at'] as Timestamp).toDate(),
      isCurrent: map['is_current'] ?? false,
    );
  }
}