part of 'tester_workspace_page.dart';

class _ConsumerMobilePortal extends StatelessWidget {
  const _ConsumerMobilePortal({
    required this.currentView,
    required this.userName,
    required this.searchController,
    required this.onViewChanged,
    required this.authBusy,
    required this.onLogout,
  });

  final _ConsumerView currentView;
  final String userName;
  final TextEditingController searchController;
  final ValueChanged<_ConsumerView> onViewChanged;
  final bool authBusy;
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
            _ConsumerMobileHeader(userName: userName),
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
            else if (currentView == _ConsumerView.settings)
              _ConsumerMobileSettingsCard(
                userName: userName,
                authBusy: authBusy,
                onLogout: onLogout,
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
  const _ConsumerMobileHeader({required this.userName});

  final String userName;

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
        CircleAvatar(
          backgroundColor: TaraTheme.primaryTint,
          child: Text(
            _consumerInitials(userName),
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
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  selected: currentView == _ConsumerView.settings,
                  onTap: () => onViewChanged(_ConsumerView.settings),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConsumerMobileSettingsCard extends StatelessWidget {
  const _ConsumerMobileSettingsCard({
    required this.userName,
    required this.authBusy,
    required this.onLogout,
  });

  final String userName;
  final bool authBusy;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
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
          const SizedBox(height: 14),
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
    );
  }
}

