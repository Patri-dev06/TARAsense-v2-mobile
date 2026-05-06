import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarasense_mobile/core/theme/tara_theme.dart';
import 'package:tarasense_mobile/core/widgets/tara_brand_lockup.dart';
import 'package:tarasense_mobile/features/auth/state/auth_providers.dart';

enum _AdminView { dashboard, users, studies, logs, settings }

class AdminWorkspacePage extends ConsumerStatefulWidget {
  const AdminWorkspacePage({super.key});

  @override
  ConsumerState<AdminWorkspacePage> createState() => _AdminWorkspacePageState();
}

class _AdminWorkspacePageState extends ConsumerState<AdminWorkspacePage> {
  _AdminView _currentView = _AdminView.dashboard;
  final List<_RoleRequestDraft> _roleRequests = <_RoleRequestDraft>[
    _RoleRequestDraft(
      initials: 'JR',
      name: 'Juan Reyes',
      detail: 'Consumer -> MSME upgrade',
    ),
    _RoleRequestDraft(
      initials: 'MC',
      name: 'Maria Cruz',
      detail: 'New FIC assignment',
    ),
  ];
  final List<_AuditEntry> _auditLog = <_AuditEntry>[
    const _AuditEntry(
      icon: Icons.person_outline_rounded,
      title: 'User role updated',
      detail: 'admin@dost.gov - 2 min ago',
      tint: TaraTheme.primaryTint,
      iconColor: TaraTheme.primaryDark,
    ),
    const _AuditEntry(
      icon: Icons.fact_check_outlined,
      title: 'New study approved',
      detail: 'msme@example.ph - 15 min ago',
      tint: Color(0xFFEAF8D9),
      iconColor: TaraTheme.mintText,
    ),
    const _AuditEntry(
      icon: Icons.schedule_rounded,
      title: 'FIC availability updated',
      detail: 'fic.station3 - 1 hr ago',
      tint: Color(0xFFF3F4F6),
      iconColor: TaraTheme.textSecondary,
    ),
  ];

