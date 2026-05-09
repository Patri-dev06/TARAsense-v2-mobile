import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarasense_mobile/core/theme/tara_theme.dart';
import 'package:tarasense_mobile/core/widgets/tara_brand_lockup.dart';
import 'package:tarasense_mobile/features/auth/state/auth_providers.dart';
import 'package:tarasense_mobile/features/auth/ui/auth_loading_dialog.dart';
import 'package:tarasense_mobile/features/fic/ui/fic_workspace_page.dart';
import 'package:tarasense_mobile/features/msme/ui/msme_workspace_page.dart';

enum _AdminView {
  dashboard,
  users,
  profile,
  roleRequests,
  msmePreview,
  ficPreview,
}

class AdminWorkspacePage extends ConsumerStatefulWidget {
  const AdminWorkspacePage({super.key});

  @override
  ConsumerState<AdminWorkspacePage> createState() => _AdminWorkspacePageState();
}

class _AdminWorkspacePageState extends ConsumerState<AdminWorkspacePage> {
  _AdminView _currentView = _AdminView.dashboard;
  final TextEditingController _globalSearchController = TextEditingController();
  final TextEditingController _userSearchController = TextEditingController();

  @override
  void dispose() {
    _globalSearchController.dispose();
    _userSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final session = authState.session;
    final double width = MediaQuery.sizeOf(context).width;
    final bool wideLayout = width >= 980;

    if (wideLayout) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6F8FB),
        body: SafeArea(
          child: Row(
            children: <Widget>[
              _AdminSidebar(
                currentView: _currentView,
                roleRequestCount: _roleRequests.length,
                onChanged: (view) => setState(() => _currentView = view),
                authBusy: authState.isBusy,
                onLogout: _handleLogout,
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    _AdminTopBar(
                      controller: _globalSearchController,
                      dateLabel: _adminDateLabel(DateTime.now()),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(28, 22, 28, 24),
                        child: _AdminMainContent(
                          currentView: _currentView,
                          name: session?.user.name ?? 'Administrator',
                          email: session?.user.email ?? '',
                          role: session?.user.role ?? 'Admin',
                          organization: session?.user.organization,
                          userSearchController: _userSearchController,
                          roleRequestCount: _roleRequests.length,
                          authBusy: authState.isBusy,
                          onLogout: _handleLogout,
                          onGoToUsers: () =>
                              setState(() => _currentView = _AdminView.users),
                          onGoToRoleRequests: () => setState(
                            () => _currentView = _AdminView.roleRequests,
                          ),
                          onOpenMsmeWorkspace: _openMsmeWorkspace,
                          onOpenFicWorkspace: _openFicWorkspace,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        toolbarHeight: 72,
        titleSpacing: 16,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TaraBrandLockup(markSize: 18, textSize: 20),
            SizedBox(height: 2),
            Text(
              'ADMINISTRATION',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(authControllerProvider.notifier).refreshProfile(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: <Widget>[
              const SizedBox(height: 8),
              _AdminTopBar(
                controller: _globalSearchController,
                dateLabel: _adminDateLabel(DateTime.now()),
                compact: true,
              ),
              const SizedBox(height: 18),
              _AdminMainContent(
                currentView: _currentView,
                name: session?.user.name ?? 'Administrator',
                email: session?.user.email ?? '',
                role: session?.user.role ?? 'Admin',
                organization: session?.user.organization,
                userSearchController: _userSearchController,
                roleRequestCount: _roleRequests.length,
                authBusy: authState.isBusy,
                onLogout: _handleLogout,
                onGoToUsers: () =>
                    setState(() => _currentView = _AdminView.users),
                onGoToRoleRequests: () =>
                    setState(() => _currentView = _AdminView.roleRequests),
                onOpenMsmeWorkspace: _openMsmeWorkspace,
                onOpenFicWorkspace: _openFicWorkspace,
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

  void _handleLogout() {
    showLogoutLoadingAndRun(
      context,
      () => ref.read(authControllerProvider.notifier).logout(),
    );
  }

  void _openMsmeWorkspace() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const MsmeWorkspacePage()),
    );
  }

  void _openFicWorkspace() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const FicWorkspacePage()),
    );
  }
}

class _AdminSidebar extends StatelessWidget {
  const _AdminSidebar({
    required this.currentView,
    required this.roleRequestCount,
    required this.onChanged,
    required this.authBusy,
    required this.onLogout,
  });

  final _AdminView currentView;
  final int roleRequestCount;
  final ValueChanged<_AdminView> onChanged;
  final bool authBusy;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 224,
      decoration: const BoxDecoration(
        color: TaraTheme.surface,
        border: Border(right: BorderSide(color: Color(0xFFE7EDF5))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                TaraBrandLockup(markSize: 20, textSize: 18),
                SizedBox(height: 8),
                Text(
                  'ADMINISTRATION',
                  style: TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE9EEF5)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            child: Text(
              'NAVIGATION',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF94A3B8),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _AdminSidebarItem(
            icon: Icons.grid_view_outlined,
            label: 'Dashboard',
            selected: currentView == _AdminView.dashboard,
            onTap: () => onChanged(_AdminView.dashboard),
          ),
          _AdminSidebarItem(
            icon: Icons.group_outlined,
            label: 'Users',
            selected: currentView == _AdminView.users,
            onTap: () => onChanged(_AdminView.users),
          ),
          _AdminSidebarItem(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            selected: currentView == _AdminView.profile,
            onTap: () => onChanged(_AdminView.profile),
          ),
          _AdminSidebarItem(
            icon: Icons.verified_user_outlined,
            label: 'Role Requests',
            badge: roleRequestCount.toString(),
            selected: currentView == _AdminView.roleRequests,
            onTap: () => onChanged(_AdminView.roleRequests),
          ),
          _AdminSidebarItem(
            icon: Icons.storefront_outlined,
            label: 'MSME View',
            selected: currentView == _AdminView.msmePreview,
            onTap: () => onChanged(_AdminView.msmePreview),
          ),
          _AdminSidebarItem(
            icon: Icons.science_outlined,
            label: 'FIC View',
            selected: currentView == _AdminView.ficPreview,
            onTap: () => onChanged(_AdminView.ficPreview),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: authBusy ? null : onLogout,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 42),
                  backgroundColor: const Color(0xFFF8FAFC),
                  side: const BorderSide(color: Color(0xFFE7EDF5)),
                  foregroundColor: TaraTheme.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Logout'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminTopBar extends StatelessWidget {
  const _AdminTopBar({
    required this.controller,
    required this.dateLabel,
    this.compact = false,
  });

  final TextEditingController controller;
  final String dateLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final Widget searchField = Expanded(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search users, requests, or studies',
            prefixIcon: const Icon(Icons.search_rounded, size: 18),
            fillColor: TaraTheme.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE3EAF3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE3EAF3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: TaraTheme.primary),
            ),
          ),
        ),
      ),
    );

    final Widget actions = Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        _AdminTopPill(
          label: 'Admin control center',
          icon: Icons.shield_outlined,
        ),
        _AdminIconButton(icon: Icons.notifications_none_rounded),
        _AdminTopPill(
          label: dateLabel,
          icon: Icons.calendar_today_outlined,
        ),
      ],
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const _AdminIconButton(icon: Icons.space_dashboard_outlined),
              const SizedBox(width: 10),
              searchField,
            ],
          ),
          const SizedBox(height: 10),
          actions,
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF6F8FB),
        border: Border(bottom: BorderSide(color: Color(0xFFE7EDF5))),
      ),
      child: Row(
        children: <Widget>[
          const _AdminIconButton(icon: Icons.space_dashboard_outlined),
          const SizedBox(width: 10),
          searchField,
          const SizedBox(width: 16),
          actions,
        ],
      ),
    );
  }
}

