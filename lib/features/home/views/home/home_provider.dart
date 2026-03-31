import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../data/models/winner_model.dart';

class HomeProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PageController pageController = PageController();

  List<WinnerModel> _winners = [];
  String _activeGroupTitle = ""; // To show "Class 10 Toppers" in UI

  List<WinnerModel> get winners => _winners;
  String get activeGroupTitle => _activeGroupTitle;

  Timer? _timer;
  int _currentPage = 0;

  List<SchoolEvent> sampleEvents = [
    SchoolEvent(
      title: "Annual Science Fair 2026",
      location: "Main Assembly Hall",
      time: "10:00 AM",
      day: "24",
      month: "MAR",
    ),
    SchoolEvent(
      title: "Parent-Teacher Conference",
      location: "Block A - Room 102",
      time: "09:30 AM",
      day: "12",
      month: "APR",
    ),
    SchoolEvent(
      title: "Inter-School Cricket Final",
      location: "School Sports Ground",
      time: "02:00 PM",
      day: "18",
      month: "APR",
    ),
    SchoolEvent(
      title: "Art & Craft Exhibition",
      location: "Creative Arts Center",
      time: "11:00 AM",
      day: "05",
      month: "MAY",
    ),
  ];

  HomeProvider() {
    fetchActiveWinnerGroup();
  }

  void fetchActiveWinnerGroup() {
    // We query for the group where isActive is true
    _firestore
        .collection('winner_groups')
        .where('isActive', isEqualTo: true)
        .limit(1) // Only fetch the current active group
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        _activeGroupTitle = data['title'] ?? "";

        // Map the 'students' array from the document to our WinnerModel list
        List<dynamic> studentList = data['students'] ?? [];
        _winners = studentList
            .map((s) => WinnerModel.fromJson(s as Map<String, dynamic>))
            .toList();

        notifyListeners();
        _startAutoScroll();
      }
    });
  }

  void _startAutoScroll() {
    _timer?.cancel();
    if (_winners.isEmpty) return;

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (pageController.hasClients && _winners.isNotEmpty) {
        if (_currentPage < _winners.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }

        pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    pageController.dispose();
    super.dispose();
  }
}