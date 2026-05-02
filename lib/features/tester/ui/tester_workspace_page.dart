import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarasense_mobile/core/theme/tara_theme.dart';
import 'package:tarasense_mobile/core/widgets/tara_brand_lockup.dart';
import 'package:tarasense_mobile/features/auth/state/auth_providers.dart';

class TesterWorkspacePage extends ConsumerWidget {
  const TesterWorkspacePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final session = authState.session;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Expanded(child: TaraBrandLockup()),
                  IconButton(
                    tooltip: 'Log out',
                    onPressed: authState.isBusy
                        ? null
                        : () => ref
                              .read(authControllerProvider.notifier)
                              .logout(),
                    icon: const Icon(Icons.logout_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'Tester Workspace',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: TaraTheme.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Welcome${session == null ? '' : ', ${session.user.name}'}. Find assigned tests, confirm session details, and submit sensory responses here.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: const <Widget>[
                    _WorkspaceTile(
                      icon: Icons.playlist_add_check_outlined,
                      title: 'Available Tests',
                      subtitle:
                          'View studies you can join based on your tester profile and eligibility.',
                    ),
                    _WorkspaceTile(
                      icon: Icons.calendar_month_outlined,
                      title: 'My Sessions',
                      subtitle:
                          'Check confirmed schedules, locations, reminders, and sample instructions.',
                    ),
                    _WorkspaceTile(
                      icon: Icons.rate_review_outlined,
                      title: 'Response Forms',
                      subtitle:
                          'Complete sensory questionnaires and track submitted evaluations.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkspaceTile extends StatelessWidget {
  const _WorkspaceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        border: Border.all(color: TaraTheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: TaraTheme.primaryDark),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