class _AdminMainContent extends StatelessWidget {
  const _AdminMainContent({
    required this.currentView,
    required this.name,
    required this.email,
    required this.role,
    required this.organization,
    required this.userSearchController,
    required this.roleRequestCount,
    required this.authBusy,
    required this.onLogout,
    required this.onGoToUsers,
    required this.onGoToRoleRequests,
    required this.onOpenMsmeWorkspace,
    required this.onOpenFicWorkspace,
  });

  final _AdminView currentView;
  final String name;
  final String email;
  final String role;
  final String? organization;
  final TextEditingController userSearchController;
  final int roleRequestCount;
  final bool authBusy;
  final VoidCallback onLogout;
  final VoidCallback onGoToUsers;
  final VoidCallback onGoToRoleRequests;
  final VoidCallback onOpenMsmeWorkspace;
  final VoidCallback onOpenFicWorkspace;

  @override
  Widget build(BuildContext context) {
    switch (currentView) {
      case _AdminView.dashboard:
        return _AdminDashboardView(
          roleRequestCount: roleRequestCount,
          onGoToUsers: onGoToUsers,
          onGoToRoleRequests: onGoToRoleRequests,
          onOpenMsmeWorkspace: onOpenMsmeWorkspace,
          onOpenFicWorkspace: onOpenFicWorkspace,
        );
      case _AdminView.users:
        return _AdminUsersPanel(searchController: userSearchController);
      case _AdminView.profile:
        return _AdminProfilePanel(
          name: name,
          email: email,
          role: role,
          organization: organization,
          authBusy: authBusy,
          onLogout: onLogout,
        );
      case _AdminView.roleRequests:
        return _AdminRoleRequestsView(roleRequestCount: roleRequestCount);
      case _AdminView.msmePreview:
        return _AdminWorkspaceLaunchView(
          eyebrow: 'MSME VIEW',
          title: 'Open MSME Access',
          subtitle:
              'Study creation, booking status, and survey response progress.',
          icon: Icons.storefront_outlined,
          onOpen: onOpenMsmeWorkspace,
          buttonLabel: 'Open MSME Workspace',
        );
      case _AdminView.ficPreview:
        return _AdminWorkspaceLaunchView(
          eyebrow: 'FIC VIEW',
          title: 'Open FIC Access',
          subtitle:
              'Facility queue, uploaded studies, and in-lab coordination updates.',
          icon: Icons.science_outlined,
          onOpen: onOpenFicWorkspace,
          buttonLabel: 'Open FIC Workspace',
        );
    }
  }
}

