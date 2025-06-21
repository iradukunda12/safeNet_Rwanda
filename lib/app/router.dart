import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../features/auth/views/sign_in_view.dart';
import '../features/auth/views/sign_up_view.dart';
import 'go_router_refresh_stream.dart';
import '../features/onboarding/onboarding_view.dart';
import '../features/onboarding/splash_view.dart';
import '../features/Dashboard/DashboardLayout.dart';
import '../features/Dashboard/DashboardHomeView.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  final routerRefresh = GoRouterRefreshStream(
    ref.read(authStateProvider.stream),
  );

  return GoRouter(
    initialLocation: '/',
    refreshListenable: routerRefresh,

    redirect: (context, state) {
      final user = authState.maybeWhen(
        data: (user) => user,
        orElse: () => null,
      );

      final isAuth = user != null;
      final isAtAuth = state.uri.path == '/sign-in' || state.uri.path == '/sign-up';
      final isAtOnboarding = state.uri.path == '/' || state.uri.path == '/onboarding';

      if (!isAuth && !isAtAuth && !isAtOnboarding) {
        return '/sign-in';
      }

      if (isAuth && (state.uri.path == '/' || state.uri.path == '/sign-in' || state.uri.path == '/sign-up')) {
        return '/dashboard';
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
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInView(),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (context, state) => const SignUpView(),
      ),

      /// 👇 Authenticated layout
      ShellRoute(
        builder: (context, state, child) {
          return DashboardLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardHomeView(),
          ),
          // You can add more authenticated routes here
        ],
      ),
    ],
  );
});
