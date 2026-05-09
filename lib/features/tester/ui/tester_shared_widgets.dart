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
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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

class _ConsumerStudyListTile extends StatelessWidget {
  const _ConsumerStudyListTile({
    required this.survey,
    required this.compact,
  });

  final _ConsumerSurvey survey;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String dateLabel = _sessionSegment(survey.session, 0);
    final String sessionLabel = _sessionSegment(survey.session, 1);
    final String timeLabel = _sessionSegment(survey.session, 2);
    final int slotsLeft = (survey.capacity - survey.selected).clamp(0, 9999);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: compact ? 8 : 10),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 14,
        vertical: compact ? 12 : 14,
      ),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE7E0D7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  survey.title,
                  maxLines: compact ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: (compact ? textTheme.titleSmall : textTheme.titleMedium)
                      ?.copyWith(
                        color: const Color(0xFF0F172A),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                        height: 1.1,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$sessionLabel - $timeLabel',
                  maxLines: compact ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF9AA3AF),
                    fontSize: compact ? 11 : 12,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: <Widget>[
                    _StudyCompactTag(label: survey.owner),
                    _StudyCompactTag(label: survey.category),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                '$slotsLeft',
                style: (compact ? textTheme.titleMedium : textTheme.titleLarge)
                    ?.copyWith(
                      color: const Color(0xFF111827),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                'slots left',
                style: textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF9AA3AF),
                  fontSize: compact ? 10 : 11,
                ),
              ),
              const SizedBox(height: 10),
              _StudyStatePill(
                label: survey.status == 'RECRUITING'
                    ? 'Available'
                    : survey.status,
                success: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
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
  return session;
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
        Text('TARA', style: style.copyWith(color: TaraTheme.brandNavy)),
        Text('sense', style: style.copyWith(color: TaraTheme.primary)),
      ],
    );
  }
}

class _StudyCompactTag extends StatelessWidget {
  const _StudyCompactTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(7),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: TaraTheme.primaryTint,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: const Color(0xFFFFD8B5)),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: TaraTheme.primaryDark,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _StudyStatePill extends StatelessWidget {
  const _StudyStatePill({required this.label, this.success = false});

  final String label;
  final bool success;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: success ? TaraTheme.mint : const Color(0xFFF4EEE7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: success ? TaraTheme.mintText : const Color(0xFF7C5E47),
          fontSize: 12,
          fontWeight: FontWeight.w800,
          height: 1,
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

