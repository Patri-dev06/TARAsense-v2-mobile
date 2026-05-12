part of 'msme_workspace_page.dart';

class _MsmePageHeader extends StatelessWidget {
  const _MsmePageHeader({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String label;
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
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
            color: Color(0x28F97316),
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
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0x44FFFFFF)),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xCCFFFFFF),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
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
                if (subtitle.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xB3FFFFFF),
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
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
            key: ValueKey('${attribute.name}_${attribute.dimension}'),
            initialValue: dimensionOptions.contains(attribute.dimension)
                ? attribute.dimension
                : (dimensionOptions.isNotEmpty ? dimensionOptions.first : null),
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

class _MobileFacilityCalendar extends StatefulWidget {
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
  State<_MobileFacilityCalendar> createState() =>
      _MobileFacilityCalendarState();
}

class _MobileFacilityCalendarState extends State<_MobileFacilityCalendar> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    _displayedMonth = DateTime(widget.startDate.year, widget.startDate.month);
  }

  @override
  void didUpdateWidget(_MobileFacilityCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final DateTime newMonth = DateTime(
      widget.startDate.year,
      widget.startDate.month,
    );
    if (newMonth != _displayedMonth) {
      setState(() => _displayedMonth = newMonth);
    }
  }

  void _prevMonth() => setState(
    () => _displayedMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month - 1,
    ),
  );

  void _nextMonth() => setState(
    () => _displayedMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final DateTime todayNorm = DateTime(today.year, today.month, today.day);
    final DateTime startNorm = DateTime(
      widget.startDate.year,
      widget.startDate.month,
      widget.startDate.day,
    );
    final int safeDuration = widget.durationDays.clamp(1, 365);
    final int daysInMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    final int firstWeekday =
        DateTime(_displayedMonth.year, _displayedMonth.month, 1).weekday;
    final int startOffset = firstWeekday - 1;
    final int rows = ((startOffset + daysInMonth) / 7).ceil();

    final String facilityName =
        widget.selectedFacility?.trim().isEmpty ?? true
        ? 'No facility selected'
        : widget.selectedFacility!;
    final int totalCapacity = widget.sessions.fold<int>(
      0,
      (int total, _SessionDraft s) => total + s.capacity,
    );

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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              _CalendarNavButton(
                icon: Icons.chevron_left_rounded,
                onTap: _prevMonth,
              ),
              Expanded(
                child: Text(
                  _monthYearLabel(_displayedMonth),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF061A3A),
                  ),
                ),
              ),
              _CalendarNavButton(
                icon: Icons.chevron_right_rounded,
                onTap: _nextMonth,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <String>['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map(
                  (String d) => Expanded(
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF52657D),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 6),
          ...List<Widget>.generate(rows, (int rowIndex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: List<Widget>.generate(7, (int colIndex) {
                  final int day = rowIndex * 7 + colIndex - startOffset + 1;
                  if (day < 1 || day > daysInMonth) {
                    return const Expanded(child: SizedBox());
                  }
                  final DateTime cellDate = DateTime(
                    _displayedMonth.year,
                    _displayedMonth.month,
                    day,
                  );
                  final bool isPast = cellDate.isBefore(todayNorm);
                  final bool isToday = cellDate == todayNorm;
                  final int dayOffset = cellDate.difference(startNorm).inDays;
                  final bool inRange =
                      dayOffset >= 0 && dayOffset < safeDuration;
                  final bool isStart = dayOffset == 0;
                  final bool hasSessions = widget.sessions.any(
                    (_SessionDraft s) => s.dayOffset == dayOffset,
                  );
                  return Expanded(
                    child: _CalendarCell(
                      day: day,
                      isPast: isPast,
                      isToday: isToday,
                      inRange: inRange,
                      isStart: isStart,
                      hasSessions: hasSessions,
                      onTap: isPast
                          ? null
                          : () => widget.onDateSelected(cellDate),
                    ),
                  );
                }),
              ),
            );
          }),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: _CalendarMetric(
                  label: 'Duration',
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
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: <Widget>[
              _CalendarLegendDot(
                label: 'Start date',
                color: TaraTheme.primary,
              ),
              _CalendarLegendDot(
                label: 'Selected range',
                color: TaraTheme.primarySoft,
              ),
              const _CalendarLegendDot(
                label: 'Session',
                color: TaraTheme.dostBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _monthYearLabel(DateTime date) {
    const List<String> months = <String>[
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _CalendarNavButton extends StatelessWidget {
  const _CalendarNavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: TaraTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: TaraTheme.border),
        ),
        child: Icon(icon, size: 18, color: TaraTheme.textSecondary),
      ),
    );
  }
}

class _CalendarCell extends StatelessWidget {
  const _CalendarCell({
    required this.day,
    required this.isPast,
    required this.isToday,
    required this.inRange,
    required this.isStart,
    required this.hasSessions,
    required this.onTap,
  });

  final int day;
  final bool isPast;
  final bool isToday;
  final bool inRange;
  final bool isStart;
  final bool hasSessions;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color textColor;
    final Color? bgColor;
    final Border? border;

    if (isPast) {
      textColor = TaraTheme.textSecondary.withValues(alpha: 0.35);
      bgColor = null;
      border = null;
    } else if (isStart) {
      textColor = Colors.white;
      bgColor = TaraTheme.primary;
      border = null;
    } else if (inRange) {
      textColor = TaraTheme.primaryDark;
      bgColor = TaraTheme.primarySoft;
      border = null;
    } else if (isToday) {
      textColor = TaraTheme.primary;
      bgColor = null;
      border = Border.all(color: TaraTheme.primary, width: 1.5);
    } else {
      textColor = const Color(0xFF061A3A);
      bgColor = null;
      border = null;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: border,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              day.toString(),
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight:
                    isStart || inRange ? FontWeight.w800 : FontWeight.w500,
                height: 1,
              ),
            ),
            if (hasSessions) ...<Widget>[
              const SizedBox(height: 2),
              Container(
                height: 4,
                width: 4,
                decoration: const BoxDecoration(
                  color: TaraTheme.dostBlue,
                  shape: BoxShape.circle,
                ),
              ),
            ],
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

