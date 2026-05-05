import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarasense_mobile/core/theme/tara_theme.dart';
import 'package:tarasense_mobile/features/auth/state/auth_providers.dart';

enum _ConsumerView {
  dashboard,
  profile,
  availableSurveys,
  completedSurveys,
  roleApplications,
}

class TesterWorkspacePage extends ConsumerStatefulWidget {
  const TesterWorkspacePage({super.key});

  @override
  ConsumerState<TesterWorkspacePage> createState() =>
      _TesterWorkspacePageState();
}

class _TesterWorkspacePageState extends ConsumerState<TesterWorkspacePage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _msmeReasonController = TextEditingController();
  final TextEditingController _ficReasonController = TextEditingController();

  _ConsumerView _currentView = _ConsumerView.dashboard;

  @override
  void dispose() {
    _searchController.dispose();
    _msmeReasonController.dispose();
    _ficReasonController.dispose();
    super.dispose();
  }

  void _submitRoleApplication(String role) {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$role application is ready to submit.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final session = authState.session;
    final bool useSidebar = MediaQuery.sizeOf(context).width >= 980;

    if (!useSidebar) {
      return _ConsumerMobilePortal(
        currentView: _currentView,
        userName: session?.user.name ?? 'Consumer',
        searchController: _searchController,
        onViewChanged: (view) => setState(() => _currentView = view),
        onLogout: authState.isBusy
            ? null
            : () => ref.read(authControllerProvider.notifier).logout(),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Row(
          children: <Widget>[
            _ConsumerSidebar(
              currentView: _currentView,
              onViewChanged: (view) => setState(() => _currentView = view),
              onLogout: authState.isBusy
                  ? null
                  : () => ref.read(authControllerProvider.notifier).logout(),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  _ConsumerTopBar(
                    searchController: _searchController,
                    showMobileBrand: !useSidebar,
                    authBusy: authState.isBusy,
                    onLogout: () =>
                        ref.read(authControllerProvider.notifier).logout(),
                  ),
                  Expanded(
                    child: _ConsumerContent(
                      currentView: _currentView,
                      userName: session?.user.name ?? 'Consumer',
                      email: session?.user.email ?? '',
                      organization: session?.user.organization,
                      msmeReasonController: _msmeReasonController,
                      ficReasonController: _ficReasonController,
                      onViewChanged: (view) =>
                          setState(() => _currentView = view),
                      onSubmitApplication: _submitRoleApplication,
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
}

class _ConsumerMobilePortal extends StatelessWidget {
  const _ConsumerMobilePortal({
    required this.currentView,
    required this.userName,
    required this.searchController,
    required this.onViewChanged,
    required this.onLogout,
  });

  final _ConsumerView currentView;
  final String userName;
  final TextEditingController searchController;
  final ValueChanged<_ConsumerView> onViewChanged;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final bool showDiscover =
        currentView == _ConsumerView.dashboard ||
        currentView == _ConsumerView.availableSurveys;

    return Scaffold(
      backgroundColor: TaraTheme.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          children: <Widget>[
            _ConsumerMobileHeader(userName: userName, onLogout: onLogout),
            const SizedBox(height: 14),
            _ConsumerMobileSearchField(controller: searchController),
            const SizedBox(height: 10),
            const _ConsumerMobileFilterRail(),
            const SizedBox(height: 16),
            if (showDiscover)
              _ConsumerDiscoverBody(
                onApply: () => onViewChanged(_ConsumerView.roleApplications),
              )
            else if (currentView == _ConsumerView.profile)
              _ConsumerMobileProfileCard(userName: userName)
            else if (currentView == _ConsumerView.completedSurveys)
              const _ConsumerMobileEmptyState(
                title: 'No completed sessions yet',
                message: 'Completed tastings will appear here after submission.',
              )
            else
              const _ConsumerMobileApplications(),
          ],
        ),
      ),
      bottomNavigationBar: _ConsumerMobileNavBar(
        currentView: currentView,
        onViewChanged: onViewChanged,
      ),
    );
  }
}

class _ConsumerMobileHeader extends StatelessWidget {
  const _ConsumerMobileHeader({required this.userName, required this.onLogout});

  final String userName;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.more_horiz_rounded,
                  size: 20,
                  color: TaraTheme.textPrimary.withValues(alpha: 0.62),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Good morning,',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: TaraTheme.textPrimary,
                  fontSize: 11,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userName.trim().isEmpty ? 'Consumer' : userName.trim(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          onPressed: onLogout,
          icon: Text(
            _consumerInitials(userName),
            style: const TextStyle(
              color: TaraTheme.primaryDark,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          style: IconButton.styleFrom(
            backgroundColor: TaraTheme.primaryTint,
            fixedSize: const Size(36, 36),
            shape: const CircleBorder(),
          ),
        ),
      ],
    );
  }
}

class _ConsumerMobileSearchField extends StatelessWidget {
  const _ConsumerMobileSearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: TextField(
        controller: controller,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
        decoration: InputDecoration(
          hintText: 'Search studies...',
          prefixIcon: const Icon(Icons.search_rounded, size: 15),
          filled: true,
          fillColor: const Color(0xFFF4F4F4),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: TaraTheme.primary),
          ),
        ),
      ),
    );
  }
}

