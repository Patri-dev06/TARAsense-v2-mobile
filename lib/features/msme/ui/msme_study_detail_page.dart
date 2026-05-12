import 'dart:ui' as ui;

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tarasense_mobile/core/config/app_config.dart';
import 'package:tarasense_mobile/core/theme/tara_theme.dart';
import 'package:tarasense_mobile/features/msme/domain/msme_models.dart';

class MsmeStudyDetailPage extends StatefulWidget {
  const MsmeStudyDetailPage({
    required this.studyId,
    this.initialStudy,
    super.key,
  });

  final String studyId;
  final MsmeStudyItem? initialStudy;

  @override
  State<MsmeStudyDetailPage> createState() => _MsmeStudyDetailPageState();
}

class _MsmeStudyDetailPageState extends State<MsmeStudyDetailPage> {
  bool _isDownloadingQr = false;

  String get _registrationUrl {
    final String fromStudy =
        widget.initialStudy?.publicRegistrationUrl.trim() ?? '';
    if (fromStudy.isNotEmpty) {
      return fromStudy;
    }
    return AppConfig.publicStudyRegistrationUri(widget.studyId).toString();
  }

  String get _title {
    final String title = widget.initialStudy?.title.trim() ?? '';
    return title.isEmpty ? 'Study Form and QR' : title;
  }

  Future<void> _copyRegistrationLink() async {
    await Clipboard.setData(ClipboardData(text: _registrationUrl));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Registration link copied.')));
  }

  Future<void> _downloadQrCode() async {
    if (_isDownloadingQr) {
      return;
    }
    setState(() => _isDownloadingQr = true);
    try {
      final QrPainter painter = QrPainter(
        data: _registrationUrl,
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
      final Uint8List bytes = byteData.buffer.asUint8List();
      await FileSaver.instance.saveFile(
        name: '${_fileSafeName(_title)}-qr-code',
        bytes: bytes,
        fileExtension: 'png',
        mimeType: MimeType.png,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('QR code downloaded.')));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not download QR code: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isDownloadingQr = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final MsmeStudyItem? study = widget.initialStudy;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F4),
      appBar: AppBar(
        title: const Text('Study Form and QR'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
          children: <Widget>[
            _StudySummaryPanel(studyId: widget.studyId, study: study),
            const SizedBox(height: 14),
            _QrPanel(
              title: _title,
              registrationUrl: _registrationUrl,
              isDownloading: _isDownloadingQr,
              onDownload: _downloadQrCode,
              onCopy: _copyRegistrationLink,
            ),
          ],
        ),
      ),
    );
  }
}

class _StudySummaryPanel extends StatelessWidget {
  const _StudySummaryPanel({required this.studyId, required this.study});

  final String studyId;
  final MsmeStudyItem? study;

  @override
  Widget build(BuildContext context) {
    return _DetailPanel(
      icon: Icons.science_outlined,
      title: study?.title.trim().isEmpty == false
          ? study!.title
          : 'Study $studyId',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (study?.productName.trim().isNotEmpty == true)
            _DetailLine(label: 'Product', value: study!.productName),
          if (study?.category.trim().isNotEmpty == true)
            _DetailLine(label: 'Category', value: study!.category),
          if (study?.location.trim().isNotEmpty == true)
            _DetailLine(label: 'Facility', value: study!.location),
          if (study != null)
            _DetailLine(
              label: 'Responses',
              value: '${study!.responseCount}/${study!.sampleSize}',
            ),
          _DetailLine(label: 'Study ID', value: studyId),
        ],
      ),
    );
  }
}

class _QrPanel extends StatelessWidget {
  const _QrPanel({
    required this.title,
    required this.registrationUrl,
    required this.isDownloading,
    required this.onDownload,
    required this.onCopy,
  });

  final String title;
  final String registrationUrl;
  final bool isDownloading;
  final VoidCallback onDownload;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return _DetailPanel(
      icon: Icons.qr_code_rounded,
      title: 'Public Registration QR',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 260,
              height: 260,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: TaraTheme.border),
              ),
              child: QrImageView(
                data: registrationUrl,
                version: QrVersions.auto,
                gapless: true,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            registrationUrl,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: TaraTheme.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              FilledButton.icon(
                onPressed: isDownloading ? null : onDownload,
                icon: isDownloading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download_rounded),
                label: const Text('Download QR Code'),
              ),
              OutlinedButton.icon(
                onPressed: onCopy,
                icon: const Icon(Icons.link_rounded),
                label: const Text('Copy Link'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({
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

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: TaraTheme.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: TaraTheme.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _fileSafeName(String value) {
  final String normalized = value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return normalized.isEmpty ? 'study' : normalized;
}
