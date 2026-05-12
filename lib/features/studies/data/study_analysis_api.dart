import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarasense_mobile/core/network/api_client.dart';
import 'package:tarasense_mobile/features/auth/state/auth_providers.dart';
import 'package:tarasense_mobile/features/studies/domain/study_analysis.dart';

class StudyAnalysisApi {
  StudyAnalysisApi(this._client);

  final ApiClient _client;

  Future<StudyAnalysis> fetchAnalysis(
    String accessToken, {
    required String studyId,
    bool refresh = false,
  }) async {
    final response = await _client.getJson(
      '/studies/${Uri.encodeComponent(studyId)}/analysis',
      bearerToken: accessToken,
      queryParameters: refresh ? <String, dynamic>{'refresh': '1'} : null,
    );
    return StudyAnalysis.fromJson(response);
  }
}

final studyAnalysisApiProvider = Provider<StudyAnalysisApi>((ref) {
  return StudyAnalysisApi(ref.watch(apiClientProvider));
});
