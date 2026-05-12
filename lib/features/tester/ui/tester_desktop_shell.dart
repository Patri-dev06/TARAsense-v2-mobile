part of 'tester_workspace_page.dart';

class _ConsumerSidebar extends StatelessWidget {
  const _ConsumerSidebar({
    required this.currentView,
    required this.studiesAsync,
    required this.completedStudiesAsync,
    required this.onViewChanged,
  });

  final _ConsumerView currentView;
  final AsyncValue<List<ConsumerStudy>> studiesAsync;
  final AsyncValue<List<ConsumerStudy>> completedStudiesAsync;
  final ValueChanged<_ConsumerView> onViewChanged;

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
            icon: Icons.explore_outlined,
            label: 'Available Surveys',
            badge: _studyCountLabel(studiesAsync),
            selected: currentView == _ConsumerView.availableSurveys,
            onTap: () => onViewChanged(_ConsumerView.availableSurveys),
          ),
          _ConsumerNavButton(
            icon: Icons.assignment_turned_in_outlined,
            label: 'Completed Surveys',
            badge: _studyCountLabel(completedStudiesAsync),
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
          _ConsumerNavButton(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            selected: currentView == _ConsumerView.settings,
            onTap: () => onViewChanged(_ConsumerView.settings),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _ConsumerContent extends StatelessWidget {
  const _ConsumerContent({
    required this.currentView,
    required this.userName,
    required this.email,
    required this.organization,
    required this.searchController,
    required this.studiesAsync,
    required this.completedStudiesAsync,
    required this.msmeReasonController,
    required this.ficReasonController,
    required this.onViewChanged,
    required this.onSubmitApplication,
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
  final TextEditingController msmeReasonController;
  final TextEditingController ficReasonController;
  final ValueChanged<_ConsumerView> onViewChanged;
  final ValueChanged<String> onSubmitApplication;
  final bool authBusy;
  final VoidCallback onLogout;

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
        _ConsumerPageHeader(userName: userName),
        const SizedBox(height: 20),
        _ConsumerStatsGrid(
          studiesAsync: studiesAsync,
          completedStudiesAsync: completedStudiesAsync,
        ),
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
        return _AvailableSurveysPanel(
          searchController: searchController,
          studiesAsync: studiesAsync,
        );
      case _ConsumerView.completedSurveys:
        return _CompletedSurveysPanel(
          completedStudiesAsync: completedStudiesAsync,
          searchQuery: '',
        );
      case _ConsumerView.roleApplications:
        return _RoleApplicationsPanel(
          msmeReasonController: msmeReasonController,
          ficReasonController: ficReasonController,
          onSubmitApplication: onSubmitApplication,
        );
      case _ConsumerView.settings:
        return _ConsumerSettingsPanel(
          userName: userName,
          email: email,
          organization: organization,
          authBusy: authBusy,
          onLogout: onLogout,
        );
    }
  }
}

class _ConsumerSettingsPanel extends StatelessWidget {
  const _ConsumerSettingsPanel({
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
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height - 190,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: TaraTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: TaraTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Profile', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _ConsumerSettingsFormGrid(
              fields: <_ConsumerSettingsField>[
                _ConsumerSettingsField(label: 'Name', value: userName),
                _ConsumerSettingsField(label: 'Email', value: email),
                const _ConsumerSettingsField(label: 'Role', value: 'Consumer'),
                if (organization != null && organization!.trim().isNotEmpty)
                  _ConsumerSettingsField(
                    label: 'Organization',
                    value: organization!.trim(),
                  ),
              ],
            ),
            const Spacer(),
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
      ),
    );
  }
}

class _ConsumerSettingsFormGrid extends StatelessWidget {
  const _ConsumerSettingsFormGrid({required this.fields});

  final List<_ConsumerSettingsField> fields;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool twoColumns = constraints.maxWidth >= 620;
        final double fieldWidth = twoColumns
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: fields
              .map(
                (_ConsumerSettingsField field) => SizedBox(
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

class _ConsumerSettingsField {
  const _ConsumerSettingsField({required this.label, required this.value});

  final String label;
  final String value;
}

class _ConsumerPageHeader extends StatelessWidget {
  const _ConsumerPageHeader({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    final String displayName = userName.trim().isEmpty
        ? 'Consumer'
        : userName.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Good morning,',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(0xFF52657D),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: const Color(0xFF061A3A),
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _ConsumerStatsGrid extends StatelessWidget {
  const _ConsumerStatsGrid({
    required this.studiesAsync,
    required this.completedStudiesAsync,
  });

  final AsyncValue<List<ConsumerStudy>> studiesAsync;
  final AsyncValue<List<ConsumerStudy>> completedStudiesAsync;

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

        final List<_ConsumerStat> stats = <_ConsumerStat>[
          _ConsumerStat(
            icon: Icons.explore_outlined,
            value: _studyCountLabel(studiesAsync),
            label: 'STUDY NOTIFICATIONS',
            subtitle: 'Active studies you can join',
            tint: const Color(0xFFEAF2FF),
            iconColor: const Color(0xFF155BFF),
          ),
          const _ConsumerStat(
            icon: Icons.verified_user_outlined,
            value: '0',
            label: 'PENDING APPLICATIONS',
            subtitle: 'Awaiting admin review',
            tint: Color(0xFFFFF7E6),
            iconColor: TaraTheme.primaryDark,
          ),
          const _ConsumerStat(
            icon: Icons.assignment_turned_in_outlined,
            value: '0',
            label: 'APPROVED UPGRADES',
            subtitle: 'Role requests approved',
            tint: Color(0xFFE7FAF3),
            iconColor: Color(0xFF07936E),
          ),
          _ConsumerStat(
            icon: Icons.description_outlined,
            value: _studyCountLabel(completedStudiesAsync),
            label: 'COMPLETED SURVEYS',
            subtitle: 'Surveys you already submitted',
            tint: const Color(0xFFF0F4F8),
            iconColor: const Color(0xFF344B66),
          ),
        ];

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: stats
              .map((stat) => _ConsumerStatCard(stat: stat, width: cardWidth))
              .toList(),
        );
      },
    );
  }
}
