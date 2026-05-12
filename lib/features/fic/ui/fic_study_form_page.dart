import 'package:flutter/material.dart';
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
      studyId,
    ).toString();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F4),
      appBar: AppBar(
        title: const Text('Sensory Score Sheet'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool twoColumns = constraints.maxWidth >= 920;
            final Widget scoreSheet = _ScoreSheetPanel(
              title: title,
              product: product,
              study: study,
            );
            final Widget qrPanel = _StudyQrPanel(
              registrationUrl: registrationUrl,
            );

            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              children: <Widget>[
                if (twoColumns)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(flex: 2, child: scoreSheet),
                      const SizedBox(width: 22),
                      SizedBox(width: 360, child: qrPanel),
                    ],
                  )
                else ...<Widget>[
                  scoreSheet,
                  const SizedBox(height: 16),
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

class _ScoreSheetPanel extends StatelessWidget {
  const _ScoreSheetPanel({
    required this.title,
    required this.product,
    required this.study,
  });

  final String title;
  final String product;
  final FicStudy? study;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'SENSORY SCORE SHEET',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: TaraTheme.primary,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: TaraTheme.textPrimary,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'No purpose provided.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: TaraTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool twoColumns = constraints.maxWidth >= 620;
              final double width = twoColumns
                  ? (constraints.maxWidth - 14) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: <Widget>[
                  _InfoTile(
                    width: width,
                    label: 'PRODUCT / STUDY TYPE',
                    value: product,
                  ),
                  _InfoTile(
                    width: width,
                    label: 'CATEGORY',
                    value: study?.category ?? 'Consumer Test',
                  ),
                  _InfoTile(
                    width: width,
                    label: 'FACILITY',
                    value: study?.location ?? 'Food iHub (DOST Caraga)',
                  ),
                  _InfoTile(
                    width: width,
                    label: 'TARGET RESPONSES',
                    value: (study?.targetCount ?? 0) > 0
                        ? study!.targetCount.toString()
                        : '35',
                  ),
                  _InfoTile(
                    width: width,
                    label: 'TARGET CONSUMER PROFILE',
                    value: 'Any consumer profile',
                  ),
                  _InfoTile(width: width, label: 'NO. OF SAMPLES', value: '2'),
                  _InfoTile(
                    width: width,
                    label: 'METHOD',
                    value: 'CONSUMER TEST / Consumer Test',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          const _InstructionBlock(
            title: 'Study Introduction',
            lines: <String>[
              'You will evaluate the product samples based on personal liking and perception. There are no right or wrong answers. Please rinse your mouth between samples.',
            ],
          ),
          const SizedBox(height: 16),
          const _InstructionBlock(
            title: 'Instructions to Panelist',
            lines: <String>[
              'You will evaluate 2 product samples.',
              'Taste the samples in the order presented.',
              'Rinse your mouth with water between samples.',
              'There are no right or wrong answers - please rate based on your personal preference.',
            ],
          ),
          const SizedBox(height: 16),
          const _AttributePreview(),
        ],
      ),
    );
  }
}

class _StudyQrPanel extends StatelessWidget {
  const _StudyQrPanel({required this.registrationUrl});

  final String registrationUrl;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'QR Code',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: TaraTheme.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Use this QR to send consumers to registration before sensory participation.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: TaraTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 280,
              height: 280,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: TaraTheme.border),
              ),
              child: QrImageView(
                data: registrationUrl,
                version: QrVersions.auto,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            registrationUrl,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: TaraTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: TaraTheme.border),
      ),
      child: child,
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.width,
    required this.label,
    required this.value,
  });

  final double width;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF52657D),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: TaraTheme.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionBlock extends StatelessWidget {
  const _InstructionBlock({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: TaraTheme.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          ...lines.map(
            (String line) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                line,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: TaraTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttributePreview extends StatelessWidget {
  const _AttributePreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Attribute Evaluation',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: TaraTheme.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: TaraTheme.border),
            ),
            child: Text(
              'Saltiness\n- JAR\n- Attribute Liking',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: TaraTheme.textPrimary,
                fontWeight: FontWeight.w700,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _studyTitle(FicStudy? study, String studyId) {
  final String title = study?.title.trim() ?? '';
  return title.isEmpty ? 'Study $studyId' : title;
}

String _studyProduct(FicStudy? study) {
  final String product = study?.productName.trim() ?? '';
  if (product.isNotEmpty) {
    return product;
  }
  final String title = study?.title.trim() ?? '';
  if (title.contains(' - ')) {
    return title.split(' - ').first.trim();
  }
  return title.isEmpty ? 'Product sample' : title;
}
