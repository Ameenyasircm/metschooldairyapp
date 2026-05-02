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
        await sendPushToDevices(deviceTokens, title, body);
      }
    } catch (e) {
      debugPrint("Error sending late notification: $e");
    }
  }


  Future<void> sendPushToDevices(List<String> tokens, String title, String body) async {
    final String projectId = "met-school-codemates";

    // 1. Service Account JSON (Hardcoding is risky, but for testing:)
    final serviceAccountJson ={
      "type": "service_account",
      "project_id": "met-school-codemates",
      "private_key_id": "451f3c49648993acc71dc8121e2595f12b69d025",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCfMuZSigW5/357\nk8xx2pc1iD1hlMUR3GqtcHmw5WKBGu9zk+wJn9QdSu4rnE+MixcCkP5d2asehzyB\nlbUmbeEH/2a0fSXnd5q3GpO6rVfPz9oU6H4J/g6jGZCg4CXRJ7CsBrE2FUfGgFWK\nblUOAvIn7mJJOH96v1m/qdagW0emSdaknl5FSmMxk+uCl07Xy8MecG1cqYxCC+4H\ne/9uKmVbEDSVXWTulcDETQCXHrSSG28b9yFGxdG3+T/l3k0lY15w5zJ3SBnyBaOi\n2CTWnNJJ4+CjsLpTR88ffqM+LAPqf/Pxup6qV10JFZidinc8bKkRu47yPtDPpiGa\n/ETnBiqrAgMBAAECggEAI9/0ADijNrlpFs8FHMkOFx2m+2Trje1WStRUT/U5H+/i\ncvCsGbUfNySqDEDSulCjtEvZTmvdQGloTKlgY5MSSVuYGOc00fblcgq2rLQgXC+y\nLNEBih3qzX1W1rH8Q6hGi1WMvKvJ+2TzIdlgKGKokDALjQWC0LXrMyJCP+uh90pE\nVSwFYXjB4LwqPW7TlBhK7EK8wgGUkqmXaau7oDlCILPshqREt9Ewmg0sWDPnX5y3\nyY841aJJUXoGiFK27A6FpXtH5/oX/GQge552Clwj193VYRL4NvzYrVg/aN+JJ2Jf\nvjI/u/izFEKLJB2mGPd+9yiFtX7Z8LKBf7yLzqe68QKBgQDTFvqJQ6U/MPzVwr6o\niUqhmLEYG/HU7n5cZJWP1bn6VSX5eFb82p9WRGpipbz6dzLtWSiIPMkgBPJZrCRM\nHSDut3dwa4u4r3Ic3NV261emmYk1v99F1FTTb60CvdyHCj5RSL2WvJb7f5HcWqFE\nsYxikYoighqLCvXnH8o6yC9gGwKBgQDBEa1SVS9QZ2p1YWQhBoJTonndrWWsCaDl\nLIW9m9axPp08tP0gZBUxvAwkj/fL4Yw9HN3cxl1DhMX7jJahHhNYNeFF2/Z8GjG/\nGL9eMYo1j4LwdCDBBLdOrflcdmEDHz1cPR4s1orKniPhCHjrkM2A7n/YhDR48lj7\naBVv9smosQKBgC1F+GYIRCDReOi/4/Rxvbf678Cj/bIVlLRsPkejJ0gxivt+e+mv\nWg0+jzKpKWbuudV+EdtmbhyX8wKYkRBiDvYkE1HhPw5VUrwuAPqIbzwkIfGNPW3U\npHzUrt6vqeSspcD5QPBbcmZubfI83enFyr45SM8t6FN5/lOb1dvVo5ORAoGAb22E\nWsBPTlhhWN2crHLVRO/A5e/tfh0QfzPy/Du07Rb2KNNMRCV/FfUyDOgKW+EQzzSZ\n15GkwhMfMM8zIEn7YC24llkdKQL1MxVVXUe6PK9XIu/i94OBSCegg3zPAL5G67Va\ndQZdlBMxIe+B2nL4KDF+F7g1kJhOQssPlE8alAECgYBi7TJy3jPrgYZC2TVnURYP\n6lrTX3uua/yFDSnfsMXZRBsnRRxzWfCfSccm3uE0zAewXDcORsQEskc+OQ7PqubI\nY/awQldKtxCTw/uC8SWuiw3MGDj/TqiWP9CgQ5NF/txJcVX41Tlk5vxKZ/qaLbLA\n4fs9opbEejm4qlSCyOLMuw==\n-----END PRIVATE KEY-----\n",
      "client_email": "firebase-adminsdk-fbsvc@met-school-codemates.iam.gserviceaccount.com",
      "client_id": "116198068989121668624",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40met-school-codemates.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    try {
      // 2. Get Access Token automatically using googleapis_auth
      final client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
      );

      final String url = 'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

      for (String token in tokens) {
        final response = await client.post(
          Uri.parse(url),
          body: jsonEncode({
            'message': {
              'token': token,
              'notification': {
                'title': title,
                'body': body,
              },
              'data': {
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'type': 'late_attendance',
              },
              'android': {
                'priority': 'high',
                'notification': {
                  'channel_id': 'high_importance_channel',
                },
              },
            }
          }),
        );

        if (response.statusCode == 200) {
          print("Success: Notification sent to $token");
        } else {
          print("Error: ${response.body}");
        }
      }

      client.close(); // Always close the client
    } catch (e) {
      print("Error getting auth client: $e");
    }
  }}
