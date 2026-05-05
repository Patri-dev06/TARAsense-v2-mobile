import 'package:flutter/material.dart';

class DostLogoMark extends StatelessWidget {
  const DostLogoMark({super.key, this.size = 44});

  static const String assetPath = 'assets/images/dost-logo.png';

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'DOST logo',
      image: true,
      child: Image.asset(
        assetPath,
        height: size,
        width: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
