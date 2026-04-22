import 'package:flutter/material.dart';
import 'package:tarasense_mobile/core/theme/tara_theme.dart';

class TaraBrandLockup extends StatelessWidget {
  const TaraBrandLockup({
    super.key,
    this.markSize = 28,
    this.textSize = 26,
    this.senseColor,
    this.center = false,
  });

  final double markSize;
  final double textSize;
  final Color? senseColor;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final textColor = senseColor ?? TaraTheme.textPrimary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: center
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: <Widget>[
        _TaraBrandMark(size: markSize),
        const SizedBox(width: 10),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: textSize,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
            children: <InlineSpan>[
              const TextSpan(
                text: 'TARA',
                style: TextStyle(color: TaraTheme.primary),
              ),
              TextSpan(
                text: 'sense',
                style: TextStyle(color: textColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TaraBrandMark extends StatelessWidget {
  const _TaraBrandMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              border: Border.all(color: TaraTheme.primary, width: size * 0.12),
              borderRadius: BorderRadius.circular(size),
            ),
          ),
          Positioned(
            top: size * 0.08,
            right: size * 0.02,
            child: Container(
              height: size * 0.26,
              width: size * 0.26,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(size),
              ),
            ),
          ),
          Container(
            height: size * 0.26,
            width: size * 0.26,
            decoration: BoxDecoration(
              color: TaraTheme.primary,
              borderRadius: BorderRadius.circular(size),
            ),
          ),
        ],
      ),
    );
  }
}