class _ConsumerMobileFilterRail extends StatelessWidget {
  const _ConsumerMobileFilterRail();

  @override
  Widget build(BuildContext context) {
    const List<String> filters = <String>[
      'Discover',
      'My applications',
      'Completed',
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((String label) {
          final bool selected = label == 'Discover';
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: selected ? TaraTheme.primaryTint : TaraTheme.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selected ? TaraTheme.primary : TaraTheme.border,
                ),
              ),
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: selected ? TaraTheme.primaryDark : TaraTheme.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ConsumerDiscoverBody extends StatelessWidget {
  const _ConsumerDiscoverBody({required this.onApply});

  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _ConsumerMobileSectionTitle('OPEN STUDIES NEAR YOU'),
        const SizedBox(height: 7),
        _OpenStudyMobileCard(
          station: 'FIC: NCR Station 2 - In-lab',
          slots: '30 slots left',
          title: 'Dried Mango Texture Evaluation',
          details: '45 min - PHP150 incentive',
          tags: const <String>['JAR Scale', 'Texture'],
          dark: false,
          onApply: onApply,
        ),
        const SizedBox(height: 10),
        _OpenStudyMobileCard(
          station: 'FIC: Davao Station - In-lab',
          slots: '12 slots left',
          title: 'Cacao Dark Chocolate Study',
          details: '60 min - PHP200 incentive',
          tags: const <String>['Bitterness', 'Aroma'],
          dark: true,
          onApply: onApply,
        ),
        const SizedBox(height: 14),
        _ConsumerMobileSectionTitle('MY APPLICATIONS'),
        const SizedBox(height: 7),
        const _ConsumerMobileApplications(),
      ],
    );
  }
}

class _OpenStudyMobileCard extends StatelessWidget {
  const _OpenStudyMobileCard({
    required this.station,
    required this.slots,
    required this.title,
    required this.details,
    required this.tags,
    required this.dark,
    required this.onApply,
  });

  final String station;
  final String slots;
  final String title;
  final String details;
  final List<String> tags;
  final bool dark;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final Color bandColor = dark ? const Color(0xFF111111) : TaraTheme.primary;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: bandColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    station,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    slots,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 13,
              height: 1.15,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            details,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: TaraTheme.textPrimary,
              fontSize: 10,
              height: 1,
            ),
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: tags
                .map((String tag) => _ConsumerMiniTag(label: tag))
                .toList(),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 34,
            child: FilledButton(
              onPressed: onApply,
              style: FilledButton.styleFrom(
                backgroundColor: TaraTheme.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 34),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              child: const Text('Apply now'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsumerMobileApplications extends StatelessWidget {
  const _ConsumerMobileApplications();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TaraTheme.border),
      ),
      child: const Column(
        children: <Widget>[
          _ApplicationRow(
            icon: Icons.check_box_outline_blank_rounded,
            title: 'Coconut Vinegar Taste',
            subtitle: 'May 12 - 10:00 AM',
            status: 'Confirmed',
            confirmed: true,
          ),
          Divider(height: 18),
          _ApplicationRow(
            icon: Icons.schedule_rounded,
            title: 'Bagoong Flavor Panel',
            subtitle: 'Awaiting confirmation',
            status: 'Pending',
            confirmed: false,
          ),
        ],
      ),
    );
  }
}

