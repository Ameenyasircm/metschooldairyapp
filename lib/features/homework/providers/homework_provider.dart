import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../modules/teacher/homework/data/models/homework_model.dart';
import '../services/homework_service.dart';

class HomeworkProvider extends ChangeNotifier {
  final HomeworkService _service = HomeworkService();

  List<HomeworkModel> _homeworkList = [];
  List<HomeworkModel> get homeworkList => _homeworkList;

  List<HomeworkSubmissionModel> _submissions = [];
  List<HomeworkSubmissionModel> get submissions => _submissions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _classId;
  String? _className;
  String? _divisionId;
  String? _divisionName;
  String? _teacherId;
  String? _teacherName;
  String? _academicId;

  String? get className => _className;
  String? get divisionName => _divisionName;

  Future<void> loadTeacherData() async {
    final prefs = await SharedPreferences.getInstance();
    _classId = prefs.getString("classId");
    _className = prefs.getString("className");
    _divisionId = prefs.getString("divisionId");
    _divisionName = prefs.getString("divisionName");
    _teacherId = prefs.getString("staffId");
    _teacherName = prefs.getString("staffName");
    _academicId = prefs.getString("academicYearId");
    notifyListeners();
  }

  Future<void> fetchHomework() async {
    if (_classId == null || _divisionId == null) await loadTeacherData();
    
    _isLoading = true;
    notifyListeners();

    try {
      _homeworkList = await _service.getHomeworkList(
        classId: _classId!,
        divisionId: _divisionId!,
      );
    } catch (e) {
      debugPrint('Error fetching homework: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addHomework({
    required String title,
    required String description,
    required String subject,
    required DateTime dueDate,
  }) async {
    if (_classId == null) await loadTeacherData();

    _isLoading = true;
    notifyListeners();

    try {
      final homework = HomeworkModel(
        id: '',
        title: title,
        description: description,
        dueDate: dueDate,
        createdAt: DateTime.now(),
        classId: _classId!,
        className: _className!,
        divisionId: _divisionId!,
        divisionName: _divisionName!,
        teacherId: _teacherId!,
        teacherName: _teacherName!,
        subject: subject,
        academicYearId: _academicId!,
      );

      final homeworkId = await _service.addHomework(homework);
      await _service.initializeSubmissions(
        homeworkId: homeworkId,
        classId: _classId!,
        divisionId: _divisionId!,
      );
      
      await fetchHomework();
    } catch (e) {
      debugPrint('Error adding homework: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSubmissions(String homeworkId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _submissions = await _service.getSubmissions(homeworkId);
    } catch (e) {
      debugPrint('Error fetching submissions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSubmissionStatus({
    required String homeworkId,
    required String studentId,
    required String status,
  }) async {
    try {
      await _service.updateSubmissionStatus(
        homeworkId: homeworkId,
        studentId: studentId,
        status: status,
      );

      final index = _submissions.indexWhere((s) => s.studentId == studentId);
      if (index != -1) {
        // Create a new list instance to ensure UI update
        final newList = List<HomeworkSubmissionModel>.from(_submissions);
        newList[index] = HomeworkSubmissionModel(
          studentId: _submissions[index].studentId,
          studentName: _submissions[index].studentName,
          status: status,
          updatedAt: DateTime.now(),
          parentPhone: _submissions[index].parentPhone,
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
      await _service.bulkUpdateSubmissionStatus(
        homeworkId: homeworkId,
        studentIds: studentIds,
        status: status,
      );
      
      // Update local state with a new list instance
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
