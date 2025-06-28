import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

// Views
import 'package:school_project/features/onboarding/splash_view.dart';
import 'package:school_project/features/onboarding/onboarding_view.dart';
import 'package:school_project/features/auth/views/sign_in_view.dart';
import 'package:school_project/features/auth/views/sign_up_view.dart';
import 'package:school_project/features/Dashboard/dashboard_home_view.dart';
import 'package:school_project/features/Dashboard/contact_view.dart';
import 'package:school_project/features/Dashboard/contact/crisis_message_view.dart';
import 'package:school_project/features/Dashboard/contact/phone_view.dart';
import 'package:school_project/features/Dashboard/contact/crisis_center_view.dart';
import 'package:school_project/features/Dashboard/contact/chat_view.dart';
import 'package:school_project/features/Dashboard/record_view.dart';
import 'package:school_project/features/Dashboard/setting_view.dart';
import 'package:school_project/features/Dashboard/Setting/notifications_page.dart';
import 'package:school_project/features/Dashboard/Setting/import_export_page.dart';
import 'package:school_project/features/Dashboard/Setting/about_page.dart';

// Record subpages
import 'package:school_project/features/Dashboard/record/mood_monitoring_view.dart';
import 'package:school_project/features/Dashboard/record/my_sleep_view.dart';
import 'package:school_project/features/Dashboard/record/diary_view.dart';
import 'package:school_project/features/Dashboard/record/journey_view.dart';
import 'package:school_project/features/Dashboard/record/meal_record_view.dart';
import 'package:school_project/features/Dashboard/Contact/health_page.dart';

// Layouts
import '../features/auth/authentication_layout.dart';
import '../features/Dashboard/DashboardLayout.dart';

// Controllers
import '../features/auth/controllers/auth_controller.dart';
import 'go_router_refresh_stream.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final routerRefresh = GoRouterRefreshStream(ref.read(authStateProvider.stream));
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  final router = GoRouter(
    initialLocation: '/',
    refreshListenable: routerRefresh,

    redirect: (context, state) {
      final user = authState.maybeWhen(data: (user) => user, orElse: () => null);
      final isAuth = user != null;

      final path = state.uri.path;
      final isAtAuth = path == '/sign-in' || path == '/sign-up';
      final isAtSplash = path == '/';
      final isAtOnboarding = path == '/onboarding';

      if (!isAuth && !(isAtAuth || isAtSplash || isAtOnboarding)) {
        return '/sign-in';
      }

      if (isAuth && (isAtSplash || isAtOnboarding || isAtAuth)) {
        return '/dashboard/home';
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingView(),
      ),

      // Auth layout
      ShellRoute(
        builder: (context, state, child) => AuthenticationLayout(child: child),
        routes: [
          GoRoute(
            path: '/sign-in',
            builder: (context, state) => const SignInView(),
          ),
          GoRoute(
            path: '/sign-up',
            builder: (context, state) => const SignUpView(),
          ),
        ],
      ),

      // Dashboard layout
      ShellRoute(
        builder: (context, state, child) {
          final location = state.uri.toString();
          int selectedIndex = 0;

          if (location.startsWith('/dashboard/record')) {
            selectedIndex = 1;
          } else if (location.startsWith('/dashboard/contact')) selectedIndex = 2;
          else if (location.startsWith('/dashboard/settings')) selectedIndex = 3;
          else selectedIndex = 0;

          return DashboardLayoutWithIndex(selectedIndex: selectedIndex, child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard/home',
            builder: (context, state) => const DashboardHomeView(),
          ),
          GoRoute(
            path: '/dashboard/record',
            builder: (context, state) => const RecordView(),
            routes: [
              GoRoute(
                path: 'mood-monitoring',
                builder: (context, state) => const MoodMonitoringView(),
              ),
              GoRoute(
                path: 'my-sleep',
                builder: (context, state) => const MySleepView(),
              ),
              GoRoute(
                path: 'diary',
                builder: (context, state) => const DiaryView(),
              ),
              GoRoute(
                path: 'journey',
                builder: (context, state) => const JourneyView(),
              ),
              GoRoute(
                path: 'meal-record',
                builder: (context, state) => const MealRecordView(),
              ),
            ],
          ),

          // Contact route with nested routes
          GoRoute(
            path: '/dashboard/contact',
            builder: (context, state) => const ContactView(),
            routes: [
              GoRoute(
                path: 'crisis-message',
                builder: (context, state) => const CrisisMessageView(),
              ),
              GoRoute(
                path: 'phone',
                builder: (context, state) => const PhoneView(),
              ),
              GoRoute(
                path: 'crisis-center',
                builder: (context, state) => const CrisisCenterView(),
              ),
              GoRoute(
                path: 'chat',
                builder: (context, state) => const ChatView(),
              ),
              GoRoute(
                path: 'speech',
                builder: (context, state) => const HealthBlogPage(),
              ),
            ],
          ),

          // Settings route with subpages
          GoRoute(
            path: '/dashboard/settings',
            builder: (context, state) => const SettingView(),
            routes: [
              GoRoute(
                path: 'notification',
                builder: (context, state) => const NotificationsPage(),
              ),
              GoRoute(
                path: 'import-export',
                builder: (context, state) => const ImportExportPage(),
              ),
              GoRoute(
                path: 'about',
                builder: (context, state) => const AboutPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );


  router.routerDelegate.addListener(() {
    final location = router.routerDelegate.currentConfiguration.location;
    if (location != null) {
      analytics.setCurrentScreen(screenName: location).then((_) {
        debugPrint('Analytics: Logged screen $location');
      }).catchError((e) {
        debugPrint('Analytics: Failed to log screen: $e');
      });

      analytics.logEvent(
        name: 'screen_view',
        parameters: {'screen_name': location},
      );
    }
  });

  return router;
});

extension on RouteMatchList {
   get location => null;
}
