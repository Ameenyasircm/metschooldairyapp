import 'dart:async';

import 'package:flutter/material.dart';
import '../../data/models/tech_student_model.dart';
import '../../data/repository/student_repository.dart';

class StudentProvider extends ChangeNotifier {
  final StudentRepository repository;
  StudentProvider(this.repository);

  List<TechStudentModel> allStudents = []; // 🔥 source of truth
  List<TechStudentModel> students = [];    // 🔥 filtered list

  bool hasMore = true;
  String searchQuery = '';
  bool isInitialLoading = false;
  bool isLoadingMore = false;

  // ---------------- FETCH ----------------

  Future<void> fetchInitial() async {
    repository.resetPagination();
    allStudents.clear();
    students.clear();
    hasMore = true;

    isInitialLoading = true;
    notifyListeners();

    final newData = await repository.getStudents(
      isFirst: true,
    );

    allStudents = newData;
    students = List.from(allStudents); // initially same

    isInitialLoading = false;
    notifyListeners();
  }

  Future<void> fetchMore() async {
    if (isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    notifyListeners();

    final newData = await repository.getStudents();

    if (newData.isEmpty) {
      hasMore = false;
    } else {
      allStudents.addAll(newData);
      _applyLocalSearch(); // 🔥 reapply filter after pagination
    }

    isLoadingMore = false;
    notifyListeners();
  }

  // ---------------- SEARCH (LOCAL) ----------------

  Timer? _debounce;

  void searchWithDebounce(String value) {
    searchQuery = value;
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      _applyLocalSearch();
    });
  }

  void _applyLocalSearch() {
    if (searchQuery.isEmpty) {
      students = List.from(allStudents);
    } else {
      students = allStudents.where((student) {
        final name = student.name.toLowerCase() ?? '';
        final admissionNO = student.admissionNumber.toLowerCase() ?? '';
        final query = searchQuery.toLowerCase();
        return name.contains(query)||admissionNO.contains(query);
      }).toList();
    }

    notifyListeners();
  }

  // ---------------- SELECTION ----------------

  Set<String> selectedStudentIds = {};
  bool isClassTeacher = true;

  void toggleSelection(String studentId) {
    if (selectedStudentIds.contains(studentId)) {
      selectedStudentIds.remove(studentId);
    } else {
      selectedStudentIds.add(studentId);
    }
    notifyListeners();
  }

  bool isSelected(String studentId) {
    return selectedStudentIds.contains(studentId);
  }

  void clearSelection() {
    selectedStudentIds.clear();
    notifyListeners();
  }

  void selectAll() {
    selectedStudentIds = students.map((e) => e.studentId).toSet();
    notifyListeners();
  }

  void deselectAll() {
    selectedStudentIds.clear();
    notifyListeners();
  }
}