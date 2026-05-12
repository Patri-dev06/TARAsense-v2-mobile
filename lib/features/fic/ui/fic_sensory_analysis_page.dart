import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tarasense_mobile/core/network/api_error_formatter.dart';
import 'package:tarasense_mobile/core/theme/tara_theme.dart';
import 'package:tarasense_mobile/features/auth/state/auth_providers.dart';
import 'package:tarasense_mobile/features/fic/domain/fic_models.dart';
import 'package:tarasense_mobile/features/studies/data/study_analysis_api.dart';
import 'package:tarasense_mobile/features/studies/domain/study_analysis.dart';

class FicSensoryAnalysisPage extends ConsumerStatefulWidget {
  const FicSensoryAnalysisPage({required this.studyId, this.study, super.key});

  final String studyId;
  final FicStudy? study;

  @override
  ConsumerState<FicSensoryAnalysisPage> createState() =>
      _FicSensoryAnalysisPageState();
}

class _FicSensoryAnalysisPageState
    extends ConsumerState<FicSensoryAnalysisPage> {
  late Future<StudyAnalysis> _analysisFuture;

  @override
  void initState() {
    super.initState();
    _analysisFuture = _fetchAnalysis();
  }

  Future<StudyAnalysis> _fetchAnalysis({bool refresh = false}) {
    final String accessToken =
        ref.read(authControllerProvider).session?.tokens.accessToken ?? '';
    if (accessToken.trim().isEmpty) {
      throw const FormatException(
        'Please sign in again before loading results.',
      );
    }
    return ref
        .read(studyAnalysisApiProvider)
        .fetchAnalysis(accessToken, studyId: widget.studyId, refresh: refresh);
  }

  void _reload({bool refresh = false}) {
    setState(() {
      _analysisFuture = _fetchAnalysis(refresh: refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EE),
      appBar: AppBar(
        title: const Text('Sensory Analysis Results'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<StudyAnalysis>(
          future: _analysisFuture,
          builder:
              (BuildContext context, AsyncSnapshot<StudyAnalysis> snapshot) {
                final StudyAnalysis? analysis = snapshot.data;
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 980),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 26),
                      children: <Widget>[
                        _AnalysisHeader(
                          initialStudy: widget.study,
                          analysis: analysis,
                          loading:
                              snapshot.connectionState ==
                              ConnectionState.waiting,
                          onRefresh: () => _reload(refresh: true),
                        ),
                        const SizedBox(height: 18),
                        if (snapshot.hasError)
                          _AnalysisErrorPanel(
                            message: formatApiError(
                              snapshot.error!,
                              includeUri: true,
                            ),
                            onRetry: _reload,
                          )
                        else if (snapshot.connectionState ==
                            ConnectionState.waiting)
                          const _AnalysisLoadingPanel()
                        else if (analysis != null) ...<Widget>[
                          _AiRecommendationPanel(analysis: analysis),
                          const SizedBox(height: 18),
                          _AttributeScoresPanel(stats: analysis.attributeStats),
                          const SizedBox(height: 18),
                          _JarDistributionPanel(analysis: analysis),
                          const SizedBox(height: 18),
                          _PenaltyAnalysisPanel(rows: analysis.penaltyAnalysis),
                          const SizedBox(height: 18),
                          const _AnalysisNotice(),
                        ],
                      ],
                    ),
                  ),
                );
              },
        ),
      ),
    );
  }
}

class _AnalysisHeader extends StatelessWidget {
  const _AnalysisHeader({
    required this.initialStudy,
    required this.analysis,
    required this.loading,
    required this.onRefresh,
  });

