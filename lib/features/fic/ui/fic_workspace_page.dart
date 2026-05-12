import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tarasense_mobile/core/network/api_error_formatter.dart';
import 'package:tarasense_mobile/core/theme/tara_theme.dart';
import 'package:tarasense_mobile/features/auth/state/auth_providers.dart';
import 'package:tarasense_mobile/features/auth/ui/auth_loading_dialog.dart';
import 'package:tarasense_mobile/features/fic/data/fic_api.dart';
import 'package:tarasense_mobile/features/fic/domain/fic_models.dart';

enum _FicView { dashboard, queue, calendar, profile }

final _ficDashboardProvider = FutureProvider.autoDispose<FicDashboardData>((
  ref,
) async {
  final session = ref.watch(
    authControllerProvider.select((state) => state.session),
  );
  final String accessToken = session?.tokens.accessToken ?? '';
  if (accessToken.trim().isEmpty) {
    return const FicDashboardData(
      activeSessions: 0,
      nextTitle: '',
      nextTime: '',
      studies: <FicStudy>[],
      calendar: <FicCalendarItem>[],
    );
  }
  return ref.watch(ficApiProvider).fetchDashboard(accessToken);
});

final _ficStudiesProvider = FutureProvider.autoDispose<List<FicStudy>>((
  ref,
) async {
  final session = ref.watch(
    authControllerProvider.select((state) => state.session),
  );
  final String accessToken = session?.tokens.accessToken ?? '';
  if (accessToken.trim().isEmpty) {
    return <FicStudy>[];
  }
  return ref.watch(ficApiProvider).fetchStudies(accessToken);
});

final _ficCalendarProvider = FutureProvider.autoDispose<List<FicCalendarItem>>((
  ref,
) async {
  final session = ref.watch(
    authControllerProvider.select((state) => state.session),
  );
  final String accessToken = session?.tokens.accessToken ?? '';
  if (accessToken.trim().isEmpty) {
    return <FicCalendarItem>[];
  }
  return ref.watch(ficApiProvider).fetchCalendar(accessToken);
});

final _ficAvailabilityProvider =
    FutureProvider.autoDispose<List<FicAvailabilityDay>>((ref) async {
      final session = ref.watch(
        authControllerProvider.select((state) => state.session),
      );
      final String accessToken = session?.tokens.accessToken ?? '';
      if (accessToken.trim().isEmpty) {
        return <FicAvailabilityDay>[];
      }
      final DateTime now = DateTime.now();
      final DateTime startDate = DateTime(now.year, now.month);
      final DateTime endDate = DateTime(now.year, now.month + 1, 0);
      return ref
          .watch(ficApiProvider)
          .fetchAvailability(
            accessToken,
            startDate: startDate,
            endDate: endDate,
          );
    });

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
    final AsyncValue<FicDashboardData> dashboardAsync = ref.watch(
      _ficDashboardProvider,
    );
    final AsyncValue<List<FicStudy>> studiesAsync = ref.watch(
      _ficStudiesProvider,
    );
    final AsyncValue<List<FicCalendarItem>> calendarAsync = ref.watch(
      _ficCalendarProvider,
    );
    final AsyncValue<List<FicAvailabilityDay>> availabilityAsync = ref.watch(
      _ficAvailabilityProvider,
    );

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
                        _FicHeader(title: displayName, subtitle: location),
                        const SizedBox(height: 14),
                        _buildCurrentView(
                          displayName: displayName,
                          location: location,
                          authBusy: authState.isBusy,
                          dashboardAsync: dashboardAsync,
                          studiesAsync: studiesAsync,
                          calendarAsync: calendarAsync,
                          availabilityAsync: availabilityAsync,
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
    required AsyncValue<FicDashboardData> dashboardAsync,
    required AsyncValue<List<FicStudy>> studiesAsync,
    required AsyncValue<List<FicCalendarItem>> calendarAsync,
    required AsyncValue<List<FicAvailabilityDay>> availabilityAsync,
  }) {
    switch (_currentView) {
      case _FicView.dashboard:
        return _FicDashboardTab(
          dashboardAsync: dashboardAsync,
          studiesAsync: studiesAsync,
          availabilityAsync: availabilityAsync,
          onViewQueue: () => setState(() => _currentView = _FicView.queue),
        );
      case _FicView.queue:
        return _FicQueueTab(studiesAsync: studiesAsync);
      case _FicView.calendar:
        return _FicCalendarTab(
          calendarAsync: calendarAsync,
          availabilityAsync: availabilityAsync,
        );
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
  const _FicDashboardTab({
    required this.dashboardAsync,
    required this.studiesAsync,
    required this.availabilityAsync,
    required this.onViewQueue,
  });

  final AsyncValue<FicDashboardData> dashboardAsync;
  final AsyncValue<List<FicStudy>> studiesAsync;
  final AsyncValue<List<FicAvailabilityDay>> availabilityAsync;
  final VoidCallback onViewQueue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _FicActiveSessionsCard(
          dashboardAsync: dashboardAsync,
          onViewQueue: onViewQueue,
        ),
        const SizedBox(height: 12),
        _FicCalendarCard(availabilityAsync: availabilityAsync),
        const SizedBox(height: 12),
        _FicStudyQueueCard(studiesAsync: studiesAsync),
      ],
    );
  }
}

