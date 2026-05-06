import 'package:tarasense_mobile/core/network/api_client.dart';
import 'package:tarasense_mobile/features/auth/domain/auth_models.dart';

class AuthApi {
  AuthApi(this._apiClient);

  final ApiClient _apiClient;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.postJson(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    return AuthSession.fromAuthResponse(response);
  }

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? organization,
  }) async {
    final data = {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    };

    if (organization != null) {
      data['organization'] = organization;
    }

    final response = await _apiClient.postJson(
      '/auth/register',
      data: data,
    );

    return AuthSession.fromAuthResponse(response);
  }

  Future<AuthSession> refresh(String refreshToken) async {
    final response = await _apiClient.postJson(
      '/auth/refresh',
      data: {
        'refreshToken': refreshToken,
      },
    );
    return AuthSession.fromAuthResponse(response);
  }

  Future<UserProfile> me(String accessToken) async {
    final response = await _apiClient.getJson(
      '/auth/me',
      bearerToken: accessToken,
    );

    return UserProfile.fromJson(response);
  }

  Future<void> logout({
    required String accessToken,
    String? refreshToken,
  }) async {
    final data = <String, dynamic>{};
    if (refreshToken != null && refreshToken.trim().isNotEmpty) {
      data['refreshToken'] = refreshToken;
    }

    await _apiClient.postJson(
      '/auth/logout',
      bearerToken: accessToken,
      data: data.isEmpty ? null : data,
    );
  }
}

