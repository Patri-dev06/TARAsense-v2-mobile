import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarasense_mobile/core/network/api_client.dart';
import 'package:tarasense_mobile/features/auth/state/auth_providers.dart';

class ApiTestApi {
  ApiTestApi(this._client, this._ref);

  final ApiClient _client;
  final Ref _ref;

  Future<Map<String, dynamic>> testAuthMe() async {
    return _get('/auth/me');
  }

  Future<Map<String, dynamic>> testProfile() async {
    return _get('/profile');
  }

  Future<Map<String, dynamic>> testMsmeDashboard() async {
    return _get('/msme/dashboard');
  }

  Future<Map<String, dynamic>> testStudyBuilderOptions() async {
    return _get('/msme/study-builder-options');
  }

  String? get _accessToken =>
      _ref.read(authControllerProvider).session?.tokens.accessToken;

  Future<Map<String, dynamic>> _get(String path) {
    return _client.getJson(path, bearerToken: _accessToken);
  }
}
