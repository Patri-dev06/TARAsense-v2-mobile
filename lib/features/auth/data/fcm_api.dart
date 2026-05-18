import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarasense_mobile/core/network/api_client.dart';
import 'package:tarasense_mobile/features/auth/state/auth_providers.dart';

final fcmApiProvider = Provider<FcmApi>(
  (ref) => FcmApi(ref.watch(apiClientProvider)),
);

class FcmApi {
  const FcmApi(this._client);

  final ApiClient _client;

  /// Registers a device token with the backend so it can send push notifications.
  /// Call this after login, and again whenever [NotificationService.onTokenRefresh] fires.
  Future<void> registerToken({
    required String accessToken,
    required String fcmToken,
  }) async {
    try {
      await _client.postJson(
        '/auth/device-token',
        bearerToken: accessToken,
        data: <String, String>{'token': fcmToken, 'platform': 'android'},
      );
    } catch (_) {
      // Non-critical — the user can still receive notifications if this fails
      // on a single attempt; the backend may retry on next login.
    }
  }

  /// Removes a device token from the backend so the device stops receiving
  /// notifications after logout.
  Future<void> removeToken({
    required String accessToken,
    required String fcmToken,
  }) async {
    try {
      await _client.postJson(
        '/auth/device-token/remove',
        bearerToken: accessToken,
        data: <String, String>{'token': fcmToken},
      );
    } catch (_) {
      // Silently ignore — the token will eventually expire on the backend.
    }
  }
}
