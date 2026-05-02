import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarasense_mobile/features/auth/state/auth_providers.dart';

class SystemApi {
  SystemApi(this._read);

  final Ref _read;

  Future<String> checkHealth() async {
    final accessToken = _read
        .read(authControllerProvider)
        .session
        ?.tokens
        .accessToken;
    final response = await _read
        .read(apiClientProvider)
        .getJson('/auth/me', bearerToken: accessToken);
    return response.isEmpty ? 'unknown' : 'ok';
  }
}

final systemApiProvider = Provider<SystemApi>((ref) {
  return SystemApi(ref);
});
