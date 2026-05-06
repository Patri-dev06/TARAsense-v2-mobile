import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarasense_mobile/core/theme/tara_theme.dart';
import 'package:tarasense_mobile/core/widgets/tara_brand_lockup.dart';
import 'package:tarasense_mobile/features/auth/state/auth_providers.dart';
import 'package:tarasense_mobile/features/auth/ui/auth_loading_dialog.dart';

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
              _SettingsPanel(
                name: session?.user.name ?? 'FIC User',
                email: session?.user.email ?? '',
                role: session?.user.role ?? 'FIC',
                organization: session?.user.organization,
                authBusy: authState.isBusy,
                onLogout: () => showLogoutLoadingAndRun(
                  context,
                  () => ref.read(authControllerProvider.notifier).logout(),
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

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({
    required this.name,
    required this.email,
    required this.role,
    required this.organization,
    required this.authBusy,
    required this.onLogout,
  });

  final String name;
  final String email;
  final String role;
  final String? organization;
  final bool authBusy;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        border: Border.all(color: TaraTheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Profile', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _SettingsFormGrid(
            fields: <_SettingsField>[
              _SettingsField(label: 'Name', value: name),
              _SettingsField(label: 'Email', value: email),
              _SettingsField(label: 'Role', value: role),
              if (organization != null && organization!.trim().isNotEmpty)
                _SettingsField(
                  label: 'Organization',
                  value: organization!.trim(),
                ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: authBusy ? null : onLogout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: TaraTheme.roseText,
                side: const BorderSide(color: Color(0xFFFECDD3)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsFormGrid extends StatelessWidget {
  const _SettingsFormGrid({required this.fields});

  final List<_SettingsField> fields;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool twoColumns = constraints.maxWidth >= 560;
        final double fieldWidth = twoColumns
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: fields
              .map(
                (_SettingsField field) => SizedBox(
                  width: fieldWidth,
                  child: TextFormField(
                    initialValue: field.value.isEmpty ? '-' : field.value,
                    readOnly: true,
                    decoration: InputDecoration(labelText: field.label),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _SettingsField {
  const _SettingsField({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}
