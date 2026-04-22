import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarasense_mobile/app/router.dart';
import 'package:tarasense_mobile/core/theme/tara_theme.dart';

class TaraSenseApp extends ConsumerWidget {
  const TaraSenseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'TARAsense Mobile',
      debugShowCheckedModeBanner: false,
      theme: TaraTheme.light(),
      routerConfig: router,
    );
  }
}
