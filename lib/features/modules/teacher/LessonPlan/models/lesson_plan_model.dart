/// lesson_plan_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class LessonPlanModel {
  final String id;
  final String teacherId;
  final String teacherName;
  final String subject;
  final String grade;
  final String topicName;
  final String duration;
  final String periodsAllotted;
  final String methodologies;
  final String activity;
  final String instructionalTools;
  final String learningObjectives;
  final DateTime createdAt;
  final String status;
  final DateTime? approvedAt; // ← nullable; only set when approved

  LessonPlanModel({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.subject,
    required this.grade,
    required this.topicName,
    required this.duration,
    required this.periodsAllotted,
    required this.methodologies,
    required this.activity,
    required this.instructionalTools,
    required this.learningObjectives,
    required this.createdAt,
    required this.status,
    this.approvedAt, // optional
  });

  Map<String, dynamic> toMap() {
    return {
      "ID": id,
      "TEACHER_ID": teacherId,
      "TEACHER_NAME": teacherName,
      "SUBJECT": subject,
      "GRADE": grade,
      "TOPIC_NAME": topicName,
      "DURATION": duration,
      "PERIODS_ALLOTTED": periodsAllotted,
      "METHODOLOGIES": methodologies,
      "ACTIVITY": activity,
      "INSTRUCTIONAL_TOOLS": instructionalTools,
      "LEARNING_OBJECTIVES": learningObjectives,
      "STATUS": status,
      "CREATED_AT": Timestamp.fromDate(createdAt),

      // only writes the field if it has a value, otherwise null
      "APPROVED_AT": approvedAt != null
          ? Timestamp.fromDate(approvedAt!)
          : null,
    };
  }

  factory LessonPlanModel.fromMap(Map<String, dynamic> map) {
    return LessonPlanModel(
      id: map['ID'] ?? '',
      teacherId: map['TEACHER_ID'] ?? '',
      teacherName: map['TEACHER_NAME'] ?? '',
      subject: map['SUBJECT'] ?? '',
      grade: map['GRADE'] ?? '',
      topicName: map['TOPIC_NAME'] ?? '',
      duration: map['DURATION'] ?? '',
      periodsAllotted: map['PERIODS_ALLOTTED'] ?? '',
      methodologies: map['METHODOLOGIES'] ?? '',
      activity: map['ACTIVITY'] ?? '',
      instructionalTools: map['INSTRUCTIONAL_TOOLS'] ?? '',
      learningObjectives: map['LEARNING_OBJECTIVES'] ?? '',
      status: map['STATUS'] ?? '',
      createdAt: (map['CREATED_AT'] as Timestamp).toDate(),

      // safely handles missing or null field from Firestore
      approvedAt: map['APPROVED_AT'] != null
          ? (map['APPROVED_AT'] as Timestamp).toDate()
          : null,
    );
  }
}