import 'package:tarasense_mobile/features/auth/data/auth_api.dart';
import 'package:tarasense_mobile/features/auth/data/auth_repository.dart';
import 'package:tarasense_mobile/features/auth/domain/auth_models.dart';
import 'package:tarasense_mobile/core/storage/local_storage.dart';

class AuthService {
  AuthService({
    required AuthRepository repository,
    required LocalStorage localStorage,
  })  : _repository = repository,
        _localStorage = localStorage;

  final AuthRepository _repository;
  final LocalStorage _localStorage;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final session = await _repository.login(
      email: email,
      password: password,
    );

    // Save tokens to local storage
    await _localStorage.saveAuthTokens(session.tokens);

    return session;
  }

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? organization,
  }) async {
    final session = await _repository.register(
      name: name,
      email: email,
      password: password,
      role: role,
      organization: organization,
    );

    // Save tokens to local storage
    await _localStorage.saveAuthTokens(session.tokens);

    return session;
  }

  Future<AuthSession> refresh() async {
    final refreshToken = await _localStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw const FormatException('No refresh token available');
    }

    final session = await _repository.refresh(refreshToken);
    
    // Save new tokens to local storage
    await _localStorage.saveAuthTokens(session.tokens);

    return session;
  }

  Future<UserProfile> getProfile() async {
    final accessToken = await _localStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw const FormatException('No access token available');
    }

    return await _repository.me(accessToken);
  }

  Future<void> logout() async {
    final accessToken = await _localStorage.getAccessToken();
    final refreshToken = await _localStorage.getRefreshToken();

    if (accessToken != null && accessToken.isNotEmpty) {
      try {
        await _repository.logout(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      } catch (e) {
        // Even if logout fails, we still clear local storage
      }
    }

    // Clear local storage
    await _localStorage.clearAuthTokens();
  }
}