class _FicActiveSessionsCard extends StatelessWidget {
  const _FicActiveSessionsCard({
    required this.dashboardAsync,
    required this.onViewQueue,
  });

  final AsyncValue<FicDashboardData> dashboardAsync;
  final VoidCallback onViewQueue;

  @override
  Widget build(BuildContext context) {
    final String countLabel = dashboardAsync.when(
      data: (FicDashboardData dashboard) =>
          '${dashboard.activeSessions} active',
      error: (_, _) => 'Unavailable',
      loading: () => 'Loading',
    );
    final String nextLabel = dashboardAsync.when(
      data: (FicDashboardData dashboard) {
        if (dashboard.nextTitle.trim().isEmpty) {
          return 'No upcoming session found';
        }
        final String time = dashboard.nextTime.trim();
        return time.isEmpty
            ? 'Next: ${dashboard.nextTitle}'
            : 'Next: ${dashboard.nextTitle} - $time';
      },
      error: (Object error, StackTrace stackTrace) =>
          formatApiError(error, includeUri: true),
      loading: () => 'Syncing dashboard...',
    );

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
            countLabel,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontSize: 30,
              height: 1,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            nextLabel,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
                onPressed: onViewQueue,
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
            ],
          ),
        ],
      ),
    );
  }
}

class _FicCalendarCard extends StatelessWidget {
  const _FicCalendarCard({required this.availabilityAsync});

  final AsyncValue<List<FicAvailabilityDay>> availabilityAsync;

