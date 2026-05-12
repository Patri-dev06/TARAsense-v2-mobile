part of 'tester_workspace_page.dart';

class _ConsumerMobilePortal extends StatelessWidget {
  const _ConsumerMobilePortal({
    required this.currentView,
    required this.userName,
    required this.email,
    required this.organization,
    required this.searchController,
    required this.studiesAsync,
    required this.completedStudiesAsync,
    required this.onViewChanged,
    required this.authBusy,
    required this.onLogout,
  });

  final _ConsumerView currentView;
  final String userName;
  final String email;
  final String? organization;
  final TextEditingController searchController;
  final AsyncValue<List<ConsumerStudy>> studiesAsync;
  final AsyncValue<List<ConsumerStudy>> completedStudiesAsync;
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
            if (currentView == _ConsumerView.settings) ...<Widget>[
              const _ConsumerMobileBrandHeader(),
              const SizedBox(height: 14),
            ] else ...<Widget>[
              _ConsumerMobileHeader(userName: userName),
              const SizedBox(height: 14),
            ],
            if (currentView != _ConsumerView.settings) ...<Widget>[
              _ConsumerMobileFilterRail(
                currentView: currentView,
                onViewChanged: onViewChanged,
              ),
              const SizedBox(height: 16),
            ],
            if (showDiscover)
              _ConsumerDiscoverBody(
                searchController: searchController,
                studiesAsync: studiesAsync,
              )
            else if (currentView == _ConsumerView.profile)
              _ConsumerMobileProfileCard(userName: userName)
            else if (currentView == _ConsumerView.completedSurveys)
              _ConsumerCompletedBody(
                completedStudiesAsync: completedStudiesAsync,
                searchQuery: '',
              )
            else if (currentView == _ConsumerView.settings)
              _ConsumerMobileSettingsCard(
                userName: userName,
                email: email,
                organization: organization,
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
    final String displayName = userName.trim().isEmpty
        ? 'Consumer'
        : userName.trim();
    final String firstName = displayName.split(' ').first;
    final String greeting = _timeGreeting(DateTime.now().hour);

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
            color: Color(0x18F97316),
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
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x44FFFFFF)),
            ),
            child: Center(
              child: Text(
                _consumerInitials(displayName),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  height: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '$greeting · Consumer',
                  style: const TextStyle(
                    color: Color(0xCCFFFFFF),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  firstName,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsumerMobileBrandHeader extends StatelessWidget {
  const _ConsumerMobileBrandHeader();

  @override
  Widget build(BuildContext context) {
    return const _ConsumerWordmark(textSize: 24);
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

class _ConsumerDiscoverBody extends StatelessWidget {
  const _ConsumerDiscoverBody({
    required this.searchController,
    required this.studiesAsync,
  });

  final TextEditingController searchController;
  final AsyncValue<List<ConsumerStudy>> studiesAsync;

  @override
  Widget build(BuildContext context) {
    final int? count = studiesAsync.maybeWhen(
      data: (s) => s.length,
      orElse: () => null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _ConsumerMobileSearchField(controller: searchController),
        const SizedBox(height: 14),
        Row(
          children: <Widget>[
            _ConsumerMobileSectionTitle('OPEN STUDIES'),
            if (count != null && count > 0) ...<Widget>[
              const SizedBox(width: 8),
              _ConsumerStudyCountBadge(count: count),
            ],
          ],
        ),
        const SizedBox(height: 8),
        _ConsumerStudyList(
          studiesAsync: studiesAsync,
          searchQuery: searchController.text,
          compact: true,
        ),
      ],
    );
  }
}

class _ConsumerStudyCountBadge extends StatelessWidget {
  const _ConsumerStudyCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: TaraTheme.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

class _ConsumerCompletedBody extends StatelessWidget {
  const _ConsumerCompletedBody({
    required this.completedStudiesAsync,
    required this.searchQuery,
  });

  final AsyncValue<List<ConsumerStudy>> completedStudiesAsync;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _ConsumerMobileSectionTitle('COMPLETED SURVEYS'),
        const SizedBox(height: 8),
        _CompletedStudyList(
          studiesAsync: completedStudiesAsync,
          searchQuery: searchQuery,
          compact: true,
        ),
      ],
    );
  }
}

class _ConsumerMobileFilterRail extends StatelessWidget {
  const _ConsumerMobileFilterRail({
    required this.currentView,
    required this.onViewChanged,
  });

  final _ConsumerView currentView;
  final ValueChanged<_ConsumerView> onViewChanged;

  @override
  Widget build(BuildContext context) {
    const List<_ConsumerFilterItem> filters = <_ConsumerFilterItem>[
      _ConsumerFilterItem(label: 'Discover', view: _ConsumerView.dashboard),
      _ConsumerFilterItem(
        label: 'My applications',
        view: _ConsumerView.roleApplications,
      ),
      _ConsumerFilterItem(
        label: 'Completed',
        view: _ConsumerView.completedSurveys,
      ),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((_ConsumerFilterItem filter) {
          final bool selected =
              currentView == filter.view ||
              (filter.view == _ConsumerView.dashboard &&
                  currentView == _ConsumerView.availableSurveys);
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () => onViewChanged(filter.view),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: selected ? TaraTheme.primaryTint : TaraTheme.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: selected ? TaraTheme.primary : TaraTheme.border,
                  ),
                ),
                child: Text(
                  filter.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: selected
                        ? TaraTheme.primaryDark
                        : TaraTheme.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ConsumerMobileApplications extends StatelessWidget {
  const _ConsumerMobileApplications();

  @override
  Widget build(BuildContext context) {
    final int confirmedCount = _consumerApplications
        .where((_ConsumerApplication item) => item.isConfirmed)
        .length;
    final int pendingCount = _consumerApplications
        .where((_ConsumerApplication item) => item.isPending)
        .length;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7E0D7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                'Active applications',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: const Color(0xFF111827),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              const Spacer(),
              _ApplicationCountPill(
                value: _consumerApplications.length.toString(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _ApplicationSummaryChip(
                label: 'Confirmed',
                value: confirmedCount.toString(),
                tint: const Color(0xFFEAF8D9),
                textColor: TaraTheme.mintText,
              ),
              _ApplicationSummaryChip(
                label: 'Pending',
                value: pendingCount.toString(),
                tint: TaraTheme.primaryTint,
                textColor: TaraTheme.primaryDark,
              ),
              _ApplicationSummaryChip(
                label: 'Reviewing',
                value:
                    (_consumerApplications.length -
                            confirmedCount -
                            pendingCount)
                        .toString(),
                tint: const Color(0xFFF4F4F5),
                textColor: TaraTheme.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_consumerApplications.isEmpty)
            Text(
              'No active applications to show.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: TaraTheme.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            ..._consumerApplications.asMap().entries.map((entry) {
              final bool isLast = entry.key == _consumerApplications.length - 1;
              return Column(
                children: <Widget>[
                  _ApplicationListItem(application: entry.value),
                  if (!isLast)
                    const Divider(
                      height: 18,
                      thickness: 1,
                      color: Color(0xFFF0E8DF),
                    ),
                ],
              );
            }),
        ],
      ),
    );
  }
}

class _ApplicationSummaryChip extends StatelessWidget {
  const _ApplicationSummaryChip({
    required this.label,
    required this.value,
    required this.tint,
    required this.textColor,
  });

  final String label;
  final String value;
  final Color tint;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w900,
              fontSize: 11,
              height: 1,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplicationCountPill extends StatelessWidget {
  const _ApplicationCountPill({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: TaraTheme.primaryTint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: TaraTheme.primaryDark,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

class _ApplicationListItem extends StatelessWidget {
  const _ApplicationListItem({required this.application});

  final _ConsumerApplication application;

  @override
  Widget build(BuildContext context) {
    final bool confirmed = application.isConfirmed;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: confirmed
                  ? const Color(0xFFEAF8D9)
                  : TaraTheme.primaryTint,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              confirmed ? Icons.check_rounded : Icons.schedule_rounded,
              color: confirmed ? TaraTheme.mintText : TaraTheme.primaryDark,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  application.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF111827),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${application.owner}  •  ${application.schedule}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6B7280),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  application.note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF667085),
                    fontSize: 10,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _ConsumerStatusPill(label: application.status, confirmed: confirmed),
        ],
      ),
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
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: confirmed ? const Color(0xFFD9F0BE) : const Color(0xFFFFD8B5),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: confirmed ? TaraTheme.mintText : TaraTheme.primaryDark,
          fontSize: 10,
          fontWeight: FontWeight.w900,
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
                  icon: Icons.person_outline_rounded,
                  label: 'Profile',
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
    required this.email,
    required this.organization,
    required this.authBusy,
    required this.onLogout,
  });

  final String userName;
  final String email;
  final String? organization;
  final bool authBusy;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final String initials = _consumerInitials(userName);
    final String displayName =
        userName.trim().isEmpty ? 'Consumer' : userName.trim();
    final String org = organization?.trim() ?? '';

    return SizedBox(
      height: MediaQuery.sizeOf(context).height - 190,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Gradient hero header
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Color(0xFFFB923C), TaraTheme.primaryDark],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Row(
                children: <Widget>[
                  Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      color: const Color(0x33FFFFFF),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0x50FFFFFF),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                          height: 1,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          displayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            height: 1.15,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x33FFFFFF),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: const Color(0x40FFFFFF),
                            ),
                          ),
                          child: const Text(
                            'Consumer',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              height: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Info tiles card
          Container(
            decoration: BoxDecoration(
              color: TaraTheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x0A0F172A),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                _ProfileInfoTile(
                  icon: Icons.person_outline_rounded,
                  label: 'Name',
                  value: displayName,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                _ProfileInfoTile(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: email.trim().isEmpty ? '-' : email,
                ),
                const Divider(height: 1, indent: 56),
                _ProfileInfoTile(
                  icon: Icons.verified_user_outlined,
                  label: 'Role',
                  value: 'Consumer',
                  borderRadius: org.isEmpty
                      ? const BorderRadius.vertical(
                          bottom: Radius.circular(16),
                        )
                      : null,
                ),
                if (org.isNotEmpty) ...<Widget>[
                  const Divider(height: 1, indent: 56),
                  _ProfileInfoTile(
                    icon: Icons.business_outlined,
                    label: 'Organization',
                    value: org,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Spacer(),
          // Logout row
          Container(
            decoration: BoxDecoration(
              color: TaraTheme.rose,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFDA4AF)),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: authBusy ? null : onLogout,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        height: 38,
                        width: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFECDD3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.logout_rounded,
                          color: TaraTheme.roseText,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Log out',
                              style: Theme.of(
                                context,
                              ).textTheme.titleSmall?.copyWith(
                                color: TaraTheme.roseText,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Sign out of your account',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: TaraTheme.roseText,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (authBusy)
                        const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: TaraTheme.roseText,
                          ),
                        )
                      else
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: TaraTheme.roseText,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  const _ProfileInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.borderRadius,
  });

  final IconData icon;
  final String label;
  final String value;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: borderRadius,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: <Widget>[
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: TaraTheme.primaryTint,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: const Color(0xFFFFD8B5)),
            ),
            child: Icon(icon, color: TaraTheme.primaryDark, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: TaraTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TaraTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
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

class _ConsumerFilterItem {
  const _ConsumerFilterItem({required this.label, required this.view});

  final String label;
  final _ConsumerView view;
}


String _timeGreeting(int hour) {
  if (hour >= 5 && hour < 12) return 'Good morning,';
  if (hour >= 12 && hour < 17) return 'Good afternoon,';
  if (hour >= 17 && hour < 21) return 'Good evening,';
  return 'Good night,';
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
            const SizedBox(height: 4),
            Container(
              height: 3,
              width: 16,
              decoration: BoxDecoration(
                color: selected ? TaraTheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
