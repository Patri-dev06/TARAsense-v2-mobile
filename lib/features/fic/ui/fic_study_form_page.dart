import 'dart:ui' as ui;

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tarasense_mobile/core/config/app_config.dart';
import 'package:tarasense_mobile/core/theme/tara_theme.dart';
import 'package:tarasense_mobile/features/fic/domain/fic_models.dart';

class FicStudyFormPage extends StatelessWidget {
  const FicStudyFormPage({required this.studyId, this.study, super.key});

  final String studyId;
  final FicStudy? study;

  @override
  Widget build(BuildContext context) {
    final String title = _studyTitle(study, studyId);
    final String product = _studyProduct(study);
    final String registrationUrl = AppConfig.publicStudyRegistrationUri(
      study?.id.isNotEmpty == true ? study!.id : studyId,
    ).toString();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F0),
      appBar: AppBar(
        backgroundColor: TaraTheme.surface,
        title: const Text('Study Form & QR'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: <Widget>[
          TextButton.icon(
            onPressed: () => context.push(
              '/fic/studies/$studyId/analysis',
              extra: study,
            ),
            icon: const Icon(Icons.bar_chart_rounded, size: 16),
            label: const Text('Analysis'),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool wide = constraints.maxWidth >= 920;
            final Widget scoreSheet = _ScoreSheetPanel(
              title: title,
              product: product,
              study: study,
              studyId: studyId,
            );
            final Widget qrPanel = _QrPanel(
              title: title,
              registrationUrl: registrationUrl,
              study: study,
              studyId: studyId,
            );

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: <Widget>[
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(flex: 2, child: scoreSheet),
                      const SizedBox(width: 16),
                      SizedBox(width: 340, child: qrPanel),
                    ],
                  )
                else ...<Widget>[
                  scoreSheet,
                  const SizedBox(height: 14),
                  qrPanel,
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── Score Sheet ──────────────────────────────────────────────────────────────

class _ScoreSheetPanel extends StatelessWidget {
  const _ScoreSheetPanel({
    required this.title,
    required this.product,
    required this.study,
    required this.studyId,
  });

  final String title;
  final String product;
  final FicStudy? study;
  final String studyId;

  @override
  Widget build(BuildContext context) {
    final FicStudy? s = study;
    return Container(
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        children: <Widget>[
          // ── Gradient study header ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFFFB923C), TaraTheme.primaryDark],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withAlpha(60),
                        ),
                      ),
                      child: const Text(
                        'SENSORY SCORE SHEET',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (s != null)
                      _WhiteStatusBadge(status: s.status.toUpperCase()),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s?.scheduleLabel ?? 'Schedule pending',
                  style: TextStyle(
                    color: Colors.white.withAlpha(200),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // ── Stats row ──
          if (s != null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFFFAF8F5),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFEDE8E1)),
                ),
              ),
              child: Row(
                children: <Widget>[
                  _StatCell(
                    label: 'TARGET',
                    value: s.targetCount > 0 ? '${s.targetCount}' : '—',
                  ),
                  _StatDivider(),
                  _StatCell(
                    label: 'REGISTERED',
                    value: '${s.participantCount}',
                  ),
                  _StatDivider(),
                  _StatCell(
                    label: 'RESPONSES',
                    value: '${s.responseCount}',
                  ),
                ],
              ),
            ),
          // ── Info tiles ──
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                LayoutBuilder(
                  builder: (BuildContext ctx, BoxConstraints c) {
                    final double half = (c.maxWidth - 10) / 2;
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: <Widget>[
                        _InfoTile(
                          width: half,
                          icon: Icons.science_outlined,
                          label: 'PRODUCT',
                          value: product,
                        ),
                        _InfoTile(
                          width: half,
                          icon: Icons.category_outlined,
                          label: 'CATEGORY',
                          value: s?.category.isNotEmpty == true
                              ? s!.category
                              : '—',
                        ),
                        _InfoTile(
                          width: half,
                          icon: Icons.location_on_outlined,
                          label: 'FACILITY',
                          value: s?.location.isNotEmpty == true
                              ? s!.location
                              : '—',
                        ),
                        _InfoTile(
                          width: half,
                          icon: Icons.business_outlined,
                          label: 'ORGANIZER',
                          value: s?.ownerName.isNotEmpty == true
                              ? s!.ownerName
                              : '—',
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                _SectionLabel('STUDY INTRODUCTION'),
                const SizedBox(height: 10),
                _InstructionCard(
                  lines: const <String>[
                    'You will evaluate the product samples based on personal liking and perception.',
                    'There are no right or wrong answers. Please rinse your mouth between samples.',
                  ],
                ),
                const SizedBox(height: 14),
                _SectionLabel('INSTRUCTIONS TO PANELIST'),
                const SizedBox(height: 10),
                _InstructionCard(
                  numbered: true,
                  lines: const <String>[
                    'Evaluate each sample in the order presented.',
                    'Rinse your mouth with water between samples.',
                    'Rate based on your personal preference — there are no wrong answers.',
                    'Your panel number is on your consent form. Use it on the evaluation sheet.',
                  ],
                ),
                const SizedBox(height: 14),
                _AnalysisLinkCard(studyId: s?.id ?? studyId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: TaraTheme.textPrimary,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: TaraTheme.textSecondary,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: const Color(0xFFE5DDD4),
    );
  }
}

class _WhiteStatusBadge extends StatelessWidget {
  const _WhiteStatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(35),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withAlpha(80)),
      ),
      child: Text(
        status.isEmpty ? 'PENDING' : status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: TaraTheme.primary,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _InstructionCard extends StatelessWidget {
  const _InstructionCard({required this.lines, this.numbered = false});

  final List<String> lines;
  final bool numbered;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines.asMap().entries.map((MapEntry<int, String> entry) {
          return Padding(
            padding: EdgeInsets.only(bottom: entry.key < lines.length - 1 ? 8 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  numbered ? '${entry.key + 1}.' : '•',
                  style: const TextStyle(
                    color: TaraTheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    height: 1.5,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.value,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: TaraTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                      height: 1.55,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AnalysisLinkCard extends StatelessWidget {
  const _AnalysisLinkCard({required this.studyId});

  final String studyId;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TaraTheme.primaryTint,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFD8B5)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: TaraTheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.bar_chart_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Sensory Analysis',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: TaraTheme.primaryDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'View scores, JAR & penalty results',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: TaraTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: studyId.isNotEmpty
                ? () => context.push('/fic/studies/$studyId/analysis')
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: TaraTheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            child: const Text('View'),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
  });

  final double width;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 15, color: TaraTheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: const TextStyle(
                    color: TaraTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: TaraTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
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

// ─── QR Panel ─────────────────────────────────────────────────────────────────

class _QrPanel extends StatefulWidget {
  const _QrPanel({
    required this.title,
    required this.registrationUrl,
    required this.studyId,
    this.study,
  });

  final String title;
  final String registrationUrl;
  final String studyId;
  final FicStudy? study;

  @override
  State<_QrPanel> createState() => _QrPanelState();
}

class _QrPanelState extends State<_QrPanel> {
  bool _isDownloading = false;
  bool _copied = false;

  String get _decodedUrl {
    try {
      return Uri.decodeFull(widget.registrationUrl);
    } catch (_) {
      return widget.registrationUrl;
    }
  }

  Future<void> _downloadQrCode() async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);
    try {
      final QrPainter painter = QrPainter(
        data: widget.registrationUrl,
        version: QrVersions.auto,
        gapless: true,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Color(0xFF000000),
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Color(0xFF000000),
        ),
      );
      final ByteData? byteData = await painter.toImageData(
        1024,
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        throw StateError('QR image could not be generated.');
      }
      await FileSaver.instance.saveFile(
        name: '${_fileSafeName(widget.title)}-qr-code',
        bytes: byteData.buffer.asUint8List(),
        fileExtension: 'png',
        mimeType: MimeType.png,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR code saved.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save QR: $error')),
      );
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _copyLink() async {
    await Clipboard.setData(ClipboardData(text: widget.registrationUrl));
    if (!mounted) return;
    setState(() => _copied = true);
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final FicStudy? s = widget.study;
    final int registered = s?.participantCount ?? 0;
    final int target = s?.targetCount ?? 0;
    final double progress = target > 0
        ? (registered / target).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        children: <Widget>[
          // ── Panel header ──
          Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(
                bottom: BorderSide(color: Color(0xFFEDE8E1)),
              ),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: TaraTheme.primaryTint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.qr_code_rounded,
                    color: TaraTheme.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Registration QR Code',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: TaraTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Consumer scan-to-register',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: TaraTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ── QR code ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5DDD4), width: 1.5),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: widget.registrationUrl,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),
          // ── URL chip ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: GestureDetector(
              onTap: _copyLink,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      _copied ? Icons.check_rounded : Icons.link_rounded,
                      size: 14,
                      color: _copied
                          ? const Color(0xFF15803D)
                          : TaraTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _decodedUrl,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _copied
                              ? const Color(0xFF15803D)
                              : TaraTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _copied ? 'Copied!' : 'Tap to copy',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _copied
                            ? const Color(0xFF15803D)
                            : TaraTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ── Registration progress ──
          if (s != null) ...<Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Text(
                        'Registered Consumers',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: TaraTheme.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        target > 0
                            ? '$registered / $target'
                            : '$registered registered',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: TaraTheme.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: target > 0 ? progress : null,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFEDE8E1),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        TaraTheme.primary,
                      ),
                    ),
                  ),
                  if (target > 0) ...<Widget>[
                    const SizedBox(height: 5),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}% of target',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: TaraTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          // ── Action buttons ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isDownloading ? null : _downloadQrCode,
                    icon: _isDownloading
                        ? const SizedBox(
                            height: 14,
                            width: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.download_rounded, size: 16),
                    label: const Text('Download'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(
                      '/fic/studies/${widget.studyId}/analysis',
                      extra: widget.study,
                    ),
                    icon: const Icon(Icons.bar_chart_rounded, size: 16),
                    label: const Text('Analysis'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
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

// ─── Helpers ──────────────────────────────────────────────────────────────────

String _fileSafeName(String value) {
  final String normalized = value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return normalized.isEmpty ? 'study' : normalized;
}

String _studyTitle(FicStudy? study, String studyId) {
  final String title = study?.title.trim() ?? '';
  return title.isEmpty ? 'Study $studyId' : title;
}

String _studyProduct(FicStudy? study) {
  final String product = study?.productName.trim() ?? '';
  if (product.isNotEmpty) return product;
  final String title = study?.title.trim() ?? '';
  if (title.contains(' - ')) return title.split(' - ').first.trim();
  return title.isEmpty ? 'Product sample' : title;
}
