part of 'msme_workspace_page.dart';

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({
    required this.isLoading,
    required this.error,
    required this.dashboard,
    required this.onRefresh,
    required this.onRetry,
    required this.onOpenStudy,
    required this.onOpenCreateStudy,
  });

  final bool isLoading;
  final String? error;
  final MsmeDashboardData? dashboard;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final ValueChanged<MsmeStudyItem> onOpenStudy;
  final VoidCallback onOpenCreateStudy;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        children: <Widget>[
          if (isLoading)
            const _LoadingCard()
          else if (error != null)
            _ErrorCard(message: error!, onRetry: onRetry)
          else if (dashboard != null) ...<Widget>[
            Text(
              dashboard!.workspaceLabel.trim().isEmpty
                  ? 'MSME WORKSPACE'
                  : dashboard!.workspaceLabel.toUpperCase(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF52657D),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              dashboard!.title.trim().isEmpty
                  ? 'MSME Dashboard'
                  : dashboard!.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF061A3A),
                letterSpacing: 0,
                height: 1.08,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              dashboard!.subtitle.trim().isEmpty
                  ? 'Create and manage studies, coordinate with FIC, and monitor response progress in one view.'
                  : dashboard!.subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF52657D)),
            ),
            const SizedBox(height: 18),
            _DashboardStatsGrid(stats: dashboard!.stats),
            const SizedBox(height: 18),
            const Divider(height: 1),
            const SizedBox(height: 18),
            _WebStudyListPanel(
              studies: dashboard!.studies,
              onOpenStudy: onOpenStudy,
              onOpenCreateStudy: onOpenCreateStudy,
              title: 'MSME Study List',
            ),
          ],
        ],
      ),
    );
  }
}

class _StudyHistoryTab extends StatelessWidget {
  const _StudyHistoryTab({
    required this.isLoading,
    required this.error,
    required this.dashboard,
    required this.onRefresh,
    required this.onRetry,
    required this.onOpenStudy,
    required this.onOpenCreateStudy,
  });

  final bool isLoading;
  final String? error;
  final MsmeDashboardData? dashboard;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final ValueChanged<MsmeStudyItem> onOpenStudy;
  final VoidCallback onOpenCreateStudy;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        children: <Widget>[
          Text(
            'MSME WORKSPACE',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF52657D),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Study History',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF061A3A),
              letterSpacing: 0,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Review imported, completed, and active MSME studies in the same format as the web dashboard.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF52657D)),
          ),
          const SizedBox(height: 18),
          if (isLoading)
            const _LoadingCard()
          else if (error != null)
            _ErrorCard(message: error!, onRetry: onRetry)
          else
            _WebStudyListPanel(
              studies: dashboard?.studies ?? <MsmeStudyItem>[],
              onOpenStudy: onOpenStudy,
              onOpenCreateStudy: onOpenCreateStudy,
              title: 'MSME Study List',
            ),
        ],
      ),
    );
  }
}

class _DashboardStatsGrid extends StatelessWidget {
  const _DashboardStatsGrid({required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final List<_WebStatData> items = <_WebStatData>[
      _WebStatData(
        label: 'Book to FIC',
        value: stats.ficBookings.toString(),
        subtitle: 'Studies using FIC facilities',
        icon: Icons.assignment_turned_in_outlined,
        tint: const Color(0xFFFFF7E6),
        color: TaraTheme.primaryDark,
      ),
      _WebStatData(
        label: 'Recent / History',
        value: stats.totalStudies.toString(),
        subtitle: 'Total studies created',
        icon: Icons.grid_view_rounded,
        tint: const Color(0xFFEAF2FF),
        color: const Color(0xFF155BFF),
      ),
      _WebStatData(
        label: 'Survey Responses',
        value: stats.totalResponses.toString(),
        subtitle: 'Responses collected',
        icon: Icons.assignment_rounded,
        tint: const Color(0xFFE7FAF3),
        color: TaraTheme.mintText,
      ),
      _WebStatData(
        label: 'Active Studies',
        value: stats.activeStudies.toString(),
        subtitle: 'Recruiting or ongoing studies',
        icon: Icons.add_circle_outline_rounded,
        tint: const Color(0xFFF1F5F9),
        color: const Color(0xFF344B66),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool twoColumns = constraints.maxWidth >= 620;
        final double width = twoColumns
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items
              .map(
                (_WebStatData item) => _WebStatCard(item: item, width: width),
              )
              .toList(),
        );
      },
    );
  }
}