  final FicStudy? initialStudy;
  final StudyAnalysis? analysis;
  final bool loading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final String title = _analysisTitle(initialStudy, analysis);
    final DateTime? generatedAt = analysis?.generatedAt ?? analysis?.updatedAt;
    return _AnalysisPanel(
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 430,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Sensory Analysis Results',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: TaraTheme.textPrimary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  generatedAt == null
                      ? 'Generated date unavailable'
                      : 'Generated on ${_dateLabel(generatedAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: TaraTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: TaraTheme.textSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (analysis != null) ...<Widget>[
                  const SizedBox(height: 5),
                  Text(
                    '${analysis!.responseCount} responses',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: TaraTheme.primaryDark,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: loading ? null : onRefresh,
                icon: loading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Refresh'),
              ),
              OutlinedButton.icon(
                onPressed: () => _showExportSnack(context, 'PDF'),
                icon: const Icon(Icons.download_rounded, size: 16),
                label: const Text('Export PDF'),
              ),
              OutlinedButton.icon(
                onPressed: () => _showExportSnack(context, 'Excel'),
                icon: const Icon(Icons.download_rounded, size: 16),
                label: const Text('Export Excel'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnalysisErrorPanel extends StatelessWidget {
  const _AnalysisErrorPanel({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _AnalysisPanel(
      background: const Color(0xFFFFF1F2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.wifi_off_rounded, color: TaraTheme.roseText),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Could not load analysis',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: TaraTheme.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: TaraTheme.roseText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisLoadingPanel extends StatelessWidget {
  const _AnalysisLoadingPanel();

  @override
  Widget build(BuildContext context) {
    return const _AnalysisPanel(
      child: Row(
        children: <Widget>[
          SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Loading sensory analysis...'),
        ],
      ),
    );
  }
}

class _AiRecommendationPanel extends StatelessWidget {
  const _AiRecommendationPanel({required this.analysis});

  final StudyAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final String status = analysis.hasAiInterpretation ? 'READY' : 'PENDING';
    return _AnalysisPanel(
      background: const Color(0xFFF1F5F9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.check_circle_outline_rounded, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'AI Recommendation: $status',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: TaraTheme.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  analysis.interpretationText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: TaraTheme.textSecondary,
                  ),
                ),
                if (!analysis.hasAiInterpretation) ...<Widget>[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: TaraTheme.border),
                    ),
                    child: const Text.rich(
                      TextSpan(
                        children: <InlineSpan>[
                          TextSpan(
                            text: 'Action Required: ',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          TextSpan(
                            text:
                                'Collect more responses or configure OPENAI_API_KEY.',
                          ),
                        ],
                      ),
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

class _AttributeScoresPanel extends StatelessWidget {
  const _AttributeScoresPanel({required this.stats});

  final List<Map<String, dynamic>> stats;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 426,
      child: _AnalysisPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Attribute Liking Scores',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: TaraTheme.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 18),
            if (stats.isEmpty)
              const SizedBox(height: 210, child: _EmptyChart())
            else
              ...stats
                  .take(8)
                  .map(
                    (Map<String, dynamic> stat) => _AttributeScoreRow(
                      label: _statLabel(stat),
                      value: _statScore(stat),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _AttributeScoreRow extends StatelessWidget {
  const _AttributeScoreRow({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final double progress = (value / 9).clamp(0, 1).toDouble();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Text(value <= 0 ? '-' : value.toStringAsFixed(1)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE5E7EB),
              color: TaraTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _JarDistributionPanel extends StatelessWidget {
  const _JarDistributionPanel({required this.analysis});

  final StudyAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    return _AnalysisPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'JAR Distribution',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: TaraTheme.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            analysis.attributeStats.isEmpty
                ? 'No JAR distribution available yet.'
                : '${analysis.attributeStats.length} attribute statistics loaded from the live endpoint.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: TaraTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PenaltyAnalysisPanel extends StatelessWidget {
  const _PenaltyAnalysisPanel({required this.rows});

  final List<Map<String, dynamic>> rows;

  @override
  Widget build(BuildContext context) {
    return _AnalysisPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Penalty Analysis',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: TaraTheme.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _AnalysisNote(
            text:
                'What does this mean? Attributes marked as drivers are those where many participants felt the level was not right and overall liking dropped.',
          ),
          const SizedBox(height: 10),
          const _PenaltyTableHeader(),
          if (rows.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE7FAF3),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF99F6E4)),
              ),
              child: const Text(
                'No strong drivers detected. This suggests the product is generally well balanced, or changes may not significantly improve liking.',
                style: TextStyle(
                  color: TaraTheme.mintText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            ...rows.map(_PenaltyRow.new),
          const SizedBox(height: 12),
          _AnalysisNote(
            text:
                '* Penalty = Mean liking (JAR group) - Mean liking (non-JAR group). Strong: penalty >= 1.0 with >= 20% non-JAR. Moderate: 0.5-0.99 with >= 20% non-JAR.',
          ),
        ],
      ),
    );
  }
}

class _PenaltyRow extends StatelessWidget {
  const _PenaltyRow(this.row);

  final Map<String, dynamic> row;

  @override
  Widget build(BuildContext context) {
    final List<String> values = <String>[
      _statLabel(row),
      _percentText(
        analysisDouble(row, const <String>['tooLowPercent', 'tooLowPct']),
      ),
      _numberText(analysisDouble(row, const <String>['tooLowPenalty'])),
      _percentText(
        analysisDouble(row, const <String>['tooHighPercent', 'tooHighPct']),
      ),
      _numberText(analysisDouble(row, const <String>['tooHighPenalty'])),
      analysisString(row, const <String>['status', 'driverStatus']),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: values
            .map(
              (String value) => Expanded(
                child: Text(
                  value.isEmpty ? '-' : value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _PenaltyTableHeader extends StatelessWidget {
  const _PenaltyTableHeader();

  @override
  Widget build(BuildContext context) {
    const List<String> labels = <String>[
      'Attribute',
      'Too Low %',
      'Penalty',
      'Too High %',
      'Penalty',
      'Status',
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      color: const Color(0xFFF8FAFC),
      child: Row(
        children: labels
            .map(
              (String label) => Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _AnalysisNotice extends StatelessWidget {
  const _AnalysisNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFD8B5)),
      ),
      child: const Row(
        children: <Widget>[
          Icon(Icons.lightbulb_outline_rounded, color: TaraTheme.primary),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'This screen is styled to match the Lovable dashboard language while still using your live analysis endpoint.',
              style: TextStyle(
                color: TaraTheme.primaryDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _EmptyChartPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _EmptyChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint axis = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1;
    final Paint grid = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;
    final double left = 70;
    final double top = 20;
    final double right = size.width - 20;
    final double bottom = size.height - 30;
    canvas.drawLine(Offset(left, bottom), Offset(right, bottom), axis);
    canvas.drawLine(Offset(left, top), Offset(left, bottom), axis);
    canvas.drawLine(Offset(left, top), Offset(right, top), grid);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AnalysisNote extends StatelessWidget {
  const _AnalysisNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: const Color(0xFF52657D),
          fontSize: 11,
        ),
      ),
    );
  }
}

class _AnalysisPanel extends StatelessWidget {
  const _AnalysisPanel({required this.child, this.background});

  final Widget child;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background ?? TaraTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TaraTheme.border),
      ),
      child: child,
    );
  }
}

void _showExportSnack(BuildContext context, String type) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('$type export is ready for backend wiring.')),
  );
}

String _analysisTitle(FicStudy? study, StudyAnalysis? analysis) {
  final String fromAnalysis = analysis?.study.title.trim() ?? '';
  if (fromAnalysis.isNotEmpty) {
    return fromAnalysis;
  }
  final String fromStudy = study?.title.trim() ?? '';
  return fromStudy.isEmpty ? 'Sensory Study' : fromStudy;
}

String _dateLabel(DateTime value) {
  final DateTime local = value.toLocal();
  return '${local.month}/${local.day}/${local.year}';
}

String _statLabel(Map<String, dynamic> stat) {
  return analysisString(stat, const <String>[
    'attribute',
    'attributeName',
    'name',
    'label',
  ]);
}

double _statScore(Map<String, dynamic> stat) {
  return analysisDouble(stat, const <String>[
    'mean',
    'average',
    'score',
    'likingScore',
    'meanLiking',
  ]);
}

String _percentText(double value) {
  if (value <= 0) {
    return '-';
  }
  return '${value.toStringAsFixed(value >= 10 ? 0 : 1)}%';
}

String _numberText(double value) {
  if (value == 0) {
    return '-';
  }
  return value.toStringAsFixed(2);
}
