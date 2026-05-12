import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarasense_mobile/core/network/api_client.dart';
import 'package:tarasense_mobile/features/auth/state/auth_providers.dart';
import 'package:tarasense_mobile/features/fic/domain/fic_models.dart';

class FicApi {
  FicApi(this._client);

  final ApiClient _client;

  Future<FicDashboardData> fetchDashboard(
    String accessToken, {
    String? query,
  }) async {
    final response = await _client.getData(
      '/fic/dashboard',
      bearerToken: accessToken,
      queryParameters: <String, dynamic>{
        if ((query ?? '').trim().isNotEmpty) 'q': query!.trim(),
      },
    );
    return FicDashboardData.fromJson(response);
  }

  Future<List<FicStudy>> fetchStudies(
    String accessToken, {
    String? query,
    int limit = 50,
  }) async {
    final response = await _client.getData(
      '/fic/studies',
      bearerToken: accessToken,
      queryParameters: <String, dynamic>{
        if ((query ?? '').trim().isNotEmpty) 'q': query!.trim(),
        'limit': limit,
      },
    );
    return parseFicStudies(response);
  }

  Future<List<FicCalendarItem>> fetchCalendar(
    String accessToken, {
    String? query,
    int limit = 100,
  }) async {
    final response = await _client.getData(
      '/fic/calendar',
      bearerToken: accessToken,
      queryParameters: <String, dynamic>{
        if ((query ?? '').trim().isNotEmpty) 'q': query!.trim(),
        'limit': limit,
      },
    );
    return parseFicCalendarItems(response);
  }

  Future<List<FicAvailabilityDay>> fetchAvailability(
    String accessToken, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await _client.getData(
      '/fic/availability',
      bearerToken: accessToken,
      queryParameters: <String, dynamic>{
        'startDate': _formatDateOnly(startDate),
        'endDate': _formatDateOnly(endDate),
      },
    );
    return parseFicAvailability(response);
  }

  Future<Map<String, dynamic>> createAvailability(
    String accessToken, {
    required Map<String, dynamic> payload,
  }) {
    return _client.postJson(
      '/fic/availability',
      bearerToken: accessToken,
      data: payload,
    );
  }

  Future<Map<String, dynamic>> updateAvailability(
    String accessToken, {
    required DateTime date,
    required Map<String, dynamic> payload,
  }) {
    return _client.patchJson(
      '/fic/availability/${_formatDateOnly(date)}',
      bearerToken: accessToken,
      data: payload,
    );
  }
}

String _formatDateOnly(DateTime value) {
  final String month = value.month.toString().padLeft(2, '0');
  final String day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}

final ficApiProvider = Provider<FicApi>((ref) {
  return FicApi(ref.watch(apiClientProvider));
});
