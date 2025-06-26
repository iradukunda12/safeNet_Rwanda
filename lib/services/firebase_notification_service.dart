import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final notificationServiceProvider = Provider((ref) {
  return NotificationService()..init();
});

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // ✅ Request permission (iOS/Android 13+)
    await _messaging.requestPermission();

    // ✅ Setup local notification plugin
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);

    // ✅ Get FCM token
    final token = await _messaging.getToken();
    print('🔑 FCM Token: $token');

    // ✅ Foreground message listener
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification != null) {
        _localNotifications.show(
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails('default_channel', 'General Notifications'),
          ),
        );
      }
    });
  }
}