class _ApplicationRow extends StatelessWidget {
  const _ApplicationRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.confirmed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final bool confirmed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          height: 28,
          width: 28,
          decoration: BoxDecoration(
            color: confirmed ? TaraTheme.primaryTint : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: confirmed ? TaraTheme.primaryDark : TaraTheme.textSecondary,
            size: 14,
          ),
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 11,
                  height: 1.1,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: TaraTheme.textPrimary.withValues(alpha: 0.72),
                  fontSize: 9,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _ConsumerStatusPill(
          label: status,
          confirmed: confirmed,
        ),
      ],
    );
  }
}

class _ConsumerStatusPill extends StatelessWidget {
  const _ConsumerStatusPill({required this.label, required this.confirmed});

  final String label;
  final bool confirmed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: confirmed ? const Color(0xFFEAF8D9) : TaraTheme.primaryTint,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: confirmed ? TaraTheme.mintText : TaraTheme.primaryDark,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

class _ConsumerMiniTag extends StatelessWidget {
  const _ConsumerMiniTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: TaraTheme.textPrimary,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

class _ConsumerMobileSectionTitle extends StatelessWidget {
  const _ConsumerMobileSectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: TaraTheme.textPrimary,
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.7,
        height: 1,
      ),
    );
  }
}

class _ConsumerMobileProfileCard extends StatelessWidget {
  const _ConsumerMobileProfileCard({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: TaraTheme.primaryTint,
            child: Text(
              _consumerInitials(userName),
              style: const TextStyle(
                color: TaraTheme.primaryDark,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              userName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsumerMobileEmptyState extends StatelessWidget {
  const _ConsumerMobileEmptyState({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(message, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ConsumerMobileNavBar extends StatelessWidget {
  const _ConsumerMobileNavBar({
    required this.currentView,
    required this.onViewChanged,
  });

  final _ConsumerView currentView;
  final ValueChanged<_ConsumerView> onViewChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: const BoxDecoration(
        color: TaraTheme.surface,
        border: Border(top: BorderSide(color: TaraTheme.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: <Widget>[
            Expanded(
              child: _ConsumerMobileNavItem(
                icon: Icons.search_rounded,
                label: 'Discover',
                selected:
                    currentView == _ConsumerView.dashboard ||
                    currentView == _ConsumerView.availableSurveys,
                onTap: () => onViewChanged(_ConsumerView.dashboard),
              ),
            ),
            Expanded(
              child: _ConsumerMobileNavItem(
                icon: Icons.assignment_outlined,
                label: 'Applied',
                selected: currentView == _ConsumerView.roleApplications,
                onTap: () => onViewChanged(_ConsumerView.roleApplications),
              ),
            ),
            Expanded(
              child: _ConsumerMobileNavItem(
                icon: Icons.view_agenda_outlined,
                label: 'Sessions',
                selected: currentView == _ConsumerView.completedSurveys,
                onTap: () => onViewChanged(_ConsumerView.completedSurveys),
              ),
            ),
            Expanded(
              child: _ConsumerMobileNavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                selected: currentView == _ConsumerView.profile,
                onTap: () => onViewChanged(_ConsumerView.profile),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsumerMobileNavItem extends StatelessWidget {
  const _ConsumerMobileNavItem({
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
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, color: color, size: 17),
            const SizedBox(height: 3),
            Text(
              label,
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
    );
  }
}

class _ConsumerSidebar extends StatelessWidget {
  const _ConsumerSidebar({
    required this.currentView,
    required this.onViewChanged,
    required this.onLogout,
  });

  final _ConsumerView currentView;
  final ValueChanged<_ConsumerView> onViewChanged;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 288,
      decoration: const BoxDecoration(
        color: TaraTheme.surface,
        border: Border(right: BorderSide(color: TaraTheme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.fromLTRB(22, 22, 22, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _ConsumerWordmark(textSize: 26),
                SizedBox(height: 10),
                Text(
                  'CONSUMER WORKSPACE',
                  style: TextStyle(
                    color: Color(0xFF52657D),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 18, 12),
            child: Text(
              'NAVIGATION',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF8A98AC),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _ConsumerNavButton(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            selected: currentView == _ConsumerView.dashboard,
            onTap: () => onViewChanged(_ConsumerView.dashboard),
          ),
          _ConsumerNavButton(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            selected: currentView == _ConsumerView.profile,
            onTap: () => onViewChanged(_ConsumerView.profile),
          ),
          _ConsumerNavButton(
            icon: Icons.explore_outlined,
            label: 'Available Surveys',
            badge: '3',
            selected: currentView == _ConsumerView.availableSurveys,
            onTap: () => onViewChanged(_ConsumerView.availableSurveys),
          ),
          _ConsumerNavButton(
            icon: Icons.assignment_turned_in_outlined,
            label: 'Completed Surveys',
            badge: '0',
            selected: currentView == _ConsumerView.completedSurveys,
            onTap: () => onViewChanged(_ConsumerView.completedSurveys),
          ),
          _ConsumerNavButton(
            icon: Icons.verified_user_outlined,
            label: 'Role Applications',
            badge: '0',
            selected: currentView == _ConsumerView.roleApplications,
            onTap: () => onViewChanged(_ConsumerView.roleApplications),
          ),
          const Spacer(),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(22),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onLogout,
                child: const Text('Logout'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsumerTopBar extends StatelessWidget {
  const _ConsumerTopBar({
    required this.searchController,
    required this.showMobileBrand,
    required this.authBusy,
    required this.onLogout,
  });

  final TextEditingController searchController;
  final bool showMobileBrand;
  final bool authBusy;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    if (showMobileBrand) {
      return Container(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
        decoration: const BoxDecoration(
          color: TaraTheme.surface,
          border: Border(bottom: BorderSide(color: TaraTheme.border)),
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                const _ConsumerWordmark(textSize: 24),
                const Spacer(),
                IconButton(
                  tooltip: 'Log out',
                  onPressed: authBusy ? null : onLogout,
                  icon: const Icon(Icons.logout_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ConsumerSearchField(controller: searchController),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                const _TopChip(label: 'Consumer panel'),
                const Spacer(),
                _DateChip(date: DateTime.now()),
              ],
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxWidth < 760;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 18 : 28,
            vertical: 12,
          ),
          decoration: const BoxDecoration(
            color: TaraTheme.surface,
            border: Border(bottom: BorderSide(color: TaraTheme.border)),
          ),
          child: compact
              ? Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.keyboard_tab_outlined),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ConsumerSearchField(
                            controller: searchController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        const _TopChip(label: 'Consumer panel'),
                        const Spacer(),
                        _DateChip(date: DateTime.now()),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.keyboard_tab_outlined),
                      style: IconButton.styleFrom(
                        backgroundColor: TaraTheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: TaraTheme.border),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: _ConsumerSearchField(
                          controller: searchController,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const _TopChip(label: 'Consumer panel'),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_none_rounded),
                      style: IconButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                          side: const BorderSide(color: TaraTheme.border),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _DateChip(date: DateTime.now()),
                  ],
                ),
        );
      },
    );
  }
}

class _ConsumerContent extends StatelessWidget {
  const _ConsumerContent({
    required this.currentView,
    required this.userName,
    required this.email,
    required this.organization,
    required this.msmeReasonController,
    required this.ficReasonController,
    required this.onViewChanged,
    required this.onSubmitApplication,
  });

  final _ConsumerView currentView;
  final String userName;
  final String email;
  final String? organization;
  final TextEditingController msmeReasonController;
  final TextEditingController ficReasonController;
  final ValueChanged<_ConsumerView> onViewChanged;
  final ValueChanged<String> onSubmitApplication;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        MediaQuery.sizeOf(context).width >= 980 ? 32 : 16,
        26,
        MediaQuery.sizeOf(context).width >= 980 ? 32 : 16,
        28,
      ),
      children: <Widget>[
        const _ConsumerPageHeader(),
        const SizedBox(height: 20),
        const _ConsumerStatsGrid(),
        const SizedBox(height: 22),
        const Divider(height: 1),
        const SizedBox(height: 24),
        _buildCurrentView(context),
      ],
    );
  }

  Widget _buildCurrentView(BuildContext context) {
    switch (currentView) {
      case _ConsumerView.dashboard:
        return _DashboardPanel(onViewChanged: onViewChanged);
      case _ConsumerView.profile:
        return _ProfilePanel(
          userName: userName,
          email: email,
          organization: organization,
        );
      case _ConsumerView.availableSurveys:
        return const _AvailableSurveysPanel();
      case _ConsumerView.completedSurveys:
        return const _CompletedSurveysPanel();
      case _ConsumerView.roleApplications:
        return _RoleApplicationsPanel(
          msmeReasonController: msmeReasonController,
          ficReasonController: ficReasonController,
          onSubmitApplication: onSubmitApplication,
        );
    }
  }
}

class _ConsumerPageHeader extends StatelessWidget {
  const _ConsumerPageHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'CONSUMER WORKSPACE',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(0xFF52657D),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Consumer Dashboard',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: const Color(0xFF061A3A),
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Track study invitations, apply for role upgrades, and manage your participation flow.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF52657D),
          ),
        ),
      ],
    );
  }
}

class _ConsumerStatsGrid extends StatelessWidget {
  const _ConsumerStatsGrid();

  static const List<_ConsumerStat> _stats = <_ConsumerStat>[
    _ConsumerStat(
      icon: Icons.explore_outlined,
      value: '3',
      label: 'STUDY NOTIFICATIONS',
      subtitle: 'Active studies you can join',
      tint: Color(0xFFEAF2FF),
      iconColor: Color(0xFF155BFF),
    ),
    _ConsumerStat(
      icon: Icons.verified_user_outlined,
      value: '0',
      label: 'PENDING APPLICATIONS',
      subtitle: 'Awaiting admin review',
      tint: Color(0xFFFFF7E6),
      iconColor: TaraTheme.primaryDark,
    ),
    _ConsumerStat(
      icon: Icons.assignment_turned_in_outlined,
      value: '0',
      label: 'APPROVED UPGRADES',
      subtitle: 'Role requests approved',
      tint: Color(0xFFE7FAF3),
      iconColor: Color(0xFF07936E),
    ),
    _ConsumerStat(
      icon: Icons.description_outlined,
      value: '0',
      label: 'COMPLETED SURVEYS',
      subtitle: 'Surveys you already submitted',
      tint: Color(0xFFF0F4F8),
      iconColor: Color(0xFF344B66),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool oneColumn = constraints.maxWidth < 620;
        final bool twoColumns = constraints.maxWidth < 1040;
        final int columns = oneColumn
            ? 1
            : twoColumns
            ? 2
            : 4;
        final double cardWidth = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - (16 * (columns - 1))) / columns;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: _stats
              .map((stat) => _ConsumerStatCard(stat: stat, width: cardWidth))
              .toList(),
        );
      },
    );
  }
}

class _DashboardPanel extends StatelessWidget {
  const _DashboardPanel({required this.onViewChanged});

  final ValueChanged<_ConsumerView> onViewChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _SectionPanel(
          title: 'System Messages',
          trailing: const Icon(Icons.keyboard_arrow_down_rounded),
          child: Text(
            'No urgent system messages. Available studies and role application updates will appear here.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF52657D),
            ),
          ),
        ),
        const SizedBox(height: 18),
        _SectionPanel(
          title: 'Quick Actions',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              _QuickActionButton(
                icon: Icons.explore_outlined,
                label: 'View Available Surveys',
                onTap: () => onViewChanged(_ConsumerView.availableSurveys),
              ),
              _QuickActionButton(
                icon: Icons.verified_user_outlined,
                label: 'Apply for Access Upgrade',
                onTap: () => onViewChanged(_ConsumerView.roleApplications),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AvailableSurveysPanel extends StatelessWidget {
  const _AvailableSurveysPanel();

  @override
  Widget build(BuildContext context) {
    return _SectionPanel(
      title: 'Available Surveys',
      badge: '3',
      trailing: const Icon(Icons.keyboard_arrow_up_rounded),
      child: Column(
        children: _availableSurveys
            .map(
              (survey) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _SurveyCard(survey: survey),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _CompletedSurveysPanel extends StatelessWidget {
  const _CompletedSurveysPanel();

  @override
  Widget build(BuildContext context) {
    return _SectionPanel(
      title: 'Completed Surveys',
      badge: '0',
      trailing: const Icon(Icons.keyboard_arrow_up_rounded),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: TaraTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: TaraTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'No completed surveys yet.',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Completed studies will appear here after submission.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF6B4A35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleApplicationsPanel extends StatelessWidget {
  const _RoleApplicationsPanel({
    required this.msmeReasonController,
    required this.ficReasonController,
    required this.onSubmitApplication,
  });

  final TextEditingController msmeReasonController;
  final TextEditingController ficReasonController;
  final ValueChanged<String> onSubmitApplication;

  @override
  Widget build(BuildContext context) {
    return _SectionPanel(
      title: 'Apply for Access Upgrade',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'All accounts start as Consumer. Submit an application and wait for admin approval.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF6B4A35),
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isNarrow = constraints.maxWidth < 760;
              final double width = isNarrow
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 16) / 2;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: <Widget>[
                  _RoleApplicationCard(
                    width: width,
                    title: 'Apply for MSME User',
                    hint: 'Reason for MSME access (optional)',
                    controller: msmeReasonController,
                    buttonLabel: 'Submit MSME Application',
                    onSubmit: () => onSubmitApplication('MSME'),
                  ),
                  _RoleApplicationCard(
                    width: width,
                    title: 'Apply for FIC User',
                    hint: 'Reason for FIC access (optional)',
                    controller: ficReasonController,
                    buttonLabel: 'Submit FIC Application',
                    onSubmit: () => onSubmitApplication('FIC'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProfilePanel extends StatelessWidget {
  const _ProfilePanel({
    required this.userName,
    required this.email,
    required this.organization,
  });

  final String userName;
  final String email;
  final String? organization;

  @override
  Widget build(BuildContext context) {
    return _SectionPanel(
      title: 'Profile',
      child: Column(
        children: <Widget>[
          _ProfileRow(label: 'Name', value: userName),
          _ProfileRow(label: 'Email', value: email.isEmpty ? '-' : email),
          _ProfileRow(
            label: 'Organization',
            value: organization?.trim().isEmpty == false
                ? organization!.trim()
                : '-',
          ),
          const _ProfileRow(label: 'Current role', value: 'Consumer panel'),
        ],
      ),
    );
  }
}

class _ConsumerNavButton extends StatelessWidget {
  const _ConsumerNavButton({
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
        : const Color(0xFF14243D);
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 18, 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? TaraTheme.primaryTint : TaraTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TaraTheme.border),
          ),
          child: Row(
            children: <Widget>[
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: selected ? TaraTheme.primarySoft : TaraTheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: TaraTheme.border),
                ),
                child: Icon(icon, size: 20, color: foreground),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (badge != null) _CountBadge(value: badge!),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConsumerSearchField extends StatelessWidget {
  const _ConsumerSearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search studies and applications',
        prefixIcon: const Icon(Icons.search_rounded),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: TaraTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: TaraTheme.border),
        ),
      ),
    );
  }
}

class _ConsumerStatCard extends StatelessWidget {
  const _ConsumerStatCard({required this.stat, required this.width});

  final _ConsumerStat stat;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TaraTheme.border),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x100F172A),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: stat.tint,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: TaraTheme.border),
            ),
            child: Icon(stat.icon, color: stat.iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  stat.value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF061A3A),
                    letterSpacing: 0,
                  ),
                ),
                Text(
                  stat.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF52657D),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  stat.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF52657D),
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

class _SectionPanel extends StatelessWidget {
  const _SectionPanel({
    required this.title,
    required this.child,
    this.badge,
    this.trailing,
  });

  final String title;
  final String? badge;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: TaraTheme.border),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF061A3A),
                    letterSpacing: 0,
                  ),
                ),
                if (badge != null) ...<Widget>[
                  const SizedBox(width: 10),
                  _SoftBadge(value: badge!),
                ],
                const Spacer(),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(padding: const EdgeInsets.all(20), child: child),
        ],
      ),
    );
  }
}

class _SurveyCard extends StatelessWidget {
  const _SurveyCard({required this.survey});

  final _ConsumerSurvey survey;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LayoutBuilder(
            builder: (context, constraints) {
              final bool stackHeader = constraints.maxWidth < 560;
              final Widget titleBlock = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    survey.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF0A101C),
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    survey.owner,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF6B4A35),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
              final Widget action = FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  minimumSize: const Size(124, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('View Study'),
              );

              if (stackHeader) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    titleBlock,
                    const SizedBox(height: 14),
                    SizedBox(width: double.infinity, child: action),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: titleBlock),
                  const SizedBox(width: 16),
                  action,
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              _TagPill(label: survey.category),
              _TagPill(label: survey.stage),
              _TagPill(label: survey.status, success: true),
            ],
          ),
          const SizedBox(height: 16),
          if (survey.showSessionPicker) _SessionPicker(survey: survey),
          if (!survey.showSessionPicker)
            FilledButton(
              onPressed: () {},
              child: const Text('Participate'),
            ),
        ],
      ),
    );
  }
}

