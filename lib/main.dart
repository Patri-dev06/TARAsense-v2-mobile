import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarasense_mobile/app/app.dart';
import 'package:tarasense_mobile/core/notifications/notification_service.dart';
import 'package:tarasense_mobile/core/storage/onboarding_prefs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait(<Future<void>>[
    Firebase.initializeApp(),
    OnboardingPrefs.load(),
  ]);
  await NotificationService.instance.initialize();
  runApp(const ProviderScope(child: TaraSenseApp()));
}
