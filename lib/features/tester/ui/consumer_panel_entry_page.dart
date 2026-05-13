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

  // If the consumer already has a participation record, we can skip the API
  // lookup and simply validate that the number matches.
  ConsumerStudyParticipation? get _knownParticipation =>
      widget.study?.myParticipation;

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
      if (known != null && known.panelistNumber == number) {
        participantId = known.id;
      } else {
        // Look up by panel number via API
        final String? token = _accessToken;
        if (token == null) throw StateError('Not authenticated.');
        final ConsumerStudyParticipation participation = await ref
            .read(consumerStudiesApiProvider)
            .lookupParticipantByPanelNumber(
              token,
              studyId: widget.studyId,
              panelistNumber: number,
            );
        participantId = participation.id;
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
      setState(
        () => _errorText =
            'Panel number not found. ${formatApiError(error)}',
      );
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
                  color: TaraTheme.primaryTint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pin_outlined,
                  color: TaraTheme.primary,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Enter your panel number',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: TaraTheme.textPrimary,
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
            const SizedBox(height: 32),
            // Input
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TaraTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: TaraTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'PANEL NUMBER',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: TaraTheme.textSecondary,
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
                      color: TaraTheme.textPrimary,
                      letterSpacing: -1,
                    ),
                    decoration: InputDecoration(
                      hintText: '—',
                      hintStyle: TextStyle(
                        color: TaraTheme.border,
                        fontWeight: FontWeight.w900,
                        fontSize: 42,
                      ),
                      errorText: _errorText,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: TaraTheme.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: TaraTheme.border),
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
                    onSubmitted: (_) => unawaited(_submit()),
                    enabled: !_isLookingUp,
                    onChanged: (_) {
                      if (_errorText != null) {
                        setState(() => _errorText = null);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This is the number given to you when you registered for this study.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: TaraTheme.textSecondary,
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
                onPressed: _isLookingUp ? null : () => unawaited(_submit()),
                icon: _isLookingUp
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.arrow_forward_rounded),
                label: Text(_isLookingUp ? 'Looking up…' : 'Continue'),
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
