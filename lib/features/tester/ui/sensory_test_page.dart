import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tarasense_mobile/core/network/api_error_formatter.dart';
import 'package:tarasense_mobile/core/theme/tara_theme.dart';
import 'package:tarasense_mobile/features/auth/state/auth_providers.dart';
import 'package:tarasense_mobile/features/tester/data/consumer_studies_api.dart';
import 'package:tarasense_mobile/features/tester/domain/consumer_study.dart';

enum _TestPhase { instructions, sample, rest, ranking, comments, submitted }

class SensoryTestPage extends ConsumerStatefulWidget {
  const SensoryTestPage({
    required this.studyId,
    this.participantId,
    this.initialStudy,
    super.key,
  });

  final String studyId;
  final String? participantId;
  final ConsumerStudy? initialStudy;

  @override
  ConsumerState<SensoryTestPage> createState() => _SensoryTestPageState();
}

class _SensoryTestPageState extends ConsumerState<SensoryTestPage> {
  final TextEditingController _likedMostController = TextEditingController();
  final TextEditingController _improvementsController = TextEditingController();

  ConsumerStudy? _loadedStudy;
  bool _isLoadingTest = false;
  bool _isSubmitting = false;
  String? _loadError;
  ConsumerStudyResponseSubmission? _submissionResult;

  _TestPhase _phase = _TestPhase.instructions;
  int _sampleIndex = 0;
  int _questionIndex = 0;
  int _restSeconds = 30;
  Timer? _restTimer;
  String? _validationMessage;

  final Map<int, Map<String, dynamic>> _sampleAnswers =
      <int, Map<String, dynamic>>{};
  final Map<int, Map<String, dynamic>> _sampleResponses =
      <int, Map<String, dynamic>>{};
  final Map<int, int> _ranking = <int, int>{};

  ConsumerStudy get _study =>
      _loadedStudy ??
      widget.initialStudy ??
      ConsumerStudy(
        id: widget.studyId,
        title: 'Sensory Test',
        owner: 'TARAsense',
        category: 'Product',
        stage: 'Evaluation',
        status: 'AVAILABLE',
        session: 'Schedule to be announced | Testing site',
        selected: 0,
        capacity: 0,
        sampleCount: 1,
        sampleCodes: const <String>[],
        attributes: const <ConsumerStudyAttribute>[
          ConsumerStudyAttribute(
            name: 'Overall Liking',
            type: 'OVERALL_LIKING',
          ),
        ],
        commentQuestions: const <String>[],
        myParticipation: null,
        participantId: widget.participantId ?? '',
      );

  List<String> get _sampleCodes {
    final ConsumerStudy study = _study;
    if (study.sampleCodes.length >= study.sampleCount) {
      return study.sampleCodes.take(study.sampleCount).toList();
    }
    return List<String>.generate(study.sampleCount.clamp(1, 24), (int index) {
      if (index < study.sampleCodes.length) {
        return study.sampleCodes[index];
      }
      return ((482 + (index * 237)) % 900 + 100).toString();
    });
  }

  List<ConsumerStudyAttribute> get _questions => _study.attributes;

  ConsumerStudyAttribute get _currentQuestion => _questions[_questionIndex];

  String get _effectiveParticipantId {
    final String fromRoute = widget.participantId?.trim() ?? '';
    if (fromRoute.isNotEmpty) {
      return fromRoute;
    }
    final String fromLoaded = _loadedStudy?.participantId.trim() ?? '';
    if (fromLoaded.isNotEmpty) {
      return fromLoaded;
    }
    return widget.initialStudy?.participantId.trim() ?? '';
  }

  String get _phaseLabel {
    switch (_phase) {
      case _TestPhase.instructions:
        return 'Instructions';
      case _TestPhase.sample:
        return 'Sample';
      case _TestPhase.rest:
        return 'Rest';
      case _TestPhase.ranking:
        return 'Ranking';
      case _TestPhase.comments:
        return 'Comments';
      case _TestPhase.submitted:
        return 'Ready';
    }
  }

