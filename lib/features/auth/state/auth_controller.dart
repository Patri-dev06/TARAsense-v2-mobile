import 'dart:async';

import 'package:dio/dio.dart';
import 'package:riverpod/riverpod.dart';
import 'package:tarasense_mobile/core/config/app_config.dart';
import 'package:tarasense_mobile/core/storage/token_storage.dart';
import 'package:tarasense_mobile/features/auth/data/auth_api.dart';
import 'package:tarasense_mobile/features/auth/domain/auth_models.dart';
import 'package:tarasense_mobile/features/auth/state/auth_providers.dart';
import 'package:tarasense_mobile/features/auth/state/auth_state.dart';

class AuthController extends Notifier<AuthState> {
  late final AuthApi _authApi;
  late final TokenStorage _tokenStorage;

  @override
  AuthState build() {
    _authApi = ref.watch(authApiProvider);
    _tokenStorage = ref.watch(tokenStorageProvider);
    unawaited(restoreSession());
    return AuthState.initializing();
  }

  Future<void> restoreSession() async {
    state = AuthState.initializing();
    try {
      final storedTokens = await _tokenStorage.readTokens();
      if (storedTokens == null) {
        state = AuthState.unauthenticated();
        return;
      }

      final session = await _hydrateSession(
        storedTokens,
      ).timeout(const Duration(seconds: 8), onTimeout: () => null);
      if (session == null) {
        await _tokenStorage.clear();
        state = AuthState.unauthenticated();
        return;
      }

      state = AuthState.authenticated(session);
    } catch (_) {
      // Prevent startup from getting stuck on splash if secure storage or
      // session hydration fails unexpectedly on a device/runtime.
      await _tokenStorage.clear();
      state = AuthState.unauthenticated();
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isBusy: true, clearError: true);
    try {
      final session = await _authApi.login(email: email, password: password);
      await _tokenStorage.saveTokens(session.tokens);
      state = AuthState.authenticated(session);
    } catch (error) {
      state = AuthState.unauthenticated(errorMessage: _errorMessage(error));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? organization,
  }) async {
    state = state.copyWith(isBusy: true, clearError: true);
    try {
      final session = await _authApi.register(
        name: name,
        email: email,
        password: password,
        organization: organization,
      );
      await _tokenStorage.saveTokens(session.tokens);
      state = AuthState.authenticated(session);
    } catch (error) {
      state = AuthState.unauthenticated(errorMessage: _errorMessage(error));
    }
  }

  Future<void> refreshProfile() async {
    final currentSession = state.session;
    if (currentSession == null) {
      return;
    }

    state = state.copyWith(isBusy: true, clearError: true);
    final nextSession = await _hydrateSession(currentSession.tokens);
    if (nextSession == null) {
      await _tokenStorage.clear();
      state = AuthState.unauthenticated(
        errorMessage: 'Session expired. Please sign in again.',
      );
      return;
    }

    state = AuthState.authenticated(nextSession);
  }

  Future<void> logout() async {
    final currentSession = state.session;
    state = state.copyWith(isBusy: true, clearError: true);

    if (currentSession != null) {
      try {
        await _authApi.logout(
          accessToken: currentSession.tokens.accessToken,
          refreshToken: currentSession.tokens.refreshToken,
        );
      } catch (_) {
        // Ignore network errors on logout; we still clear local session.
      }
    }

    await _tokenStorage.clear();
    state = AuthState.unauthenticated();
  }

  Future<AuthSession?> _hydrateSession(AuthTokens tokens) async {
    if (tokens.accessToken.trim().isEmpty ||
        tokens.refreshToken.trim().isEmpty) {
      return null;
    }

    try {
      final user = await _authApi.me(tokens.accessToken);
      if (user.id.trim().isEmpty || user.email.trim().isEmpty) {
        return null;
      }
      return AuthSession(user: user, tokens: tokens);
    } on DioException catch (error) {
      if (!_isUnauthorized(error)) {
        return null;
      }
      return _tryRefresh(tokens.refreshToken);
    } catch (_) {
      return null;
    }
  }

  Future<AuthSession?> _tryRefresh(String refreshToken) async {
    try {
      final session = await _authApi.refresh(refreshToken);
      await _tokenStorage.saveTokens(session.tokens);
      return session;
    } catch (_) {
      return null;
    }
  }

  bool _isUnauthorized(DioException error) {
    return error.response?.statusCode == 401;
  }

  String _errorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        return data['message'].toString();
      }
      if (error.response?.statusCode == 401) {
        return 'Invalid credentials.';
      }
      if (error.type == DioExceptionType.connectionError) {
        final String message = error.message?.toLowerCase() ?? '';
        if (message.contains('connection refused') ||
            message.contains('failed host lookup') ||
            message.contains('connection closed')) {
          return 'Cannot connect to API at ${AppConfig.apiBaseUrl}. '
              'Make sure the TARAsense API is running.';
        }
        return 'Cannot connect to API at ${AppConfig.apiBaseUrl}.';
      }
      return error.message ?? 'Request failed. Please try again.';
    }
    if (error is FormatException) {
      return error.message;
    }
    return 'Something went wrong. Please try again.';
  }
}
