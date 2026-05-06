import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarasense_mobile/core/theme/tara_theme.dart';
import 'package:tarasense_mobile/core/widgets/tara_brand_lockup.dart';
import 'package:tarasense_mobile/features/auth/state/auth_providers.dart';

class FicWorkspacePage extends ConsumerWidget {
  const FicWorkspacePage({super.key});

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
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'FIC Workspace',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: TaraTheme.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Welcome${session == null ? '' : ', ${session.user.name}'}. Manage facility bookings, study coordination, and sensory test schedules here.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: const <Widget>[
                    _WorkspaceTile(
                      icon: Icons.event_available_outlined,
                      title: 'Facility Requests',
                      subtitle:
                          'Review MSME booking requests and confirm available FIC schedules.',
                    ),
                    _WorkspaceTile(
                      icon: Icons.assignment_outlined,
                      title: 'Study Coordination',
                      subtitle:
                          'Track samples, test setup details, panel capacity, and active study status.',
                    ),
                    _WorkspaceTile(
                      icon: Icons.groups_outlined,
                      title: 'Tester Sessions',
                      subtitle:
                          'Prepare participant sessions and monitor check-ins during sensory tests.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _WorkspaceTile(
                icon: Icons.settings_outlined,
                title: 'Settings',
                subtitle: 'Manage account actions for this FIC workspace.',
                trailing: OutlinedButton.icon(
                  onPressed: authState.isBusy
                      ? null
                      : () => ref
                            .read(authControllerProvider.notifier)
                            .logout(),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Log out'),
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
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

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
          if (trailing != null) ...<Widget>[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}
