import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tarasense_mobile/core/config/app_config.dart';
import 'package:tarasense_mobile/features/api_test/ui/api_test_page.dart';
import 'package:tarasense_mobile/features/admin/ui/admin_workspace_page.dart';
import 'package:tarasense_mobile/features/auth/state/auth_providers.dart';
import 'package:tarasense_mobile/features/auth/state/auth_state.dart';
import 'package:tarasense_mobile/features/auth/ui/login_page.dart';
import 'package:tarasense_mobile/features/auth/ui/register_page.dart';
import 'package:tarasense_mobile/features/fic/domain/fic_models.dart';
import 'package:tarasense_mobile/features/fic/ui/fic_sensory_analysis_page.dart';
import 'package:tarasense_mobile/features/fic/ui/fic_study_form_page.dart';
import 'package:tarasense_mobile/features/fic/ui/fic_workspace_page.dart';
import 'package:tarasense_mobile/features/landing/ui/landing_page.dart';
import 'package:tarasense_mobile/features/msme/domain/msme_models.dart';
import 'package:tarasense_mobile/features/msme/ui/msme_study_detail_page.dart';
import 'package:tarasense_mobile/features/msme/ui/msme_workspace_page.dart';
import 'package:tarasense_mobile/features/splash/ui/splash_page.dart';
import 'package:tarasense_mobile/features/tester/domain/consumer_study.dart';
import 'package:tarasense_mobile/features/tester/ui/consumer_consent_page.dart';
import 'package:tarasense_mobile/features/tester/ui/consumer_panel_entry_page.dart';
import 'package:tarasense_mobile/features/tester/ui/consumer_study_detail_page.dart';
import 'package:tarasense_mobile/features/tester/ui/sensory_test_page.dart';
import 'package:tarasense_mobile/features/tester/ui/tester_workspace_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = _AuthStateNotifier(ref.read(authControllerProvider));
  ref.listen<AuthState>(authControllerProvider, (_, next) {
    authNotifier.value = next;
  });
  ref.onDispose(authNotifier.dispose);

  return GoRouter(
    initialLocation: AppConfig.uiPreviewMode ? '/dashboard' : '/splash',
    refreshListenable: authNotifier,
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
        path: '/msme/studies/:studyId',
        builder: (context, state) => MsmeStudyDetailPage(
          studyId: state.pathParameters['studyId'] ?? '',
          initialStudy: state.extra is MsmeStudyItem
              ? state.extra! as MsmeStudyItem
              : null,
        ),
      ),
      GoRoute(
        path: '/fic',
        builder: (context, state) => const FicWorkspacePage(),
      ),
      GoRoute(
        path: '/fic/studies/:studyId/form',
        builder: (context, state) => FicStudyFormPage(
          studyId: state.pathParameters['studyId'] ?? '',
          study: state.extra is FicStudy ? state.extra! as FicStudy : null,
        ),
      ),
      GoRoute(
        path: '/fic/studies/:studyId/analysis',
        builder: (context, state) => FicSensoryAnalysisPage(
          studyId: state.pathParameters['studyId'] ?? '',
          study: state.extra is FicStudy ? state.extra! as FicStudy : null,
        ),
      ),
      GoRoute(
        path: '/consumer',
        builder: (context, state) => const TesterWorkspacePage(),
      ),
      GoRoute(
        path: '/consumer/studies/:studyId',
        builder: (context, state) => ConsumerStudyDetailPage(
          studyId: state.pathParameters['studyId'] ?? '',
          study: state.extra is ConsumerStudy
              ? state.extra! as ConsumerStudy
              : null,
        ),
      ),
      GoRoute(
        path: '/consumer/studies/:studyId/panel-entry',
        builder: (context, state) => ConsumerPanelEntryPage(
          studyId: state.pathParameters['studyId'] ?? '',
          study: state.extra is ConsumerStudy
              ? state.extra! as ConsumerStudy
              : null,
        ),
      ),
      GoRoute(
        path: '/consumer/studies/:studyId/consent',
        builder: (context, state) {
          final String studyId = state.pathParameters['studyId'] ?? '';
          final ConsumerConsentArgs? args = state.extra is ConsumerConsentArgs
              ? state.extra! as ConsumerConsentArgs
              : null;
          return ConsumerConsentPage(
            studyId: studyId,
            participantId: args?.participantId ?? '',
            study: args?.study,
            panelistNumber: args?.panelistNumber,
          );
        },
      ),
      GoRoute(
        path: '/consumer/studies/:studyId/test',
        builder: (context, state) => SensoryTestPage(
          studyId: state.pathParameters['studyId'] ?? '',
          initialStudy: state.extra is ConsumerStudy
              ? state.extra! as ConsumerStudy
              : null,
        ),
      ),
      GoRoute(
        path: '/consumer/studies/:studyId/participants/:participantId/test',
        builder: (context, state) => SensoryTestPage(
          studyId: state.pathParameters['studyId'] ?? '',
          participantId: state.pathParameters['participantId'] ?? '',
          initialStudy: state.extra is ConsumerStudy
              ? state.extra! as ConsumerStudy
              : null,
        ),
      ),
      GoRoute(
        path: '/tester',
        builder: (context, state) => const TesterWorkspacePage(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminWorkspacePage(),
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

      final authState = authNotifier.value;
      final path = state.matchedLocation;

      if (authState.status == AuthStatus.initializing) {
        return path == '/splash' ? null : '/splash';
      }

      if (authState.status == AuthStatus.authenticated) {
        final String homePath =
            authState.session?.user.homePath ?? '/dashboard';
        if (path == '/splash' || path == '/login' || path == '/register') {
          return homePath;
        }
        if (_isRoleWorkspace(path) && path != homePath) {
          return homePath;
        }
        return null;
      }

      if (path == '/splash') {
        return '/login';
      }

      if (_isProtectedPath(path)) {
        return '/login';
      }

      return null;
    },
  );
});

class _AuthStateNotifier extends ChangeNotifier {
  _AuthStateNotifier(AuthState initial) : _value = initial;

  AuthState _value;
  AuthState get value => _value;
  set value(AuthState next) {
    _value = next;
    notifyListeners();
  }
}

bool _isRoleWorkspace(String path) {
  return path == '/dashboard' ||
      path == '/fic' ||
      path == '/consumer' ||
      path == '/tester' ||
      path == '/admin';
}

bool _isProtectedPath(String path) {
  return _isRoleWorkspace(path) ||
      path == '/api-test' ||
      path.startsWith('/msme/studies/') ||
      path.startsWith('/fic/studies/') ||
      path.startsWith('/consumer/studies/') ||
      path.startsWith('/consumer/studies');
}
