import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarasense_mobile/features/api_test/data/api_test_api.dart';
import 'package:tarasense_mobile/features/auth/state/auth_providers.dart';

final apiTestApiProvider = Provider<ApiTestApi>((ref) {
  return ApiTestApi(ref.watch(apiClientProvider));
});
