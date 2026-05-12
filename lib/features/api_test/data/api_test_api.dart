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

  Future<Map<String, dynamic>> testFicDashboard() async {
    return _get('/fic/dashboard');
  }

  Future<Map<String, dynamic>> testFicStudies() async {
    return _get(
      '/fic/studies',
      queryParameters: <String, dynamic>{'limit': 50},
    );
  }

  Future<Map<String, dynamic>> testFicCalendar() async {
    return _get(
      '/fic/calendar',
      queryParameters: <String, dynamic>{'limit': 100},
    );
  }

  Future<Map<String, dynamic>> testFicAvailability() async {
    return _get(
      '/fic/availability',
      queryParameters: <String, dynamic>{
        'startDate': '2026-05-01',
        'endDate': '2026-05-31',
      },
    );
  }

  Future<Map<String, dynamic>> testConsumerStudies() async {
    final response = await _client.getData(
      '/consumer/studies',
      bearerToken: _accessToken,
    );
    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }
    if (response is List) {
      return <String, dynamic>{'studies': response};
    }
    return <String, dynamic>{'data': response};
  }

  Future<Map<String, dynamic>> testStudyBuilderOptions() async {
    return _get('/msme/study-builder-options');
  }

  String? get _accessToken =>
      _ref.read(authControllerProvider).session?.tokens.accessToken;

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _client.getData(
      path,
      bearerToken: _accessToken,
      queryParameters: queryParameters,
    );
    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }
    if (response is List) {
      return <String, dynamic>{'data': response};
    }
    return <String, dynamic>{'data': response};
  }
}
