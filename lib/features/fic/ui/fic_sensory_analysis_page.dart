import 'dart:math';

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
      backgroundColor: TaraTheme.background,
      appBar: AppBar(
        title: const Text('Sensory Analysis Results'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () => _reload(refresh: true),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<StudyAnalysis>(
          future: _analysisFuture,
          builder: (BuildContext context, AsyncSnapshot<StudyAnalysis> snap) {
            if (snap.hasError) {
              return _ErrorView(
                message: formatApiError(snap.error!, includeUri: true),
                onRetry: _reload,
              );
            }
            if (snap.connectionState == ConnectionState.waiting) {
              return const _LoadingView();
            }
            final StudyAnalysis? analysis = snap.data;
            if (analysis == null) {
              return const _LoadingView();
            }
            return _AnalysisBody(
              study: widget.study,
              analysis: analysis,
              onRefresh: () => _reload(refresh: true),
            );
          },
        ),
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _AnalysisBody extends StatefulWidget {
  const _AnalysisBody({
    required this.study,
    required this.analysis,
    required this.onRefresh,
  });

  final FicStudy? study;
  final StudyAnalysis analysis;
  final VoidCallback onRefresh;

  @override
  State<_AnalysisBody> createState() => _AnalysisBodyState();
}

class _AnalysisBodyState extends State<_AnalysisBody> {
  int _selectedSample = 0;

  List<Map<String, dynamic>> get _samples =>
      widget.analysis.perSampleResults;

  bool get _hasSamples => _samples.isNotEmpty;

  Map<String, dynamic> get _currentSample =>
      _hasSamples ? _samples[_selectedSample] : <String, dynamic>{};

  List<Map<String, dynamic>> get _currentAttributeStats {
    if (_hasSamples) {
      final dynamic raw = _currentSample['attributeStats'] ??
          _currentSample['attributes'] ??
          _currentSample['stats'];
      if (raw is List && raw.isNotEmpty) {
        return raw.whereType<Map>()
            .map((Map m) => Map<String, dynamic>.from(m))
            .toList();
      }
    }
    return widget.analysis.attributeStats;
  }

  List<Map<String, dynamic>> get _currentPenalty {
    if (_hasSamples) {
      final dynamic raw = _currentSample['penaltyAnalysis'] ??
          _currentSample['penalty'] ??
          _currentSample['jarPenalty'];
      if (raw is List && raw.isNotEmpty) {
        return raw.whereType<Map>()
            .map((Map m) => Map<String, dynamic>.from(m))
            .toList();
      }
    }
    return widget.analysis.penaltyAnalysis;
  }

  List<Map<String, dynamic>> get _currentMeanDrop {
    if (_hasSamples) {
      final dynamic raw = _currentSample['meanDropAnalysis'] ??
          _currentSample['meanDrop'];
      if (raw is List && raw.isNotEmpty) {
        return raw.whereType<Map>()
            .map((Map m) => Map<String, dynamic>.from(m))
            .toList();
      }
    }
    return widget.analysis.meanDropAnalysis;
  }

  String _sampleLabel(int index) {
    if (!_hasSamples) return 'Sample ${index + 1}';
    final Map<String, dynamic> s = _samples[index];
    final String label = _str(s, const <String>[
      'sampleLabel',
      'sampleName',
      'sample',
      'sampleId',
      'label',
      'name',
    ]);
    return label.isEmpty ? 'Sample ${index + 1}' : label;
  }

  @override
  Widget build(BuildContext context) {
    final StudyAnalysis a = widget.analysis;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
      children: <Widget>[
        _HeaderPanel(study: widget.study, analysis: a, onRefresh: widget.onRefresh),
        const SizedBox(height: 14),
        _StudyOverviewPanel(analysis: a),
        const SizedBox(height: 14),
        _AutoInterpretationPanel(analysis: a),
        const SizedBox(height: 14),
        if (_hasSamples) ...<Widget>[
          _SampleSelector(
            count: _samples.length,
            selected: _selectedSample,
            labelOf: _sampleLabel,
            onSelect: (int i) => setState(() => _selectedSample = i),
          ),
          const SizedBox(height: 14),
        ],
        _RadarAndStatsPanel(
          attributeStats: _currentAttributeStats,
          sampleLabel: _hasSamples ? _sampleLabel(_selectedSample) : '',
        ),
        const SizedBox(height: 14),
        _PenaltyTablePanel(
          rows: _currentPenalty,
          sampleLabel: _hasSamples ? _sampleLabel(_selectedSample) : '',
        ),
        if (_currentMeanDrop.isNotEmpty) ...<Widget>[
          const SizedBox(height: 14),
          _MeanDropTablePanel(
            rows: _currentMeanDrop,
            sampleLabel: _hasSamples ? _sampleLabel(_selectedSample) : '',
          ),
        ],
        const SizedBox(height: 14),
        _AiPanel(analysis: a),
      ],
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _HeaderPanel extends StatelessWidget {
  const _HeaderPanel({
    required this.study,
    required this.analysis,
    required this.onRefresh,
  });

  final FicStudy? study;
  final StudyAnalysis analysis;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final DateTime? generatedAt = analysis.generatedAt ?? analysis.updatedAt;
    return _AnalysisPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Sensory Analysis Results',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            generatedAt == null
                ? 'Generated date unavailable'
                : 'Generated on ${_dateLabel(generatedAt)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded, size: 15),
                label: const Text('Refresh'),
                style: _compactOutlined,
              ),
              OutlinedButton.icon(
                onPressed: () => _exportSnack(context, 'PDF'),
                icon: const Icon(Icons.picture_as_pdf_rounded, size: 15),
                label: const Text('Export PDF'),
                style: _compactOutlined,
              ),
              OutlinedButton.icon(
                onPressed: () => _exportSnack(context, 'Excel'),
                icon: const Icon(Icons.table_chart_rounded, size: 15),
                label: const Text('Export Excel'),
                style: _compactOutlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Study overview ───────────────────────────────────────────────────────────

class _StudyOverviewPanel extends StatelessWidget {
  const _StudyOverviewPanel({required this.analysis});

  final StudyAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final s = analysis.study;
    final int samples = analysis.perSampleResults.length;
    final List<String> attributes = analysis.attributeStats
        .map((Map<String, dynamic> stat) => _str(stat, const <String>[
              'attribute',
              'attributeName',
              'name',
              'label',
            ]))
        .where((String l) => l.isNotEmpty)
        .toList();

    return _AnalysisPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Study Overview',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 20,
            runSpacing: 12,
            children: <Widget>[
              _OverviewField(label: 'STUDY', value: s.title.isEmpty ? '—' : s.title),
              _OverviewField(
                label: 'PRODUCT',
                value: s.productName.isEmpty ? '—' : s.productName,
              ),
              _OverviewField(
                label: 'CONSUMERS',
                value: '${analysis.responseCount}',
              ),
              if (samples > 0)
                _OverviewField(label: 'SAMPLES', value: '$samples'),
              _OverviewField(
                label: 'STATUS',
                value: s.status.isEmpty ? '—' : s.status.toUpperCase(),
              ),
              if (s.location.isNotEmpty)
                _OverviewField(label: 'LOCATION', value: s.location),
            ],
          ),
          if (attributes.isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: attributes
                  .map(
                    (String attr) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: TaraTheme.background,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: TaraTheme.border),
                      ),
                      child: Text(
                        attr,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: TaraTheme.textPrimary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _OverviewField extends StatelessWidget {
  const _OverviewField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: TaraTheme.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// ─── Automatic interpretation ─────────────────────────────────────────────────

class _AutoInterpretationPanel extends StatelessWidget {
  const _AutoInterpretationPanel({required this.analysis});

  final StudyAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final String raw = analysis.automaticInterpretation?.trim() ?? '';
    if (raw.isEmpty) return const SizedBox.shrink();

    final List<String> sentences = raw
        .split(RegExp(r'(?<=\.)\s+'))
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList();

    return _AnalysisPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Automatic Interpretation',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ...sentences.map(
            (String sentence) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    height: 5,
                    width: 5,
                    decoration: BoxDecoration(
                      color: TaraTheme.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      sentence,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sample selector ──────────────────────────────────────────────────────────

class _SampleSelector extends StatelessWidget {
  const _SampleSelector({
    required this.count,
    required this.selected,
    required this.labelOf,
    required this.onSelect,
  });

  final int count;
  final int selected;
  final String Function(int) labelOf;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List<Widget>.generate(count, (int i) {
          final bool active = i == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: active ? TaraTheme.textPrimary : TaraTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: active ? TaraTheme.textPrimary : TaraTheme.border,
                  ),
                ),
                child: Text(
                  labelOf(i),
                  style: TextStyle(
                    color: active ? Colors.white : TaraTheme.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Radar + attribute stats ──────────────────────────────────────────────────

class _RadarAndStatsPanel extends StatelessWidget {
  const _RadarAndStatsPanel({
    required this.attributeStats,
    required this.sampleLabel,
  });

  final List<Map<String, dynamic>> attributeStats;
  final String sampleLabel;

  @override
  Widget build(BuildContext context) {
    final String title =
        sampleLabel.isEmpty ? 'Attribute Radar' : '$sampleLabel Attribute Radar';
    return _AnalysisPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          if (attributeStats.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No attribute data available.'),
              ),
            )
          else
            LayoutBuilder(
              builder: (BuildContext ctx, BoxConstraints constraints) {
                final bool wide = constraints.maxWidth >= 560;
                final List<_RadarPoint> points = attributeStats
                    .take(8)
                    .map(
                      (Map<String, dynamic> stat) => _RadarPoint(
                        label: _str(stat, const <String>[
                          'attribute',
                          'attributeName',
                          'name',
                          'label',
                        ]),
                        value: _dbl(stat, const <String>[
                          'mean',
                          'average',
                          'score',
                          'likingScore',
                          'meanLiking',
                        ]),
                      ),
                    )
                    .where((p) => p.label.isNotEmpty)
                    .toList();

                final Widget radar = SizedBox(
                  height: 240,
                  child: _RadarChart(points: points, maxValue: 9),
                );
                final Widget table = _AttributeStatsTable(
                  stats: attributeStats,
                );

                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(child: radar),
                      const SizedBox(width: 16),
                      Expanded(child: table),
                    ],
                  );
                }
                return Column(
                  children: <Widget>[
                    radar,
                    const SizedBox(height: 16),
                    table,
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

// ─── Radar chart ─────────────────────────────────────────────────────────────

class _RadarPoint {
  const _RadarPoint({required this.label, required this.value});

  final String label;
  final double value;
}

class _RadarChart extends StatelessWidget {
  const _RadarChart({required this.points, required this.maxValue});

  final List<_RadarPoint> points;
  final double maxValue;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();
    return CustomPaint(
      painter: _RadarPainter(points: points, maxValue: maxValue),
      child: const SizedBox.expand(),
    );
  }
}

class _RadarPainter extends CustomPainter {
  const _RadarPainter({required this.points, required this.maxValue});

  final List<_RadarPoint> points;
  final double maxValue;

  @override
  void paint(Canvas canvas, Size size) {
    final int n = points.length;
    if (n < 3) return;

    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double labelPad = 28;
    final double r = min(cx, cy) - labelPad;

    // ── Grid rings ──
    final Paint gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (int level = 1; level <= 5; level++) {
      final double ratio = level / 5;
      final Path ring = Path();
      for (int i = 0; i < n; i++) {
        final Offset pt = _anglePoint(cx, cy, r * ratio, i, n);
        if (i == 0) {
          ring.moveTo(pt.dx, pt.dy);
        } else {
          ring.lineTo(pt.dx, pt.dy);
        }
      }
      ring.close();
      canvas.drawPath(ring, gridPaint);
    }

    // ── Axes ──
    final Paint axisPaint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..strokeWidth = 1;
    for (int i = 0; i < n; i++) {
      final Offset edge = _anglePoint(cx, cy, r, i, n);
      canvas.drawLine(Offset(cx, cy), edge, axisPaint);
    }

    // ── Data polygon ──
    final Path dataPath = Path();
    for (int i = 0; i < n; i++) {
      final double ratio = (points[i].value / maxValue).clamp(0.0, 1.0);
      final Offset pt = _anglePoint(cx, cy, r * ratio, i, n);
      if (i == 0) {
        dataPath.moveTo(pt.dx, pt.dy);
      } else {
        dataPath.lineTo(pt.dx, pt.dy);
      }
    }
    dataPath.close();

    canvas.drawPath(
      dataPath,
      Paint()
        ..color = const Color(0x557C8CDB)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = const Color(0xFF4A5FA8)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    // ── Labels ──
    for (int i = 0; i < n; i++) {
      final Offset edge = _anglePoint(cx, cy, r + labelPad - 6, i, n);
      _drawLabel(canvas, _truncate(points[i].label), edge.dx, edge.dy);
    }
  }

  Offset _anglePoint(double cx, double cy, double r, int i, int n) {
    final double angle = (2 * pi * i / n) - pi / 2;
    return Offset(cx + r * cos(angle), cy + r * sin(angle));
  }

  void _drawLabel(Canvas canvas, String text, double x, double y) {
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: 64);
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  String _truncate(String label) {
    final List<String> words = label.trim().split(' ');
    if (words.length <= 2) return label;
    return '${words[0]}\n${words[1]}…';
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) =>
      old.points != points || old.maxValue != maxValue;
}

// ─── Attribute stats table ────────────────────────────────────────────────────

class _AttributeStatsTable extends StatelessWidget {
  const _AttributeStatsTable({required this.stats});

  final List<Map<String, dynamic>> stats;

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _TableRow(
          cells: const <String>['Attribute', 'Mean', 'SD', 'N'],
          isHeader: true,
        ),
        ...stats.take(8).map(
          (Map<String, dynamic> stat) => _TableRow(
            cells: <String>[
              _str(stat, const <String>[
                'attribute',
                'attributeName',
                'name',
                'label',
              ]),
              _fmt(_dbl(stat, const <String>['mean', 'average', 'score'])),
              _fmt(_dbl(stat, const <String>['sd', 'standardDeviation', 'stdDev'])),
              _int(stat, const <String>['n', 'count', 'responses']).toString(),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Penalty table ────────────────────────────────────────────────────────────

class _PenaltyTablePanel extends StatelessWidget {
  const _PenaltyTablePanel({required this.rows, required this.sampleLabel});

  final List<Map<String, dynamic>> rows;
  final String sampleLabel;

  @override
  Widget build(BuildContext context) {
    final String title = sampleLabel.isEmpty
        ? 'JAR And Penalty Analysis'
        : '$sampleLabel JAR And Penalty';
    return _AnalysisPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            _GreenNotice(
              text:
                  'No strong drivers detected. The product appears well balanced.',
            )
          else ...<Widget>[
            _AnalysisNote(
              text:
                  'Penalty = Mean liking (JAR group) − Mean liking (non-JAR group). '
                  'Strong: penalty ≥ 1.0 with ≥ 20% non-JAR.',
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                headingRowHeight: 36,
                dataRowMinHeight: 36,
                dataRowMaxHeight: 48,
                headingTextStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: TaraTheme.textPrimary,
                ),
                dataTextStyle: const TextStyle(
                  fontSize: 11,
                  color: TaraTheme.textPrimary,
                ),
                columns: const <DataColumn>[
                  DataColumn(label: Text('Attribute')),
                  DataColumn(label: Text('Too Low %'), numeric: true),
                  DataColumn(label: Text('JAR %'), numeric: true),
                  DataColumn(label: Text('Too High %'), numeric: true),
                  DataColumn(label: Text('Too Low Pen.'), numeric: true),
                  DataColumn(label: Text('Too High Pen.'), numeric: true),
                  DataColumn(label: Text('Driver')),
                ],
                rows: rows.map((Map<String, dynamic> row) {
                  final String status = _str(row, const <String>[
                    'status',
                    'driverStatus',
                    'driver',
                  ]);
                  return DataRow(
                    cells: <DataCell>[
                      DataCell(Text(
                        _str(row, const <String>[
                          'attribute',
                          'attributeName',
                          'name',
                        ]),
                      )),
                      DataCell(Text(_pct(_dbl(row, const <String>[
                        'tooLowPercent',
                        'tooLowPct',
                        'tooLow',
                      ])))),
                      DataCell(Text(_pct(_dbl(row, const <String>[
                        'jarPercent',
                        'jarPct',
                        'jar',
                      ])))),
                      DataCell(Text(_pct(_dbl(row, const <String>[
                        'tooHighPercent',
                        'tooHighPct',
                        'tooHigh',
                      ])))),
                      DataCell(Text(_fmt(_dbl(row, const <String>[
                        'tooLowPenalty',
                        'penaltyLow',
                      ])))),
                      DataCell(Text(_fmt(_dbl(row, const <String>[
                        'tooHighPenalty',
                        'penaltyHigh',
                      ])))),
                      DataCell(_DriverBadge(status: status)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Mean drop table ──────────────────────────────────────────────────────────

class _MeanDropTablePanel extends StatelessWidget {
  const _MeanDropTablePanel({required this.rows, required this.sampleLabel});

  final List<Map<String, dynamic>> rows;
  final String sampleLabel;

  @override
  Widget build(BuildContext context) {
    final String title = sampleLabel.isEmpty
        ? 'Mean Drop Analysis'
        : '$sampleLabel Mean Drop Analysis';
    return _AnalysisPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 16,
              headingRowHeight: 36,
              dataRowMinHeight: 36,
              dataRowMaxHeight: 48,
              headingTextStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: TaraTheme.textPrimary,
              ),
              dataTextStyle: const TextStyle(
                fontSize: 11,
                color: TaraTheme.textPrimary,
              ),
              columns: const <DataColumn>[
                DataColumn(label: Text('Attribute')),
                DataColumn(label: Text('JAR %'), numeric: true),
                DataColumn(label: Text('Too Low %'), numeric: true),
                DataColumn(label: Text('Too High %'), numeric: true),
                DataColumn(label: Text('JAR Mean'), numeric: true),
                DataColumn(label: Text('Non-JAR Mean'), numeric: true),
                DataColumn(label: Text('Mean Drop'), numeric: true),
                DataColumn(label: Text('Severity')),
              ],
              rows: rows.map((Map<String, dynamic> row) {
                final double drop = _dbl(row, const <String>[
                  'meanDrop',
                  'drop',
                  'meanDropValue',
                ]);
                final String severity = _str(row, const <String>[
                  'severity',
                  'status',
                  'driverStatus',
                ]);
                return DataRow(
                  cells: <DataCell>[
                    DataCell(Text(_str(row, const <String>[
                      'attribute',
                      'attributeName',
                      'name',
                    ]))),
                    DataCell(Text(_pct(_dbl(row, const <String>[
                      'jarPercent',
                      'jarPct',
                      'jar',
                    ])))),
                    DataCell(Text(_pct(_dbl(row, const <String>[
                      'tooLowPercent',
                      'tooLowPct',
                    ])))),
                    DataCell(Text(_pct(_dbl(row, const <String>[
                      'tooHighPercent',
                      'tooHighPct',
                    ])))),
                    DataCell(Text(_fmt(_dbl(row, const <String>[
                      'jarMean',
                      'meanJar',
                    ])))),
                    DataCell(Text(_fmt(_dbl(row, const <String>[
                      'nonJarMean',
                      'meanNonJar',
                    ])))),
                    DataCell(Text(
                      drop == 0 ? '—' : drop.toStringAsFixed(2),
                      style: TextStyle(
                        color: drop < 0 ? TaraTheme.roseText : TaraTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    )),
                    DataCell(_DriverBadge(status: severity)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── AI recommendation ────────────────────────────────────────────────────────

class _AiPanel extends StatelessWidget {
  const _AiPanel({required this.analysis});

  final StudyAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    return _AnalysisPanel(
      background: const Color(0xFFF1F5F9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.auto_awesome_rounded, size: 18, color: TaraTheme.primaryDark),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'AI Recommendation',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  analysis.interpretationText,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared small widgets ─────────────────────────────────────────────────────

class _TableRow extends StatelessWidget {
  const _TableRow({required this.cells, this.isHeader = false});

  final List<String> cells;
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: isHeader ? TaraTheme.background : null,
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        children: cells
            .map(
              (String c) => Expanded(
                child: Text(
                  c,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isHeader ? FontWeight.w900 : FontWeight.w500,
                    color: TaraTheme.textPrimary,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _DriverBadge extends StatelessWidget {
  const _DriverBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final String s = status.trim().toUpperCase();
    Color bg;
    Color fg;
    if (s.contains('STRONG')) {
      bg = const Color(0xFFFFE4E6);
      fg = TaraTheme.roseText;
    } else if (s.contains('MODERATE')) {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFF92400E);
    } else if (s.contains('NOT') || s.contains('ACTION')) {
      bg = const Color(0xFFD1FAE5);
      fg = TaraTheme.mintText;
    } else {
      bg = TaraTheme.background;
      fg = TaraTheme.textSecondary;
    }
    final String label = status.trim().isEmpty ? '—' : status.trim();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

class _GreenNotice extends StatelessWidget {
  const _GreenNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE7FAF3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF99F6E4)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: TaraTheme.mintText,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
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
        color: TaraTheme.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TaraTheme.border),
      ),
      child: child,
    );
  }
}

// ─── Loading / error views ────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading sensory analysis…'),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: TaraTheme.roseText,
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load analysis',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: TaraTheme.roseText),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

ButtonStyle get _compactOutlined => OutlinedButton.styleFrom(
      minimumSize: const Size(0, 36),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
    );

String _str(Map<String, dynamic> json, List<String> keys) {
  for (final String key in keys) {
    final dynamic v = json[key];
    if (v == null || v is Map || v is List) continue;
    final String s = v.toString().trim();
    if (s.isNotEmpty && s.toLowerCase() != 'null') return s;
  }
  return '';
}

double _dbl(Map<String, dynamic> json, List<String> keys) {
  for (final String key in keys) {
    final dynamic v = json[key];
    if (v is num) return v.toDouble();
    final double? parsed = double.tryParse(v?.toString() ?? '');
    if (parsed != null) return parsed;
  }
  return 0;
}

int _int(Map<String, dynamic> json, List<String> keys) {
  for (final String key in keys) {
    final dynamic v = json[key];
    if (v is int) return v;
    if (v is num) return v.toInt();
    final int? parsed = int.tryParse(v?.toString() ?? '');
    if (parsed != null) return parsed;
  }
  return 0;
}

String _fmt(double value) => value == 0 ? '—' : value.toStringAsFixed(2);
String _pct(double value) => value <= 0 ? '—' : '${value.toStringAsFixed(0)}%';

String _dateLabel(DateTime value) {
  final DateTime local = value.toLocal();
  return '${local.month}/${local.day}/${local.year}';
}

void _exportSnack(BuildContext context, String type) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('$type export is not yet connected to a backend.')),
  );
}
