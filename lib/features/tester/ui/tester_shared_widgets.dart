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

