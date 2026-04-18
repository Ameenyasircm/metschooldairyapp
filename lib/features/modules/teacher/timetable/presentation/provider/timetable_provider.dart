import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/timetable_model.dart';

class TimetableProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TimetableModel? _timetable;
  bool _isLoading = false;
  bool _isEditing = false;
  bool _isSaving = false;

  final Map<String, List<TextEditingController>> controllers = {};
  final List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

  TimetableModel? get timetable => _timetable;
  bool get isLoading => _isLoading;
  bool get isEditing => _isEditing;
  bool get isSaving => _isSaving;

  TimetableProvider() {
    _initControllers();
  }

  void _initControllers() {
    for (var day in days) {
      controllers[day] = List.generate(7, (_) => TextEditingController());
    }
  }

  void toggleEditMode() {
    _isEditing = !_isEditing;
    if (!_isEditing) {
      _syncControllersWithData();
    }
    notifyListeners();
  }

  void _syncControllersWithData() {
    if (_timetable != null) {
      _timetable!.timetable.forEach((day, periods) {
        if (controllers.containsKey(day)) {
          for (int i = 0; i < periods.length; i++) {
            controllers[day]![i].text = periods[i];
          }
        }
      });
    }
  }

  /// Fetches timetable for a specific class.
  Future<void> fetchTimetable(String standard, String division,String academicId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final docId = '${standard}_$division';
      final doc = await _firestore.collection('timetables').doc(docId).get();

      if (doc.exists) {
        _timetable = TimetableModel.fromMap(doc.data()!);
      } else {
        _timetable = TimetableModel.empty(standard, division,academicId);
      }
      _syncControllersWithData();
    } catch (e) {
      debugPrint('Error fetching timetable: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Validates that all 35 periods are filled.
  bool validateTimetable() {
    for (var day in controllers.keys) {
      for (var controller in controllers[day]!) {
        if (controller.text.trim().isEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  /// Saves the timetable to Firestore.
  Future<bool> saveTimetable() async {
    if (_isSaving) return false;
    if (_timetable == null) return false;

    if (!validateTimetable()) {
      return false;
    }

    _isSaving = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final staffId = prefs.getString("staffId")??'';
      final staffName = prefs.getString("staffName")??'';

      // Update memory from controllers
      controllers.forEach((day, list) {
        for (int i = 0; i < list.length; i++) {
          _timetable!.timetable[day]![i] = list[i].text.trim();
        }
      });

      final docId = '${_timetable!.standard}_${_timetable!.division}_${timetable!.academicId}';
      await _firestore.collection('timetables').doc(docId).set(
            {
              ..._timetable!.toMap(),
              "added_by_id": staffId,
              "added_by": staffName,
            },
            SetOptions(merge: true),
          );
      _isEditing = false;
      return true;
    } catch (e) {
      debugPrint('Error saving timetable: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    for (var list in controllers.values) {
      for (var controller in list) {
        controller.dispose();
      }
    }
    super.dispose();
  }
}
