import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarasense_mobile/core/network/api_error_formatter.dart';
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
    return formatApiError(error, includeUri: true);
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
            'Tap buttons to test the read-only mobile API endpoints from the web system list. Login, register, refresh, logout, create study, and profile update are exercised by their actual app flows.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),

          _buildSection('Authentication Endpoints'),
          _buildTestButton(
            'GET /auth/me',
            'auth_me',
            () => _testEndpoint('auth_me', api.testAuthMe),
          ),

          _buildSection('MSME'),
          _buildTestButton(
            'GET /msme/dashboard',
            'msme_dashboard',
            () => _testEndpoint('msme_dashboard', api.testMsmeDashboard),
          ),
          _buildTestButton(
            'GET /msme/study-builder-options',
            'study_builder_options',
            () => _testEndpoint(
              'study_builder_options',
              api.testStudyBuilderOptions,
            ),
          ),

          _buildSection('Profile'),
          _buildTestButton(
            'GET /profile',
            'profile',
            () => _testEndpoint('profile', api.testProfile),
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
