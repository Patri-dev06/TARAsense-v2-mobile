import 'package:tarasense_mobile/features/auth/data/auth_api.dart';
import 'package:tarasense_mobile/features/auth/domain/auth_models.dart';

abstract class AuthRepository {
  Future<AuthSession> login({
    required String email,
    required String password,
  });

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? organization,
  });

  Future<AuthSession> refresh(String refreshToken);

  Future<UserProfile> me(String accessToken);

  Future<void> logout({
    required String accessToken,
    String? refreshToken,
  });
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._api);

  final AuthApi _api;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    return await _api.login(email: email, password: password);
  }

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? organization,
  }) async {
    return await _api.register(
      name: name,
      email: email,
      password: password,
      role: role,
      organization: organization,
    );
  }

  @override
  Future<AuthSession> refresh(String refreshToken) async {
    return await _api.refresh(refreshToken);
  }

  @override
  Future<UserProfile> me(String accessToken) async {
    return await _api.me(accessToken);
  }

  @override
  Future<void> logout({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _api.logout(accessToken: accessToken, refreshToken: refreshToken);
  }
}