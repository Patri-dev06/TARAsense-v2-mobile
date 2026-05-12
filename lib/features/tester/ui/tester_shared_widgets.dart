part of 'tester_workspace_page.dart';

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
        hintText: 'Search studies...',
        prefixIcon: const Icon(Icons.search_rounded),
        fillColor: const Color(0xFFF7F3EE),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE8DED2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE8DED2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: TaraTheme.primary),
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

class _ConsumerStudyList extends StatelessWidget {
  const _ConsumerStudyList({
    required this.studiesAsync,
    required this.searchQuery,
    required this.compact,
  });

  final AsyncValue<List<ConsumerStudy>> studiesAsync;
  final String searchQuery;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return studiesAsync.when(
      data: (List<ConsumerStudy> studies) {
        final List<ConsumerStudy> visibleStudies = studies
            .where((ConsumerStudy study) => study.matches(searchQuery))
            .toList();
        if (visibleStudies.isEmpty) {
          return _ConsumerStudyMessage(
            compact: compact,
            icon: Icons.search_off_rounded,
            title: searchQuery.trim().isEmpty
                ? 'No open studies'
                : 'No matching studies',
            message: searchQuery.trim().isEmpty
                ? 'Available consumer studies will appear here.'
                : 'Try a different search term.',
          );
        }
        if (compact) {
          return Column(
            children: visibleStudies.asMap().entries.map((entry) {
              final bool isLast = entry.key == visibleStudies.length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                child: _ConsumerStudyMobileCard(study: entry.value),
              );
            }).toList(),
          );
        }
        return _ConsumerStudyListShell(
          compact: compact,
          children: visibleStudies.asMap().entries.map((entry) {
            final bool isLast = entry.key == visibleStudies.length - 1;
            return Column(
              children: <Widget>[
                _ConsumerStudyListItem(study: entry.value, compact: compact),
                if (!isLast)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFFFE2CC),
                  ),
              ],
            );
          }).toList(),
        );
      },
      error: (Object error, StackTrace stackTrace) => _ConsumerStudyMessage(
        compact: compact,
        icon: Icons.wifi_off_rounded,
        title: 'Could not load studies',
        message: formatApiError(error, includeUri: true),
      ),
      loading: () => _ConsumerStudyListShell(
        compact: compact,
        children: const <Widget>[_ConsumerStudyLoadingRow()],
      ),
    );
  }
}

class _ConsumerStudyListItem extends StatelessWidget {
  const _ConsumerStudyListItem({required this.study, required this.compact});

  final ConsumerStudy study;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final String encodedStudyId = Uri.encodeComponent(study.id);
    final String encodedParticipantId = Uri.encodeComponent(
      study.participantId,
    );
    final String testPath = encodedParticipantId.isEmpty
        ? '/consumer/studies/$encodedStudyId/test'
        : '/consumer/studies/$encodedStudyId/participants/$encodedParticipantId/test';
    void openStudy() => context.push(testPath, extra: study);

    return InkWell(
      onTap: study.id.trim().isEmpty ? null : openStudy,
      borderRadius: BorderRadius.circular(compact ? 16 : 8),
      child: Padding(
        padding: compact
            ? EdgeInsets.zero
            : const EdgeInsets.all(10),
        child: compact
            ? _ConsumerStudyMobileRow(study: study, onOpen: openStudy)
            : _ConsumerStudyDesktopRow(study: study, onOpen: openStudy),
      ),
    );
  }
}

class _CompletedStudyList extends StatelessWidget {
  const _CompletedStudyList({
    required this.studiesAsync,
    required this.searchQuery,
    required this.compact,
  });

  final AsyncValue<List<ConsumerStudy>> studiesAsync;
  final String searchQuery;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return studiesAsync.when(
      data: (List<ConsumerStudy> studies) {
        final List<ConsumerStudy> visibleStudies = studies
            .where((ConsumerStudy study) => study.matches(searchQuery))
            .toList();
        if (visibleStudies.isEmpty) {
          return _ConsumerStudyMessage(
            compact: compact,
            icon: Icons.assignment_turned_in_outlined,
            title: 'No completed surveys yet',
            message: 'Completed studies will appear here after submission.',
          );
        }
        if (compact) {
          return Column(
            children: visibleStudies.asMap().entries.map((entry) {
              final bool isLast = entry.key == visibleStudies.length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                child: _CompletedStudyMobileCard(study: entry.value),
              );
            }).toList(),
          );
        }
        return _ConsumerStudyListShell(
          compact: compact,
          children: visibleStudies.asMap().entries.map((entry) {
            final bool isLast = entry.key == visibleStudies.length - 1;
            return Column(
              children: <Widget>[
                _CompletedStudyListItem(study: entry.value, compact: compact),
                if (!isLast)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFE7F3EE),
                  ),
              ],
            );
          }).toList(),
        );
      },
      error: (Object error, StackTrace stackTrace) => _ConsumerStudyMessage(
        compact: compact,
        icon: Icons.wifi_off_rounded,
        title: 'Could not load completed surveys',
        message: formatApiError(error, includeUri: true),
      ),
      loading: () => _ConsumerStudyListShell(
        compact: compact,
        children: const <Widget>[_ConsumerStudyLoadingRow()],
      ),
    );
  }
}