  @override
  Widget build(BuildContext context) {
    return _FicPanel(
      title: 'Availability Calendar',
      child: availabilityAsync.when(
        data: (List<FicAvailabilityDay> availability) {
          final List<FicAvailabilityDay> days = _visibleAvailabilityDays(
            availability,
          );
          if (days.isEmpty) {
            return const _FicMessageRow(
              icon: Icons.calendar_month_outlined,
              message: 'No availability records for this month.',
            );
          }
          return Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: days
                    .map(
                      (FicAvailabilityDay day) => Expanded(
                        child: Center(
                          child: Text(
                            _weekdayLabel(day.date),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
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
                children: days
                    .map(
                      (FicAvailabilityDay day) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: _CalendarDatePill(
                            date: day.date.toLocal().day,
                            kind: _calendarKindFor(day),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 10),
              const Wrap(
                spacing: 10,
                runSpacing: 6,
                children: <Widget>[
                  _CalendarLegend(label: 'Today', color: TaraTheme.primary),
                  _CalendarLegend(label: 'Available', color: Color(0xFFB7D8A8)),
                  _CalendarLegend(label: 'Booked', color: Color(0xFFF5BBB0)),
                ],
              ),
            ],
          );
        },
        error: (Object error, StackTrace stackTrace) => _FicMessageRow(
          icon: Icons.wifi_off_rounded,
          message: formatApiError(error, includeUri: true),
        ),
        loading: () => const _FicMessageRow(
          icon: Icons.sync_rounded,
          message: 'Loading availability...',
        ),
      ),
    );
  }
}

class _FicStudyQueueCard extends StatelessWidget {
  const _FicStudyQueueCard({required this.studiesAsync});

  final AsyncValue<List<FicStudy>> studiesAsync;

  @override
  Widget build(BuildContext context) {
    return _FicPanel(
      title: 'Study Queue',
      child: _FicStudyList(studiesAsync: studiesAsync, limit: 3),
    );
  }
}

class _FicQueueTab extends StatelessWidget {
  const _FicQueueTab({required this.studiesAsync});

  final AsyncValue<List<FicStudy>> studiesAsync;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _FicPanel(
          title: 'Queue',
          child: _FicStudyList(studiesAsync: studiesAsync, limit: 12),
        ),
      ],
    );
  }
}

class _FicCalendarTab extends StatelessWidget {
  const _FicCalendarTab({
    required this.calendarAsync,
    required this.availabilityAsync,
  });

  final AsyncValue<List<FicCalendarItem>> calendarAsync;
  final AsyncValue<List<FicAvailabilityDay>> availabilityAsync;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _FicCalendarCard(availabilityAsync: availabilityAsync),
        const SizedBox(height: 12),
        _FicPanel(
          title: 'Upcoming Slots',
          child: calendarAsync.when(
            data: (List<FicCalendarItem> calendar) {
              if (calendar.isEmpty) {
                return const _FicMessageRow(
                  icon: Icons.event_busy_outlined,
                  message: 'No scheduled studies found.',
                );
              }
              return Column(
                children: calendar.take(8).map((FicCalendarItem item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _CalendarScheduleRow(
                      title: item.title,
                      detail: item.detailLabel,
                    ),
                  );
                }).toList(),
              );
            },
            error: (Object error, StackTrace stackTrace) => _FicMessageRow(
              icon: Icons.wifi_off_rounded,
              message: formatApiError(error, includeUri: true),
            ),
            loading: () => const _FicMessageRow(
              icon: Icons.sync_rounded,
              message: 'Loading calendar...',
            ),
          ),
        ),
      ],
    );
  }
}

class _FicStudyList extends StatelessWidget {
  const _FicStudyList({required this.studiesAsync, required this.limit});

  final AsyncValue<List<FicStudy>> studiesAsync;
  final int limit;

  @override
  Widget build(BuildContext context) {
    return studiesAsync.when(
      data: (List<FicStudy> studies) {
        final List<FicStudy> visibleStudies = studies.take(limit).toList();
        if (visibleStudies.isEmpty) {
          return const _FicMessageRow(
            icon: Icons.fact_check_outlined,
            message: 'No FIC studies found.',
          );
        }
        return Column(
          children: visibleStudies.map((FicStudy study) {
            final _FicStatusStyle statusStyle = _statusStyleFor(study.status);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _StudyQueueTile(
                study: study,
                title: study.title,
                detail: '${study.progressLabel} - ${study.scheduleLabel}',
                status: _humanizeStatus(study.status),
                statusColor: statusStyle.foreground,
                statusTint: statusStyle.background,
                icon: statusStyle.icon,
              ),
            );
          }).toList(),
        );
      },
      error: (Object error, StackTrace stackTrace) => _FicMessageRow(
        icon: Icons.wifi_off_rounded,
        message: formatApiError(error, includeUri: true),
      ),
      loading: () => const _FicMessageRow(
        icon: Icons.sync_rounded,
        message: 'Loading studies...',
      ),
    );
  }
}

