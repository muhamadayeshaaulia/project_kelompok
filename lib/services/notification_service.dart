import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:project_kelompok/detail/postingan.dart'; 

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
}

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static Future<void> initializeAll() async {
    await _initLocalNotifications();
    await _initFCM();
    await _handleInitialNotification();
  }
  static Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

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
  static Future<void> _handleInitialNotification() async {
    final details = await _notificationsPlugin.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      String? payload = details.notificationResponse?.payload;
      if (payload != null) _delayedNav(payload);
    }
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null && initialMessage.data['postId'] != null) {
      _delayedNav(initialMessage.data['postId']);
    }
  }

  static Future<void> showPostSuccessNotification(String postId, {String? title, String? body}) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'post_channel',
      'Post Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      DateTime.now().millisecond,
      title ?? 'Yey! Postingan Berhasil 🚀',
      body ?? 'Karyamu sudah publish di publik, klik untuk melihat!',
      notificationDetails,
      payload: postId,
    );
  }
  static void _navigateToDetail(String postId) async {
    final doc = await FirebaseFirestore.instance.collection('posts').doc(postId).get();

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
    Future.delayed(const Duration(seconds: 2), () => _navigateToDetail(payload));
  }
}