import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tarasense_mobile/core/theme/tara_theme.dart';
import 'package:tarasense_mobile/core/widgets/dost_logo_mark.dart';

part 'landing_nav.dart';
part 'landing_sections.dart';
part 'landing_visuals.dart';
part 'landing_shared.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBF8),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('TARAsense support chat will be available soon.'),
            ),
          );
        },
        backgroundColor: TaraTheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.chat_bubble_outline_rounded),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(child: _LandingNav(onSignIn: () => context.go('/login'))),
            SliverToBoxAdapter(
              child: _PageShell(
                child: Column(
                  children: <Widget>[
                    _HeroSection(onGetStarted: () => context.go('/register')),
                    const SizedBox(height: 70),
                    const _FicStrip(),
                    const SizedBox(height: 78),
                    const _MediaFeatureSection(
                      eyebrow: 'SIGNAL CLARITY',
                      title: 'Every Signal.\nOne Clear View.',
                      body:
                          'Bring concept testing, campaign performance, and brand learning into one elegant operating layer so every team can see the same truth and act faster.',
                      bullets: <String>[
                        'Unified scorecards',
                        'Audience breakouts',
                        'AI-written decision summaries',
                      ],
                      buttonLabel: 'Explore connected workflows',
                      visual: _InsightDashboardVisual(),
                    ),
                    const SizedBox(height: 84),
                    const _MediaFeatureSection(
                      eyebrow: 'CREATIVE INTELLIGENCE',
                      title: 'Emotion Data.\nCreative Edge.',
                      body:
                          'Blend qualitative reactions, emotion signals, and performance forecasting into premium creative scorecards your brand team can use immediately.',
                      bullets: <String>[
                        'Moment-by-moment feedback',
                        'Conversion drivers',
                        'Market-by-market comparisons',
                      ],
                      buttonLabel: 'Review creative analytics',
                      visual: _SensoryBoothVisual(),
                      reverse: true,
                    ),
                    const SizedBox(height: 90),
                    const _MemorySection(),
                    const SizedBox(height: 90),
                    const _PlatformSection(),
                    const SizedBox(height: 78),
                    const _ProofSection(),
                    const SizedBox(height: 72),
                    _CtaPanel(onGetStarted: () => context.go('/register')),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