class _FicMessageRow extends StatelessWidget {
  const _FicMessageRow({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 16, color: TaraTheme.primaryDark),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: TaraTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
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
    required this.study,
    required this.title,
    required this.detail,
    required this.status,
    required this.statusColor,
    required this.statusTint,
    required this.icon,
  });

  final FicStudy study;
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
      child: Column(
        children: <Widget>[
          Row(
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
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _openStudyForm(context, study),
                  child: const Text('View Form'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: () => _openAnalysis(context, study),
                  child: const Text('View Dashboard'),
                ),
              ),
            ],
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
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontSize: 9, height: 1),
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
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontSize: 10),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
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
  const _FicBottomNav({required this.currentView, required this.onChanged});

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

class _FicStatusStyle {
  const _FicStatusStyle({
    required this.foreground,
    required this.background,
    required this.icon,
  });

  final Color foreground;
  final Color background;
  final IconData icon;
}

_FicStatusStyle _statusStyleFor(String status) {
  final String normalized = status.trim().toUpperCase();
  if (normalized.contains('PROGRESS') ||
      normalized.contains('LIVE') ||
      normalized.contains('ACTIVE')) {
    return const _FicStatusStyle(
      foreground: TaraTheme.primaryDark,
      background: TaraTheme.primaryTint,
      icon: Icons.groups_2_outlined,
    );
  }
  if (normalized.contains('COMPLETE') || normalized.contains('DONE')) {
    return const _FicStatusStyle(
      foreground: TaraTheme.mintText,
      background: Color(0xFFEAF8D9),
      icon: Icons.check_circle_outline_rounded,
    );
  }
  return const _FicStatusStyle(
    foreground: TaraTheme.textPrimary,
    background: Color(0xFFF1F5F9),
    icon: Icons.fact_check_outlined,
  );
}

_CalendarKind _calendarKindFor(FicAvailabilityDay day) {
  final DateTime local = day.date.toLocal();
  final DateTime now = DateTime.now();
  if (local.year == now.year &&
      local.month == now.month &&
      local.day == now.day) {
    return _CalendarKind.today;
  }
  if (day.booked) {
    return _CalendarKind.booked;
  }
  if (day.available) {
    return _CalendarKind.available;
  }
  return _CalendarKind.idle;
}

List<FicAvailabilityDay> _visibleAvailabilityDays(
  List<FicAvailabilityDay> availability,
) {
  if (availability.isEmpty) {
    return <FicAvailabilityDay>[];
  }
  final DateTime now = DateTime.now();
  final List<FicAvailabilityDay> upcoming = availability
      .where((FicAvailabilityDay day) {
        final DateTime local = day.date.toLocal();
        return !DateTime(
          local.year,
          local.month,
          local.day,
        ).isBefore(DateTime(now.year, now.month, now.day));
      })
      .take(7)
      .toList();
  return upcoming.isNotEmpty ? upcoming : availability.take(7).toList();
}

String _weekdayLabel(DateTime value) {
  const List<String> days = <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  return days[value.toLocal().weekday - 1];
}

String _humanizeStatus(String value) {
  final String normalized = value.trim();
  if (normalized.isEmpty) {
    return 'Upcoming';
  }
  return normalized
      .replaceAll('_', ' ')
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((String part) => part.isNotEmpty)
      .map(
        (String part) =>
            '${part.substring(0, 1).toUpperCase()}${part.substring(1)}',
      )
      .join(' ');
}

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

void _openStudyForm(BuildContext context, FicStudy study) {
  context.push(
    '/fic/studies/${Uri.encodeComponent(study.id)}/form',
    extra: study,
  );
}

void _openAnalysis(BuildContext context, FicStudy study) {
  context.push(
    '/fic/studies/${Uri.encodeComponent(study.id)}/analysis',
    extra: study,
  );
}
