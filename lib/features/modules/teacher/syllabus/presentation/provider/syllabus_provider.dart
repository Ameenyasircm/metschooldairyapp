import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/syllabus_model.dart';
import '../../data/services/syllabus_service.dart';
import 'package:uuid/uuid.dart';

class SyllabusProvider extends ChangeNotifier {
  final SyllabusService _service = SyllabusService();
  
  List<SyllabusModel> _syllabusList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SyllabusModel> get syllabusList => _syllabusList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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
      // 1. Upload to Cloudinary
      final fileUrl = await _service.uploadSyllabusFile(file);

      // 2. Create SyllabusModel
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

      // 3. Save to Firestore
      await _service.saveSyllabusMetadata(syllabus);
      
      // Refresh list if it was for the same class/division
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
