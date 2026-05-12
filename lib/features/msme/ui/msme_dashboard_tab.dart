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
            _MsmePageHeader(
              label: dashboard!.workspaceLabel.trim().isEmpty
                  ? 'MSME WORKSPACE'
                  : dashboard!.workspaceLabel.toUpperCase(),
              title: dashboard!.title.trim().isEmpty
                  ? 'MSME Dashboard'
                  : dashboard!.title,
              subtitle: dashboard!.subtitle.trim().isEmpty
                  ? 'Create and manage studies, coordinate with FIC, and monitor response progress in one view.'
                  : dashboard!.subtitle,
              icon: Icons.dashboard_rounded,
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
          const _MsmePageHeader(
            label: 'MSME WORKSPACE',
            title: 'Study History',
            subtitle: 'Review imported, completed, and active MSME studies in the same format as the web dashboard.',
            icon: Icons.history_rounded,
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

class _ImportDatasetTab extends StatelessWidget {
  const _ImportDatasetTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      children: <Widget>[
        const _MsmePageHeader(
          label: 'MSME WORKSPACE',
          title: 'Import Dataset',
          subtitle: 'Upload an existing CSV or Excel sensory dataset and have it analyzed instantly.',
          icon: Icons.upload_file_rounded,
        ),
        const SizedBox(height: 18),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: TaraTheme.surface,
            borderRadius: BorderRadius.all(Radius.circular(14)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Color(0x0A0F172A),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
              BoxShadow(
                color: Color(0x050F172A),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  height: 4,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[Color(0xFFFB923C), TaraTheme.primaryDark],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 56,
                        width: 56,
                        decoration: BoxDecoration(
                          color: TaraTheme.primaryTint,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.upload_file_rounded,
                          color: TaraTheme.primaryDark,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Upload Sensory Data File',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0A101C),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Accepted formats: .xlsx, .csv\n'
                        'Required columns: Respondent_ID, Sample, Overall_Liking, Attribute, JAR_Score',
                        style: TextStyle(
                          color: Color(0xFF52657D),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => _showWebDashboardSnack(
                            context,
                            'File picker is ready for backend wiring.',
                          ),
                          icon: const Icon(Icons.attach_file_rounded, size: 18),
                          label: const Text('Choose File from Device'),
                          style: FilledButton.styleFrom(
                            backgroundColor: TaraTheme.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TaraTheme.primaryTint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'WHAT HAPPENS AFTER UPLOAD',
                style: TextStyle(
                  color: TaraTheme.primaryDark,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              ...<String>[
                'Study record is auto-created from your file',
                'Each row is imported as a respondent + sensory response',
                'Penalty analysis and JAR distributions are computed',
                'Study is marked COMPLETED and ready to view in Results',
              ].map(
                (String step) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Icon(
                        Icons.check_circle_rounded,
                        color: TaraTheme.primaryDark,
                        size: 15,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          step,
                          style: const TextStyle(
                            color: TaraTheme.primaryDark,
                            fontSize: 13,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EvaluateStudiesTab extends StatelessWidget {
  const _EvaluateStudiesTab({
    required this.isLoading,
    required this.error,
    required this.studies,
    required this.onRefresh,
    required this.onRetry,
    required this.onStartEvaluation,
  });

  final bool isLoading;
  final String? error;
  final List<EvaluatePeerStudyItem> studies;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final ValueChanged<EvaluatePeerStudyItem> onStartEvaluation;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        children: <Widget>[
          const _MsmePageHeader(
            label: 'MSME WORKSPACE',
            title: 'Evaluate Studies',
            subtitle: 'Peer studies you are eligible to evaluate based on your panelist profile.',
            icon: Icons.compass_calibration_rounded,
          ),
          const SizedBox(height: 18),
          if (isLoading)
            const _LoadingCard()
          else if (error != null)
            _ErrorCard(message: error!, onRetry: onRetry)
          else if (studies.isEmpty)
            const _EmptyCard(
              title: 'No eligible studies',
              message: 'Peer studies from other MSMEs that match your panelist demographics will appear here once they start recruiting.',
            )
          else
            Column(
              children: studies
                  .map(
                    (EvaluatePeerStudyItem study) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _EvaluatePeerStudyCard(
                        study: study,
                        onStartEvaluation: onStartEvaluation,
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _EvaluatePeerStudyCard extends StatelessWidget {
  const _EvaluatePeerStudyCard({
    required this.study,
    required this.onStartEvaluation,
  });

  final EvaluatePeerStudyItem study;
  final ValueChanged<EvaluatePeerStudyItem> onStartEvaluation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.all(Radius.circular(14)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
          BoxShadow(
            color: Color(0x050F172A),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[Color(0xFFFB923C), TaraTheme.primaryDark],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    study.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF0A101C),
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    study.productName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: TaraTheme.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'By ${study.creatorName} · ${study.creatorOrganization}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: TaraTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: <Widget>[
                      _WebTag(label: study.category),
                      _WebTag(label: study.stage),
                      _WebTag(label: _humanizeLabel(study.status)),
                      _WebTag(
                        label: '${study.responseCount}/${study.sampleSize} responses',
                        blue: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${study.responseCount} of ${study.sampleSize} responses collected',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0A101C),
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: study.progress,
                          minHeight: 6,
                          backgroundColor: TaraTheme.primarySoft,
                          color: TaraTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => onStartEvaluation(study),
                      style: FilledButton.styleFrom(
                        backgroundColor: TaraTheme.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      child: Text(
                        study.hasStarted ? 'Continue Evaluation' : 'Start Evaluation',
                      ),
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
        final double width = (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x050F172A),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: item.tint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: item.color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF061A3A),
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF52657D),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    height: 1,
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
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
          BoxShadow(
            color: Color(0x050F172A),
            blurRadius: 4,
            offset: Offset(0, 1),
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
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.all(Radius.circular(14)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
          BoxShadow(
            color: Color(0x050F172A),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[Color(0xFFFB923C), TaraTheme.primaryDark],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    study.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF0A101C),
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    study.productName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: TaraTheme.primaryDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: <Widget>[
                      _WebTag(label: study.category),
                      _WebTag(label: study.stage),
                      _WebTag(label: _humanizeLabel(study.status)),
                      _WebTag(
                        label: '${study.responseCount}/${study.sampleSize} responses',
                        blue: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _WebStatusAction(
                          label: completed
                              ? 'All Participants Completed'
                              : 'Study In Progress',
                          completed: completed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _WebOutlineAction(
                          label: 'Form + QR',
                          onTap: () => onOpenStudy(study),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _WebOutlineAction(
                          label: 'Open Dashboard',
                          onTap: () => onOpenStudy(study),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: _WebOutlineAction(
                      label: 'Delete Study',
                      danger: true,
                      onTap: () => _showWebDashboardSnack(
                        context,
                        'Delete study action is ready for backend wiring.',
                      ),
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
        foregroundColor: danger ? const Color(0xFFDC2626) : TaraTheme.primaryDark,
        side: BorderSide(
          color: danger ? const Color(0xFFFECACA) : TaraTheme.primarySoft,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
      child: Text(label),
    );
  }
}

class _WebStatusAction extends StatelessWidget {
  const _WebStatusAction({required this.label, this.completed = false});

  final String label;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final Color bg = completed ? const Color(0xFFE7FAF3) : TaraTheme.primaryTint;
    final Color fg = completed ? const Color(0xFF047857) : TaraTheme.primaryDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w800,
          fontSize: 13,
          height: 1,
        ),
      ),
    );
  }
}

void _showWebDashboardSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