class _WebStatData {
  const _WebStatData({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.tint,
    required this.color,
  });

  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color tint;
  final Color color;
}

class _WebStatCard extends StatelessWidget {
  const _WebStatCard({required this.item, required this.width});

  final _WebStatData item;
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
            color: Color(0x0D0F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: item.tint,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: TaraTheme.border),
                ),
                child: Icon(item.icon, color: item.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.value,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: const Color(0xFF061A3A),
                            letterSpacing: 0,
                            height: 1,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label.toUpperCase(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF52657D),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: const Color(0xFF52657D)),
          ),
        ],
      ),
    );
  }
}

class _WebStudyListPanel extends StatelessWidget {
  const _WebStudyListPanel({
    required this.studies,
    required this.onOpenStudy,
    required this.onOpenCreateStudy,
    required this.title,
  });

  final List<MsmeStudyItem> studies;
  final ValueChanged<MsmeStudyItem> onOpenStudy;
  final VoidCallback onOpenCreateStudy;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TaraTheme.border),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF061A3A),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 8),
                _WebCountBadge(value: studies.length.toString()),
                const Spacer(),
                const Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: Color(0xFF52657D),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: studies.isEmpty
                ? _EmptyCard(
                    title: 'No studies yet',
                    message:
                        'Create your first MSME study to start collecting responses.',
                  )
                : Column(
                    children: studies
                        .map(
                          (MsmeStudyItem study) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _WebStudyHistoryCard(
                              study: study,
                              onOpenStudy: onOpenStudy,
                              onOpenCreateStudy: onOpenCreateStudy,
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _WebStudyHistoryCard extends StatelessWidget {
  const _WebStudyHistoryCard({
    required this.study,
    required this.onOpenStudy,
    required this.onOpenCreateStudy,
  });

  final MsmeStudyItem study;
  final ValueChanged<MsmeStudyItem> onOpenStudy;
  final VoidCallback onOpenCreateStudy;

  @override
  Widget build(BuildContext context) {
    final bool completed =
        study.status.toUpperCase().contains('COMPLETED') ||
        study.responseCount >= study.sampleSize && study.sampleSize > 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LayoutBuilder(
            builder: (context, constraints) {
              final bool compact = constraints.maxWidth < 620;
              final Widget details = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    study.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF0A101C),
                      fontSize: 19,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    study.productName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF6B4A35),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      _WebTag(label: study.category),
                      _WebTag(label: study.stage),
                      _WebTag(label: _humanizeLabel(study.status)),
                      _WebTag(
                        label:
                            'Responses ${study.responseCount}/${study.sampleSize}',
                        blue: true,
                      ),
                    ],
                  ),
                ],
              );
              final Widget actions = Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: <Widget>[
                  _WebOutlineAction(
                    label: 'Form + QR',
                    onTap: () => onOpenStudy(study),
                  ),
                  _WebOutlineAction(
                    label: 'Open Dashboard',
                    onTap: () => onOpenStudy(study),
                  ),
                  _WebStatusAction(
                    label: completed
                        ? 'All Participants Completed'
                        : 'Study In Progress',
                  ),
                ],
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    details,
                    const SizedBox(height: 14),
                    actions,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: details),
                  const SizedBox(width: 16),
                  actions,
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          _WebOutlineAction(
            label: 'Delete Study',
            danger: true,
            onTap: () => _showWebDashboardSnack(
              context,
              'Delete study action is ready for backend wiring.',
            ),
          ),
        ],
      ),
    );
  }
}

class _WebCountBadge extends StatelessWidget {
  const _WebCountBadge({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: TaraTheme.primaryTint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: TaraTheme.primaryDark,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

class _WebTag extends StatelessWidget {
  const _WebTag({required this.label, this.blue = false});

  final String label;
  final bool blue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: blue ? const Color(0xFFEAF2FF) : const Color(0xFFF5ECE5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: blue ? const Color(0xFF155BFF) : const Color(0xFF6B4A35),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}

class _WebOutlineAction extends StatelessWidget {
  const _WebOutlineAction({
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 42),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        backgroundColor: TaraTheme.surface,
        foregroundColor: danger ? Colors.red : const Color(0xFF6B4A35),
        side: BorderSide(
          color: danger ? const Color(0xFFE5E7EB) : TaraTheme.border,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      child: Text(label),
    );
  }
}

class _WebStatusAction extends StatelessWidget {
  const _WebStatusAction({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFE7FAF3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF047857),
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

void _showWebDashboardSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
