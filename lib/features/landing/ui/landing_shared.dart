part of 'landing_page.dart';

class _SoftPanel extends StatelessWidget {
  const _SoftPanel({
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.width,
  });

  final Widget child;
  final EdgeInsets padding;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFDDE3EE)),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x0E1A2440), blurRadius: 28, offset: Offset(0, 14)),
        ],
      ),
      child: child,
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFFFF3D7A),
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          height: 24,
          width: 24,
          decoration: const BoxDecoration(
            color: Color(0xFFE9EDFF),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF2452FF), size: 15),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF1C2030),
                  fontSize: 16,
                ),
          ),
        ),
      ],
    );
  }
}

class _NeutralPill extends StatelessWidget {
  const _NeutralPill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double maxWidth = screenWidth < 520 ? screenWidth - 96 : 380;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE8E2D8),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w800),
          softWrap: true,
        ),
      ),
    );
  }
}

class _FloatingBadge extends StatelessWidget {
  const _FloatingBadge({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 0),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: TaraTheme.border),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x0F1A2440), blurRadius: 16, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: const TextStyle(color: Color(0xFF606B82), fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _SmallStatus extends StatelessWidget {
  const _SmallStatus({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.shield_outlined, color: Color(0xFF2452FF), size: 16),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Color(0xFF606B82), fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ForecastCard extends StatelessWidget {
  const _ForecastCard({this.width = 300});

  final double width;

  @override
  Widget build(BuildContext context) {
    return _SoftPanel(
      width: width,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _Eyebrow('FORECAST'),
          const SizedBox(height: 14),
          const Text(
            '12 markets\naligned',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, height: 1.08),
          ),
          const SizedBox(height: 30),
          SizedBox(height: 110, child: CustomPaint(painter: _LineChartPainter(), child: const SizedBox.expand())),
        ],
      ),
    );
  }
}

class _TopActionsCard extends StatelessWidget {
  const _TopActionsCard({this.width = 188, this.compact = false});

  final double width;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return _SoftPanel(
      width: width,
      padding: EdgeInsets.all(compact ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Top actions',
            style: TextStyle(
              color: Color(0xFF606B82),
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: compact ? 10 : 16),
          _ActionBubble(label: 'Insight\narchives', number: '01', compact: compact),
          SizedBox(height: compact ? 8 : 12),
          _ActionBubble(label: 'Governed\ntemplates', number: '02', compact: compact),
          SizedBox(height: compact ? 8 : 12),
          _ActionBubble(
            label: 'Cross-market\nlearnings',
            number: '03',
            compact: compact,
          ),
        ],
      ),
    );
  }
}

class _ActionBubble extends StatelessWidget {
  const _ActionBubble({
    required this.label,
    required this.number,
    this.compact = false,
  });

  final String label;
  final String number;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 10 : 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E2D8),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(height: 1.2, fontSize: compact ? 12 : null),
            ),
          ),
          Text(
            number,
            style: TextStyle(
              color: const Color(0xFF606B82),
              fontSize: compact ? 12 : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalMixCard extends StatelessWidget {
  const _SignalMixCard({this.width = 184, this.compact = false});

  final double width;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return _SoftPanel(
      width: width,
      padding: EdgeInsets.all(compact ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Expanded(child: Text('Signal mix', style: TextStyle(color: Color(0xFF606B82), fontWeight: FontWeight.w800))),
              Text('Live', style: TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
          SizedBox(height: compact ? 12 : 18),
          _ProgressMetric(label: 'INTENT', value: 0.78, compact: compact),
          _ProgressMetric(label: 'CLARITY', value: 0.62, compact: compact),
          _ProgressMetric(label: 'RECALL', value: 0.49, compact: compact),
        ],
      ),
    );
  }
}

class _ProgressMetric extends StatelessWidget {
  const _ProgressMetric({
    required this.label,
    required this.value,
    this.compact = false,
  });

  final String label;
  final double value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 9 : 12),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: const Color(0xFF606B82),
                    fontSize: compact ? 10 : 12,
                  ),
                ),
              ),
              Text(
                '${(value * 100).round()}%',
                style: TextStyle(
                  color: const Color(0xFF606B82),
                  fontSize: compact ? 10 : 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: const Color(0xFFE8E2D8),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2452FF)),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter({this.alpha = 0.42});

  final double alpha;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFFDDE3EE).withValues(alpha: alpha)
      ..strokeWidth = 1;
    for (double x = 0; x <= size.width; x += 26) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += 26) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.alpha != alpha;
  }
}

class _LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint grid = Paint()
      ..color = TaraTheme.border
      ..strokeWidth = 1;
    for (int i = 1; i < 5; i++) {
      final double y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final List<Offset> points = <Offset>[
      Offset(0, size.height * .82),
      Offset(size.width * .16, size.height * .68),
      Offset(size.width * .33, size.height * .50),
      Offset(size.width * .5, size.height * .34),
      Offset(size.width * .66, size.height * .22),
      Offset(size.width * .83, size.height * .16),
      Offset(size.width, size.height * .02),
    ];
    final Path path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final Offset point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF2452FF)
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke,
    );
    for (final Offset point in points) {
      canvas.drawCircle(point, 5, Paint()..color = Colors.white);
      canvas.drawCircle(
        point,
        5,
        Paint()
          ..color = const Color(0xFF2452FF)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