  double get _progress {
    final int sampleQuestionCount = _sampleCodes.length * _questions.length;
    final int answered =
        _sampleResponses.length * _questions.length +
        (_phase == _TestPhase.sample ? _questionIndex : 0);
    final int extraSteps = _sampleCodes.length > 1 ? 2 : 1;
    final int phaseOffset = _phase == _TestPhase.instructions
        ? 0
        : _phase == _TestPhase.ranking
        ? sampleQuestionCount
        : _phase == _TestPhase.comments || _phase == _TestPhase.submitted
        ? sampleQuestionCount + extraSteps
        : answered;
    return (phaseOffset / (sampleQuestionCount + extraSteps + 1))
        .clamp(0.04, 1)
        .toDouble();
  }

  @override
  void initState() {
    super.initState();
    unawaited(_loadTestDefinition());
  }

  @override
  void didUpdateWidget(covariant SensoryTestPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.studyId != widget.studyId ||
        oldWidget.participantId != widget.participantId) {
      unawaited(_loadTestDefinition());
    }
  }

  Future<void> _loadTestDefinition() async {
    final String participantId = _effectiveParticipantId;
    if (widget.studyId.trim().isEmpty || participantId.isEmpty) {
      return;
    }
    final String accessToken =
        ref.read(authControllerProvider).session?.tokens.accessToken ?? '';
    if (accessToken.trim().isEmpty) {
      return;
    }
    setState(() {
      _isLoadingTest = true;
      _loadError = null;
    });
    try {
      final ConsumerStudy study = await ref
          .read(consumerStudiesApiProvider)
          .fetchStudyTest(
            accessToken,
            studyId: widget.studyId,
            participantId: participantId,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _loadedStudy = study;
        _phase = _TestPhase.instructions;
        _sampleIndex = 0;
        _questionIndex = 0;
        _sampleAnswers.clear();
        _sampleResponses.clear();
        _ranking.clear();
        _submissionResult = null;
        _isLoadingTest = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadError = formatApiError(error, includeUri: true);
        _isLoadingTest = false;
      });
    }
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    _likedMostController.dispose();
    _improvementsController.dispose();
    super.dispose();
  }

  void _startEvaluation() {
    setState(() {
      _phase = _TestPhase.sample;
      _validationMessage = null;
    });
  }

  void _selectAnswer(dynamic value) {
    setState(() {
      _sampleAnswers.putIfAbsent(
        _sampleIndex,
        () => <String, dynamic>{},
      )[_currentQuestion.name] = value;
      _validationMessage = null;
    });
  }

  void _continueSample() {
    final Map<String, dynamic> answers =
        _sampleAnswers[_sampleIndex] ?? <String, dynamic>{};
    if (!answers.containsKey(_currentQuestion.name)) {
      setState(() {
        _validationMessage = 'Choose a response before continuing.';
      });
      return;
    }

    if (_questionIndex < _questions.length - 1) {
      setState(() {
        _questionIndex += 1;
        _validationMessage = null;
      });
      return;
    }

    _sampleResponses[_sampleIndex] = Map<String, dynamic>.from(answers);
    if (_sampleIndex < _sampleCodes.length - 1) {
      _beginRest();
      return;
    }

    setState(() {
      _phase = _sampleCodes.length > 1
          ? _TestPhase.ranking
          : _TestPhase.comments;
      _validationMessage = null;
    });
  }

  void _beginRest() {
    _restTimer?.cancel();
    setState(() {
      _phase = _TestPhase.rest;
      _restSeconds = 30;
      _validationMessage = null;
    });
    _restTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_restSeconds <= 1) {
        timer.cancel();
        setState(() {
          _sampleIndex += 1;
          _questionIndex = 0;
          _phase = _TestPhase.sample;
          _restSeconds = 30;
        });
        return;
      }
      setState(() => _restSeconds -= 1);
    });
  }

  void _continueRanking() {
    if (_ranking.length != _sampleCodes.length) {
      setState(() {
        _validationMessage = 'Assign a rank to every sample.';
      });
      return;
    }
    if (_ranking.values.toSet().length != _sampleCodes.length) {
      setState(() {
        _validationMessage = 'Each rank can only be used once.';
      });
      return;
    }
    setState(() {
      _phase = _TestPhase.comments;
      _validationMessage = null;
    });
  }

  Future<void> _submitResponse() async {
    if (_isSubmitting) {
      return;
    }
    final String participantId = _effectiveParticipantId;
    if (participantId.isEmpty) {
      setState(() {
        _validationMessage =
            'This study does not have a confirmed participant record yet.';
      });
      return;
    }
    final String accessToken =
        ref.read(authControllerProvider).session?.tokens.accessToken ?? '';
    if (accessToken.trim().isEmpty) {
      setState(() {
        _validationMessage = 'Please sign in again before submitting.';
      });
      return;
    }

    final Map<String, dynamic> payload = _buildPayload();
    setState(() {
      _isSubmitting = true;
      _validationMessage = null;
    });
    try {
      final ConsumerStudyResponseSubmission result = await ref
          .read(consumerStudiesApiProvider)
          .submitStudyResponse(
            accessToken,
            studyId: widget.studyId,
            participantId: participantId,
            payload: payload,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _submissionResult = result;
        _phase = _TestPhase.submitted;
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.alreadySubmitted
                ? 'This response was already submitted.'
                : 'Sensory response submitted.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _validationMessage = formatApiError(error, includeUri: true);
        _isSubmitting = false;
      });
    }
  }

  Map<String, dynamic> _buildPayload() {
    final List<Map<String, dynamic>> sampleResponses = _sampleCodes
        .asMap()
        .entries
        .map((MapEntry<int, String> entry) {
          final Map<String, dynamic> attributes = _submissionAttributesFor(
            _sampleResponses[entry.key] ?? <String, dynamic>{},
          );
          final int? overallLiking = _overallLiking(attributes);
          final Map<String, dynamic> response = <String, dynamic>{
            'sampleNumber': entry.key + 1,
            'attributes': attributes,
          };
          if (overallLiking != null) {
            response['overallLiking'] = overallLiking;
          }
          return response;
        })
        .toList();
    final Map<String, dynamic> firstAttributes = sampleResponses.isEmpty
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(sampleResponses.first['attributes'] as Map);
    final int? overallLiking = sampleResponses.isEmpty
        ? null
        : sampleResponses.first['overallLiking'] as int?;
    final List<MapEntry<int, int>> rankingEntries = _ranking.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final Map<String, dynamic> payload = <String, dynamic>{
      'attributes': firstAttributes,
      'sampleResponses': sampleResponses,
      'sampleRanking': _sampleCodes.length <= 1
          ? <Map<String, dynamic>>[]
          : rankingEntries
                .map(
                  (MapEntry<int, int> entry) => <String, dynamic>{
                    'sampleNumber': entry.key + 1,
                    'rank': entry.value,
                  },
                )
                .toList(),
      'comments': <String, dynamic>{
        'likedMost': _likedMostController.text.trim(),
        'improvements': _improvementsController.text.trim(),
      },
      'submittedAt': DateTime.now().toUtc().toIso8601String(),
    };
    if (overallLiking != null) {
      payload['overallLiking'] = overallLiking;
    }
    return payload;
  }

  Map<String, dynamic> _submissionAttributesFor(Map<String, dynamic> answers) {
    return <String, dynamic>{
      for (final ConsumerStudyAttribute question in _questions)
        if (answers.containsKey(question.name))
          question.name: _submissionValueFor(question, answers[question.name]),
    };
  }

  dynamic _submissionValueFor(ConsumerStudyAttribute question, dynamic value) {
    if (!question.isJar) {
      return value;
    }
    if (value is Map) {
      return value['bucket']?.toString() ?? '';
    }
    return value;
  }

  int? _overallLiking(Map<String, dynamic> attributes) {
    for (final ConsumerStudyAttribute question in _questions) {
      if (question.isOverallLiking && attributes[question.name] is int) {
        return attributes[question.name] as int;
      }
    }
    return null;
  }

  String _likedMostLabel() {
    return _study.commentQuestions.firstWhere(
      (String item) => item.toLowerCase().contains('like'),
      orElse: () => 'What did you like most about the product?',
    );
  }

  String _improvementsLabel() {
    return _study.commentQuestions.firstWhere(
      (String item) =>
          item.toLowerCase().contains('improve') ||
          item.toLowerCase().contains('better'),
      orElse: () => 'What should be improved?',
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currentCode =
        _phase == _TestPhase.sample || _phase == _TestPhase.rest
        ? _sampleCodes[_sampleIndex]
        : '';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F4),
      appBar: AppBar(
        title: const Text('Sensory Test'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _TestHeader(
              productName: _study.title,
              phaseLabel: _phaseLabel,
              sampleCode: currentCode,
              progress: _progress,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                children: <Widget>[
                  if (_isLoadingTest) ...<Widget>[
                    const _TestStatusPanel(
                      icon: Icons.sync_rounded,
                      title: 'Loading test setup',
                      message: 'Getting the latest samples and questions.',
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (_loadError != null) ...<Widget>[
                    _TestStatusPanel(
                      icon: Icons.wifi_off_rounded,
                      title: 'Could not load live test setup',
                      message: _loadError!,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (_phase == _TestPhase.instructions)
                    _InstructionsPanel(
                      sampleCount: _sampleCodes.length,
                      participantReady: _effectiveParticipantId.isNotEmpty,
                      onStart: _startEvaluation,
                    )
                  else if (_phase == _TestPhase.sample)
                    _SampleQuestionPanel(
                      sampleCode: currentCode,
                      question: _currentQuestion,
                      selectedValue:
                          _sampleAnswers[_sampleIndex]?[_currentQuestion.name],
                      validationMessage: _validationMessage,
                      onSelected: _selectAnswer,
                      onContinue: _continueSample,
                    )
                  else if (_phase == _TestPhase.rest)
                    _RestPanel(
                      completedCode: _sampleCodes[_sampleIndex],
                      nextCode: _sampleCodes[_sampleIndex + 1],
                      seconds: _restSeconds,
                    )
                  else if (_phase == _TestPhase.ranking)
                    _RankingPanel(
                      sampleCodes: _sampleCodes,
                      ranking: _ranking,
                      validationMessage: _validationMessage,
                      onChanged: (int sampleIndex, int? rank) {
                        setState(() {
                          if (rank == null) {
                            _ranking.remove(sampleIndex);
                          } else {
                            _ranking[sampleIndex] = rank;
                          }
                          _validationMessage = null;
                        });
                      },
                      onContinue: _continueRanking,
                    )
                  else if (_phase == _TestPhase.comments)
                    _CommentsPanel(
                      likedMostLabel: _likedMostLabel(),
                      improvementsLabel: _improvementsLabel(),
                      likedMostController: _likedMostController,
                      improvementsController: _improvementsController,
                      isSubmitting: _isSubmitting,
                      validationMessage: _validationMessage,
                      onSubmit: _submitResponse,
                    )
                  else
                    _SubmittedPanel(
                      result: _submissionResult,
                      onDone: () => context.go('/consumer'),
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

class _TestHeader extends StatelessWidget {
  const _TestHeader({
    required this.productName,
    required this.phaseLabel,
    required this.sampleCode,
    required this.progress,
  });

  final String productName;
  final String phaseLabel;
  final String sampleCode;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      decoration: const BoxDecoration(
        color: TaraTheme.surface,
        border: Border(bottom: BorderSide(color: TaraTheme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            productName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: TaraTheme.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              _HeaderPill(label: phaseLabel),
              if (sampleCode.isNotEmpty) ...<Widget>[
                const SizedBox(width: 8),
                _HeaderPill(label: 'Sample $sampleCode'),
              ],
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: const Color(0xFFE5E7EB),
              color: TaraTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionsPanel extends StatelessWidget {
  const _InstructionsPanel({
    required this.sampleCount,
    required this.participantReady,
    required this.onStart,
  });

  final int sampleCount;
  final bool participantReady;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return _TestPanel(
      icon: Icons.info_outline_rounded,
      title: 'Instructions to Panelist',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'You will evaluate $sampleCount product sample(s).',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 14),
          const _InstructionLine(text: 'Taste samples in order.'),
          const _InstructionLine(
            text: 'Rinse mouth with water between samples.',
          ),
          const _InstructionLine(text: 'There are no right or wrong answers.'),
          if (!participantReady) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              'A confirmed participant record is required before answering this score sheet.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: TaraTheme.roseText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: participantReady ? onStart : null,
              child: const Text('Start Evaluation'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TestStatusPanel extends StatelessWidget {
  const _TestStatusPanel({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return _TestPanel(
      icon: icon,
      title: title,
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: TaraTheme.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SampleQuestionPanel extends StatelessWidget {
  const _SampleQuestionPanel({
    required this.sampleCode,
    required this.question,
    required this.selectedValue,
    required this.validationMessage,
    required this.onSelected,
    required this.onContinue,
  });

  final String sampleCode;
  final ConsumerStudyAttribute question;
  final dynamic selectedValue;
  final String? validationMessage;
  final ValueChanged<dynamic> onSelected;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final List<_ScaleOption> options = question.isJar
        ? _jarOptions(question.jarOptions)
        : _likingOptions;

    return _TestPanel(
      icon: Icons.science_outlined,
      title: 'Sample code: $sampleCode',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            question.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: TaraTheme.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          ...options.map(
            (_ScaleOption option) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ScaleButton(
                option: option,
                selected: _isSelectedScaleValue(
                  selectedValue,
                  option.value,
                  jar: question.isJar,
                ),
                onTap: () => onSelected(
                  question.isJar ? _jarValue(option.value) : option.value,
                ),
              ),
            ),
          ),
          if (validationMessage != null) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              validationMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: TaraTheme.roseText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onContinue,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RestPanel extends StatelessWidget {
  const _RestPanel({
    required this.completedCode,
    required this.nextCode,
    required this.seconds,
  });

  final String completedCode;
  final String nextCode;
  final int seconds;

  @override
  Widget build(BuildContext context) {
    return _TestPanel(
      icon: Icons.hourglass_bottom_rounded,
      title: 'Sample $completedCode completed',
      child: Column(
        children: <Widget>[
          Text(
            'Please wait before proceeding to Sample $nextCode',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 18),
          Text(
            '${seconds}s',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: TaraTheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Use this time to rinse your mouth with water.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _RankingPanel extends StatelessWidget {
  const _RankingPanel({
    required this.sampleCodes,
    required this.ranking,
    required this.validationMessage,
    required this.onChanged,
    required this.onContinue,
  });

  final List<String> sampleCodes;
  final Map<int, int> ranking;
  final String? validationMessage;
  final void Function(int sampleIndex, int? rank) onChanged;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return _TestPanel(
      icon: Icons.format_list_numbered_rounded,
      title: 'Rank Samples',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '1 = Most Preferred, ${sampleCodes.length} = Least Preferred',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          ...sampleCodes.asMap().entries.map(
            (MapEntry<int, String> entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DropdownButtonFormField<int>(
                initialValue: ranking[entry.key],
                decoration: InputDecoration(labelText: 'Sample ${entry.value}'),
                items: List<DropdownMenuItem<int>>.generate(
                  sampleCodes.length,
                  (int index) => DropdownMenuItem<int>(
                    value: index + 1,
                    child: Text('Rank ${index + 1}'),
                  ),
                ),
                onChanged: (int? value) => onChanged(entry.key, value),
              ),
            ),
          ),
          if (validationMessage != null)
            Text(
              validationMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: TaraTheme.roseText,
                fontWeight: FontWeight.w700,
              ),
            ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onContinue,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentsPanel extends StatelessWidget {
  const _CommentsPanel({
    required this.likedMostLabel,
    required this.improvementsLabel,
    required this.likedMostController,
    required this.improvementsController,
    required this.isSubmitting,
    required this.validationMessage,
    required this.onSubmit,
  });

  final String likedMostLabel;
  final String improvementsLabel;
  final TextEditingController likedMostController;
  final TextEditingController improvementsController;
  final bool isSubmitting;
  final String? validationMessage;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return _TestPanel(
      icon: Icons.rate_review_outlined,
      title: 'Final Comments',
      child: Column(
        children: <Widget>[
          TextField(
            controller: likedMostController,
            maxLength: 2000,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(labelText: likedMostLabel),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: improvementsController,
            maxLength: 2000,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(labelText: improvementsLabel),
          ),
          if (validationMessage != null) ...<Widget>[
            const SizedBox(height: 2),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                validationMessage!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: TaraTheme.roseText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isSubmitting ? null : onSubmit,
              child: isSubmitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit Response'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmittedPanel extends StatelessWidget {
  const _SubmittedPanel({required this.result, required this.onDone});

  final ConsumerStudyResponseSubmission? result;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final bool alreadySubmitted = result?.alreadySubmitted ?? false;
    final String? responseId = result?.responseId;
    final String participantStatus = result?.participantStatus ?? 'COMPLETED';
    return _TestPanel(
      icon: Icons.check_circle_outline_rounded,
      title: alreadySubmitted ? 'Already Submitted' : 'Response Submitted',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            alreadySubmitted
                ? 'The server has already recorded this sensory response.'
                : 'Your sensory score sheet was saved successfully.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          _SubmittedDetail(
            label: 'Participant status',
            value: participantStatus,
          ),
          if (responseId != null && responseId.trim().isNotEmpty)
            _SubmittedDetail(label: 'Response ID', value: responseId),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: onDone, child: const Text('Done')),
          ),
        ],
      ),
    );
  }
}

class _SubmittedDetail extends StatelessWidget {
  const _SubmittedDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: <Widget>[
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: TaraTheme.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: TaraTheme.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TestPanel extends StatelessWidget {
  const _TestPanel({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, color: TaraTheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: TaraTheme.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ScaleButton extends StatelessWidget {
  const _ScaleButton({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _ScaleOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? TaraTheme.primaryTint : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? TaraTheme.primary : TaraTheme.border,
          ),
        ),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 24,
              child: Text(
                option.value.toString(),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            Expanded(child: Text(option.label)),
          ],
        ),
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: TaraTheme.primaryTint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: TaraTheme.primaryDark,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InstructionLine extends StatelessWidget {
  const _InstructionLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.check_rounded, size: 18, color: TaraTheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _ScaleOption {
  const _ScaleOption(this.value, this.label);

  final int value;
  final String label;
}

const List<_ScaleOption> _likingOptions = <_ScaleOption>[
  _ScaleOption(1, 'Dislike Extremely'),
  _ScaleOption(2, 'Dislike Very Much'),
  _ScaleOption(3, 'Dislike Moderately'),
  _ScaleOption(4, 'Dislike Slightly'),
  _ScaleOption(5, 'Neither'),
  _ScaleOption(6, 'Like Slightly'),
  _ScaleOption(7, 'Like Moderately'),
  _ScaleOption(8, 'Like Very Much'),
  _ScaleOption(9, 'Like Extremely'),
];

List<_ScaleOption> _jarOptions(List<String> customOptions) {
  if (customOptions.length >= 5) {
    return List<_ScaleOption>.generate(
      5,
      (int index) => _ScaleOption(index + 1, customOptions[index]),
    );
  }
  return const <_ScaleOption>[
    _ScaleOption(1, 'Much too low'),
    _ScaleOption(2, 'Slightly too low'),
    _ScaleOption(3, 'Just about right'),
    _ScaleOption(4, 'Slightly too high'),
    _ScaleOption(5, 'Much too high'),
  ];
}

Map<String, dynamic> _jarValue(int rawValue) {
  return <String, dynamic>{
    'type': 'JAR_5PT',
    'rawValue': rawValue,
    'bucket': rawValue <= 2
        ? 'too_low'
        : rawValue == 3
        ? 'just_right'
        : 'too_high',
  };
}

bool _isSelectedScaleValue(
  dynamic selectedValue,
  int optionValue, {
  required bool jar,
}) {
  if (!jar) {
    return selectedValue == optionValue;
  }
  if (selectedValue is Map) {
    return selectedValue['rawValue'] == optionValue;
  }
  return false;
}
