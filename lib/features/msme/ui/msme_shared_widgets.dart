part of 'msme_workspace_page.dart';

class _HeroWorkspaceCard extends StatelessWidget {
  const _HeroWorkspaceCard({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: TaraTheme.border),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x120057A8),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const DostLogoMark(size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const TaraBrandLockup(markSize: 20, textSize: 22),
                    const SizedBox(height: 8),
                    Text(
                      'Sensory and consumer driven food innovation platform',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: TaraTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Test. Analyze. Refine. Advance.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: TaraTheme.textPrimary,
              height: 1.08,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: TaraTheme.dostBlue,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: TaraTheme.textSecondary,
              height: 1.5,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 18),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _HeroSignalPill(label: 'Food Innovation Centers'),
              _HeroSignalPill(label: 'MSME studies'),
              _HeroSignalPill(label: 'Consumer feedback'),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: TaraTheme.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSignalPill extends StatelessWidget {
  const _HeroSignalPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: TaraTheme.primaryTint,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: TaraTheme.primarySoft),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: TaraTheme.dostBlueDark,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ChoiceWrap extends StatelessWidget {
  const _ChoiceWrap({
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  final List<SelectOption> options;
  final String selectedValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options
          .map(
            (SelectOption option) => ChoiceChip(
              label: Text(option.label),
              selected: selectedValue == option.value,
              onSelected: (_) => onSelected(option.value),
              selectedColor: TaraTheme.primarySoft,
              side: const BorderSide(color: TaraTheme.border),
              labelStyle: TextStyle(
                color: selectedValue == option.value
                    ? TaraTheme.primaryDark
                    : TaraTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _AttributeEditor extends StatelessWidget {
  const _AttributeEditor({
    required this.attribute,
    required this.dimensionOptions,
    required this.onChanged,
  });

  final _StudyAttributeDraft attribute;
  final List<String> dimensionOptions;
  final ValueChanged<_StudyAttributeDraft> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TaraTheme.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        children: <Widget>[
          TextFormField(
            initialValue: attribute.name,
            onChanged: (String value) =>
                onChanged(attribute.copyWith(name: value)),
            decoration: const InputDecoration(labelText: 'Attribute'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: attribute.dimension,
            items: dimensionOptions
                .map(
                  (String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  ),
                )
                .toList(),
            onChanged: (String? value) {
              if (value != null) {
                onChanged(attribute.copyWith(dimension: value));
              }
            },
            decoration: const InputDecoration(labelText: 'Type'),
          ),
          const SizedBox(height: 10),
          CheckboxListTile(
            value: attribute.isJarTarget,
            onChanged: (bool? value) =>
                onChanged(attribute.copyWith(isJarTarget: value ?? false)),
            contentPadding: EdgeInsets.zero,
            title: const Text('Priority'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }
}

class _MobileFacilityCalendar extends StatelessWidget {
  const _MobileFacilityCalendar({
    required this.startDate,
    required this.durationDays,
    required this.selectedFacility,
    required this.sessions,
    required this.onDateSelected,
  });

  final DateTime startDate;
  final int durationDays;
  final String? selectedFacility;
  final List<_SessionDraft> sessions;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final int safeDuration = durationDays < 1 ? 1 : durationDays;
    final DateTime today = DateTime.now();
    final DateTime firstDate = DateTime(today.year, today.month, today.day);
    final DateTime selectedDate = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final DateTime rangeStart = selectedDate.isBefore(firstDate)
        ? selectedDate
        : firstDate;
    final List<DateTime> visibleDates = List<DateTime>.generate(
      14,
      (int index) => rangeStart.add(Duration(days: index)),
    );
    final int totalCapacity = sessions.fold<int>(
      0,
      (int total, _SessionDraft session) => total + session.capacity,
    );
    final String facilityName = selectedFacility?.trim().isEmpty ?? true
        ? 'No facility selected'
        : selectedFacility!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: TaraTheme.primaryTint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.calendar_month_outlined,
                  color: TaraTheme.primaryDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Facility Calendar',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      facilityName,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: visibleDates.map((DateTime date) {
                final int dayOffset = date.difference(selectedDate).inDays;
                final bool selected = dayOffset >= 0 && dayOffset < safeDuration;
                final bool past = date.isBefore(firstDate);
                final bool hasSessions = sessions.any(
                  (_SessionDraft session) => session.dayOffset == dayOffset,
                );
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _CalendarDateChip(
                    date: date,
                    selected: selected,
                    disabled: past,
                    hasSessions: hasSessions,
                    onTap: past ? null : () => onDateSelected(date),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: _CalendarMetric(
                  label: 'Selected',
                  value: '$safeDuration day${safeDuration == 1 ? '' : 's'}',
                  icon: Icons.event_available_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CalendarMetric(
                  label: 'Capacity',
                  value: '$totalCapacity seats',
                  icon: Icons.groups_2_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _CalendarLegendDot(
                label: 'Testing date',
                color: TaraTheme.primary,
              ),
              const _CalendarLegendDot(
                label: 'Has session',
                color: TaraTheme.dostBlue,
              ),
              _CalendarLegendDot(
                label: 'Unavailable',
                color: TaraTheme.textSecondary.withValues(alpha: 0.38),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalendarDateChip extends StatelessWidget {
  const _CalendarDateChip({
    required this.date,
    required this.selected,
    required this.disabled,
    required this.hasSessions,
    required this.onTap,
  });

  final DateTime date;
  final bool selected;
  final bool disabled;
  final bool hasSessions;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = selected ? TaraTheme.primary : TaraTheme.border;
    final Color textColor = disabled
        ? TaraTheme.textSecondary.withValues(alpha: 0.55)
        : selected
        ? TaraTheme.primaryDark
        : TaraTheme.textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 74,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: disabled
              ? TaraTheme.background
              : selected
              ? TaraTheme.primaryTint
              : TaraTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
        ),
        child: Column(
          children: <Widget>[
            Text(
              _formatWeekday(date),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              date.day.toString(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: textColor,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 6,
              width: 6,
              decoration: BoxDecoration(
                color: hasSessions ? TaraTheme.dostBlue : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarMetric extends StatelessWidget {
  const _CalendarMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: TaraTheme.primaryDark, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(value, style: Theme.of(context).textTheme.titleMedium),
                Text(label, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarLegendDot extends StatelessWidget {
  const _CalendarLegendDot({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 8,
          width: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _SessionEditor extends StatelessWidget {
  const _SessionEditor({
    required this.session,
    required this.index,
    required this.onChanged,
    required this.durationDays,
    this.onRemove,
  });

  final _SessionDraft session;
  final int index;
  final ValueChanged<_SessionDraft> onChanged;
  final int durationDays;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TaraTheme.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Session ${index + 1}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (onRemove != null)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
            ],
          ),
          TextFormField(
            initialValue: session.label,
            onChanged: (String value) =>
                onChanged(session.copyWith(label: value)),
            decoration: const InputDecoration(labelText: 'Session Label'),
          ),
          const SizedBox(height: 12),
          if (durationDays > 1) ...<Widget>[
            DropdownButtonFormField<int>(
              initialValue: session.dayOffset
                  .clamp(0, durationDays - 1)
                  .toInt(),
              items: List<DropdownMenuItem<int>>.generate(
                durationDays,
                (int index) => DropdownMenuItem<int>(
                  value: index,
                  child: Text('Day ${index + 1}'),
                ),
              ),
              onChanged: (int? value) {
                if (value != null) {
                  onChanged(session.copyWith(dayOffset: value));
                }
              },
              decoration: const InputDecoration(labelText: 'Testing Day'),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  initialValue: session.startTime,
                  onChanged: (String value) =>
                      onChanged(session.copyWith(startTime: value)),
                  decoration: const InputDecoration(labelText: 'Start'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  initialValue: session.endTime,
                  onChanged: (String value) =>
                      onChanged(session.copyWith(endTime: value)),
                  decoration: const InputDecoration(labelText: 'End'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: session.capacity.toString(),
            keyboardType: TextInputType.number,
            onChanged: (String value) => onChanged(
              session.copyWith(
                capacity: int.tryParse(value.trim()) ?? session.capacity,
              ),
            ),
            decoration: const InputDecoration(labelText: 'Session Capacity'),
          ),
        ],
      ),
    );
  }
}

class _SampleSetupEditor extends StatelessWidget {
  const _SampleSetupEditor({
    required this.index,
    required this.setup,
    required this.onChanged,
  });

  final int index;
  final _SampleSetupDraft setup;
  final ValueChanged<_SampleSetupDraft> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TaraTheme.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Sample Set-up ${index + 1}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: setup.description,
            onChanged: (String value) =>
                onChanged(setup.copyWith(description: value)),
            decoration: const InputDecoration(
              labelText: 'General Description / Formulation Notes',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: setup.ingredient,
            onChanged: (String value) =>
                onChanged(setup.copyWith(ingredient: value)),
            decoration: const InputDecoration(
              labelText: 'Ingredient (Optional)',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: setup.allergen,
            onChanged: (String value) =>
                onChanged(setup.copyWith(allergen: value)),
            decoration: const InputDecoration(labelText: 'Allergen'),
          ),
        ],
      ),
    );
  }
}

class _SelectionSection extends StatelessWidget {
  const _SelectionSection({
    required this.title,
    required this.options,
    required this.selectedValues,
    required this.onChanged,
  });

  final String title;
  final List<SelectOption> options;
  final Set<String> selectedValues;
  final void Function(String value, bool selected) onChanged;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: title,
      subtitle: 'Tap each option to keep your panelist profile accurate.',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: options
            .map(
              (SelectOption option) => FilterChip(
                label: Text(option.label),
                selected: selectedValues.contains(option.value),
                onSelected: (bool selected) =>
                    onChanged(option.value, selected),
                selectedColor: TaraTheme.primarySoft,
                side: const BorderSide(color: TaraTheme.border),
                labelStyle: TextStyle(
                  color: selectedValues.contains(option.value)
                      ? TaraTheme.primaryDark
                      : TaraTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: TaraTheme.border),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TaraTheme.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        children: <Widget>[
          const Icon(
            Icons.folder_open_rounded,
            color: TaraTheme.primaryDark,
            size: 34,
          ),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        children: <Widget>[
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: TaraTheme.roseText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Try Again')),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: TaraTheme.roseText,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

