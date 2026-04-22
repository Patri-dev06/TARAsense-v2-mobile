import 'package:flutter/material.dart';
import 'package:tarasense_mobile/core/theme/tara_theme.dart';
import 'package:tarasense_mobile/core/widgets/tara_brand_lockup.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFFF9FBFD), TaraTheme.backgroundAlt],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const <Widget>[
            TaraBrandLockup(markSize: 34, textSize: 32, center: true),
            SizedBox(height: 20),
            CircularProgressIndicator(color: TaraTheme.primary),
            SizedBox(height: 14),
            Text(
              'Loading your workspace...',
              style: TextStyle(
                color: TaraTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
