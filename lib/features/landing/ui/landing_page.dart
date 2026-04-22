import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tarasense_mobile/core/theme/tara_theme.dart';
import 'package:tarasense_mobile/core/widgets/tara_brand_lockup.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  static const List<_RoleCardData> _roles = <_RoleCardData>[
    _RoleCardData(
      icon: Icons.storefront_outlined,
      title: 'MSME',
      description:
          'Create projects, define product categories, and prepare sensory work.',
      tint: Color(0xFFFFE7D6),
    ),
    _RoleCardData(
      icon: Icons.science_outlined,
      title: 'FIC',
      description:
          'Coordinate technical support and keep sensory programs moving.',
      tint: Color(0xFFE0F2FE),
    ),
    _RoleCardData(
      icon: Icons.groups_2_outlined,
      title: 'Participant',
      description:
          'Access survey activities and respond from a simpler mobile flow.',
      tint: Color(0xFFEDE9FE),
    ),
  ];

  static const List<_FeatureData> _features = <_FeatureData>[
    _FeatureData(
      title: 'Aligned with the web app',
      description:
          'The mobile experience now reflects the current TARAsense account and dashboard structure.',
      icon: Icons.devices_outlined,
    ),
    _FeatureData(
      title: 'Project-first workflow',
      description:
          'Start with project details, then continue with samples, attributes, and support requests.',
      icon: Icons.inventory_2_outlined,
    ),
    _FeatureData(
      title: 'Touch-first design',
      description:
          'Bigger surfaces, clearer hierarchy, and cleaner forms for faster mobile use.',
      icon: Icons.touch_app_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFFF9FBFD), TaraTheme.background],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
            children: <Widget>[
              Row(
                children: <Widget>[
                  const TaraBrandLockup(markSize: 24, textSize: 24),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Log in'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[Color(0xFFF97316), Color(0xFFFFA24D)],
                  ),
                  borderRadius: BorderRadius.circular(34),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x24F97316),
                      blurRadius: 34,
                      offset: Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Mobile Workspace',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Create projects, configure tests, and coordinate sensory support.',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'The refreshed mobile UI follows the latest TARAsense web content with a cleaner, more focused layout.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => context.go('/register'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: TaraTheme.primaryDark,
                        ),
                        child: const Text('Create account'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => context.go('/login'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Color(0x55FFFFFF)),
                        ),
                        child: const Text('Log in'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Built for every workspace role',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ..._roles.map(
                (_RoleCardData role) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RoleCard(role: role),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Why this redesign works better',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ..._features.map(
                (_FeatureData feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _FeatureCard(feature: feature),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCardData {
  const _RoleCardData({
    required this.icon,
    required this.title,
    required this.description,
    required this.tint,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color tint;
}

class _FeatureData {
  const _FeatureData({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.role});

  final _RoleCardData role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: role.tint,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(role.icon, color: TaraTheme.textPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  role.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  role.description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature});

  final _FeatureData feature;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: TaraTheme.primaryTint,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(feature.icon, color: TaraTheme.primaryDark),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  feature.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  feature.description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
