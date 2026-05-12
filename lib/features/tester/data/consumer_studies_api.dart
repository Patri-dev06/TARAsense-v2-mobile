import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarasense_mobile/core/network/api_client.dart';
import 'package:tarasense_mobile/features/auth/state/auth_providers.dart';
import 'package:tarasense_mobile/features/tester/domain/consumer_study.dart';

class ConsumerStudiesApi {
  ConsumerStudiesApi(this._client);

  final ApiClient _client;

  Future<List<ConsumerStudy>> fetchStudies(String accessToken) async {
    final response = await _client.getData(
      '/consumer/studies',
      bearerToken: accessToken,
    );
    return parseConsumerStudies(response);
  }

  Future<ConsumerStudy> fetchStudyTest(
    String accessToken, {
    required String studyId,
    required String participantId,
  }) async {
    final response = await _client.getData(
      '/consumer/studies/${Uri.encodeComponent(studyId)}/participants/${Uri.encodeComponent(participantId)}/test',
      bearerToken: accessToken,
    );
    return parseConsumerStudy(response);
  }

  Future<ConsumerStudyResponseSubmission> submitStudyResponse(
    String accessToken, {
    required String studyId,
    required String participantId,
    required Map<String, dynamic> payload,
  }) async {
    final response = await _client.postJson(
      '/consumer/studies/${Uri.encodeComponent(studyId)}/participants/${Uri.encodeComponent(participantId)}/responses',
      bearerToken: accessToken,
      data: payload,
    );
    return ConsumerStudyResponseSubmission.fromJson(response);
  }

  Future<List<ConsumerStudy>> fetchCompletedStudies(
    String accessToken, {
    String? query,
    int limit = 20,
  }) async {
    final response = await _client.getData(
      '/consumer/studies/completed',
      bearerToken: accessToken,
      queryParameters: <String, dynamic>{
        if ((query ?? '').trim().isNotEmpty) 'q': query!.trim(),
        'limit': limit,
      },
      validateStatus: (int? status) =>
          status != null && (status < 400 || status == 404),
    );
    if (_isMobileRouteNotFound(response)) {
      throw const FormatException(
        'Completed surveys are not available yet. The mobile completed-surveys API route is not deployed on the server.',
      );
    }
    return parseConsumerStudies(response);
  }
}

bool _isMobileRouteNotFound(dynamic response) {
  if (response is! Map) {
    return false;
  }
  final dynamic error = response['error'];
  if (error is! Map) {
    return false;
  }
  return error['code']?.toString() == 'NOT_FOUND';
}

final consumerStudiesApiProvider = Provider<ConsumerStudiesApi>((ref) {
  return ConsumerStudiesApi(ref.watch(apiClientProvider));
});
