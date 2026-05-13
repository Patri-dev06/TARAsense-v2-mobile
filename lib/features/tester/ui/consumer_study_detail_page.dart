import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tarasense_mobile/core/network/api_error_formatter.dart';
import 'package:tarasense_mobile/core/theme/tara_theme.dart';
import 'package:tarasense_mobile/features/auth/state/auth_providers.dart';
import 'package:tarasense_mobile/features/tester/data/consumer_studies_api.dart';
import 'package:tarasense_mobile/features/tester/domain/consumer_study.dart';
import 'package:tarasense_mobile/features/tester/ui/consumer_panel_entry_page.dart';

// ─── Page ─────────────────────────────────────────────────────────────────────

class ConsumerStudyDetailPage extends ConsumerStatefulWidget {
  const ConsumerStudyDetailPage({
    required this.studyId,
    this.study,
    super.key,
  });

  final String studyId;
  final ConsumerStudy? study;

  @override
  ConsumerState<ConsumerStudyDetailPage> createState() =>
      _ConsumerStudyDetailPageState();
}

class _ConsumerStudyDetailPageState
    extends ConsumerState<ConsumerStudyDetailPage> {
  bool _isJoining = false;
  String? _selectedSlotId;

  String? get _accessToken =>
      ref.read(authControllerProvider).session?.tokens.accessToken;

  ConsumerStudyParticipation? get _myParticipation =>
      widget.study?.myParticipation;

  bool get _alreadyJoined =>
      _myParticipation != null && _myParticipation!.id.trim().isNotEmpty;

  Future<void> _joinStudy() async {
    final String? token = _accessToken;
    if (token == null || _isJoining) return;
    setState(() => _isJoining = true);
    try {
      final StudyScheduleSlot? selectedSlot = widget.study?.schedules
          .where((StudyScheduleSlot s) => s.id == _selectedSlotId)
          .firstOrNull;
      final String? requestedSessionAt =
          selectedSlot?.startTime?.toUtc().toIso8601String();
      final ConsumerJoinResult result = await ref
          .read(consumerStudiesApiProvider)
          .joinStudy(
            token,
            studyId: widget.studyId,
            requestedSessionAt: requestedSessionAt,
          );
      if (!mounted) return;
      await _showPanelNumberSheet(result);
    } on StudyAlreadyJoinedException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You\'re already registered for this study.'),
        ),
      );
      _openPanelEntry();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(formatApiError(error))),
      );
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  Future<void> _showPanelNumberSheet(ConsumerJoinResult result) {
    return showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _PanelNumberSheet(
        panelistNumber: result.panelistNumber,
        studyTitle: widget.study?.title ?? 'Study',
        onContinue: () {
          Navigator.of(context).pop();
          context.push(
            '/consumer/studies/${Uri.encodeComponent(widget.studyId)}/consent',
            extra: ConsumerConsentArgs(
              study: widget.study,
              participantId: result.participantId,
              panelistNumber: result.panelistNumber > 0
                  ? result.panelistNumber
                  : null,
            ),
          );
        },
      ),
    );
  }

  void _openPanelEntry() {
    final ConsumerStudyParticipation? participation = _myParticipation;
    if (participation != null && participation.id.trim().isNotEmpty) {
      // participantId already known — skip panel lookup, go straight to consent
      context.push(
        '/consumer/studies/${Uri.encodeComponent(widget.studyId)}/consent',
        extra: ConsumerConsentArgs(
          study: widget.study,
          participantId: participation.id,
          panelistNumber: participation.panelistNumber > 0
              ? participation.panelistNumber
              : null,
        ),
      );
    } else {
      context.push(
        '/consumer/studies/${Uri.encodeComponent(widget.studyId)}/panel-entry',
        extra: widget.study,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ConsumerStudy? study = widget.study;

    return Scaffold(
      backgroundColor: TaraTheme.background,
      appBar: AppBar(
        title: const Text('Study Details'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 32),
          children: <Widget>[
            _StudyHeroCard(study: study, studyId: widget.studyId),
            const SizedBox(height: 14),
            if (_alreadyJoined) ...<Widget>[
              _AlreadyJoinedCard(
                participation: _myParticipation!,
                onEnterTest: _openPanelEntry,
              ),
            ] else ...<Widget>[
              if (study != null && study.schedules.isNotEmpty)
                _ScheduleSection(
                  slots: study.schedules,
                  selectedSlotId: _selectedSlotId,
                  onSlotSelected: (String id) =>
                      setState(() => _selectedSlotId = id),
                )
              else
                _SessionInfoCard(session: study?.session ?? ''),
              const SizedBox(height: 20),
              _JoinButton(
                isJoining: _isJoining,
                canJoin: study == null ||
                    study.schedules.isEmpty ||
                    _selectedSlotId != null,
                onJoin: () => unawaited(_joinStudy()),
              ),
              const SizedBox(height: 10),
              _AlreadyRegisteredLink(onTap: _openPanelEntry),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Study hero card ──────────────────────────────────────────────────────────

class _StudyHeroCard extends StatelessWidget {
  const _StudyHeroCard({required this.study, required this.studyId});

  final ConsumerStudy? study;
  final String studyId;

  @override
  Widget build(BuildContext context) {
    final String title =
        study?.title.trim().isNotEmpty == true
            ? study!.title
            : 'Study $studyId';
    final String owner =
        study?.owner.trim().isNotEmpty == true ? study!.owner : 'TARAsense';
    final int slotsLeft = study?.slotsLeft ?? 0;
    final int capacity = study?.capacity ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: TaraTheme.primaryTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.science_outlined,
                  color: TaraTheme.primaryDark,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: TaraTheme.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      owner,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: TaraTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (study != null) ...<Widget>[
            const SizedBox(height: 14),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: <Widget>[
                if (study!.category.trim().isNotEmpty && study!.category != '-')
                  _Chip(label: study!.category),
                if (study!.stage.trim().isNotEmpty && study!.stage != '-')
                  _Chip(label: study!.stage, subdued: true),
                if (study!.session.trim().isNotEmpty)
                  _Chip(
                    label: study!.session,
                    subdued: true,
                    icon: Icons.schedule_rounded,
                  ),
              ],
            ),
            if (capacity > 0) ...<Widget>[
              const SizedBox(height: 14),
              _CapacityBar(slotsLeft: slotsLeft, capacity: capacity),
            ],
          ],
        ],
      ),
    );
  }
}

// ─── Already joined card ──────────────────────────────────────────────────────

class _AlreadyJoinedCard extends StatelessWidget {
  const _AlreadyJoinedCard({
    required this.participation,
    required this.onEnterTest,
  });

  final ConsumerStudyParticipation participation;
  final VoidCallback onEnterTest;

  @override
  Widget build(BuildContext context) {
    final int number = participation.panelistNumber;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF8D9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: TaraTheme.mintText,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'You\'re registered',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: TaraTheme.textPrimary,
                ),
              ),
            ],
          ),
          if (number > 0) ...<Widget>[
            const SizedBox(height: 16),
            Text(
              'YOUR PANEL NUMBER',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: TaraTheme.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$number',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: TaraTheme.primary,
                height: 1,
                letterSpacing: -1,
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onEnterTest,
              icon: const Icon(Icons.login_rounded),
              label: const Text('Enter Panel Number to Start'),
              style: FilledButton.styleFrom(
                backgroundColor: TaraTheme.primary,
                minimumSize: const Size(0, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Session info card ────────────────────────────────────────────────────────

class _SessionInfoCard extends StatelessWidget {
  const _SessionInfoCard({required this.session});

  final String session;

  @override
  Widget build(BuildContext context) {
    final String label = session.trim().isEmpty ? 'Schedule to be announced' : session;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.schedule_rounded, size: 16, color: TaraTheme.primaryDark),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'SCHEDULE',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: TaraTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TaraTheme.textPrimary,
                    fontWeight: FontWeight.w700,
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

// ─── Join button ──────────────────────────────────────────────────────────────

class _JoinButton extends StatelessWidget {
  const _JoinButton({
    required this.isJoining,
    required this.canJoin,
    required this.onJoin,
  });

  final bool isJoining;
  final bool canJoin;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final bool enabled = !isJoining && canJoin;
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: enabled ? onJoin : null,
        icon: isJoining
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.how_to_reg_rounded),
        label: Text(
          isJoining
              ? 'Registering…'
              : canJoin
                  ? 'Join Study'
                  : 'Select a Schedule First',
        ),
        style: FilledButton.styleFrom(
          backgroundColor: TaraTheme.primary,
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          textStyle:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    );
  }
}

// ─── Panel number bottom sheet ────────────────────────────────────────────────

class _PanelNumberSheet extends StatelessWidget {
  const _PanelNumberSheet({
    required this.panelistNumber,
    required this.studyTitle,
    required this.onContinue,
  });

  final int panelistNumber;
  final String studyTitle;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: TaraTheme.border,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: TaraTheme.primaryTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.badge_outlined,
              color: TaraTheme.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'You\'re registered!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: TaraTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            studyTitle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: TaraTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          if (panelistNumber > 0) ...<Widget>[
            Text(
              'YOUR PANEL NUMBER',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: TaraTheme.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                color: TaraTheme.primaryTint,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFD8B5), width: 1.5),
              ),
              child: Text(
                '$panelistNumber',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: TaraTheme.primary,
                  height: 1,
                  letterSpacing: -2,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Remember this number — you\'ll need it to start your evaluation.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: TaraTheme.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ] else ...<Widget>[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: TaraTheme.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: TaraTheme.border),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: TaraTheme.primaryDark,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your panel number will be provided by the study coordinator at the testing facility.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: TaraTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onContinue,
              icon: const Icon(Icons.login_rounded),
              label: const Text('Enter Panel Number'),
              style: FilledButton.styleFrom(
                backgroundColor: TaraTheme.primary,
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
    );
  }
}

// ─── Schedule section ─────────────────────────────────────────────────────────

class _ScheduleSection extends StatelessWidget {
  const _ScheduleSection({
    required this.slots,
    required this.selectedSlotId,
    required this.onSlotSelected,
  });

  final List<StudyScheduleSlot> slots;
  final String? selectedSlotId;
  final ValueChanged<String> onSlotSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.schedule_rounded,
                size: 15,
                color: TaraTheme.primaryDark,
              ),
              const SizedBox(width: 7),
              Text(
                'SELECT SCHEDULE',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: TaraTheme.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.05,
            children: slots
                .map(
                  (StudyScheduleSlot slot) => _SlotTile(
                    slot: slot,
                    isSelected: slot.id == selectedSlotId,
                    onTap: slot.isFull
                        ? null
                        : () => onSlotSelected(slot.id),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SlotTile extends StatelessWidget {
  const _SlotTile({
    required this.slot,
    required this.isSelected,
    this.onTap,
  });

  final StudyScheduleSlot slot;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isFull = slot.isFull;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? TaraTheme.primaryTint : TaraTheme.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? TaraTheme.primary : TaraTheme.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 18,
                width: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? TaraTheme.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? TaraTheme.primary : TaraTheme.border,
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 10,
                      )
                    : null,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  slot.label,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isFull
                        ? TaraTheme.textSecondary
                        : TaraTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ),
            ),
            if (isFull)
              const Text(
                'FULL',
                style: TextStyle(
                  color: TaraTheme.roseText,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              )
            else
              Text(
                '${slot.slotsLeft} left',
                style: TextStyle(
                  color: slot.slotsLeft <= 5
                      ? const Color(0xFFF59E0B)
                      : TaraTheme.mintText,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Already registered link ──────────────────────────────────────────────────

class _AlreadyRegisteredLink extends StatelessWidget {
  const _AlreadyRegisteredLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.badge_outlined,
              size: 15,
              color: TaraTheme.primaryDark,
            ),
            const SizedBox(width: 6),
            Text(
              'Already registered? Enter your panel number',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: TaraTheme.primaryDark,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
                decorationColor: TaraTheme.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Small shared widgets ─────────────────────────────────────────────────────

class _CapacityBar extends StatelessWidget {
  const _CapacityBar({required this.slotsLeft, required this.capacity});

  final int slotsLeft;
  final int capacity;

  @override
  Widget build(BuildContext context) {
    final double filled =
        capacity > 0 ? ((capacity - slotsLeft) / capacity).clamp(0.0, 1.0) : 0;
    final Color barColor = slotsLeft == 0
        ? TaraTheme.roseText
        : slotsLeft <= 5
        ? const Color(0xFFF59E0B)
        : TaraTheme.mintText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              '$slotsLeft slots remaining',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: TaraTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '$capacity total',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: TaraTheme.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: filled,
            minHeight: 6,
            backgroundColor: TaraTheme.border,
            color: barColor,
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.subdued = false, this.icon});

  final String label;
  final bool subdued;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final Color bg = subdued ? TaraTheme.background : TaraTheme.primaryTint;
    final Color fg = subdued ? TaraTheme.textSecondary : TaraTheme.primaryDark;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: icon != null ? 8 : 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 11, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

