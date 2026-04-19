import 'package:cloud_firestore/cloud_firestore.dart';

class SchoolEventModel {
  String id;
  String title;
  String description;
  DateTime date;

  SchoolEventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
  });

  /// 🔹 FROM FIRESTORE
  factory SchoolEventModel.fromMap(
      Map<String, dynamic> map, String id) {
    return SchoolEventModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] != null
          ? (map['date'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// 🔹 TO FIRESTORE
  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "date": date,
      "createdAt": FieldValue.serverTimestamp(),
    };
  }
}