class _SessionPicker extends StatelessWidget {
  const _SessionPicker({required this.survey});

  final _ConsumerSurvey survey;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TaraTheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: TaraTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Choose a Testing Session',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF0A101C),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Timezone: Asia/Manila. Full sessions are automatically disabled.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6B4A35),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Session slot',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6B4A35),
                ),
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  final bool stackControls = constraints.maxWidth < 520;
                  final Widget dropdown = DropdownButtonFormField<String>(
                    initialValue: null,
                    isExpanded: true,
                    hint: const Text(
                      'Select a session',
                      overflow: TextOverflow.ellipsis,
                    ),
                    items: <DropdownMenuItem<String>>[
                      DropdownMenuItem<String>(
                        value: survey.session,
                        child: Text(
                          survey.session,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    onChanged: (_) {},
                  );
                  final Widget action = FilledButton(
                    onPressed: () {},
                    child: const Text('Participate'),
                  );

                  if (stackControls) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        dropdown,
                        const SizedBox(height: 10),
                        action,
                      ],
                    );
                  }

                  return Row(
                    children: <Widget>[
                      Expanded(child: dropdown),
                      const SizedBox(width: 10),
                      action,
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TaraTheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: TaraTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'SESSION AVAILABILITY',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF8A674C),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: TaraTheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: TaraTheme.border),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final Widget sessionText = Text(
                      survey.session,
                      maxLines: constraints.maxWidth < 520 ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6B4A35),
                      ),
                    );
                    final Widget availability = Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: TaraTheme.mint,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${survey.selected}/${survey.capacity} selected',
                        style: const TextStyle(
                          color: TaraTheme.mintText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    );

                    if (constraints.maxWidth < 520) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          sessionText,
                          const SizedBox(height: 10),
                          availability,
                        ],
                      );
                    }

                    return Row(
                      children: <Widget>[
                        Expanded(child: sessionText),
                        const SizedBox(width: 12),
                        availability,
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoleApplicationCard extends StatelessWidget {
  const _RoleApplicationCard({
    required this.width,
    required this.title,
    required this.hint,
    required this.controller,
    required this.buttonLabel,
    required this.onSubmit,
  });

  final double width;
  final String title;
  final String hint;
  final TextEditingController controller;
  final String buttonLabel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFF0A101C),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            minLines: 3,
            maxLines: 4,
            decoration: InputDecoration(hintText: hint),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onSubmit,
              child: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 236,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF52657D),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF0A101C),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsumerWordmark extends StatelessWidget {
  const _ConsumerWordmark({required this.textSize});

  final double textSize;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = TextStyle(
      fontSize: textSize,
      height: 1,
      letterSpacing: 0,
      fontWeight: FontWeight.w900,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('TARA', style: style.copyWith(color: TaraTheme.dostBlue)),
        Text('sense', style: style.copyWith(color: TaraTheme.primary)),
      ],
    );
  }
}

