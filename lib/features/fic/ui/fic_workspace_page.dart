import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tarasense_mobile/core/network/api_error_formatter.dart';
import 'package:tarasense_mobile/core/theme/tara_theme.dart';
import 'package:tarasense_mobile/features/auth/state/auth_providers.dart';
import 'package:tarasense_mobile/features/auth/ui/auth_loading_dialog.dart';
import 'package:tarasense_mobile/features/fic/data/fic_api.dart';
import 'package:tarasense_mobile/features/fic/domain/fic_models.dart';
import 'package:tarasense_mobile/features/profile/ui/profile_tab.dart';

// ─── Riverpod providers ───────────────────────────────────────────────────────

final _ficDashboardProvider = FutureProvider.autoDispose<FicDashboardData>((
  ref,
) async {
  final String token = ref
          .watch(authControllerProvider.select((s) => s.session))
          ?.tokens
          .accessToken ??
      '';
  if (token.trim().isEmpty) {
    return const FicDashboardData(
      activeSessions: 0,
      nextTitle: '',
      nextTime: '',
      studies: <FicStudy>[],
      calendar: <FicCalendarItem>[],
    );
  }
  return ref.watch(ficApiProvider).fetchDashboard(token);
});

final _ficStudiesProvider = FutureProvider.autoDispose<List<FicStudy>>((
  ref,
) async {
  final String token = ref
          .watch(authControllerProvider.select((s) => s.session))
          ?.tokens
          .accessToken ??
      '';
  if (token.trim().isEmpty) return <FicStudy>[];
  return ref.watch(ficApiProvider).fetchStudies(token);
});

final _ficCalendarProvider =
    FutureProvider.autoDispose<List<FicCalendarItem>>((ref) async {
      final String token = ref
              .watch(authControllerProvider.select((s) => s.session))
              ?.tokens
              .accessToken ??
          '';
      if (token.trim().isEmpty) return <FicCalendarItem>[];
      return ref.watch(ficApiProvider).fetchCalendar(token);
    });

final _ficAvailabilityProvider =
    FutureProvider.autoDispose<List<FicAvailabilityDay>>((ref) async {
      final String token = ref
              .watch(authControllerProvider.select((s) => s.session))
              ?.tokens
              .accessToken ??
          '';
      if (token.trim().isEmpty) return <FicAvailabilityDay>[];
      final DateTime now = DateTime.now();
      return ref.watch(ficApiProvider).fetchAvailability(
        token,
        startDate: DateTime(now.year, now.month),
        endDate: DateTime(now.year, now.month + 2, 0),
      );
    });

// ─── Page ─────────────────────────────────────────────────────────────────────

class FicWorkspacePage extends ConsumerStatefulWidget {
  const FicWorkspacePage({super.key});

  @override
  ConsumerState<FicWorkspacePage> createState() => _FicWorkspacePageState();
}

class _FicWorkspacePageState extends ConsumerState<FicWorkspacePage> {
  int _tabIndex = 0;
  bool _isTogglingDate = false;

  String? get _accessToken =>
      ref.read(authControllerProvider).session?.tokens.accessToken;

