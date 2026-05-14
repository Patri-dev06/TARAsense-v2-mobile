import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tarasense_mobile/core/network/api_error_formatter.dart';
import 'package:tarasense_mobile/core/theme/tara_theme.dart';
import 'package:tarasense_mobile/features/auth/state/auth_providers.dart';
import 'package:tarasense_mobile/features/tester/data/consumer_studies_api.dart';
import 'package:tarasense_mobile/features/tester/domain/consumer_study.dart';

enum _EntryStatus { open, upcoming, closed }

class ConsumerPanelEntryPage extends ConsumerStatefulWidget {
  const ConsumerPanelEntryPage({
    required this.studyId,
    this.study,
    super.key,
  });

  final String studyId;
  final ConsumerStudy? study;

  @override
  ConsumerState<ConsumerPanelEntryPage> createState() =>
      _ConsumerPanelEntryPageState();
}

class _ConsumerPanelEntryPageState
    extends ConsumerState<ConsumerPanelEntryPage> {
  final TextEditingController _panelController = TextEditingController();
  bool _isLookingUp = false;
  String? _errorText;

  @override
  void dispose() {
    _panelController.dispose();
    super.dispose();
  }

  String? get _accessToken =>
      ref.read(authControllerProvider).session?.tokens.accessToken;

  ConsumerStudyParticipation? get _knownParticipation =>
      widget.study?.myParticipation;

  _EntryStatus get _entryStatus {
    final ConsumerStudy? study = widget.study;
    if (study == null || study.schedules.isEmpty) return _EntryStatus.open;

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    final List<DateTime> slotDates = study.schedules
        .map((StudyScheduleSlot s) => s.startTime?.toLocal())
        .whereType<DateTime>()
        .map((DateTime d) => DateTime(d.year, d.month, d.day))
        .toList();

    if (slotDates.isEmpty) return _EntryStatus.open;
    if (slotDates.any((DateTime d) => d == today)) return _EntryStatus.open;
    if (slotDates.every((DateTime d) => d.isBefore(today))) {
      return _EntryStatus.closed;
    }
    return _EntryStatus.upcoming;
  }

  // Earliest upcoming (or today's) slot date — used for "upcoming" state.
  DateTime? get _upcomingDate {
    final ConsumerStudy? study = widget.study;
    if (study == null) return null;
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final List<DateTime> dates = study.schedules
        .map((StudyScheduleSlot s) => s.startTime?.toLocal())
        .whereType<DateTime>()
        .where((DateTime d) =>
            !DateTime(d.year, d.month, d.day).isBefore(today))
        .toList()
      ..sort();
    return dates.isNotEmpty ? dates.first : null;
  }

  // Latest slot date — used for "closed" state to show when the study last ran.
  DateTime? get _lastDate {
    final ConsumerStudy? study = widget.study;
    if (study == null) return null;
    final List<DateTime> dates = study.schedules
        .map((StudyScheduleSlot s) => s.startTime?.toLocal())
        .whereType<DateTime>()
        .toList()
      ..sort((DateTime a, DateTime b) => b.compareTo(a));
    return dates.isNotEmpty ? dates.first : null;
  }

  Future<void> _submit() async {
    final String raw = _panelController.text.trim();
    final int? number = int.tryParse(raw);

    if (raw.isEmpty) {
      setState(() => _errorText = 'Please enter your panel number.');
      return;
    }
    if (number == null || number <= 0) {
      setState(() => _errorText = 'Enter a valid panel number.');
      return;
    }

    setState(() {
      _isLookingUp = true;
      _errorText = null;
    });

    try {
      String participantId;

      final ConsumerStudyParticipation? known = _knownParticipation;
      if (known != null && known.panelistNumber > 0) {
        // Local validation — we know the assigned number.
        if (known.panelistNumber != number) {
          setState(() =>
              _errorText = 'Panel number does not match your registration.');
          return;
        }
        participantId = known.id;
      } else {
        // No cached number (either no participation record, or panelistNumber
        // was not returned by the server). Validate via the lookup endpoint.
        final String? token = _accessToken;
        if (token == null) throw StateError('Not authenticated.');
        final ConsumerStudyParticipation participation = await ref
            .read(consumerStudiesApiProvider)
            .lookupParticipantByPanelNumber(
              token,
              studyId: widget.studyId,
              panelistNumber: number,
            );
        // If the lookup succeeded but returned no ID, fall back to the known
        // participant record (handles servers that don't implement the endpoint).
        participantId = participation.id.trim().isNotEmpty
            ? participation.id
            : (known?.id ?? '');
      }

      if (!mounted) return;
      context.push(
        '/consumer/studies/${Uri.encodeComponent(widget.studyId)}/consent',
        extra: ConsumerConsentArgs(
          study: widget.study,
          participantId: participantId,
          panelistNumber: number,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      // If lookup fails but we have a known participation, surface a friendlier
      // message rather than a raw API error.
      final String msg = _knownParticipation != null
          ? 'Panel number not found. Please check the number on your registration slip.'
          : 'Panel number not found. ${formatApiError(error)}';
      setState(() => _errorText = msg);
    } finally {
      if (mounted) setState(() => _isLookingUp = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title =
        widget.study?.title.trim().isNotEmpty == true
            ? widget.study!.title
            : 'Study ${widget.studyId}';

    final _EntryStatus status = _entryStatus;
    final bool isOpen = status == _EntryStatus.open;
    final bool isClosed = status == _EntryStatus.closed;
    final bool isLocked = !isOpen;

    return Scaffold(
      backgroundColor: TaraTheme.background,
      appBar: AppBar(
        title: const Text('Enter Panel Number'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          children: <Widget>[
            // Icon hero
            Center(
              child: Container(
                height: 72,
                width: 72,
                decoration: BoxDecoration(
                  color: isOpen
                      ? TaraTheme.primaryTint
                      : isClosed
                          ? const Color(0xFFFFF1F2)
                          : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isOpen
                      ? Icons.pin_outlined
                      : isClosed
                          ? Icons.event_busy_outlined
                          : Icons.lock_outlined,
                  color: isOpen
                      ? TaraTheme.primary
                      : isClosed
                          ? TaraTheme.roseText
                          : const Color(0xFF94A3B8),
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isOpen
                  ? 'Enter your panel number'
                  : isClosed
                      ? 'Survey Period Has Concluded'
                      : 'Panel Entry Not Yet Available',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: isOpen
                    ? TaraTheme.textPrimary
                    : isClosed
                        ? TaraTheme.roseText
                        : const Color(0xFF64748B),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: TaraTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isLocked) ...<Widget>[
              const SizedBox(height: 20),
              _StatusBanner(
                date: isClosed ? _lastDate : _upcomingDate,
                isClosed: isClosed,
              ),
            ],
            const SizedBox(height: 32),
            // Input card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isOpen ? TaraTheme.surface : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isOpen
                      ? TaraTheme.border
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'PANEL NUMBER',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isOpen
                          ? TaraTheme.textSecondary
                          : const Color(0xFFCBD5E1),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _panelController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: isOpen
                          ? TaraTheme.textPrimary
                          : const Color(0xFFCBD5E1),
                      letterSpacing: -1,
                    ),
                    decoration: InputDecoration(
                      hintText: '—',
                      hintStyle: TextStyle(
                        color: isOpen
                            ? TaraTheme.border
                            : const Color(0xFFE2E8F0),
                        fontWeight: FontWeight.w900,
                        fontSize: 42,
                      ),
                      errorText: _errorText,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: TaraTheme.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isOpen
                              ? TaraTheme.border
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: TaraTheme.primary,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 16,
                      ),
                    ),
                    onSubmitted:
                        isLocked ? null : (_) => unawaited(_submit()),
                    enabled: !_isLookingUp && !isLocked,
                    onChanged: (_) {
                      if (_errorText != null) {
                        setState(() => _errorText = null);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isLocked
                        ? isClosed
                            ? 'This survey is no longer accepting responses.'
                            : 'Panel entry opens on the day of the event.'
                        : 'This is the number given to you when you registered for this study.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isOpen
                          ? TaraTheme.textSecondary
                          : const Color(0xFFCBD5E1),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isLocked || _isLookingUp
                    ? null
                    : () => unawaited(_submit()),
                icon: isLocked
                    ? Icon(isClosed
                        ? Icons.do_not_disturb_outlined
                        : Icons.lock_outlined)
                    : _isLookingUp
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.arrow_forward_rounded),
                label: Text(
                  isLocked
                      ? isClosed
                          ? 'Survey Concluded'
                          : 'Not Available Today'
                      : _isLookingUp
                          ? 'Looking up…'
                          : 'Continue',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: isLocked
                      ? isClosed
                          ? const Color(0xFFFEE2E2)
                          : const Color(0xFFE2E8F0)
                      : TaraTheme.primary,
                  foregroundColor: isLocked
                      ? isClosed
                          ? TaraTheme.roseText
                          : const Color(0xFF94A3B8)
                      : Colors.white,
                  disabledBackgroundColor: isLocked
                      ? isClosed
                          ? const Color(0xFFFEE2E2)
                          : const Color(0xFFE2E8F0)
                      : null,
                  disabledForegroundColor: isLocked
                      ? isClosed
                          ? TaraTheme.roseText
                          : const Color(0xFF94A3B8)
                      : null,
                  minimumSize: const Size(0, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({this.date, required this.isClosed});

  final DateTime? date;
  final bool isClosed;

  static const List<String> _months = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static const List<String> _weekdays = <String>[
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  String _formatDate(DateTime d) {
    final DateTime local = d.toLocal();
    final String weekday = _weekdays[local.weekday - 1];
    return '$weekday, ${_months[local.month - 1]} ${local.day}, ${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    final Color bg = isClosed
        ? const Color(0xFFFFF1F2)
        : const Color(0xFFF1F5F9);
    final Color border = isClosed
        ? const Color(0xFFFECACA)
        : const Color(0xFFE2E8F0);
    final Color iconColor = isClosed
        ? TaraTheme.roseText
        : const Color(0xFF64748B);
    final String eyebrow = isClosed ? 'CONCLUDED ON' : 'SCHEDULED FOR';
    final String dateLabel = date != null
        ? _formatDate(date!)
        : 'Schedule unavailable';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            isClosed
                ? Icons.event_busy_outlined
                : Icons.calendar_today_outlined,
            size: 18,
            color: iconColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  eyebrow,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: iconColor.withValues(alpha: 0.7),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  dateLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isClosed
                        ? TaraTheme.roseText
                        : const Color(0xFF475569),
                  ),
                ),
                if (isClosed) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    'Thank you for your interest. This survey is now closed.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: TaraTheme.roseText.withValues(alpha: 0.75),
                      height: 1.4,
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

/// Passed as route `extra` to the consent page.
class ConsumerConsentArgs {
  const ConsumerConsentArgs({
    required this.study,
    required this.participantId,
    this.panelistNumber,
  });

  final ConsumerStudy? study;
  final String participantId;
  final int? panelistNumber;
}