  void _resolveRequest(int index, bool approved) {
    final _RoleRequestDraft request = _roleRequests[index];
    setState(() {
      _roleRequests.removeAt(index);
      _auditLog.insert(
        0,
        _AuditEntry(
          icon: approved
              ? Icons.check_circle_outline_rounded
              : Icons.cancel_outlined,
          title: approved ? 'Role request approved' : 'Role request denied',
          detail: '${request.name} - just now',
          tint: approved ? const Color(0xFFEAF8D9) : TaraTheme.primaryTint,
          iconColor: approved ? TaraTheme.mintText : TaraTheme.primaryDark,
        ),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${request.name} ${approved ? 'approved' : 'denied'}.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final session = authState.session;
    final bool wide = MediaQuery.sizeOf(context).width >= 720;

    return Scaffold(
      backgroundColor: TaraTheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(authControllerProvider.notifier).refreshProfile(),
          child: ListView(
            padding: EdgeInsets.fromLTRB(wide ? 28 : 16, 14, wide ? 28 : 16, 22),
            children: <Widget>[
              _AdminHeader(
                name: session?.user.name ?? 'Admin',
              ),
              const SizedBox(height: 18),
              _buildView(
                authBusy: authState.isBusy,
                onLogout: () =>
                    ref.read(authControllerProvider.notifier).logout(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _AdminBottomNav(
        currentView: _currentView,
        onChanged: (view) => setState(() => _currentView = view),
      ),
    );
  }

  Widget _buildView({
    required bool authBusy,
    required VoidCallback onLogout,
  }) {
    switch (_currentView) {
      case _AdminView.dashboard:
        return _AdminDashboardBody(
          roleRequests: _roleRequests,
          auditLog: _auditLog,
          onResolveRequest: _resolveRequest,
        );
      case _AdminView.users:
        return _AdminListPanel(
          title: 'Users',
          children: const <Widget>[
            _AdminSimpleRow(title: 'Ana Santos', detail: 'Consumer - active'),
            _AdminSimpleRow(title: 'Juan Reyes', detail: 'MSME request pending'),
            _AdminSimpleRow(title: 'FIC Station 3', detail: 'Facility account'),
          ],
        );
      case _AdminView.studies:
        return _AdminListPanel(
          title: 'Studies',
          children: const <Widget>[
            _AdminSimpleRow(title: 'Dried Mango Texture Evaluation', detail: 'Active'),
            _AdminSimpleRow(title: 'Cacao Dark Chocolate Study', detail: 'Pending approval'),
            _AdminSimpleRow(title: 'Coconut Vinegar Taste Test', detail: 'Draft'),
          ],
        );
      case _AdminView.logs:
        return _AuditLogPanel(auditLog: _auditLog);
      case _AdminView.settings:
        return _AdminSettingsPanel(
          name: ref.watch(authControllerProvider).session?.user.name ?? 'Admin',
          authBusy: authBusy,
          onLogout: onLogout,
        );
    }
  }
}

class _AdminHeader extends StatelessWidget {
  const _AdminHeader({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const TaraBrandLockup(markSize: 18, textSize: 20),
              const SizedBox(height: 3),
              Text(
                'Admin panel',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: TaraTheme.textSecondary,
                  fontSize: 12,
                  height: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        CircleAvatar(
          radius: 18,
          backgroundColor: TaraTheme.primaryTint,
          child: Text(
            _adminInitials(name),
            style: const TextStyle(
              color: TaraTheme.primaryDark,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _AdminSettingsPanel extends StatelessWidget {
  const _AdminSettingsPanel({
    required this.name,
    required this.authBusy,
    required this.onLogout,
  });

  final String name;
  final bool authBusy;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return _AdminListPanel(
      title: 'Settings',
      children: <Widget>[
        _AdminSimpleRow(title: name, detail: 'Administrator account'),
        OutlinedButton.icon(
          onPressed: authBusy ? null : onLogout,
          icon: const Icon(Icons.logout_rounded, size: 16),
          label: const Text('Log out'),
          style: OutlinedButton.styleFrom(
            foregroundColor: TaraTheme.roseText,
            side: const BorderSide(color: Color(0xFFFECDD3)),
          ),
        ),
      ],
    );
  }
}

class _AdminDashboardBody extends StatelessWidget {
  const _AdminDashboardBody({
    required this.roleRequests,
    required this.auditLog,
    required this.onResolveRequest,
  });

  final List<_RoleRequestDraft> roleRequests;
  final List<_AuditEntry> auditLog;
  final void Function(int index, bool approved) onResolveRequest;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _AdminSectionTitle('PLATFORM OVERVIEW'),
        const SizedBox(height: 8),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.28,
          children: const <Widget>[
            _OverviewMetricCard(
              label: 'Total users',
              value: '284',
              note: '+12 this week',
              positive: true,
            ),
            _OverviewMetricCard(
              label: 'Active studies',
              value: '17',
              note: '3 pending',
              positive: false,
            ),
            _OverviewMetricCard(
              label: 'FIC facilities',
              value: '8',
              note: '2 unassigned',
            ),
            _OverviewMetricCard(
              label: 'Role requests',
              value: '5',
              note: 'Needs review',
              positive: false,
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _AdminSectionTitle('PENDING ROLE REQUESTS'),
        const SizedBox(height: 8),
        _RoleRequestsPanel(
          requests: roleRequests,
          onResolveRequest: onResolveRequest,
        ),
        const SizedBox(height: 16),
        const _AdminSectionTitle('RECENT AUDIT LOG'),
        const SizedBox(height: 8),
        _AuditLogPanel(auditLog: auditLog.take(3).toList()),
      ],
    );
  }
}

class _OverviewMetricCard extends StatelessWidget {
  const _OverviewMetricCard({
    required this.label,
    required this.value,
    required this.note,
    this.positive,
  });

  final String label;
  final String value;
  final String note;
  final bool? positive;

  @override
  Widget build(BuildContext context) {
    final Color noteColor = positive == null
        ? TaraTheme.textPrimary
        : positive!
        ? TaraTheme.mintText
        : TaraTheme.primaryDark;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: TaraTheme.textPrimary.withValues(alpha: 0.72),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 22,
              height: 1,
              letterSpacing: 0,
            ),
          ),
          const Spacer(),
          Text(
            note,
            style: TextStyle(
              color: noteColor,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleRequestsPanel extends StatelessWidget {
  const _RoleRequestsPanel({
    required this.requests,
    required this.onResolveRequest,
  });

  final List<_RoleRequestDraft> requests;
  final void Function(int index, bool approved) onResolveRequest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TaraTheme.border),
      ),
      child: requests.isEmpty
          ? const _AdminSimpleRow(
              title: 'All caught up',
              detail: 'No role requests need review.',
            )
          : Column(
              children: requests.asMap().entries.map((entry) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: entry.key == requests.length - 1 ? 0 : 8,
                  ),
                  child: _RoleRequestRow(
                    request: entry.value,
                    onApprove: () => onResolveRequest(entry.key, true),
                    onDeny: () => onResolveRequest(entry.key, false),
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class _RoleRequestRow extends StatelessWidget {
  const _RoleRequestRow({
    required this.request,
    required this.onApprove,
    required this.onDeny,
  });

  final _RoleRequestDraft request;
  final VoidCallback onApprove;
  final VoidCallback onDeny;

  @override
  Widget build(BuildContext context) {
    final Widget identity = Row(
      children: <Widget>[
        CircleAvatar(
          radius: 17,
          backgroundColor: const Color(0xFFF3F4F6),
          child: Text(
            request.initials,
            style: const TextStyle(
              color: TaraTheme.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                request.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 11,
                  height: 1.1,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                request.detail,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: TaraTheme.textPrimary.withValues(alpha: 0.76),
                  fontSize: 9,
                  height: 1.08,
                ),
              ),
            ],
          ),
        ),
      ],
    );
    final Widget actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _AdminActionButton(label: 'Approve', primary: true, onTap: onApprove),
        const SizedBox(width: 6),
        _AdminActionButton(label: 'Deny', primary: false, onTap: onDeny),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 330) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              identity,
              const SizedBox(height: 8),
              Align(alignment: Alignment.centerRight, child: actions),
            ],
          );
        }

        return Row(
          children: <Widget>[
            Expanded(child: identity),
            const SizedBox(width: 10),
            actions,
          ],
        );
      },
    );
  }
}

class _AdminActionButton extends StatelessWidget {
  const _AdminActionButton({
    required this.label,
    required this.primary,
    required this.onTap,
  });

  final String label;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: primary ? TaraTheme.primary : const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          child: Text(
            label,
            style: TextStyle(
              color: primary ? Colors.white : TaraTheme.textPrimary,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _AuditLogPanel extends StatelessWidget {
  const _AuditLogPanel({required this.auditLog});

  final List<_AuditEntry> auditLog;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        children: auditLog.asMap().entries.map((entry) {
          return Column(
            children: <Widget>[
              _AuditLogRow(entry: entry.value),
              if (entry.key != auditLog.length - 1) const Divider(height: 20),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _AuditLogRow extends StatelessWidget {
  const _AuditLogRow({required this.entry});

  final _AuditEntry entry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          height: 28,
          width: 28,
          decoration: BoxDecoration(
            color: entry.tint,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(entry.icon, color: entry.iconColor, size: 14),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                entry.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 11,
                  height: 1.1,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                entry.detail,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: TaraTheme.textPrimary.withValues(alpha: 0.72),
                  fontSize: 9,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AdminListPanel extends StatelessWidget {
  const _AdminListPanel({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _AdminSectionTitle(title.toUpperCase()),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: TaraTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TaraTheme.border),
          ),
          child: Column(
            children: children.asMap().entries.map((entry) {
              return Column(
                children: <Widget>[
                  entry.value,
                  if (entry.key != children.length - 1) const Divider(height: 20),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _AdminSimpleRow extends StatelessWidget {
  const _AdminSimpleRow({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Icon(Icons.chevron_right_rounded, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 12,
                  letterSpacing: 0,
                ),
              ),
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
    );
  }
}

class _AdminSectionTitle extends StatelessWidget {
  const _AdminSectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: TaraTheme.textPrimary.withValues(alpha: 0.72),
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.7,
        height: 1,
      ),
    );
  }
}

class _AdminBottomNav extends StatelessWidget {
  const _AdminBottomNav({
    required this.currentView,
    required this.onChanged,
  });

  final _AdminView currentView;
  final ValueChanged<_AdminView> onChanged;

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
          height: 58,
          child: Row(
            children: <Widget>[
              _AdminNavItem(
                icon: Icons.grid_view_rounded,
                label: 'Dashboard',
                selected: currentView == _AdminView.dashboard,
                onTap: () => onChanged(_AdminView.dashboard),
              ),
              _AdminNavItem(
                icon: Icons.person_outline_rounded,
                label: 'Users',
                selected: currentView == _AdminView.users,
                onTap: () => onChanged(_AdminView.users),
              ),
              _AdminNavItem(
                icon: Icons.article_outlined,
                label: 'Studies',
                selected: currentView == _AdminView.studies,
                onTap: () => onChanged(_AdminView.studies),
              ),
              _AdminNavItem(
                icon: Icons.format_align_center_rounded,
                label: 'Logs',
                selected: currentView == _AdminView.logs,
                onTap: () => onChanged(_AdminView.logs),
              ),
              _AdminNavItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                selected: currentView == _AdminView.settings,
                onTap: () => onChanged(_AdminView.settings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminNavItem extends StatelessWidget {
  const _AdminNavItem({
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
              Icon(icon, color: color, size: 17),
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

class _RoleRequestDraft {
  const _RoleRequestDraft({
    required this.initials,
    required this.name,
    required this.detail,
  });

  final String initials;
  final String name;
  final String detail;
}

class _AuditEntry {
  const _AuditEntry({
    required this.icon,
    required this.title,
    required this.detail,
    required this.tint,
    required this.iconColor,
  });

  final IconData icon;
  final String title;
  final String detail;
  final Color tint;
  final Color iconColor;
}

String _adminInitials(String value) {
  final List<String> parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((String part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) {
    return 'AD';
  }
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
      .toUpperCase();
}