  Future<void> _toggleAvailability(FicAvailabilityDay day) async {
    if (_isTogglingDate) return;
    final String? token = _accessToken;
    if (token == null) return;
    setState(() => _isTogglingDate = true);
    try {
      await ref
          .read(ficApiProvider)
          .updateAvailability(
            token,
            date: day.date.toLocal(),
            payload: <String, dynamic>{'available': !day.available},
          );
      ref.invalidate(_ficAvailabilityProvider);
    } catch (_) {
      // ignore — provider stays stale; user can pull-to-refresh
    } finally {
      if (mounted) setState(() => _isTogglingDate = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final session = authState.session;
    final String displayName =
        session?.user.name.trim().isNotEmpty == true
        ? session!.user.name.trim()
        : 'FIC Station';
    final String facility =
        session?.user.organization?.trim().isNotEmpty == true
        ? session!.user.organization!.trim()
        : 'Assigned Facility';

    final AsyncValue<FicDashboardData> dashboardAsync =
        ref.watch(_ficDashboardProvider);
    final AsyncValue<List<FicStudy>> studiesAsync =
        ref.watch(_ficStudiesProvider);
    final AsyncValue<List<FicCalendarItem>> calendarAsync =
        ref.watch(_ficCalendarProvider);
    final AsyncValue<List<FicAvailabilityDay>> availabilityAsync =
        ref.watch(_ficAvailabilityProvider);

    return Scaffold(
      backgroundColor: TaraTheme.background,
      bottomNavigationBar: _FicBottomNav(
        currentIndex: _tabIndex,
        onChanged: (int i) => setState(() => _tabIndex = i),
      ),
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _tabIndex,
          children: <Widget>[
            _FicDashboardTab(
              displayName: displayName,
              facility: facility,
              dashboardAsync: dashboardAsync,
              studiesAsync: studiesAsync,
              availabilityAsync: availabilityAsync,
              onViewQueue: () => setState(() => _tabIndex = 1),
            ),
            _FicQueueTab(
              displayName: displayName,
              facility: facility,
              studiesAsync: studiesAsync,
            ),
            _FicCalendarTab(
              displayName: displayName,
              facility: facility,
              calendarAsync: calendarAsync,
              availabilityAsync: availabilityAsync,
              isTogglingDate: _isTogglingDate,
              onToggleDate: _toggleAvailability,
              onRefreshAvailability: () => ref.invalidate(_ficAvailabilityProvider),
            ),
            ProfileTab(
              workspaceLabel: 'FIC WORKSPACE',
              onLogout: () => showLogoutLoadingAndRun(
                context,
                () => ref.read(authControllerProvider.notifier).logout(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dashboard tab ────────────────────────────────────────────────────────────

class _FicDashboardTab extends StatelessWidget {
  const _FicDashboardTab({
    required this.displayName,
    required this.facility,
    required this.dashboardAsync,
    required this.studiesAsync,
    required this.availabilityAsync,
    required this.onViewQueue,
  });

  final String displayName;
  final String facility;
  final AsyncValue<FicDashboardData> dashboardAsync;
  final AsyncValue<List<FicStudy>> studiesAsync;
  final AsyncValue<List<FicAvailabilityDay>> availabilityAsync;
  final VoidCallback onViewQueue;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
      children: <Widget>[
        _FicHeader(
          label: 'FIC WORKSPACE',
          title: displayName,
          subtitle: facility,
          icon: Icons.widgets_outlined,
        ),
        const SizedBox(height: 14),
        _FicSessionsCard(
          dashboardAsync: dashboardAsync,
          onViewQueue: onViewQueue,
        ),
        const SizedBox(height: 12),
        _FicStatsGrid(dashboardAsync: dashboardAsync),
        const SizedBox(height: 12),
        _FicAvailabilityCard(
          availabilityAsync: availabilityAsync,
          toggleable: false,
          isToggling: false,
          onToggle: null,
        ),
        const SizedBox(height: 12),
        _FicPanel(
          title: 'Study Queue',
          child: _FicStudyList(studiesAsync: studiesAsync, limit: 3),
        ),
      ],
    );
  }
}

// ─── Queue tab ────────────────────────────────────────────────────────────────

class _FicQueueTab extends StatelessWidget {
  const _FicQueueTab({
    required this.displayName,
    required this.facility,
    required this.studiesAsync,
  });

  final String displayName;
  final String facility;
  final AsyncValue<List<FicStudy>> studiesAsync;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
      children: <Widget>[
        _FicHeader(
          label: 'FIC WORKSPACE',
          title: 'Facility Queue',
          subtitle: facility,
          icon: Icons.format_list_bulleted_rounded,
        ),
        const SizedBox(height: 14),
        _FicPanel(
          title: 'Facility Queue',
          child: _FicStudyList(studiesAsync: studiesAsync, limit: 50),
        ),
      ],
    );
  }
}

// ─── Calendar tab ─────────────────────────────────────────────────────────────

class _FicCalendarTab extends StatelessWidget {
  const _FicCalendarTab({
    required this.displayName,
    required this.facility,
    required this.calendarAsync,
    required this.availabilityAsync,
    required this.isTogglingDate,
    required this.onToggleDate,
    required this.onRefreshAvailability,
  });

  final String displayName;
  final String facility;
  final AsyncValue<List<FicCalendarItem>> calendarAsync;
  final AsyncValue<List<FicAvailabilityDay>> availabilityAsync;
  final bool isTogglingDate;
  final Future<void> Function(FicAvailabilityDay) onToggleDate;
  final VoidCallback onRefreshAvailability;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
      children: <Widget>[
        _FicHeader(
          label: 'FIC WORKSPACE',
          title: 'FIC Calendar',
          subtitle: facility,
          icon: Icons.calendar_today_outlined,
        ),
        const SizedBox(height: 14),
        _FicAvailabilityCard(
          availabilityAsync: availabilityAsync,
          toggleable: true,
          isToggling: isTogglingDate,
          onToggle: onToggleDate,
        ),
        const SizedBox(height: 12),
        _FicPanel(
          title: 'Booked Sessions',
          child: calendarAsync.when(
            data: (List<FicCalendarItem> calendar) {
              if (calendar.isEmpty) {
                return const _FicMessageRow(
                  icon: Icons.event_busy_outlined,
                  message: 'No scheduled sessions found.',
                );
              }
              return Column(
                children: calendar
                    .take(20)
                    .map(
                      (FicCalendarItem item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _CalendarSessionRow(
                          title: item.title,
                          detail: item.detailLabel,
                          status: item.status,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
            error: (Object e, _) => _FicMessageRow(
              icon: Icons.wifi_off_rounded,
              message: formatApiError(e, includeUri: true),
            ),
            loading: () => const _FicMessageRow(
              icon: Icons.sync_rounded,
              message: 'Loading sessions...',
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Shared card widgets ──────────────────────────────────────────────────────

class _FicSessionsCard extends StatelessWidget {
  const _FicSessionsCard({
    required this.dashboardAsync,
    required this.onViewQueue,
  });

  final AsyncValue<FicDashboardData> dashboardAsync;
  final VoidCallback onViewQueue;

  @override
  Widget build(BuildContext context) {
    final String countLabel = dashboardAsync.when(
      data: (d) => '${d.activeSessions} active',
      error: (_, _) => 'Unavailable',
      loading: () => '—',
    );
    final String nextLabel = dashboardAsync.when(
      data: (d) {
        if (d.nextTitle.trim().isEmpty) return 'No upcoming session';
        final String t = d.nextTime.trim();
        return t.isEmpty ? 'Next: ${d.nextTitle}' : 'Next: ${d.nextTitle} · $t';
      },
      error: (e, _) => formatApiError(e, includeUri: true),
      loading: () => 'Syncing dashboard…',
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
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 12),
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
    );
  }
}

class _FicStatsGrid extends StatelessWidget {
  const _FicStatsGrid({required this.dashboardAsync});

  final AsyncValue<FicDashboardData> dashboardAsync;

  @override
  Widget build(BuildContext context) {
    final FicStats? stats = dashboardAsync.whenOrNull(data: (d) => d.stats);
    final bool loading = dashboardAsync is AsyncLoading;

    String v(int? value) => loading ? '—' : (value ?? 0).toString();

    return _FicPanel(
      title: 'Facility Summary',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: <Widget>[
          _FicStatChip(
            label: 'Bookings',
            value: v(stats?.bookingNotifications),
          ),
          _FicStatChip(
            label: 'Upcoming',
            value: v(stats?.upcomingSessions),
          ),
          _FicStatChip(
            label: 'Pending',
            value: v(stats?.pendingConfirmation),
          ),
          _FicStatChip(
            label: 'Uploaded',
            value: v(stats?.uploadedStudies),
          ),
          _FicStatChip(
            label: 'Active',
            value: v(stats?.activeStudies),
          ),
          _FicStatChip(
            label: 'Responses',
            value: v(stats?.totalResponses),
          ),
        ],
      ),
    );
  }
}

class _FicStatChip extends StatelessWidget {
  const _FicStatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: TaraTheme.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              height: 1,
              color: Color(0xFF171717),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: TaraTheme.textSecondary,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _FicAvailabilityCard extends StatelessWidget {
  const _FicAvailabilityCard({
    required this.availabilityAsync,
    required this.toggleable,
    required this.isToggling,
    required this.onToggle,
  });

  final AsyncValue<List<FicAvailabilityDay>> availabilityAsync;
  final bool toggleable;
  final bool isToggling;
  final Future<void> Function(FicAvailabilityDay)? onToggle;

  @override
  Widget build(BuildContext context) {
    return _FicPanel(
      title: toggleable ? 'My Availability' : 'Availability Calendar',
      child: availabilityAsync.when(
        data: (List<FicAvailabilityDay> availability) {
          final List<FicAvailabilityDay> days = _visibleDays(availability);
          if (days.isEmpty) {
            return const _FicMessageRow(
              icon: Icons.calendar_month_outlined,
              message: 'No availability records for this period.',
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (toggleable)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Tap a date to toggle your availability.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: TaraTheme.textSecondary,
                    ),
                  ),
                ),
              Row(
                children: days
                    .map(
                      (FicAvailabilityDay day) => Expanded(
                        child: Center(
                          child: Text(
                            _weekdayLabel(day.date),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 8),
              Row(
                children: days
                    .map(
                      (FicAvailabilityDay day) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: _CalendarDatePill(
                            date: day.date.toLocal().day,
                            kind: _calendarKindFor(day),
                            onTap: (toggleable && !isToggling && onToggle != null)
                                ? () => unawaited(onToggle!(day))
                                : null,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 6,
                children: <Widget>[
                  const _CalendarLegend(
                    label: 'Today',
                    color: TaraTheme.primary,
                  ),
                  const _CalendarLegend(
                    label: 'Available',
                    color: Color(0xFFB7D8A8),
                  ),
                  const _CalendarLegend(
                    label: 'Booked',
                    color: Color(0xFFF5BBB0),
                  ),
                  if (isToggling)
                    const _CalendarLegend(
                      label: 'Updating…',
                      color: Color(0xFFE5DED0),
                    ),
                ],
              ),
            ],
          );
        },
        error: (Object e, _) => _FicMessageRow(
          icon: Icons.wifi_off_rounded,
          message: formatApiError(e, includeUri: true),
        ),
        loading: () => const _FicMessageRow(
          icon: Icons.sync_rounded,
          message: 'Loading availability…',
        ),
      ),
    );
  }
}

// ─── Study list ───────────────────────────────────────────────────────────────

class _FicStudyList extends StatelessWidget {
  const _FicStudyList({required this.studiesAsync, required this.limit});

  final AsyncValue<List<FicStudy>> studiesAsync;
  final int limit;

  @override
  Widget build(BuildContext context) {
    return studiesAsync.when(
      data: (List<FicStudy> studies) {
        if (studies.isEmpty) {
          return const _FicMessageRow(
            icon: Icons.fact_check_outlined,
            message: 'No studies assigned to this facility.',
          );
        }
        return Column(
          children: studies.take(limit).map((FicStudy study) {
            final _FicStatusStyle style = _statusStyleFor(study.status);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _StudyQueueTile(
                study: study,
                status: _humanizeStatus(study.status),
                statusColor: style.foreground,
                statusTint: style.background,
                icon: style.icon,
              ),
            );
          }).toList(),
        );
      },
      error: (Object e, _) => _FicMessageRow(
        icon: Icons.wifi_off_rounded,
        message: formatApiError(e, includeUri: true),
      ),
      loading: () => const _FicMessageRow(
        icon: Icons.sync_rounded,
        message: 'Loading studies…',
      ),
    );
  }
}

// ─── Shared small widgets ─────────────────────────────────────────────────────

class _FicHeader extends StatelessWidget {
  const _FicHeader({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String label;
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFFB923C), TaraTheme.primaryDark],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x28F97316),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: const Color(0x33FFFFFF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0x44FFFFFF)),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xCCFFFFFF),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -0.3,
                  ),
                ),
                if (subtitle.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xB3FFFFFF),
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TaraTheme.border),
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

class _StudyQueueTile extends StatelessWidget {
  const _StudyQueueTile({
    required this.study,
    required this.status,
    required this.statusColor,
    required this.statusTint,
    required this.icon,
  });

  final FicStudy study;
  final String status;
  final Color statusColor;
  final Color statusTint;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: TaraTheme.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: TaraTheme.border),
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
                      study.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${study.progressLabel} · ${study.scheduleLabel}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        height: 1.1,
                      ),
                    ),
                    if (study.ownerName.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        study.ownerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 9,
                          color: TaraTheme.textSecondary,
                          height: 1,
                        ),
                      ),
                    ],
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
                  onPressed: () => _openForm(context, study),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 34),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('View Form'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: () => _openAnalysis(context, study),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 34),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    backgroundColor: TaraTheme.primary,
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Dashboard'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalendarSessionRow extends StatelessWidget {
  const _CalendarSessionRow({
    required this.title,
    required this.detail,
    required this.status,
  });

  final String title;
  final String detail;
  final String status;

  @override
  Widget build(BuildContext context) {
    final bool confirmed = status.toUpperCase().contains('CONFIRM');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: TaraTheme.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.calendar_today_outlined,
            size: 14,
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
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: confirmed
                  ? const Color(0xFFEAF8D9)
                  : const Color(0xFFFFF9C4),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              confirmed ? 'Confirmed' : 'Pending',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                height: 1,
                color: confirmed ? TaraTheme.mintText : const Color(0xFF92400E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarDatePill extends StatelessWidget {
  const _CalendarDatePill({
    required this.date,
    required this.kind,
    this.onTap,
  });

  final int date;
  final _CalendarKind kind;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (kind) {
      case _CalendarKind.today:
        bg = TaraTheme.primary;
        fg = Colors.white;
      case _CalendarKind.available:
        bg = const Color(0xFFDCEAD0);
        fg = TaraTheme.mintText;
      case _CalendarKind.booked:
        bg = const Color(0xFFF6D5CC);
        fg = TaraTheme.roseText;
      case _CalendarKind.idle:
        bg = Colors.transparent;
        fg = TaraTheme.textSecondary;
    }

    final Widget pill = Container(
      height: 28,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Center(
        child: Text(
          '$date',
          style: TextStyle(
            color: fg,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ),
    );

    if (onTap == null) return pill;
    return GestureDetector(onTap: onTap, child: pill);
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

// ─── Bottom nav ───────────────────────────────────────────────────────────────

class _FicBottomNav extends StatelessWidget {
  const _FicBottomNav({
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: TaraTheme.surface,
        border: Border(top: BorderSide(color: TaraTheme.border)),
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
                selected: currentIndex == 0,
                onTap: () => onChanged(0),
              ),
              _FicNavItem(
                icon: Icons.format_list_bulleted_rounded,
                label: 'Queue',
                selected: currentIndex == 1,
                onTap: () => onChanged(1),
              ),
              _FicNavItem(
                icon: Icons.calendar_today_outlined,
                label: 'Calendar',
                selected: currentIndex == 2,
                onTap: () => onChanged(2),
              ),
              _FicNavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                selected: currentIndex == 3,
                onTap: () => onChanged(3),
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
              const SizedBox(height: 3),
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

// ─── Helpers ──────────────────────────────────────────────────────────────────

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
  final String s = status.trim().toUpperCase();
  if (s.contains('PROGRESS') || s.contains('LIVE') || s.contains('ACTIVE')) {
    return const _FicStatusStyle(
      foreground: TaraTheme.primaryDark,
      background: TaraTheme.primaryTint,
      icon: Icons.groups_2_outlined,
    );
  }
  if (s.contains('COMPLETE') || s.contains('DONE')) {
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
  if (day.booked) return _CalendarKind.booked;
  if (day.available) return _CalendarKind.available;
  return _CalendarKind.idle;
}

List<FicAvailabilityDay> _visibleDays(List<FicAvailabilityDay> all) {
  if (all.isEmpty) return <FicAvailabilityDay>[];
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);
  final List<FicAvailabilityDay> upcoming = all
      .where((FicAvailabilityDay d) {
        final DateTime local = d.date.toLocal();
        return !DateTime(local.year, local.month, local.day).isBefore(today);
      })
      .take(7)
      .toList();
  return upcoming.isNotEmpty ? upcoming : all.take(7).toList();
}

String _weekdayLabel(DateTime value) {
  const List<String> days = <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  return days[value.toLocal().weekday - 1];
}

String _humanizeStatus(String value) {
  final String normalized = value.trim();
  if (normalized.isEmpty) return 'Upcoming';
  return normalized
      .replaceAll('_', ' ')
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((String p) => p.isNotEmpty)
      .map((String p) => '${p[0].toUpperCase()}${p.substring(1)}')
      .join(' ');
}


void _openForm(BuildContext context, FicStudy study) {
  context.push('/fic/studies/${Uri.encodeComponent(study.id)}/form', extra: study);
}

void _openAnalysis(BuildContext context, FicStudy study) {
  context.push(
    '/fic/studies/${Uri.encodeComponent(study.id)}/analysis',
    extra: study,
  );
}
