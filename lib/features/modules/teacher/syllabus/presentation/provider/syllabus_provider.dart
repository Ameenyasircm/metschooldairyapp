import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/syllabus_model.dart';
import '../../data/services/syllabus_service.dart';
import 'package:uuid/uuid.dart';

class SyllabusProvider extends ChangeNotifier {
  final SyllabusService _service = SyllabusService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  List<SyllabusModel> _syllabusList = [];
  List<Map<String, dynamic>> _subjectsList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SyllabusModel> get syllabusList => _syllabusList;
  List<Map<String, dynamic>> get subjectsList => _subjectsList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- Fetch Subjects (Shared logic) ---
  Future<void> fetchSubjects() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _db.collection('subjects').get();
      _subjectsList = snapshot.docs.map((doc) => {
        "id": doc.id,
        "name": doc['name']?.toString() ?? 'Unknown',
      }).toList();
    } catch (e) {
      _errorMessage = "Error fetching subjects: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Fetch Syllabus for Class ---
  Future<void> fetchSyllabus({required String classId, required String divisionId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _syllabusList = await _service.getSyllabusList(classId: classId, divisionId: divisionId);
    } catch (e) {
      _errorMessage = 'Failed to fetch syllabus: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Upload Syllabus Logic ---
  Future<bool> uploadSyllabus({
    required File file,
    required String subject,
    required String classId,
    required String className,
    required String divisionId,
    required String divisionName,
    required String teacherId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fileUrl = await _service.uploadSyllabusFile(file);

      final syllabus = SyllabusModel(
        id: const Uuid().v4(),
        subject: subject,
        classId: classId,
        className: className,
        divisionId: divisionId,
        divisionName: divisionName,
        fileUrl: fileUrl,
        uploadedAt: DateTime.now(),
        teacherId: teacherId,
      );

      await _service.saveSyllabusMetadata(syllabus);
      _syllabusList.insert(0, syllabus);
      return true;
    } catch (e) {
      _errorMessage = 'Upload failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
