import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OnboardingPrefs {
  static const String _key = 'has_seen_landing';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static bool _hasSeenLanding = false;

  /// Load persisted value once at startup, before [runApp].
  static Future<void> load() async {
    final String? value = await _storage.read(key: _key);
    _hasSeenLanding = value == 'true';
  }

  /// Whether the user has already seen the landing page.
  static bool get hasSeenLanding => _hasSeenLanding;

  /// Call when the user leaves the landing page (Sign In / Get Started).
  static Future<void> markLandingSeen() async {
    if (_hasSeenLanding) return;
    _hasSeenLanding = true;
    await _storage.write(key: _key, value: 'true');
  }
}
