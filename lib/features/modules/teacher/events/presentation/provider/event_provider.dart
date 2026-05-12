import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/event_model.dart';
import '../../data/repository/event_repository.dart';
import '../../../students/data/models/tech_student_model.dart';

class EventProvider extends ChangeNotifier {
  final EventRepository repository;
  EventProvider(this.repository);

  List<EventModel> _events = [];
  List<EventModel> get events => _events;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isInitialLoading = false;
  bool get isInitialLoading => _isInitialLoading;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  DocumentSnapshot? _lastDoc;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchEvents({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _events = [];
      _lastDoc = null;
      _hasMore = true;
      _isInitialLoading = true;
      notifyListeners();
    } else if (!_hasMore) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      final classId = prefs.getString("classId");
      final divisionId = prefs.getString("divisionId");
      final academicYearId = prefs.getString("academicYearId");

      final snapshot = await repository.getEvents(
        lastDoc: _lastDoc,
        classId: classId,
        divisionId: divisionId,
        academicYearId: academicYearId,
      );

      if (snapshot.docs.length < 15) {
        _hasMore = false;
      }

      if (snapshot.docs.isNotEmpty) {
        _lastDoc = snapshot.docs.last;
        final newEvents = snapshot.docs.map((doc) {
          return EventModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
        _events.addAll(newEvents);
      }
    } catch (e) {
      _errorMessage = "Error fetching events: $e";
      debugPrint(_errorMessage);
      _hasMore = false;
    } finally {
      _isLoading = false;
      _isInitialLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createOrUpdateEvent({
    String? id,
    required String title,
    required String description,
    required DateTime dateTime,
    File? attachmentFile,
    required String status,
    String? teacherRemarks,
    bool isTaskRequired = false,
    String? taskTitle,
    double? taskAmount,
    String? taskNote,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final staffId = prefs.getString("staffId") ?? '';
      final staffName = prefs.getString("staffName") ?? '';
      final classId = prefs.getString("classId");
      final divisionId = prefs.getString("divisionId");
      final academicYearId = prefs.getString("academicYearId");

      String? attachmentUrl;
      if (attachmentFile != null) {
        attachmentUrl = await repository.uploadAttachment(attachmentFile);
      }

      final effectiveId = id ?? FirebaseFirestore.instance.collection('events').doc().id;

      final event = EventModel(
        id: effectiveId,
        title: title,
        description: description,
        dateTime: Timestamp.fromDate(dateTime),
        attachmentUrl: attachmentUrl ?? (id != null ? _events.firstWhere((e) => e.id == id).attachmentUrl : null),
        status: status,
        teacherRemarks: teacherRemarks,
        createdById: staffId,
        createdByName: staffName,
        academicYearId: academicYearId,
        classId: classId,
        divisionId: divisionId,
        createdAt: Timestamp.now(),
        isTaskRequired: isTaskRequired,
        taskTitle: taskTitle,
        taskAmount: taskAmount,
        taskNote: taskNote,
      );

      await repository.saveEvent(event);

      if (id == null) {
        _events.insert(0, event);
      } else {
        final index = _events.indexWhere((e) => e.id == id);
        if (index != -1) {
          _events[index] = event;
        }
      }
      return true;
    } catch (e) {
      _errorMessage = "Failed to save event: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteEvent(String eventId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await repository.deleteEvent(eventId);
      _events.removeWhere((e) => e.id == eventId);
      return true;
    } catch (e) {
      _errorMessage = "Failed to delete event: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Event Task Tracking logic
  Future<List<EnrollerModel>> getStudentsForEvent(String eventId) async {
    try {
      final event = _events.firstWhere((e) => e.id == eventId);
      if (event.classId != null && event.divisionId != null) {
        return await repository.getStudentsForClass(event.classId!, event.divisionId!);
      }
    } catch (e) {
       debugPrint("Error fetching students: $e");
    }
    return [];
  }

  Future<bool> updateStudentTaskStatus({
    required String eventId,
    required String studentId,
    required String studentName,
    required String status,
    String? remark,
  }) async {
    try {
      final task = StudentEventTaskModel(
        studentId: studentId,
        studentName: studentName,
        status: status,
        remark: remark,
        updatedAt: Timestamp.now(),
      );
      await repository.updateStudentTaskStatus(eventId, task);
      return true;
    } catch (e) {
      _errorMessage = "Failed to update task status: $e";
      return false;
    }
  }

  Stream<List<StudentEventTaskModel>> getStudentTasks(String eventId) {
    return repository.getStudentTasksStream(eventId);
  }

  Future<StudentEventTaskModel?> getMyChildTaskStatus(String eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getString("studentId");
    if (studentId != null) {
      return await repository.getStudentTask(eventId, studentId);
    }
    return null;
  }
}
