import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tarasense_mobile/core/theme/tara_theme.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  bool _handled = false;
  String? _errorMessage;

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final Barcode barcode in capture.barcodes) {
      final String? raw = barcode.rawValue;
      if (raw == null) continue;
      final String? studyId = _extractStudyId(raw);
      if (studyId != null) {
        _handled = true;
        if (mounted) {
          context.pop();
          context.push('/consumer/studies/$studyId');
        }
        return;
      }
    }
    if (mounted && _errorMessage == null) {
      setState(
        () => _errorMessage = 'Not a valid TARAsense study QR code.',
      );
      Future<void>.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _errorMessage = null);
      });
    }
  }

  String? _extractStudyId(String raw) {
    final Uri? uri = Uri.tryParse(raw);
    if (uri == null) return null;
    final RegExp pattern = RegExp(r'/studies/([^/?#]+)');
    // Format: /login?next=/studies/{studyId}/start
    final String next = uri.queryParameters['next'] ?? '';
    final Match? nextMatch = pattern.firstMatch(next);
    if (nextMatch != null) return nextMatch.group(1);
    // Format: direct path /studies/{studyId}/...
    final Match? pathMatch = pattern.firstMatch(uri.path);
    if (pathMatch != null) return pathMatch.group(1);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          MobileScanner(onDetect: _onDetect),
          const _ScanOverlay(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Scan Study QR',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 44),
                    ],
                  ),
                ),
                const Spacer(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Point at a TARAsense study QR code',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.fromLTRB(32, 12, 32, 0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade900.withAlpha(220),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(height: 64),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanOverlay extends StatelessWidget {
  const _ScanOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: MediaQuery.sizeOf(context),
      painter: _OverlayPainter(),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  static const double _cutoutSize = 248;
  static const double _cornerLength = 24;
  static const double _cornerRadius = 6;
  static const double _cornerWidth = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final double left = (size.width - _cutoutSize) / 2;
    final double top = (size.height - _cutoutSize) / 2 - 48;
    final Rect cutout = Rect.fromLTWH(left, top, _cutoutSize, _cutoutSize);

    // Dark overlay with transparent cutout
    final Paint dark = Paint()..color = Colors.black.withAlpha(185);
    final Path overlay = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
        RRect.fromRectAndRadius(
          cutout,
          const Radius.circular(_cornerRadius),
        ),
      )
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(overlay, dark);

    // Corner bracket paint
    final Paint corner = Paint()
      ..color = TaraTheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = _cornerWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    void drawCorner(Offset a, Offset b, Offset c) {
      canvas.drawPath(
        Path()
          ..moveTo(a.dx, a.dy)
          ..lineTo(b.dx, b.dy)
          ..lineTo(c.dx, c.dy),
        corner,
      );
    }

    final double r = left + _cutoutSize;
    final double b = top + _cutoutSize;
    final double l = _cornerLength;

    drawCorner(Offset(left, top + l), Offset(left, top), Offset(left + l, top));
    drawCorner(Offset(r - l, top), Offset(r, top), Offset(r, top + l));
    drawCorner(Offset(left, b - l), Offset(left, b), Offset(left + l, b));
    drawCorner(Offset(r - l, b), Offset(r, b), Offset(r, b - l));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
