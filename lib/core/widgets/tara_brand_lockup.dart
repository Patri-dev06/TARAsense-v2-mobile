import 'package:flutter/material.dart';
import 'package:tarasense_mobile/core/theme/tara_theme.dart';

class TaraBrandLockup extends StatelessWidget {
  const TaraBrandLockup({
    super.key,
    this.markSize = 28,
    this.textSize = 26,
    this.senseColor,
    this.taraFillColor,
    this.taraOutlineColor,
    this.center = false,
  });

  final double markSize;
  final double textSize;
  final Color? senseColor;
  final Color? taraFillColor;
  final Color? taraOutlineColor;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final textColor = senseColor ?? TaraTheme.textPrimary;
    final TextStyle brandTextStyle = TextStyle(
      fontSize: textSize,
      fontWeight: FontWeight.w900,
      letterSpacing: -1,
      height: 1,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: center
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: <Widget>[
        _TaraBrandMark(size: markSize),
        const SizedBox(width: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _OutlinedBrandText(
              text: 'TARA',
              style: brandTextStyle,
              fillColor: taraFillColor ?? TaraTheme.primary,
              outlineColor: taraOutlineColor,
            ),
            Text('sense', style: brandTextStyle.copyWith(color: textColor)),
          ],
        ),
      ],
    );
  }
}

class _OutlinedBrandText extends StatelessWidget {
  const _OutlinedBrandText({
    required this.text,
    required this.style,
    required this.fillColor,
    this.outlineColor,
  });

  final String text;
  final TextStyle style;
  final Color fillColor;
  final Color? outlineColor;

  @override
  Widget build(BuildContext context) {
    if (outlineColor == null) {
      return Text(text, style: style.copyWith(color: fillColor));
    }

    return Stack(
      children: <Widget>[
        Text(
          text,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.4
              ..color = outlineColor!,
          ),
        ),
        Text(text, style: style.copyWith(color: fillColor)),
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
