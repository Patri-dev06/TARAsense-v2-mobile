part of 'landing_page.dart';

class _HeroLabVisual extends StatelessWidget {
  const _HeroLabVisual();

  @override
  Widget build(BuildContext context) {
    return const _FramedVisual(
      height: 360,
      child: _SensoryScene(colorA: Color(0xFFFF6A2C), colorB: Color(0xFFFFB15C)),
    );
  }
}


class _SensoryBoothVisual extends StatelessWidget {
  const _SensoryBoothVisual();

  @override
  Widget build(BuildContext context) {
    return const _FramedVisual(
      height: 360,
      child: _BoothScene(),
    );
  }
}

class _InsightDashboardVisual extends StatelessWidget {
  const _InsightDashboardVisual();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxWidth < 680;
        final double contentWidth = constraints.maxWidth - (compact ? 36 : 64);
        final double sideCardWidth = compact
            ? ((contentWidth - 12) / 2).clamp(112.0, 220.0)
            : ((contentWidth - 24) * 0.34).clamp(170.0, 220.0);
        final double forecastWidth = compact
            ? contentWidth
            : (contentWidth - sideCardWidth - 24).clamp(300.0, 420.0);
        return _SoftPanel(
          padding: EdgeInsets.all(compact ? 18 : 32),
          child: CustomPaint(
            painter: _GridPainter(alpha: 0.32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: const <Widget>[
                    _FloatingBadge(
                    title: 'AUDIENCE PULSE',
                    value: 'Trend improving',
                  ),
                    _SmallStatus(label: '12 markets aligned'),
                  ],
                ),
                const SizedBox(height: 22),
                if (compact) ...<Widget>[
                  _ForecastCard(width: forecastWidth),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: _TopActionsCard(
                          width: double.infinity,
                          compact: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SignalMixCard(
                          width: double.infinity,
                          compact: true,
                        ),
                      ),
                    ],
                  ),
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _ForecastCard(width: forecastWidth),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(child: _TopActionsCard(width: sideCardWidth)),
                            const SizedBox(width: 16),
                            Expanded(child: _SignalMixCard(width: sideCardWidth)),
                          ],
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerRight,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: compact ? contentWidth : contentWidth * 0.62,
                    ),
                    child: const _FloatingBadge(
                      title: 'NEXT BEST MOVE',
                      value: 'Shift budget to high-intent segments',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FramedVisual extends StatelessWidget {
  const _FramedVisual({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double responsiveHeight = constraints.maxWidth < 420
            ? 240
            : constraints.maxWidth < 760
                ? 300
                : height;
        return _SoftPanel(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: responsiveHeight,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _SensoryScene extends StatelessWidget {
  const _SensoryScene({required this.colorA, required this.colorB});

  final Color colorA;
  final Color colorB;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[colorA, colorB],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: CustomPaint(painter: _GridPainter(alpha: 0.12))),
          ...List<Widget>.generate(3, (index) {
            return Positioned(
              left: 36 + (index * 118),
              bottom: 52,
              child: _PanelistSilhouette(index: index),
            );
          }),
          Positioned(
            right: 28,
            bottom: 42,
            child: Row(
              children: List<Widget>.generate(
                3,
                (index) => Container(
                  margin: const EdgeInsets.only(left: 10),
                  height: 28,
                  width: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.68),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _BoothScene extends StatelessWidget {
  const _BoothScene();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[Color(0xFFE9F2F2), Color(0xFFFF7B45)],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: CustomPaint(painter: _GridPainter(alpha: 0.1))),
          ...List<Widget>.generate(4, (index) {
            return Positioned(
              left: 42.0 + (index * 106),
              top: 64,
              bottom: 42,
              child: Container(
                width: 92,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white),
                ),
              ),
            );
          }),
          Positioned(
            left: 42,
            right: 42,
            bottom: 52,
            child: Container(height: 18, color: Colors.white.withValues(alpha: 0.82)),
          ),
        ],
      ),
    );
  }
}

class _PanelistSilhouette extends StatelessWidget {
  const _PanelistSilhouette({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final Color color = index == 1 ? const Color(0xFF1B2938) : const Color(0xFF234E68);
    return Column(
      children: <Widget>[
        CircleAvatar(radius: 24, backgroundColor: color),
        const SizedBox(height: 8),
        Container(
          height: 108,
          width: 58,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ],
    );
  }
}