class _TopChip extends StatelessWidget {
  const _TopChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: const Color(0xFF14243D),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.calendar_month_outlined,
            size: 16,
            color: Color(0xFF64748B),
          ),
          const SizedBox(width: 6),
          Text(
            _formatDate(date),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF52657D),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.label, this.success = false});

  final String label;
  final bool success;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: success ? TaraTheme.mint : const Color(0xFFF4E9DD),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: success ? TaraTheme.mintText : const Color(0xFF6B4A35),
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: TaraTheme.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SoftBadge extends StatelessWidget {
  const _SoftBadge({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: TaraTheme.primaryTint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: TaraTheme.primary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ConsumerStat {
  const _ConsumerStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.subtitle,
    required this.tint,
    required this.iconColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final String subtitle;
  final Color tint;
  final Color iconColor;
}

class _ConsumerSurvey {
  const _ConsumerSurvey({
    required this.title,
    required this.owner,
    required this.category,
    required this.stage,
    required this.status,
    required this.session,
    required this.selected,
    required this.capacity,
    this.showSessionPicker = false,
  });

  final String title;
  final String owner;
  final String category;
  final String stage;
  final String status;
  final String session;
  final int selected;
  final int capacity;
  final bool showSessionPicker;
}

const List<_ConsumerSurvey> _availableSurveys = <_ConsumerSurvey>[
  _ConsumerSurvey(
    title: 'InnovBars - Consumer Test',
    owner: 'InnovBars',
    category: 'BAKERY',
    stage: 'PROTOTYPE_CHECK',
    status: 'RECRUITING',
    session: 'Tue, Apr 21 | Auto timestamp session | 1:20 PM - 11:59 PM',
    selected: 0,
    capacity: 30,
    showSessionPicker: true,
  ),
  _ConsumerSurvey(
    title: 'Product Intent Study',
    owner: 'PRODUCT INTENT',
    category: 'FUNCTIONAL_FOOD',
    stage: 'MARKET_READINESS',
    status: 'RECRUITING',
    session: 'Wed, Apr 22 | Product feedback session | 9:00 AM - 4:00 PM',
    selected: 8,
    capacity: 30,
  ),
  _ConsumerSurvey(
    title: 'Snack Preference Survey',
    owner: 'Caraga Food Innovation Lab',
    category: 'SNACKS',
    stage: 'SENSORY_CHECK',
    status: 'RECRUITING',
    session: 'Thu, Apr 23 | Preference test | 10:00 AM - 3:00 PM',
    selected: 12,
    capacity: 30,
  ),
];

String _consumerInitials(String value) {
  final List<String> parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((String part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) {
    return 'AS';
  }
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
      .toUpperCase();
}

String _formatDate(DateTime date) {
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
