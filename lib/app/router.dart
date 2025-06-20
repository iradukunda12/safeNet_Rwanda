import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../features/auth/views/sign_in_view.dart';
import '../features/auth/views/sign_up_view.dart';
import 'go_router_refresh_stream.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  final routerRefresh = GoRouterRefreshStream(
    ref.read(authStateProvider.stream),
  );

  return GoRouter(
    initialLocation: '/sign-in',
    refreshListenable: routerRefresh,
    redirect: (context, state) {
      final user = authState.maybeWhen(
        data: (user) => user,
        orElse: () => null,
      );

      final isAuth = user != null;
      final isAtAuth = state.uri.path == '/sign-in' || state.uri.path == '/sign-up';

      // If not authenticated and trying to access protected routes, redirect to sign-in
      if (!isAuth && !isAtAuth) return '/sign-in';

      // If authenticated and at auth screen, redirect to home (you might want to add this later)
      // if (isAuth && isAtAuth) return '/home';

      return null; // No redirect needed
    },
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
  );
});