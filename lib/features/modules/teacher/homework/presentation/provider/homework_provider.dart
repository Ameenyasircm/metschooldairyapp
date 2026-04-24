import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../data/models/homework_model.dart';

class HomeworkProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<HomeworkModel> _homeworkList = [];
  List<HomeworkModel> get homeworkList => _homeworkList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<HomeworkSubmissionModel> _submissions = [];
  List<HomeworkSubmissionModel> get submissions => _submissions;

  List<Map<String, dynamic>> _subjectsList = [];
  List<Map<String, dynamic>> get subjectsList => _subjectsList;

  // Fetch Subjects from Firestore
  Future<void> fetchSubjects() async {
    try {
      final snapshot = await _db.collection('subjects').get();
      _subjectsList = snapshot.docs.map((doc) => {
        "id": doc.id,
        "name": doc['name']?.toString() ?? 'Unknown',
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching subjects: $e");
    }
  }

  // Fetch Homework for a specific class and division
  Future<void> fetchHomework({
    required String classId,
    required String divisionId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _db
          .collection('homework')
          .where('classId', isEqualTo: classId)
          .where('divisionId', isEqualTo: divisionId)
          .orderBy('createdAt', descending: true)
          .get();

      _homeworkList = snapshot.docs
          .map((doc) => HomeworkModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching homework: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new homework
  Future<void> addHomework(HomeworkModel homework) async {
    _isLoading = true;
    notifyListeners();

    try {
      final docRef = _db.collection('homework').doc();
      final homeworkData = homework.toMap();
      homeworkData['id'] = docRef.id;

      await docRef.set(homeworkData);
      
      // After adding homework, we should ideally initialize submissions for all students in that division
      await _initializeSubmissions(docRef.id, homework.classId, homework.divisionId);
      
      _homeworkList.insert(0, HomeworkModel.fromMap(homeworkData, docRef.id));
    } catch (e) {
      debugPrint('Error adding homework: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Initialize submissions for all students in the division
  Future<void> _initializeSubmissions(String homeworkId, String classId, String divisionId) async {
    final studentsSnapshot = await _db
        .collection('enrollments')
        .where('class_id', isEqualTo: classId)
        .where('division_id', isEqualTo: divisionId)
        .where('status', isEqualTo: 'active')
        .get();

    final batch = _db.batch();
    for (var doc in studentsSnapshot.docs) {
      final data = doc.data();
      final submissionRef = _db
          .collection('homework')
          .doc(homeworkId)
          .collection('submissions')
          .doc(data['student_id']);

      batch.set(submissionRef, {
        'studentId': data['student_id'],
        'studentName': data['student_name'],
        'status': 'pending',
        'updatedAt': FieldValue.serverTimestamp(),
        'parentPhone': data['parent_phone'],
        'roll_number': data['roll_number'] ?? 0,
      });
    }
    await batch.commit();
  }

  // Fetch submissions for a specific homework
  Future<void> fetchSubmissions(String homeworkId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _db
          .collection('homework')
          .doc(homeworkId)
          .collection('submissions')
          .get();

      _submissions = snapshot.docs
          .map((doc) => HomeworkSubmissionModel.fromMap(doc.data()))
          .toList();
      _submissions.sort((a, b) => a.rollNo.compareTo(b.rollNo));
    } catch (e) {
      debugPrint('Error fetching submissions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update submission status (for Student/Parent or Teacher)
  Future<void> updateSubmissionStatus({
    required String homeworkId,
    required String studentId,
    required String status,
  }) async {
    try {
      await _db
          .collection('homework')
          .doc(homeworkId)
          .collection('submissions')
          .doc(studentId)
          .update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local state
      final index = _submissions.indexWhere((s) => s.studentId == studentId);
      if (index != -1) {
        final newList = List<HomeworkSubmissionModel>.from(_submissions);
        newList[index] = HomeworkSubmissionModel(
          studentId: _submissions[index].studentId,
          studentName: _submissions[index].studentName,
          status: status,
          updatedAt: DateTime.now(),
          parentPhone: _submissions[index].parentPhone,
          rollNo: _submissions[index].rollNo,
        );
        _submissions = newList;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating status: $e');
      rethrow;
    }
  }

  Future<void> bulkUpdateSubmissionStatus({
    required String homeworkId,
    required List<String> studentIds,
    required String status,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final batch = _db.batch();
      for (var studentId in studentIds) {
        final submissionRef = _db
            .collection('homework')
            .doc(homeworkId)
            .collection('submissions')
            .doc(studentId);
        batch.update(submissionRef, {
          'status': status,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();

      // Update local state
      final newList = List<HomeworkSubmissionModel>.from(_submissions);
      for (var studentId in studentIds) {
        final index = newList.indexWhere((s) => s.studentId == studentId);
        if (index != -1) {
          newList[index] = HomeworkSubmissionModel(
            studentId: newList[index].studentId,
            studentName: newList[index].studentName,
            status: status,
            updatedAt: DateTime.now(),
            parentPhone: newList[index].parentPhone,
            rollNo: newList[index].rollNo,
          );
        }
      }
      _submissions = newList;
      notifyListeners();
    } catch (e) {
      debugPrint('Error bulk updating status: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
