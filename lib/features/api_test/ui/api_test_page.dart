import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:tarasense_mobile/features/api_test/state/api_test_providers.dart';

class ApiTestPage extends ConsumerStatefulWidget {
  const ApiTestPage({super.key});

  @override
  ConsumerState<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends ConsumerState<ApiTestPage> {
  final Map<String, String> _results = {};
  final Map<String, bool> _loading = {};

  Future<void> _testEndpoint(
    String name,
    Future<Map<String, dynamic>> Function() call,
  ) async {
    if (_loading[name] == true) return;
    setState(() {
      _loading[name] = true;
      _results[name] = 'Testing...';
    });

    try {
      final result = await call();
      if (!mounted) return;
      setState(() {
        _results[name] = 'Success: ${result.toString()}';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _results[name] = 'Error: ${_formatError(error)}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading[name] = false;
        });
      }
    }
  }

  String _formatError(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final statusText = statusCode == null ? '' : 'HTTP $statusCode';
      final message = error.message?.trim() ?? '';
      final details = <String>[
        if (statusText.isNotEmpty) statusText,
        if (message.isNotEmpty) message,
      ];
      if (details.isEmpty) {
        return 'Request failed';
      }
      return details.join(' | ');
    }
    return error.toString();
  }

  @override
  Widget build(BuildContext context) {
    final api = ref.watch(apiTestApiProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('API Test')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Tap buttons to test API endpoints',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),

          // Auth endpoints
          _buildSection('Authentication Endpoints'),
          _buildTestButton(
            'GET /auth/me',
            'auth_me',
            () => _testEndpoint('auth_me', api.testAuthMe),
          ),
          _buildTestButton(
            'GET /auth/introspect',
            'auth_introspect',
            () => _testEndpoint('auth_introspect', api.testAuthIntrospect),
          ),

          // Study endpoints
          _buildSection('Study Management'),
          _buildTestButton(
            'POST /studies/new',
            'studies_new',
            () => _testEndpoint('studies_new', api.testStudiesNew),
          ),
          _buildTestButton(
            'GET /studies/{id}/analysis',
            'studies_analysis',
            () => _testEndpoint(
              'studies_analysis',
              () => api.testStudiesAnalysis('test-id'),
            ),
          ),
          _buildTestButton(
            'GET /studies/{id}/master-list',
            'studies_master_list',
            () => _testEndpoint(
              'studies_master_list',
              () => api.testStudiesMasterList('test-id'),
            ),
          ),
          _buildTestButton(
            'GET /studies/{id}/responses',
            'studies_responses',
            () => _testEndpoint(
              'studies_responses',
              () => api.testStudiesResponses('test-id'),
            ),
          ),

          // FIC endpoints
          _buildSection('FIC Management'),
          _buildTestButton(
            'GET /fic-availability/available-fics',
            'fic_available',
            () => _testEndpoint('fic_available', api.testFICAvailable),
          ),
          _buildTestButton(
            'GET /fic-availability/calendar/{id}',
            'fic_calendar',
            () => _testEndpoint(
              'fic_calendar',
              () => api.testFICCalendar('test-fic-id'),
            ),
          ),

          // Participant endpoints
          _buildSection('Participant Management'),
          _buildTestButton(
            'POST /participants/{id}/confirm',
            'participants_confirm',
            () => _testEndpoint(
              'participants_confirm',
              () => api.testParticipantsConfirm('test-participant-id'),
            ),
          ),

          // Profile and Jobs
          _buildSection('User Management'),
          _buildTestButton(
            'GET /profile',
            'profile',
            () => _testEndpoint('profile', api.testProfile),
          ),
          _buildTestButton(
            'GET /jobs/',
            'jobs',
            () => _testEndpoint('jobs', api.testJobs),
          ),

          // Health
          _buildSection('System'),
          _buildTestButton(
            'GET /health',
            'health',
            () => _testEndpoint('health', api.testHealth),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTestButton(
    String label,
    String resultKey,
    VoidCallback onPressed,
  ) {
    final isLoading = _loading[resultKey] == true;
    final result = _results[resultKey];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : onPressed,
                  child: isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Test'),
                ),
              ],
            ),
            if (result != null) ...[
              const SizedBox(height: 8),
              Text(
                result,
                style: TextStyle(
                  fontSize: 12,
                  color: result.startsWith('Error') ? Colors.red : Colors.green,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
