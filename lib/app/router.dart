import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tarasense_mobile/features/api_test/ui/api_test_page.dart';
import 'package:tarasense_mobile/features/auth/state/auth_providers.dart';
import 'package:tarasense_mobile/features/auth/state/auth_state.dart';
import 'package:tarasense_mobile/features/auth/ui/login_page.dart';
import 'package:tarasense_mobile/features/auth/ui/register_page.dart';
import 'package:tarasense_mobile/features/landing/ui/landing_page.dart';
import 'package:tarasense_mobile/features/msme/ui/msme_workspace_page.dart';
import 'package:tarasense_mobile/features/splash/ui/splash_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/splash',
    routes: <GoRoute>[
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const LandingPage()),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const MsmeWorkspacePage(),
      ),
      GoRoute(
        path: '/api-test',
        builder: (context, state) => const ApiTestPage(),
      ),
    ],
    redirect: (context, state) {
      final path = state.matchedLocation;
      final isAuthPage = path == '/login' || path == '/register';

      if (authState.status == AuthStatus.initializing) {
        return path == '/splash' ? null : '/splash';
      }

      if (authState.status == AuthStatus.authenticated) {
        if (path == '/splash' || isAuthPage) {
          return '/dashboard';
        }
        return null;
      }

      if (path == '/splash') {
        return '/login';
      }

      if (path == '/dashboard' || path == '/api-test' || path == '/home') {
        return '/login';
      }

      return null;
    },
  );
});