class _CompletedStudyMobileCard extends StatelessWidget {
  const _CompletedStudyMobileCard({required this.study});

  final ConsumerStudy study;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: TaraTheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x0A0F9470),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
            BoxShadow(
              color: Color(0x060F172A),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[Color(0xFF2DD4BF), Color(0xFF0F766E)],
                ),
              ),
            ),
            _CompletedStudyListItem(study: study, compact: true),
          ],
        ),
      ),
    );
  }
}

class _CompletedStudyListItem extends StatelessWidget {
  const _CompletedStudyListItem({required this.study, required this.compact});

  final ConsumerStudy study;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ConsumerStudyParticipation? participation = study.myParticipation;
    final DateTime? completedAt =
        participation?.completedAt ?? participation?.submittedAt;
    final String completedLabel = _formatCompletedDate(completedAt);
    final String participantLabel =
        participation?.panelistNumber == null ||
            participation!.panelistNumber <= 0
        ? 'Completed'
        : 'Panelist #${participation.panelistNumber}';

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Title + tags
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  study.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    color: TaraTheme.textPrimary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    height: 1.15,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: <Widget>[
                    _StudyMiniTag(label: study.category),
                    if (study.stage.trim().isNotEmpty && study.stage != '-')
                      _StudyMiniTag(label: study.stage, subdued: true),
                  ],
                ),
              ],
            ),
          ),
          // Completion date band
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: TaraTheme.mint,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF99F6E4)),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 13,
                    color: TaraTheme.mintText,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      completedLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: TaraTheme.mintText,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Panelist meta
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: _StudyMetaLine(
              icon: Icons.person_outline_rounded,
              label: participantLabel,
              color: TaraTheme.textSecondary,
              compact: true,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: Color(0xFFD1FAF0)),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Row(
              children: <Widget>[
                _CompletedBadge(compact: true),
              ],
            ),
          ),
        ],
      );
    }

    // Desktop layout
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: TaraTheme.mint,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF99F6E4)),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: TaraTheme.mintText,
              size: 20,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  study.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    color: TaraTheme.textPrimary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                    height: 1.12,
                  ),
                ),
                const SizedBox(height: 5),
                _StudyMetaLine(
                  icon: Icons.check_circle_outline_rounded,
                  label: completedLabel,
                  color: TaraTheme.mintText,
                  compact: false,
                ),
                const SizedBox(height: 4),
                _StudyMetaLine(
                  icon: Icons.person_outline_rounded,
                  label: participantLabel,
                  color: TaraTheme.textSecondary,
                  compact: false,
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: <Widget>[
                    _StudyMiniTag(label: study.category),
                    if (study.stage.trim().isNotEmpty && study.stage != '-')
                      _StudyMiniTag(label: study.stage, subdued: true),
                    _CompletedBadge(compact: false),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsumerStudyMobileRow extends StatelessWidget {
  const _ConsumerStudyMobileRow({required this.study, required this.onOpen});

  final ConsumerStudy study;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String dateLabel = _sessionSegment(study.session, 0);
    final String locationLabel = _sessionSegment(study.session, 1);
    final String timeLabel = _sessionSegment(study.session, 2);
    final bool isAvailable = _studyStatusIsAvailable(study.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Header: title + category tags (no icon)
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                study.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleSmall?.copyWith(
                  color: TaraTheme.textPrimary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  height: 1.15,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 7),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: <Widget>[
                  _StudyMiniTag(label: study.category),
                  if (study.stage.trim().isNotEmpty && study.stage != '-')
                    _StudyMiniTag(label: study.stage, subdued: true),
                ],
              ),
            ],
          ),
        ),
        // Schedule highlighted band
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: TaraTheme.primaryTint,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFD8B5)),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.calendar_month_rounded,
                  size: 13,
                  color: TaraTheme.primaryDark,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _scheduleSummary(dateLabel, timeLabel),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: TaraTheme.primaryDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Location meta
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: _StudyMetaLine(
            icon: Icons.place_outlined,
            label: '${study.owner} · ${_locationLabel(locationLabel)}',
            color: TaraTheme.textSecondary,
            compact: true,
          ),
        ),
        const SizedBox(height: 12),
        // Subtle divider before footer
        const Divider(height: 1, thickness: 1, color: Color(0xFFF5E8DC)),
        // Footer: slot badge + status + action button inline
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          child: Row(
            children: <Widget>[
              _StudySlotBadge(study: study, compact: true),
              const SizedBox(width: 6),
              _StudyStatePill(
                label: _studyStatusLabel(study.status),
                success: isAvailable,
                compact: true,
              ),
              const Spacer(),
              SizedBox(
                height: 36,
                child: FilledButton.icon(
                  onPressed: onOpen,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  icon: const Icon(Icons.open_in_new_rounded, size: 13),
                  label: const Text('Open Sheet'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConsumerStudyDesktopRow extends StatelessWidget {
  const _ConsumerStudyDesktopRow({required this.study, required this.onOpen});

  final ConsumerStudy study;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String dateLabel = _sessionSegment(study.session, 0);
    final String locationLabel = _sessionSegment(study.session, 1);
    final String timeLabel = _sessionSegment(study.session, 2);

    return Row(
      children: <Widget>[
        Container(
          height: 58,
          width: 3,
          decoration: BoxDecoration(
            color: TaraTheme.primary,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 4,
          child: Row(
            children: <Widget>[
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: TaraTheme.primary,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x24F97316),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.science_outlined,
                  color: Colors.white,
                  size: 17,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      study.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        color: TaraTheme.textPrimary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${study.owner} - ${_locationLabel(locationLabel)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: TaraTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _StudyMetaLine(
                icon: Icons.event_rounded,
                label: _scheduleSummary(dateLabel, timeLabel),
                color: TaraTheme.primaryDark,
                compact: false,
              ),
              const SizedBox(height: 7),
              Wrap(
                spacing: 6,
                runSpacing: 5,
                children: <Widget>[
                  _StudyMiniTag(label: study.category),
                  if (study.stage.trim().isNotEmpty && study.stage != '-')
                    _StudyMiniTag(label: study.stage, subdued: true),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 190,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 6,
                runSpacing: 6,
                children: <Widget>[
                  _StudySlotBadge(study: study, compact: true),
                  _StudyStatePill(
                    label: _studyStatusLabel(study.status),
                    success: _studyStatusIsAvailable(study.status),
                    compact: true,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: FilledButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.open_in_new_rounded, size: 15),
                  label: const Text('Open'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConsumerStudyListShell extends StatelessWidget {
  const _ConsumerStudyListShell({
    required this.compact,
    required this.children,
  });

  final bool compact;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(compact ? 8 : 10),
        border: Border.all(color: const Color(0xFFFFD8B5)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0DF97316),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _ConsumerStudyMobileCard extends StatelessWidget {
  const _ConsumerStudyMobileCard({required this.study});

  final ConsumerStudy study;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: TaraTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFD8B5)),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x14F97316),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
            BoxShadow(
              color: Color(0x060F172A),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[Color(0xFFFB923C), TaraTheme.primaryDark],
                ),
              ),
            ),
            _ConsumerStudyListItem(study: study, compact: true),
          ],
        ),
      ),
    );
  }
}

class _ConsumerStudyLoadingRow extends StatelessWidget {
  const _ConsumerStudyLoadingRow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(18),
      child: Row(
        children: <Widget>[
          SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Loading studies...'),
        ],
      ),
    );
  }
}

class _ConsumerStudyMessage extends StatelessWidget {
  const _ConsumerStudyMessage({
    required this.compact,
    required this.icon,
    required this.title,
    required this.message,
  });

  final bool compact;
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return _ConsumerStudyListShell(
      compact: compact,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(compact ? 14 : 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: TaraTheme.primaryTint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: TaraTheme.primaryDark, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: const Color(0xFF0F172A),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: TaraTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _studyCountLabel(AsyncValue<List<ConsumerStudy>> studiesAsync) {
  return studiesAsync.when(
    data: (List<ConsumerStudy> studies) => studies.length.toString(),
    error: (_, _) => '!',
    loading: () => '...',
  );
}

String _studyStatusLabel(String status) {
  final String normalized = status.trim().toUpperCase();
  if (normalized == 'RECRUITING' || normalized == 'AVAILABLE') {
    return 'Available';
  }
  if (normalized.isEmpty) {
    return 'Available';
  }
  return normalized;
}

bool _studyStatusIsAvailable(String status) {
  final String normalized = status.trim().toUpperCase();
  return normalized.isEmpty ||
      normalized == 'AVAILABLE' ||
      normalized == 'RECRUITING' ||
      normalized == 'OPEN' ||
      normalized == 'ACTIVE';
}

String _slotsLabel(ConsumerStudy study) {
  if (study.capacity <= 0) {
    return 'Open';
  }
  return '${study.slotsLeft} slots';
}

String _locationLabel(String value) {
  final String trimmed = value.trim();
  return trimmed.isEmpty ? 'Testing site' : trimmed;
}

String _scheduleSummary(String dateLabel, String timeLabel) {
  final bool hasDate =
      dateLabel.trim().isNotEmpty && dateLabel != 'Schedule to be announced';
  final bool hasTime = timeLabel.trim().isNotEmpty;
  if (hasDate && hasTime) {
    return '$dateLabel | $timeLabel';
  }
  if (hasDate) {
    return dateLabel;
  }
  return 'Schedule date unavailable';
}

class _StudyMetaLine extends StatelessWidget {
  const _StudyMetaLine({
    required this.icon,
    required this.label,
    required this.color,
    required this.compact,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: compact ? 11 : 13, color: color),
        SizedBox(width: compact ? 4 : 6),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }
}


class _StudyMiniTag extends StatelessWidget {
  const _StudyMiniTag({required this.label, this.subdued = false});

  final String label;
  final bool subdued;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 110),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: subdued ? const Color(0xFFF8FAFC) : TaraTheme.primaryTint,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: subdued ? TaraTheme.border : const Color(0xFFFFD8B5),
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: subdued ? TaraTheme.textSecondary : TaraTheme.primaryDark,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

class _StudySlotBadge extends StatelessWidget {
  const _StudySlotBadge({required this.study, required this.compact});

  final ConsumerStudy study;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final Color badgeColor = _slotBadgeColor(study);
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: compact ? 86 : 110),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 7 : 9,
          vertical: compact ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: badgeColor,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          _slotsLabel(study),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontSize: compact ? 9 : 10,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
      ),
    );
  }
}

Color _slotBadgeColor(ConsumerStudy study) {
  if (study.capacity <= 0) return TaraTheme.primary;
  if (study.slotsLeft <= 5) return const Color(0xFFDC2626);
  if (study.slotsLeft <= 15) return const Color(0xFFD97706);
  return TaraTheme.primary;
}

class _CompletedBadge extends StatelessWidget {
  const _CompletedBadge({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 9,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: TaraTheme.mint,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFF99F6E4)),
      ),
      child: Text(
        'Completed',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: TaraTheme.mintText,
          fontSize: compact ? 9 : 10,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

String _formatCompletedDate(DateTime? value) {
  if (value == null) {
    return 'Completed date unavailable';
  }
  final DateTime local = value.toLocal();
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
  final int hour = local.hour == 0
      ? 12
      : local.hour > 12
      ? local.hour - 12
      : local.hour;
  final String minute = local.minute.toString().padLeft(2, '0');
  final String suffix = local.hour >= 12 ? 'PM' : 'AM';
  return 'Completed ${months[local.month - 1]} ${local.day}, ${local.year} | $hour:$minute $suffix';
}

String _sessionSegment(String session, int index) {
  final List<String> parts = session
      .split('|')
      .map((String item) => item.trim())
      .where((String item) => item.isNotEmpty)
      .toList();
  if (index >= 0 && index < parts.length) {
    return parts[index];
  }
  return '';
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
            child: FilledButton(onPressed: onSubmit, child: Text(buttonLabel)),
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
        Text('TARA', style: style.copyWith(color: TaraTheme.brandNavy)),
        Text('sense', style: style.copyWith(color: TaraTheme.primary)),
      ],
    );
  }
}

class _StudyStatePill extends StatelessWidget {
  const _StudyStatePill({
    required this.label,
    this.success = false,
    this.compact = false,
  });

  final String label;
  final bool success;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: compact ? 92 : 120),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10,
          vertical: compact ? 5 : 6,
        ),
        decoration: BoxDecoration(
          color: success ? TaraTheme.primaryTint : const Color(0xFFF4EEE7),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: success ? const Color(0xFFFFD8B5) : const Color(0xFFE8DED2),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: success ? TaraTheme.primaryDark : const Color(0xFF7C5E47),
            fontSize: compact ? 10 : 12,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
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
