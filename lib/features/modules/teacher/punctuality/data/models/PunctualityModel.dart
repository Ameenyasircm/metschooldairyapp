import 'package:cloud_firestore/cloud_firestore.dart';

// ─── Codes ────────────────────────────────────────────────────────────────────
class PunctualityCodes {
  /// Positive behaviours  → +1 point each
  static const Map<String, String> positive = {
    "OTP": "On Time & Prepared",
    "EW":  "Excellent Work",
    "GC":  "Good Conduct",
    "HL":  "Helpful / Leadership",
    "HWD": "Homework Done Well",
    "PU":  "Proper Uniform",
  };

  /// Negative behaviours  → -1 point each
  static const Map<String, String> negative = {
    "AWL": "Absent Without Leave",
    "CC":  "Careless in Class",
    "IU":  "Improper Uniform",
    "BNB": "Books Not Brought",
    "HND": "Homework Not Done",
    "LC":  "Late Coming",
  };

  /// All codes combined (positive first)
  static Map<String, String> get all => {...positive, ...negative};

  /// Returns +1 for positive codes, -1 for negative
  static int pointFor(String code) => positive.containsKey(code) ? 1 : -1;

  /// true if code is positive
  static bool isPositive(String code) => positive.containsKey(code);
}

// ─── Record model ─────────────────────────────────────────────────────────────
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
  final int point;          // +1 or -1
  final bool isPositive;    // convenience flag

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
    required this.point,
    required this.isPositive,
  });

  factory PunctualityRecordModel.fromMap(String id, Map<String, dynamic> map) {
    final code = map['code'] ?? '';
    return PunctualityRecordModel(
      id:           id,
      studentId:    map['studentId']    ?? '',
      studentName:  map['studentName']  ?? '',
      className:    map['className']    ?? '',
      divisionName: map['divisionName'] ?? '',
      code:         code,
      remark:       map['remark']       ?? '',
      date:         (map['date']      as Timestamp).toDate(),
      createdAt:    (map['createdAt'] as Timestamp).toDate(),
      point:        (map['point']     as int?) ?? PunctualityCodes.pointFor(code),
      isPositive:   (map['isPositive'] as bool?) ?? PunctualityCodes.isPositive(code),
    );
  }

  Map<String, dynamic> toMap() => {
    "studentId":    studentId,
    "studentName":  studentName,
    "className":    className,
    "divisionName": divisionName,
    "code":         code,
    "remark":       remark,
    "date":         Timestamp.fromDate(date),
    "createdAt":    Timestamp.now(),
    "point":        point,
    "isPositive":   isPositive,
    // month-bucket for easy Firestore aggregation: "2025-06"
    "monthKey": "${date.year}-${date.month.toString().padLeft(2, '0')}",
  };
}