import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarasense_mobile/core/theme/tara_theme.dart';
import 'package:tarasense_mobile/features/auth/state/auth_providers.dart';
import 'package:tarasense_mobile/features/auth/ui/auth_loading_dialog.dart';

enum _FicView { dashboard, queue, calendar, profile }

class FicWorkspacePage extends ConsumerStatefulWidget {
  const FicWorkspacePage({super.key});

  @override
  ConsumerState<FicWorkspacePage> createState() => _FicWorkspacePageState();
}

class _FicWorkspacePageState extends ConsumerState<FicWorkspacePage> {
  _FicView _currentView = _FicView.dashboard;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final session = authState.session;
    final String displayName = session?.user.name.trim().isNotEmpty == true
        ? session!.user.name.trim()
        : 'FIC Station 3';
    final String location =
        session?.user.organization?.trim().isNotEmpty == true
        ? session!.user.organization!.trim()
        : 'Davao del Sur';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F1EC),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Container(
              color: const Color(0xFFF3F1EC),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                      children: <Widget>[
                        _FicHeader(
                          title: displayName,
                          subtitle: location,
                        ),
                        const SizedBox(height: 14),
                        _buildCurrentView(
                          displayName: displayName,
                          location: location,
                          authBusy: authState.isBusy,
                        ),
                      ],
                    ),
                  ),
                  _FicBottomNav(
                    currentView: _currentView,
                    onChanged: (view) => setState(() => _currentView = view),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentView({
    required String displayName,
    required String location,
    required bool authBusy,
  }) {
    switch (_currentView) {
      case _FicView.dashboard:
        return const _FicDashboardTab();
      case _FicView.queue:
        return const _FicQueueTab();
      case _FicView.calendar:
        return const _FicCalendarTab();
      case _FicView.profile:
        return _FicProfileTab(
          name: displayName,
          location: location,
          email: ref.watch(authControllerProvider).session?.user.email ?? '',
          role: ref.watch(authControllerProvider).session?.user.role ?? 'FIC',
          authBusy: authBusy,
          onLogout: () => showLogoutLoadingAndRun(
            context,
            () => ref.read(authControllerProvider.notifier).logout(),
          ),
        );
    }
  }
}

class _FicHeader extends StatelessWidget {
  const _FicHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 24,
                      height: 1.05,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: TaraTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              height: 34,
              width: 34,
              decoration: BoxDecoration(
                color: TaraTheme.primaryTint,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Center(
                child: Text(
                  _ficInitials(title),
                  style: const TextStyle(
                    color: TaraTheme.primaryDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(height: 1, color: TaraTheme.border),
      ],
    );
  }
}

class _FicDashboardTab extends StatelessWidget {
  const _FicDashboardTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const <Widget>[
        _FicActiveSessionsCard(),
        SizedBox(height: 12),
        _FicCalendarCard(),
        SizedBox(height: 12),
        _FicStudyQueueCard(),
      ],
    );
  }
}

