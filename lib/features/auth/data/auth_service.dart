import 'package:tarasense_mobile/core/storage/token_storage.dart';
import 'package:tarasense_mobile/features/auth/data/auth_repository.dart';
import 'package:tarasense_mobile/features/auth/domain/auth_models.dart';

class AuthService {
  AuthService({
    required AuthRepository repository,
    required TokenStorage tokenStorage,
  })  : _repository = repository,
        _tokenStorage = tokenStorage;

  final AuthRepository _repository;
  final TokenStorage _tokenStorage;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final session = await _repository.login(
      email: email,
      password: password,
    );

    await _tokenStorage.saveTokens(session.tokens);

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

    await _tokenStorage.saveTokens(session.tokens);

    return session;
  }

  Future<AuthSession> refresh() async {
    final tokens = await _tokenStorage.readTokens();
    final refreshToken = tokens?.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      throw const FormatException('No refresh token available');
    }

    final session = await _repository.refresh(refreshToken);

    await _tokenStorage.saveTokens(session.tokens);

    return session;
  }

  Future<UserProfile> getProfile() async {
    final tokens = await _tokenStorage.readTokens();
    final accessToken = tokens?.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      throw const FormatException('No access token available');
    }

    return await _repository.me(accessToken);
  }

  Future<void> logout() async {
    final tokens = await _tokenStorage.readTokens();
    final accessToken = tokens?.accessToken;
    final refreshToken = tokens?.refreshToken;

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

    await _tokenStorage.clear();
  }
}
