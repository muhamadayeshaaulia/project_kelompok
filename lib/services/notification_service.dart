import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_kelompok/detail/postingan.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          Future.delayed(Duration(milliseconds: 300), () {
            _navigateToDetail(response.payload!);
          });
        }
      },
    );
  }

  static Future<void> handleInitialNotification() async {
    final NotificationAppLaunchDetails? details = await _notificationsPlugin
        .getNotificationAppLaunchDetails();

    if (details != null && details.didNotificationLaunchApp) {
      String? payload = details.notificationResponse?.payload;
      if (payload != null && payload.isNotEmpty) {
        Future.delayed(const Duration(seconds: 2), () {
          _navigateToDetail(payload);
        });
      }
    }
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
}
