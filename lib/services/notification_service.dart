import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:project_kelompok/detail/postingan.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String _projectId = 'myfristproject-dd7da';
  static Future<String> getAccessToken() async {
    final serviceAccountJson = await rootBundle.loadString(
      'assets/json/service_account.json',
    );
    final accountCredentials = auth.ServiceAccountCredentials.fromJson(
      serviceAccountJson,
    );

    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final client = await auth.clientViaServiceAccount(
      accountCredentials,
      scopes,
    );

    return client.credentials.accessToken.data;
  }

  static Future<void> initializeAll() async {
    await _initLocalNotifications();
    await _initFCM();
    await _handleInitialNotification();
  }

  static Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          _navigateToDetail(response.payload!);
        }
      },
    );
  }

  static Future<void> _initFCM() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    String? token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        String postId = message.data['postId'] ?? "";
        showPostSuccessNotification(
          postId,
          title: message.notification?.title,
          body: message.notification?.body,
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['postId'] != null) {
        _navigateToDetail(message.data['postId']);
      }
    });
  }

  static Future<void> saveUserToken() async {
    String? token = await _firebaseMessaging.getToken();
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null && token != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
    }
  }

  static Future<void> sendPushNotification({
    required String targetToken,
    required String title,
    required String body,
    required String postId,
  }) async {
    try {
      final String accessToken = await getAccessToken();

      final response = await http.post(
        Uri.parse(
          'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send',
        ),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'message': {
            'token': targetToken,
            'notification': {'title': title, 'body': body},
            'data': {'postId': postId},
            'android': {
              'priority': 'high',
              'notification': {
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'channel_id': 'post_channel',
                'sound': 'default',
              },
            },
          },
        }),
      );

      print("FCM V1 Status Code: ${response.statusCode}");
    } catch (e) {
      print("Error FCM V1: $e");
    }
  }

  static Future<void> _handleInitialNotification() async {
    final details = await _notificationsPlugin
        .getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      String? payload = details.notificationResponse?.payload;
      if (payload != null) _delayedNav(payload);
    }
    RemoteMessage? initialMessage = await _firebaseMessaging
        .getInitialMessage();
    if (initialMessage != null && initialMessage.data['postId'] != null) {
      _delayedNav(initialMessage.data['postId']);
    }
  }

  static Future<void> showPostSuccessNotification(
    String postId, {
    String? title,
    String? body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'post_channel',
          'Post Notifications',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecond,
      title ?? 'Yey! Postingan Berhasil 🚀',
      body ?? 'Karyamu sudah publish di publik, klik untuk melihat!',
      notificationDetails,
      payload: postId,
    );
  }

  static void _navigateToDetail(String postId) async {
    final doc = await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .get();

    if (doc.exists && navigatorKey.currentState != null) {
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => PostDetailPage(
            postId: postId,
            postData: doc.data() as Map<String, dynamic>,
          ),
        ),
      );
    }
  }

  static void _delayedNav(String payload) {
    Future.delayed(
      const Duration(seconds: 2),
      () => _navigateToDetail(payload),
    );
  }
}
