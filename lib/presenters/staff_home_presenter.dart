import 'package:flutter/material.dart';

abstract class StaffHomeView {
  void showMessage(String message);
}

class StaffHomePresenter {
  final StaffHomeView _view;

  StaffHomePresenter(this._view);

  void onAddStudentsClicked() {
    _view.showMessage('Navigate to Add Students Page');
    // Implement actual navigation to Add Students page later
  }

  void onMarkAttendanceClicked() {
    _view.showMessage('Navigate to Mark Attendance Page');
    // Implement actual navigation to Mark Attendance page later
  }
}
