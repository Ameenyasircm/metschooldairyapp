import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:flutter/services.dart' show rootBundle;
import '../../../../../../core/service/firebase_service.dart';
import '../models/parent_notification_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ParentNotificationService {
  final FirebaseFirestore _db = FirebaseService.firestore;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static final ParentNotificationService _instance = ParentNotificationService._internal();
  factory ParentNotificationService() => _instance;
  ParentNotificationService._internal();

  // --- Initialization ---

  Future<void> init() async {
    // 1. Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 2. Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        _handleNotificationClick(details.payload);
      },
    );

    // 3. Request permissions
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // --- Token Management ---

  Future<void> updateDeviceToken(String parentId) async {
    try {
      String? token = await _fcm.getToken();
      if (token == null) return;

      await _db
          .collection('parents')
          .doc(parentId)
          .collection('tokens')
          .doc(token)
          .set({
        'token': token,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      debugPrint("FCM Token updated for parent: $parentId");
    } catch (e) {
      debugPrint("Error updating device token: $e");
    }
  }

  // --- Notification Handlers ---

  void setupFCMHandlers() {
    // 1. Foreground messaging
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("Foreground message received: ${message.notification?.title}");
      _showLocalNotification(message);
    });

    // 2. Background click handling
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("Notification clicked from background");
      _handleNotificationClick(null);
    });

    // 3. Terminated state handling
    _fcm.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint("App launched from notification (terminated state)");
        _handleNotificationClick(null);
      }
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  }

  void _handleNotificationClick(String? payload) {
    _onNotificationTap?.call();
  }

  VoidCallback? _onNotificationTap;
  void setOnNotificationTap(VoidCallback callback) {
    _onNotificationTap = callback;
  }

  // --- Firestore Data Management ---

  Stream<List<ParentNotificationModel>> getNotifications(String parentId) {
    return _db
        .collection('parents')
        .doc(parentId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ParentNotificationModel.fromFirestore(doc))
            .toList());
  }

  Stream<int> getUnreadCount(String parentId) {
    return _db
        .collection('parents')
        .doc(parentId)
        .collection('notifications')
        .where('isSeen', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> markAllAsSeen(String parentId) async {
    try {
      final querySnapshot = await _db
          .collection('parents')
          .doc(parentId)
          .collection('notifications')
          .where('isSeen', isEqualTo: false)
          .get();

      if (querySnapshot.docs.isEmpty) return;

      WriteBatch batch = _db.batch();
      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isSeen': true});
      }
      await batch.commit();
    } catch (e) {
      debugPrint("Error marking notifications as seen: $e");
    }
  }

  // --- Staff Side Trigger ---

  Future<void> sendLateAttendanceNotification({
    required String parentId,
    required String studentName,
    required String studentId,
    required String date,
    required String remark,
  }) async {
    final title = "Late Attendance Alert";
    final body = "$studentName was marked late on $date. Remark: $remark";

    try {
      // 1. Check if notification already exists for this student and date
      final existingNotifications = await _db
          .collection('parents')
          .doc(parentId)
          .collection('notifications')
          .where('studentId', isEqualTo: studentId)
          .where('date', isEqualTo: date)
          .where('title', isEqualTo: title)
          .limit(1)
          .get();

      if (existingNotifications.docs.isNotEmpty) {
        // Update existing notification
        await existingNotifications.docs.first.reference.update({
          'body': body,
          'remark': remark,
          'isSeen': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
        debugPrint("Updated existing late notification for student: $studentId");
      } else {
        // Create new notification
        await _db
            .collection('parents')
            .doc(parentId)
            .collection('notifications')
            .add({
          'title': title,
          'body': body,
          'studentId': studentId,
          'date': date,
          'remark': remark,
          'isSeen': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
        debugPrint("Added new late notification for student: $studentId");
      }

      // 2. Fetch Parent's Device Tokens
      final tokensSnapshot = await _db
          .collection('parents')
          .doc(parentId)
          .collection('tokens')
          .get();

      List<String> deviceTokens = tokensSnapshot.docs
          .map((doc) => doc.data()['token'] as String)
          .toList();

      if (deviceTokens.isNotEmpty) {
        // 3. Trigger Push Notification using HTTP v1
        await _sendPushToDevices(deviceTokens, title, body);
      }
    } catch (e) {
      debugPrint("Error sending late notification: $e");
    }
  }

  /// Direct FCM implementation (HTTP v1 API)
  Future<void> _sendPushToDevices(List<String> tokens, String title, String body) async {
    try {
      // 1. Load Service Account JSON
      final serviceAccountJson = await rootBundle.loadString('assets/json/service-account.json');
      final Map<String, dynamic> serviceAccountMap = jsonDecode(serviceAccountJson);
      final String projectId = serviceAccountMap['project_id'];
      
      final accountCredentials = auth.ServiceAccountCredentials.fromJson(serviceAccountJson);
      final scopes = ['https://www.googleapis.com/auth/cloud-platform'];

      // 2. Get Access Token
      final authClient = await auth.clientViaServiceAccount(accountCredentials, scopes);
      final accessToken = authClient.credentials.accessToken.data;

      final String url = 'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

      // 3. Send to each token (v1 sends to one token at a time)
      for (String token in tokens) {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({
            'message': {
              'token': token,
              'notification': {
                'title': title,
                'body': body,
              },
              'android': {
                'notification': {
                  'channel_id': 'high_importance_channel',
                  'priority': 'HIGH',
                },
              },
              'apns': {
                'payload': {
                  'aps': {
                    'sound': 'default',
                    'badge': 1,
                  },
                },
              },
              'data': {
                'type': 'late_attendance',
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              },
            }
          }),
        );

        if (response.statusCode == 200) {
          debugPrint("FCM v1 Push sent successfully to token.");
        } else {
          debugPrint("FCM v1 Push failed with status: ${response.statusCode}");
          debugPrint("Response body: ${response.body}");
        }
      }
      authClient.close();
    } catch (e) {
      debugPrint("Error sending FCM v1 push: $e");
    }
  }
}
