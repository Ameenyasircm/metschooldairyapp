import 'package:flutter/material.dart';
import '../../../../../../main.dart';
import '../../data/models/parent_notification_model.dart';
import '../../data/services/parent_notification_service.dart';
import '../screens/parent_notification_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider extends ChangeNotifier {
  final ParentNotificationService _service = ParentNotificationService();
  
  List<ParentNotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  List<ParentNotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  NotificationProvider() {
    _initService();
  }

  Future<void> _initService() async {
    await _service.init();
    _service.setupFCMHandlers();
    _service.setOnNotificationTap(() async {
      final prefs = await SharedPreferences.getInstance();
      final parentId = prefs.getString("userId");
      if (parentId != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => ParentNotificationScreen(parentId: parentId),
          ),
        );
      }
    });
  }

  void listenToNotifications(String parentId) {
    _isLoading = true;
    notifyListeners();

    _service.getNotifications(parentId).listen((data) {
      _notifications = data;
      _isLoading = false;
      notifyListeners();
    });

    _service.getUnreadCount(parentId).listen((count) {
      _unreadCount = count;
      notifyListeners();
    });
  }

  Future<void> markAsSeen(String parentId) async {
    await _service.markAllAsSeen(parentId);
  }

  Future<void> updateToken(String parentId) async {
    await _service.updateDeviceToken(parentId);
  }
}
