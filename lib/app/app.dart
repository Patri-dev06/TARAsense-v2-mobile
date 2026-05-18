import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarasense_mobile/app/router.dart';
import 'package:tarasense_mobile/core/config/app_config.dart';
import 'package:tarasense_mobile/core/network/api_client.dart';
import 'package:tarasense_mobile/core/notifications/notification_service.dart';
import 'package:tarasense_mobile/core/theme/tara_theme.dart';
import 'package:tarasense_mobile/features/auth/data/fcm_api.dart';
import 'package:tarasense_mobile/features/auth/state/auth_providers.dart';
import 'package:tarasense_mobile/features/auth/state/auth_state.dart';
import 'package:tarasense_mobile/features/auth/ui/auth_loading_dialog.dart';

class TaraSenseApp extends ConsumerStatefulWidget {
  const TaraSenseApp({super.key});

  @override
  ConsumerState<TaraSenseApp> createState() => _TaraSenseAppState();
}

class _TaraSenseAppState extends ConsumerState<TaraSenseApp> {
  Timer? _studyPollTimer;
  Timer? _studyAlertDismissTimer;
  bool _isPollingStudies = false;
  String? _activeToken;
  Set<String> _knownStudyIds = <String>{};
  _StudyAlertData? _studyAlert;

  // FCM token management
  String? _registeredFcmToken;
  StreamSubscription<String>? _fcmTokenRefreshSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _handleAuthState(ref.read(authControllerProvider));
      _listenForNotificationTaps();
    });
  }

  @override
  void dispose() {
    _studyPollTimer?.cancel();
    _studyAlertDismissTimer?.cancel();
    _fcmTokenRefreshSub?.cancel();
    super.dispose();
  }

  // ─── FCM helpers ─────────────────────────────────────────────────────────────

  void _listenForNotificationTaps() {
    // App was in background and user tapped the notification.
    NotificationService.instance.onNotificationTap.listen((_) {
      // Navigate to dashboard so the user sees the new study.
      ref.read(appRouterProvider).go('/consumer');
    });

    // App was fully killed and user tapped the notification to launch it.
    NotificationService.instance.getInitialMessage().then((message) {
      if (message != null && mounted) {
        ref.read(appRouterProvider).go('/consumer');
      }
    });
  }

  Future<void> _registerFcmToken(String accessToken) async {
    final String? token = await NotificationService.instance.getToken();
    if (token == null || token == _registeredFcmToken) return;

    _registeredFcmToken = token;
    await ref.read(fcmApiProvider).registerToken(
      accessToken: accessToken,
      fcmToken: token,
    );

    // Re-register automatically whenever FCM rotates the token.
    _fcmTokenRefreshSub?.cancel();
    _fcmTokenRefreshSub = NotificationService.instance.onTokenRefresh.listen(
      (newToken) async {
        _registeredFcmToken = newToken;
        final session = ref.read(authControllerProvider).session;
        if (session == null) return;
        await ref.read(fcmApiProvider).registerToken(
          accessToken: session.tokens.accessToken,
          fcmToken: newToken,
        );
      },
    );
  }

  Future<void> _removeFcmToken(String accessToken) async {
    final token = _registeredFcmToken;
    if (token == null) return;
    _registeredFcmToken = null;
    _fcmTokenRefreshSub?.cancel();
    _fcmTokenRefreshSub = null;
    await ref.read(fcmApiProvider).removeToken(
      accessToken: accessToken,
      fcmToken: token,
    );
  }

  void _handleAuthState(AuthState authState) {
    if (AppConfig.uiPreviewMode ||
        authState.status != AuthStatus.authenticated ||
        authState.session == null) {
      _stopStudyNotifications();
      return;
    }

    final String accessToken = authState.session!.tokens.accessToken;

    // Register FCM token for every authenticated user so all roles
    // (Consumer, MSME, FIC) receive push notifications.
    unawaited(_registerFcmToken(accessToken));

    if (!authState.session!.user.isMsme) {
      _stopStudyNotifications(clearToken: false);
      return;
    }
    if (_activeToken != accessToken) {
      _activeToken = accessToken;
      _knownStudyIds = <String>{};
      _studyAlertDismissTimer?.cancel();
      if (mounted) {
        setState(() => _studyAlert = null);
      }
      unawaited(_pollStudies(seedOnly: true));
    }

    _studyPollTimer ??= Timer.periodic(
      const Duration(seconds: 30),
      (_) => unawaited(_pollStudies()),
    );
  }

  void _stopStudyNotifications({bool clearToken = true}) {
    _studyPollTimer?.cancel();
    _studyPollTimer = null;
    _studyAlertDismissTimer?.cancel();
    _studyAlertDismissTimer = null;
    if (clearToken) {
      _activeToken = null;
    }
    _knownStudyIds = <String>{};
    if (_studyAlert != null && mounted) {
      setState(() => _studyAlert = null);
    }
  }

  Future<void> _pollStudies({bool seedOnly = false}) async {
    if (_isPollingStudies) {
      return;
    }

    final authState = ref.read(authControllerProvider);
    final session = authState.session;
    if (authState.status != AuthStatus.authenticated || session == null) {
      return;
    }

    _isPollingStudies = true;
    try {
      final ApiClient client = ref.read(apiClientProvider);
      final Map<String, dynamic> response = await client.getJson(
        '/msme/dashboard',
        bearerToken: session.tokens.accessToken,
      );
      final List<_StudyDigest> studies = _extractStudies(response);
      if (studies.isEmpty) {
        return;
      }

      final Set<String> latestIds = studies
          .map((_StudyDigest study) => study.id)
          .where((String id) => id.isNotEmpty)
          .toSet();

      if (_knownStudyIds.isEmpty || seedOnly) {
        _knownStudyIds = latestIds;
        return;
      }

      final List<_StudyDigest> newStudies = studies
          .where((_StudyDigest study) => !_knownStudyIds.contains(study.id))
          .toList();
      _knownStudyIds = latestIds;

      if (newStudies.isNotEmpty) {
        _showStudyAlert(newStudies);
      }
    } catch (_) {
      // Keep this silent for now so unsupported roles or intermittent
      // dashboard endpoint errors do not interrupt the session.
    } finally {
      _isPollingStudies = false;
    }
  }

  List<_StudyDigest> _extractStudies(Map<String, dynamic> response) {
    final List<dynamic> rawStudies = response['studies'] as List<dynamic>? ??
        <dynamic>[];
    return rawStudies
        .whereType<Map>()
        .map((Map entry) => Map<String, dynamic>.from(entry))
        .map(
          (Map<String, dynamic> study) => _StudyDigest(
            id: (study['id'] ?? study['studyId'] ?? '').toString(),
            title: (study['title'] ?? study['studyTitle'] ?? 'New study')
                .toString(),
          ),
        )
        .where((_StudyDigest study) => study.id.trim().isNotEmpty)
        .toList();
  }

  void _showStudyAlert(List<_StudyDigest> newStudies) {
    final _StudyDigest latest = newStudies.first;
    final int count = newStudies.length;

    _studyAlertDismissTimer?.cancel();
    if (!mounted) {
      return;
    }

    setState(
      () => _studyAlert = _StudyAlertData(
        title: count == 1 ? 'New study available' : '$count new studies added',
        message: count == 1
            ? latest.title
            : '${latest.title} and ${count - 1} more',
      ),
    );

    _studyAlertDismissTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) {
        return;
      }
      setState(() => _studyAlert = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      // When the user logs out, remove the FCM token from the backend while
      // we still have the old access token from the previous state.
      if (previous?.status == AuthStatus.authenticated &&
          next.status != AuthStatus.authenticated &&
          previous?.session != null) {
        unawaited(
          _removeFcmToken(previous!.session!.tokens.accessToken),
        );
      }
      _handleAuthState(next);
    });

    return MaterialApp.router(
      title: 'TARAsense Mobile',
      debugShowCheckedModeBanner: false,
      theme: TaraTheme.light(),
      routerConfig: router,
      builder: (BuildContext context, Widget? child) {
        return ValueListenableBuilder<bool>(
          valueListenable: authOperationOverlayVisible,
          builder: (context, showAuthOperationOverlay, _) {
            return Stack(
              children: <Widget>[
                child ?? const SizedBox.shrink(),
                SafeArea(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: IgnorePointer(
                        ignoring: _studyAlert == null,
                        child: AnimatedSlide(
                          offset: _studyAlert == null
                              ? const Offset(0, -1.2)
                              : Offset.zero,
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          child: AnimatedOpacity(
                            opacity: _studyAlert == null ? 0 : 1,
                            duration: const Duration(milliseconds: 200),
                            child: _StudyAlertBanner(data: _studyAlert),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (showAuthOperationOverlay)
                  const AuthOperationLoadingOverlay(
                    message: 'Logging out...',
                    subtitle: 'Securing your session...',
                    icon: Icons.logout_rounded,
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _StudyAlertData {
  const _StudyAlertData({required this.title, required this.message});

  final String title;
  final String message;
}

class _StudyDigest {
  const _StudyDigest({required this.id, required this.title});

  final String id;
  final String title;
}

class _StudyAlertBanner extends StatelessWidget {
  const _StudyAlertBanner({required this.data});

  final _StudyAlertData? data;

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const SizedBox.shrink();
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            color: TaraTheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEADBC9)),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x180F172A),
                blurRadius: 24,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: TaraTheme.primaryTint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: TaraTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      data!.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: TaraTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data!.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: TaraTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
