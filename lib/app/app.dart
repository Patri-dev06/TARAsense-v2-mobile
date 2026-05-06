import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarasense_mobile/app/router.dart';
import 'package:tarasense_mobile/core/theme/tara_theme.dart';
import 'package:tarasense_mobile/features/auth/ui/auth_loading_dialog.dart';

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
      builder: (BuildContext context, Widget? child) {
        return ValueListenableBuilder<bool>(
          valueListenable: authOperationOverlayVisible,
          builder: (context, showAuthOperationOverlay, _) {
            return Stack(
              children: <Widget>[
                child ?? const SizedBox.shrink(),
                if (showAuthOperationOverlay)
                  const AuthOperationLoadingOverlay(
                    message: 'Logging out...',
                    subtitle: 'Securing your session...',
                    icon: Icons.logout_rounded,
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