class _FicActiveSessionsCard extends StatelessWidget {
  const _FicActiveSessionsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Today's sessions",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '3 active',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontSize: 34,
              height: 1,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Next: Dried Mango - 2:00 PM',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  backgroundColor: TaraTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('View queue'),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  backgroundColor: const Color(0xFF2A2A2A),
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF2A2A2A)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Check-in'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FicCalendarCard extends StatelessWidget {
  const _FicCalendarCard();

  static const List<String> _days = <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const List<int> _dates = <int>[1, 2, 3, 4, 5, 6, 7];

  @override
  Widget build(BuildContext context) {
    return _FicPanel(
      title: 'Availability Calendar',
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _days
                .map(
                  (String day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          Row(
            children: List<Widget>.generate(_dates.length, (int index) {
              final int date = _dates[index];
              final _CalendarKind kind;
              if (date == 2 || date == 3) {
                kind = _CalendarKind.booked;
              } else if (date == 4 || date == 5 || date == 6) {
                kind = _CalendarKind.available;
              } else if (date == 1) {
                kind = _CalendarKind.today;
              } else {
                kind = _CalendarKind.idle;
              }
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _CalendarDatePill(date: date, kind: kind),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: const <Widget>[
              _CalendarLegend(
                label: 'Today',
                color: TaraTheme.primary,
              ),
              _CalendarLegend(
                label: 'Available',
                color: Color(0xFFB7D8A8),
              ),
              _CalendarLegend(
                label: 'Booked',
                color: Color(0xFFF5BBB0),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FicStudyQueueCard extends StatelessWidget {
  const _FicStudyQueueCard();

  @override
  Widget build(BuildContext context) {
    return _FicPanel(
      title: 'Study Queue',
      child: Column(
        children: const <Widget>[
          _StudyQueueTile(
            title: 'Dried Mango Sensory',
            detail: '42 participants - May 9',
            status: 'In progress',
            statusColor: TaraTheme.mintText,
            statusTint: Color(0xFFEAF8D9),
            icon: Icons.description_outlined,
          ),
          SizedBox(height: 8),
          _StudyQueueTile(
            title: 'Cacao Bar Evaluation',
            detail: '0/30 - Starts May 11',
            status: 'Upcoming',
            statusColor: TaraTheme.textPrimary,
            statusTint: Color(0xFFF1F5F9),
            icon: Icons.fact_check_outlined,
          ),
        ],
      ),
    );
  }
}

class _FicQueueTab extends StatelessWidget {
  const _FicQueueTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const <Widget>[
        _FicPanel(
          title: 'Queue',
          child: Column(
            children: <Widget>[
              _StudyQueueTile(
                title: 'Dried Mango Sensory',
                detail: 'Line moving - 3 testers waiting',
                status: 'Live queue',
                statusColor: TaraTheme.primaryDark,
                statusTint: TaraTheme.primaryTint,
                icon: Icons.groups_2_outlined,
              ),
              SizedBox(height: 8),
              _StudyQueueTile(
                title: 'Tomato Jam Screening',
                detail: 'Panel prep at 1:30 PM',
                status: 'Prep',
                statusColor: TaraTheme.textPrimary,
                statusTint: Color(0xFFF1F5F9),
                icon: Icons.schedule_rounded,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FicCalendarTab extends StatelessWidget {
  const _FicCalendarTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const <Widget>[
        _FicCalendarCard(),
        SizedBox(height: 12),
        _FicPanel(
          title: 'Upcoming Slots',
          child: Column(
            children: <Widget>[
              _CalendarScheduleRow(
                title: 'Dried Mango Sensory',
                detail: 'May 9 - 2:00 PM',
              ),
              SizedBox(height: 8),
              _CalendarScheduleRow(
                title: 'Cacao Bar Evaluation',
                detail: 'May 11 - 10:00 AM',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FicProfileTab extends StatelessWidget {
  const _FicProfileTab({
    required this.name,
    required this.location,
    required this.email,
    required this.role,
    required this.authBusy,
    required this.onLogout,
  });

  final String name;
  final String location;
  final String email;
  final String role;
  final bool authBusy;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return _FicPanel(
      title: 'Profile',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _FicProfileField(label: 'Name', value: name),
          const SizedBox(height: 10),
          _FicProfileField(label: 'Location', value: location),
          const SizedBox(height: 10),
          _FicProfileField(label: 'Email', value: email),
          const SizedBox(height: 10),
          _FicProfileField(label: 'Role', value: role),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: authBusy ? null : onLogout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: TaraTheme.roseText,
                backgroundColor: TaraTheme.surface,
                side: const BorderSide(color: Color(0xFFFECDD3)),
                minimumSize: const Size(0, 42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FicPanel extends StatelessWidget {
  const _FicPanel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD8D2C6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: TaraTheme.textSecondary,
              height: 1,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _StudyQueueTile extends StatelessWidget {
  const _StudyQueueTile({
    required this.title,
    required this.detail,
    required this.status,
    required this.statusColor,
    required this.statusTint,
    required this.icon,
  });

  final String title;
  final String detail;
  final String status;
  final Color statusColor;
  final Color statusTint;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F7F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5DED0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              color: TaraTheme.primaryTint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: TaraTheme.primaryDark, size: 15),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: statusTint,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarDatePill extends StatelessWidget {
  const _CalendarDatePill({required this.date, required this.kind});

  final int date;
  final _CalendarKind kind;

  @override
  Widget build(BuildContext context) {
    Color background;
    Color foreground;
    switch (kind) {
      case _CalendarKind.today:
        background = TaraTheme.primary;
        foreground = Colors.white;
      case _CalendarKind.available:
        background = const Color(0xFFDCEAD0);
        foreground = TaraTheme.mintText;
      case _CalendarKind.booked:
        background = const Color(0xFFF6D5CC);
        foreground = TaraTheme.roseText;
      case _CalendarKind.idle:
        background = Colors.transparent;
        foreground = TaraTheme.textSecondary;
    }

    return Container(
      height: 24,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Center(
        child: Text(
          '$date',
          style: TextStyle(
            color: foreground,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 8,
          width: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 9,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _CalendarScheduleRow extends StatelessWidget {
  const _CalendarScheduleRow({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F7F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5DED0)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.calendar_today_outlined,
            size: 15,
            color: TaraTheme.primaryDark,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FicProfileField extends StatelessWidget {
  const _FicProfileField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value.isEmpty ? '-' : value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF9F7F2),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5DED0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5DED0)),
        ),
      ),
    );
  }
}

class _FicBottomNav extends StatelessWidget {
  const _FicBottomNav({
    required this.currentView,
    required this.onChanged,
  });

  final _FicView currentView;
  final ValueChanged<_FicView> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: TaraTheme.surface,
        border: Border(top: BorderSide(color: Color(0xFFE5DED0))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: <Widget>[
              _FicNavItem(
                icon: Icons.widgets_outlined,
                label: 'Dashboard',
                selected: currentView == _FicView.dashboard,
                onTap: () => onChanged(_FicView.dashboard),
              ),
              _FicNavItem(
                icon: Icons.format_list_bulleted_rounded,
                label: 'Queue',
                selected: currentView == _FicView.queue,
                onTap: () => onChanged(_FicView.queue),
              ),
              _FicNavItem(
                icon: Icons.calendar_today_outlined,
                label: 'Calendar',
                selected: currentView == _FicView.calendar,
                onTap: () => onChanged(_FicView.calendar),
              ),
              _FicNavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                selected: currentView == _FicView.profile,
                onTap: () => onChanged(_FicView.profile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FicNavItem extends StatelessWidget {
  const _FicNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = selected ? TaraTheme.primary : TaraTheme.textSecondary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, color: color, size: 18),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 8,
                  height: 1,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _CalendarKind { today, available, booked, idle }

String _ficInitials(String value) {
  final List<String> parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((String part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) {
    return 'FC';
  }
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
      .toUpperCase();
}
