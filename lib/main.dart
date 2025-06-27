import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import './app/router.dart';
import '../providers/notification_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Africa/Kigali'));

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    super.initState();
    // Optionally log initial screen:
    logCurrentScreen('InitialScreen');
  }

  // Call this method when route changes:
  Future<void> logCurrentScreen(String screenName) async {
    await analytics.setCurrentScreen(screenName: screenName);
    // You can add debug prints here if you want
    debugPrint('Analytics: Current screen set to $screenName');
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    // Hook into router's navigator to listen for route changes
    router.routerDelegate.addListener(() {
      final currentRoute = router.routerDelegate.currentConfiguration;
      if (currentRoute != null) {
        // Log the screen name based on route name or path
        logCurrentScreen(currentRoute.toString());
      }
    });

    // Initialize notifications
    ref.read(notificationServiceProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: router,
    );
  }
}
