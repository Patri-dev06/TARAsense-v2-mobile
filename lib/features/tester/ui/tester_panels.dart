part of 'tester_workspace_page.dart';

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
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF52657D)),
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
  const _AvailableSurveysPanel({
    required this.searchController,
    required this.studiesAsync,
  });

  final TextEditingController searchController;
  final AsyncValue<List<ConsumerStudy>> studiesAsync;

  @override
  Widget build(BuildContext context) {
    return _SectionPanel(
      title: 'Discover Studies',
      badge: _studyCountLabel(studiesAsync),
      trailing: const Icon(Icons.keyboard_arrow_up_rounded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _ConsumerSearchField(controller: searchController),
          const SizedBox(height: 12),
          _ConsumerStudyList(
            studiesAsync: studiesAsync,
            searchQuery: searchController.text,
            compact: false,
          ),
        ],
      ),
    );
  }
}

class _CompletedSurveysPanel extends StatelessWidget {
  const _CompletedSurveysPanel({
    required this.completedStudiesAsync,
    required this.searchQuery,
  });

  final AsyncValue<List<ConsumerStudy>> completedStudiesAsync;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    return _SectionPanel(
      title: 'Completed Surveys',
      badge: _studyCountLabel(completedStudiesAsync),
      trailing: const Icon(Icons.keyboard_arrow_up_rounded),
      child: _CompletedStudyList(
        studiesAsync: completedStudiesAsync,
        searchQuery: searchQuery,
        compact: false,
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
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: const Color(0xFF6B4A35)),
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
