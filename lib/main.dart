// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'firebase_options.dart';
import './app/router.dart';
import '../providers/notification_provider.dart';

/// 👇 Background handler for FCM
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📩 Background FCM message: ${message.messageId}');
  print('📩 Title: ${message.notification?.title}');
  print('📩 Body: ${message.notification?.body}');
  print('📩 Data: ${message.data}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Timezone setup
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Africa/Kigali'));

  // ✅ Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ Background FCM handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // ✅ Call notification setup
    ref.read(notificationServiceProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: router,
    );
  }
}