import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tarasense_mobile/core/config/app_config.dart';
import 'package:tarasense_mobile/features/api_test/ui/api_test_page.dart';
import 'package:tarasense_mobile/features/auth/state/auth_providers.dart';
import 'package:tarasense_mobile/features/auth/state/auth_state.dart';
import 'package:tarasense_mobile/features/auth/ui/login_page.dart';
import 'package:tarasense_mobile/features/auth/ui/register_page.dart';
import 'package:tarasense_mobile/features/fic/ui/fic_workspace_page.dart';
import 'package:tarasense_mobile/features/landing/ui/landing_page.dart';
import 'package:tarasense_mobile/features/msme/ui/msme_workspace_page.dart';
import 'package:tarasense_mobile/features/splash/ui/splash_page.dart';
import 'package:tarasense_mobile/features/tester/ui/tester_workspace_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: AppConfig.uiPreviewMode ? '/dashboard' : '/splash',
    routes: <GoRoute>[
      GoRoute(path: '/', builder: (context, state) => const LandingPage()),
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
        path: '/fic',
        builder: (context, state) => const FicWorkspacePage(),
      ),
      GoRoute(
        path: '/tester',
        builder: (context, state) => const TesterWorkspacePage(),
      ),
      GoRoute(
        path: '/api-test',
        builder: (context, state) => const ApiTestPage(),
      ),
    ],
    redirect: (context, state) {
      if (AppConfig.uiPreviewMode) {
        return null;
      }

      final path = state.matchedLocation;

      if (authState.status == AuthStatus.initializing) {
        return path == '/splash' ? null : '/splash';
      }

      if (authState.status == AuthStatus.authenticated) {
        final String homePath = authState.session?.user.homePath ?? '/dashboard';
        if (path == '/splash') {
          return homePath;
        }
        if (_isRoleWorkspace(path) && path != homePath) {
          return homePath;
        }
        return null;
      }

      if (path == '/splash') {
        return '/';
      }

      if (_isRoleWorkspace(path) || path == '/api-test') {
        return '/';
      }

      return null;
    },
  );
});

bool _isRoleWorkspace(String path) {
  return path == '/dashboard' || path == '/fic' || path == '/tester';
}