class _AdminDashboardView extends StatelessWidget {
  const _AdminDashboardView({
    required this.roleRequestCount,
    required this.onGoToUsers,
    required this.onGoToRoleRequests,
    required this.onOpenMsmeWorkspace,
    required this.onOpenFicWorkspace,
  });

  final int roleRequestCount;
  final VoidCallback onGoToUsers;
  final VoidCallback onGoToRoleRequests;
  final VoidCallback onOpenMsmeWorkspace;
  final VoidCallback onOpenFicWorkspace;

  static const List<_AdminMetric> _metrics = <_AdminMetric>[
    _AdminMetric(
      icon: Icons.grid_view_outlined,
      value: '15',
      label: 'TOTAL STUDIES',
      note: 'All studies in the platform',
      tint: Color(0xFFEAF2FF),
      iconColor: Color(0xFF1D4ED8),
    ),
    _AdminMetric(
      icon: Icons.group_outlined,
      value: '116',
      label: 'REGISTERED USERS',
      note: 'All active user accounts',
      tint: Color(0xFFE7FAF3),
      iconColor: Color(0xFF059669),
    ),
    _AdminMetric(
      icon: Icons.shield_outlined,
      value: '0',
      label: 'PENDING REQUESTS',
      note: 'Awaiting review decisions',
      tint: Color(0xFFFFF4E8),
      iconColor: TaraTheme.primaryDark,
    ),
    _AdminMetric(
      icon: Icons.check_circle_outline_rounded,
      value: '21',
      label: 'APPROVED REQUESTS',
      note: 'Successfully upgraded access',
      tint: Color(0xFFE7FAF3),
      iconColor: Color(0xFF059669),
    ),
    _AdminMetric(
      icon: Icons.cancel_outlined,
      value: '0',
      label: 'REJECTED REQUESTS',
      note: 'Declined role upgrades',
      tint: Color(0xFFFFEEF1),
      iconColor: Color(0xFFE11D48),
    ),
    _AdminMetric(
      icon: Icons.person_outline_rounded,
      value: '592',
      label: 'PANELIST PROFILES',
      note: 'Profiles used for recruitment',
      tint: Color(0xFFF4F7FB),
      iconColor: Color(0xFF334155),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'ADMINISTRATION',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Admin Dashboard',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: const Color(0xFF0F2854),
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Full access to platform activity, role approvals, and cross-workspace monitoring.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 14),
        _AdminMetricGrid(metrics: _metrics),
        const SizedBox(height: 14),
        _AdminCompactNotice(
          title: 'System Messages',
          message: roleRequestCount == 0
              ? 'No urgent admin notifications right now.'
              : '$roleRequestCount role requests need attention.',
        ),
        const SizedBox(height: 14),
        _AdminQuickActionsRow(
          roleRequestCount: roleRequestCount,
          onGoToUsers: onGoToUsers,
          onGoToRoleRequests: onGoToRoleRequests,
          onOpenMsmeWorkspace: onOpenMsmeWorkspace,
          onOpenFicWorkspace: onOpenFicWorkspace,
        ),
      ],
    );
  }
}

