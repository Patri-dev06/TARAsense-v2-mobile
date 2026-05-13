import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tarasense_mobile/core/theme/tara_theme.dart';
import 'package:tarasense_mobile/features/tester/domain/consumer_study.dart';

class ConsumerConsentPage extends StatefulWidget {
  const ConsumerConsentPage({
    required this.studyId,
    required this.participantId,
    this.study,
    this.panelistNumber,
    super.key,
  });

  final String studyId;
  final String participantId;
  final ConsumerStudy? study;
  final int? panelistNumber;

  @override
  State<ConsumerConsentPage> createState() => _ConsumerConsentPageState();
}

class _ConsumerConsentPageState extends State<ConsumerConsentPage> {
  bool _agreed = false;

  void _startTest() {
    final String encodedStudy = Uri.encodeComponent(widget.studyId);
    final String encodedParticipant = Uri.encodeComponent(widget.participantId);
    context.push(
      '/consumer/studies/$encodedStudy/participants/$encodedParticipant/test',
      extra: widget.study,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String title =
        widget.study?.title.trim().isNotEmpty == true
            ? widget.study!.title
            : 'Study ${widget.studyId}';
    final String owner =
        widget.study?.owner.trim().isNotEmpty == true
            ? widget.study!.owner
            : 'TARAsense';

    return Scaffold(
      backgroundColor: TaraTheme.background,
      appBar: AppBar(
        title: const Text('Consent Form'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                children: <Widget>[
                  // Study identity header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[Color(0xFFFB923C), TaraTheme.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          height: 42,
                          width: 42,
                          decoration: BoxDecoration(
                            color: const Color(0x33FFFFFF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0x44FFFFFF)),
                          ),
                          child: const Icon(
                            Icons.science_outlined,
                            color: Colors.white,
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
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                owner,
                                style: const TextStyle(
                                  color: Color(0xCCFFFFFF),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.panelistNumber != null) ...<Widget>[
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0x33FFFFFF),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0x44FFFFFF),
                              ),
                            ),
                            child: Column(
                              children: <Widget>[
                                const Text(
                                  'PANEL',
                                  style: TextStyle(
                                    color: Color(0xCCFFFFFF),
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                    height: 1,
                                  ),
                                ),
                                Text(
                                  '${widget.panelistNumber}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Consent form body
                  _ConsentSection(
                    icon: Icons.info_outline_rounded,
                    title: 'Purpose of Study',
                    body:
                        'This sensory evaluation is conducted to gather consumer '
                        'feedback on the product(s) listed in this study. Your '
                        'responses will help improve product quality and formulation.',
                  ),
                  const SizedBox(height: 10),
                  _ConsentSection(
                    icon: Icons.volunteer_activism_outlined,
                    title: 'Voluntary Participation',
                    body:
                        'Your participation is entirely voluntary. You may withdraw '
                        'at any time without penalty or loss of benefits.',
                  ),
                  const SizedBox(height: 10),
                  _ConsentSection(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Confidentiality',
                    body:
                        'All responses are anonymous and will be used for research '
                        'purposes only. Your personal information will not be '
                        'disclosed to third parties.',
                  ),
                  const SizedBox(height: 10),
                  _ConsentSection(
                    icon: Icons.restaurant_outlined,
                    title: 'Food Safety',
                    body:
                        'Please inform the study coordinator if you have any known '
                        'food allergies or dietary restrictions before proceeding. '
                        'Do not consume samples if you feel unwell.',
                  ),
                  const SizedBox(height: 10),
                  _ConsentSection(
                    icon: Icons.rule_outlined,
                    title: 'Instructions',
                    body:
                        '• Evaluate each sample in the order provided.\n'
                        '• Rinse your mouth with water between samples.\n'
                        '• Rate honestly — there are no right or wrong answers.\n'
                        '• Do not discuss your ratings with other participants.',
                  ),
                  const SizedBox(height: 20),

                  // Agreement checkbox
                  GestureDetector(
                    onTap: () => setState(() => _agreed = !_agreed),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _agreed
                            ? TaraTheme.primaryTint
                            : TaraTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _agreed ? TaraTheme.primary : TaraTheme.border,
                          width: _agreed ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            height: 22,
                            width: 22,
                            decoration: BoxDecoration(
                              color: _agreed
                                  ? TaraTheme.primary
                                  : TaraTheme.surface,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _agreed
                                    ? TaraTheme.primary
                                    : TaraTheme.border,
                                width: 1.5,
                              ),
                            ),
                            child: _agreed
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 15,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'I have read and understood the information above. '
                              'I voluntarily agree to participate in this sensory '
                              'evaluation study.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: TaraTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    height: 1.5,
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

            // Fixed bottom action bar
            Container(
              padding: EdgeInsets.fromLTRB(
                18,
                12,
                18,
                MediaQuery.paddingOf(context).bottom + 12,
              ),
              decoration: const BoxDecoration(
                color: TaraTheme.surface,
                border: Border(top: BorderSide(color: TaraTheme.border)),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _agreed ? _startTest : null,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('I Agree — Start Test'),
                      style: FilledButton.styleFrom(
                        backgroundColor: TaraTheme.primary,
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
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
    );
  }
}

class _ConsentSection extends StatelessWidget {
  const _ConsentSection({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: TaraTheme.primaryTint,
              borderRadius: BorderRadius.circular(9),
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: TaraTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: TaraTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                    height: 1.55,
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
