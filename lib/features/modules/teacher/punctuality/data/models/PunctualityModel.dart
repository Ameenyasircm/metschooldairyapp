import 'package:cloud_firestore/cloud_firestore.dart';

class PunctualityRecordModel {
  final String id;
  final String studentId;
  final String studentName;
  final String className;
  final String divisionName;
  final String code;
  final String remark;
  final DateTime date;
  final DateTime createdAt;

  PunctualityRecordModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.className,
    required this.divisionName,
    required this.code,
    required this.remark,
    required this.date,
    required this.createdAt,
  });

  factory PunctualityRecordModel.fromMap(String id, Map<String, dynamic> map) {
    return PunctualityRecordModel(
      id: id,
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      className: map['className'] ?? '',
      divisionName: map['divisionName'] ?? '',
      code: map['code'] ?? '',
      remark: map['remark'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "studentId": studentId,
      "studentName": studentName,
      "className": className,
      "divisionName": divisionName,
      "code": code,
      "remark": remark,
      "date": Timestamp.fromDate(date),
      "createdAt": Timestamp.now(),
    };
  }
}

class PunctualityCodes {
  static const Map<String, String> codes = {
    "AWL": "Absent Without Leave",
    "CC": "Careless in Class",
    "IU": "Improper Uniform",
    "BNB": "Books Not Brought",
    "HND": "Homework Not Done",
    "LC": "Late Coming",
  };
}