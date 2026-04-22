import 'package:tarasense_mobile/core/network/api_client.dart';

class ApiTestApi {
  ApiTestApi(this._client);

  final ApiClient _client;

  // Auth endpoints
  Future<Map<String, dynamic>> testAuthMe() async {
    return await _client.getJson('/auth/me');
  }

  Future<Map<String, dynamic>> testAuthIntrospect() async {
    return await _client.getJson('/auth/introspect');
  }

  // Study endpoints
  Future<Map<String, dynamic>> testStudiesNew() async {
    return await _client.postJson(
      '/studies/new',
      data: {
        'title': 'Test Study',
        'description': 'API Test Study',
        'type': 'consumer_test',
      },
    );
  }

  Future<Map<String, dynamic>> testStudiesAnalysis(String studyId) async {
    return await _client.getJson('/studies/$studyId/analysis');
  }

  Future<Map<String, dynamic>> testStudiesMasterList(String studyId) async {
    return await _client.getJson('/studies/$studyId/master-list');
  }

  Future<Map<String, dynamic>> testStudiesResponses(String studyId) async {
    return await _client.getJson('/studies/$studyId/responses');
  }

  // FIC endpoints
  Future<Map<String, dynamic>> testFICAvailable() async {
    return await _client.getJson('/fic-availability/available-fics');
  }

  Future<Map<String, dynamic>> testFICCalendar(String ficUserId) async {
    return await _client.getJson('/fic-availability/calendar/$ficUserId');
  }

  // Participant endpoints
  Future<Map<String, dynamic>> testParticipantsConfirm(
    String participantId,
  ) async {
    return await _client.postJson(
      '/participants/$participantId/confirm',
      data: {},
    );
  }

  // Profile endpoint
  Future<Map<String, dynamic>> testProfile() async {
    return await _client.getJson('/profile');
  }

  // Jobs endpoint
  Future<Map<String, dynamic>> testJobs() async {
    return await _client.getJson('/jobs/');
  }

  // Health check
  Future<Map<String, dynamic>> testHealth() async {
    return await _client.getJson('/health');
  }
}