class _AdminUsersPanel extends StatelessWidget {
  const _AdminUsersPanel({required this.searchController});

  final TextEditingController searchController;

  static const List<_AdminUserRecord> _users = <_AdminUserRecord>[
    _AdminUserRecord(
      initials: 'AS',
      name: 'Ana Santos',
      email: 'ana.santos@example.ph',
      role: 'Consumer',
      status: 'Active',
      note: 'Panelist profile linked',
    ),
    _AdminUserRecord(
      initials: 'JR',
      name: 'Juan Reyes',
      email: 'juan.reyes@example.ph',
      role: 'MSME',
      status: 'Active',
      note: 'Study owner access',
    ),
    _AdminUserRecord(
      initials: 'MC',
      name: 'Maria Cruz',
      email: 'maria.cruz@example.ph',
      role: 'Consumer',
      status: 'Pending',
      note: 'Awaiting verification',
    ),
    _AdminUserRecord(
      initials: 'F3',
      name: 'FIC Station 3',
      email: 'fic.station3@dost.gov',
      role: 'FIC',
      status: 'Active',
      note: 'Davao del Sur',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final String query = searchController.text.trim().toLowerCase();
    final List<_AdminUserRecord> visibleUsers = _users.where((user) {
      if (query.isEmpty) {
        return true;
      }
      return user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.role.toLowerCase().contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'ADMINISTRATION',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Users',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: const Color(0xFF0F2854),
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Review registered users, roles, and account activity status.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TaraTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD7E0EC)),
          ),
          child: Column(
            children: <Widget>[
              TextField(
                controller: searchController,
                onChanged: (_) => (context as Element).markNeedsBuild(),
                decoration: InputDecoration(
                  hintText: 'Search users',
                  prefixIcon: const Icon(Icons.search_rounded, size: 18),
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD7E0EC)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD7E0EC)),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              ...visibleUsers.asMap().entries.map((entry) {
                final bool last = entry.key == visibleUsers.length - 1;
                return Column(
                  children: <Widget>[
                    _AdminUserRow(user: entry.value),
                    if (!last)
                      const Divider(
                        height: 18,
                        color: Color(0xFFE8EEF6),
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _AdminProfilePanel extends StatelessWidget {
  const _AdminProfilePanel({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'ADMINISTRATION',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Profile',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: const Color(0xFF0F2854),
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Your current administrator details and account information.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TaraTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD7E0EC)),
          ),
          child: _AdminProfileGrid(
            fields: <_AdminProfileField>[
              _AdminProfileField(label: 'Name', value: name),
              _AdminProfileField(label: 'Email', value: email),
              _AdminProfileField(label: 'Role', value: role),
              if (organization != null && organization!.trim().isNotEmpty)
                _AdminProfileField(
                  label: 'Organization',
                  value: organization!.trim(),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: authBusy ? null : onLogout,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 48),
              foregroundColor: TaraTheme.roseText,
              side: const BorderSide(color: Color(0xFFFBCDD4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AdminRoleRequestsView extends StatelessWidget {
  const _AdminRoleRequestsView({required this.roleRequestCount});

  final int roleRequestCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'ADMINISTRATION',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Role Requests',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: const Color(0xFF0F2854),
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Review consumer requests for upgraded access and platform roles.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: TaraTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD7E0EC)),
          ),
          child: roleRequestCount == 0
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'No pending role requests',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'All current access requests have already been resolved.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _AdminWorkspaceLaunchView extends StatelessWidget {
  const _AdminWorkspaceLaunchView({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onOpen,
    required this.buttonLabel,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onOpen;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD7E0EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            eyebrow,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: TaraTheme.primaryTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: TaraTheme.primaryDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF111827),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.open_in_new_rounded),
            label: Text(buttonLabel),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminMetricGrid extends StatelessWidget {
  const _AdminMetricGrid({required this.metrics});

  final List<_AdminMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns = constraints.maxWidth >= 1260
            ? 4
            : constraints.maxWidth >= 860
            ? 3
            : constraints.maxWidth >= 560
            ? 2
            : 1;
        final double width = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - (12 * (columns - 1))) / columns;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: metrics
              .map(
                (_AdminMetric metric) => SizedBox(
                  width: width,
                  child: _AdminMetricCard(metric: metric),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _AdminMetricCard extends StatelessWidget {
  const _AdminMetricCard({required this.metric});

  final _AdminMetric metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 13),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7EDF5)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x050F172A),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: metric.tint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(metric.icon, color: metric.iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  metric.value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                Text(
                  metric.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF5C6E91),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  metric.note,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF64748B),
                    fontSize: 11,
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

class _AdminCompactNotice extends StatelessWidget {
  const _AdminCompactNotice({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7EDF5)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              color: TaraTheme.primaryTint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 16,
              color: TaraTheme.primaryDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF111827),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF64748B),
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

class _AdminQuickActionsRow extends StatelessWidget {
  const _AdminQuickActionsRow({
    required this.roleRequestCount,
    required this.onGoToUsers,
    required this.onGoToRoleRequests,
    required this.onOpenMsmeWorkspace,
    required this.onOpenFicWorkspace,
  });

  final int roleRequestCount;
  final VoidCallback onGoToUsers;
  final VoidCallback onGoToRoleRequests;
  final VoidCallback onOpenMsmeWorkspace;
  final VoidCallback onOpenFicWorkspace;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns = constraints.maxWidth >= 1120
            ? 4
            : constraints.maxWidth >= 700
            ? 2
            : 1;
        final double width = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - (10 * (columns - 1))) / columns;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            SizedBox(
              width: width,
              child: _AdminActionTile(
                title: 'Users',
                subtitle: 'Registered accounts',
                badge: '116',
                onTap: onGoToUsers,
              ),
            ),
            SizedBox(
              width: width,
              child: _AdminActionTile(
                title: 'Role Requests',
                subtitle: 'Pending approvals',
                badge: roleRequestCount.toString(),
                onTap: onGoToRoleRequests,
              ),
            ),
            SizedBox(
              width: width,
              child: _AdminActionTile(
                title: 'MSME Access',
                subtitle: 'Study and response view',
                onTap: onOpenMsmeWorkspace,
              ),
            ),
            SizedBox(
              width: width,
              child: _AdminActionTile(
                title: 'FIC Access',
                subtitle: 'Facility operations view',
                onTap: onOpenFicWorkspace,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AdminActionTile extends StatelessWidget {
  const _AdminActionTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TaraTheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFBFCFE),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE7EDF5)),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF111827),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              if (badge != null) ...<Widget>[
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: TaraTheme.primaryTint,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: TaraTheme.primaryDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 10),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminUserRow extends StatelessWidget {
  const _AdminUserRow({required this.user});

  final _AdminUserRecord user;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool stack = constraints.maxWidth < 720;
        final Widget identity = Row(
          children: <Widget>[
            Container(
              height: 36,
              width: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: TaraTheme.primaryTint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.initials,
                style: const TextStyle(
                  color: TaraTheme.primaryDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    user.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF111827),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

        final Widget right = Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            _AdminTag(label: user.role),
            _AdminTag(
              label: user.status,
              background: user.status == 'Active'
                  ? const Color(0xFFE7FAF3)
                  : TaraTheme.primaryTint,
              foreground: user.status == 'Active'
                  ? const Color(0xFF059669)
                  : TaraTheme.primaryDark,
            ),
            Text(
              user.note,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        );

        if (stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              identity,
              const SizedBox(height: 8),
              right,
            ],
          );
        }

        return Row(
          children: <Widget>[
            Expanded(child: identity),
            const SizedBox(width: 16),
            Flexible(child: right),
          ],
        );
      },
    );
  }
}

class _AdminProfileGrid extends StatelessWidget {
  const _AdminProfileGrid({required this.fields});

  final List<_AdminProfileField> fields;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool twoColumns = constraints.maxWidth >= 620;
        final double width = twoColumns
            ? (constraints.maxWidth - 14) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: fields
              .map(
                (_AdminProfileField field) => SizedBox(
                  width: width,
                  child: TextFormField(
                    initialValue: field.value.isEmpty ? '-' : field.value,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: field.label,
                      fillColor: const Color(0xFFF8FAFC),
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _AdminSidebarItem extends StatelessWidget {
  const _AdminSidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final Color foreground = selected
        ? TaraTheme.primaryDark
        : const Color(0xFF223B68);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFFF8F2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? const Color(0xFFFFE3CB)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                height: 28,
                width: 28,
                decoration: BoxDecoration(
                  color: selected ? TaraTheme.primaryTint : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: foreground),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: TaraTheme.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminTopPill extends StatelessWidget {
  const _AdminTopPill({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE7EDF5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: const Color(0xFF64748B)),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF334155),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminIconButton extends StatelessWidget {
  const _AdminIconButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      width: 38,
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7EDF5)),
      ),
      child: Icon(icon, size: 18, color: const Color(0xFF64748B)),
    );
  }
}

class _AdminTag extends StatelessWidget {
  const _AdminTag({
    required this.label,
    this.background = const Color(0xFFF1F5F9),
    this.foreground = const Color(0xFF334155),
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
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
        border: Border(top: BorderSide(color: Color(0xFFD7E0EC))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: <Widget>[
              _AdminNavItem(
                icon: Icons.grid_view_outlined,
                label: 'Dashboard',
                selected: currentView == _AdminView.dashboard,
                onTap: () => onChanged(_AdminView.dashboard),
              ),
              _AdminNavItem(
                icon: Icons.group_outlined,
                label: 'Users',
                selected: currentView == _AdminView.users,
                onTap: () => onChanged(_AdminView.users),
              ),
              _AdminNavItem(
                icon: Icons.verified_user_outlined,
                label: 'Requests',
                selected: currentView == _AdminView.roleRequests,
                onTap: () => onChanged(_AdminView.roleRequests),
              ),
              _AdminNavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                selected: currentView == _AdminView.profile,
                onTap: () => onChanged(_AdminView.profile),
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
              Icon(icon, color: color, size: 18),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminMetric {
  const _AdminMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.note,
    required this.tint,
    required this.iconColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final String note;
  final Color tint;
  final Color iconColor;
}

class _AdminUserRecord {
  const _AdminUserRecord({
    required this.initials,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.note,
  });

  final String initials;
  final String name;
  final String email;
  final String role;
  final String status;
  final String note;
}

class _AdminProfileField {
  const _AdminProfileField({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

const List<_RoleRequestDraft> _roleRequests = <_RoleRequestDraft>[];

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

String _adminDateLabel(DateTime date) {
  const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
