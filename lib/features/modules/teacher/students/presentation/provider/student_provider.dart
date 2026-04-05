import 'dart:async';

import 'package:flutter/material.dart';
import '../../data/models/tech_student_model.dart';
import '../../data/repository/student_repository.dart';

class StudentProvider extends ChangeNotifier {
  final StudentRepository repository;
  StudentProvider(this.repository);

  List<TechStudentModel> students = [];
  bool isLoading = false;
  bool hasMore = true;
  String searchQuery = '';
  bool isInitialLoading = false;
  bool isLoadingMore = false;

  Future<void> fetchInitial() async {
    repository.resetPagination();
    students.clear();
    hasMore = true;
    isInitialLoading = true;
    notifyListeners();

    final newData = await repository.getStudents(
      search: searchQuery,
      isFirst: true,
    );

    students = newData;

    isInitialLoading = false;
    notifyListeners();
  }

  Future<void> fetchMore() async {
    if (isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    notifyListeners();

    final newData = await repository.getStudents(
      search: searchQuery,
    );

    if (newData.isEmpty) {
      hasMore = false;
    } else {
      students.addAll(newData);
    }

    isLoadingMore = false;
    notifyListeners();
  }
  Timer? _debounce;

  void searchWithDebounce(String value) {
    searchQuery = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      fetchInitial();
    });
  }

}