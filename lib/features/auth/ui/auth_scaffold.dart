import 'package:flutter/material.dart';
import 'package:tarasense_mobile/core/theme/tara_theme.dart';
import 'package:tarasense_mobile/core/widgets/tara_brand_lockup.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    this.isLoading = false,
    this.loadingMessage = 'Please wait...',
    this.isSuccess = false,
    this.successMessage = 'Success.',
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final bool isLoading;
  final String loadingMessage;
  final bool isSuccess;
  final String successMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFFFFFCF9), Color(0xFFF7F2EC)],
          ),
        ),
        child: Stack(
          children: <Widget>[
            const _BackgroundGlow(
              alignment: Alignment.topLeft,
              size: 220,
              color: Color(0x14F97316),
            ),
            const _BackgroundGlow(
              alignment: Alignment.bottomRight,
              size: 280,
              color: Color(0x120057A8),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final bool isWide = constraints.maxWidth >= 980;
                  final EdgeInsets padding = EdgeInsets.symmetric(
                    horizontal: isWide ? 32 : 18,
                    vertical: isWide ? 28 : 16,
                  );

                  final Widget formCard = Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: _FormPanel(
                        title: title,
                        subtitle: subtitle,
                        child: child,
                      ),
                    ),
                  );

                  if (!isWide) {
                    return SingleChildScrollView(
                      padding: padding,
                      child: formCard,
                    );
                  }

                  return Padding(
                    padding: padding,
                    child: Row(
                      children: <Widget>[
                        const Expanded(child: _BrandPanel()),
                        const SizedBox(width: 28),
                        Expanded(child: formCard),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (isLoading) _AuthLoadingScreen(message: loadingMessage),
            if (!isLoading && isSuccess)
              _AuthSuccessScreen(message: successMessage),
          ],
        ),
      ),
    );
  }
}

class AuthErrorMessage extends StatelessWidget {
  const AuthErrorMessage({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFECDD3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.error_outline_rounded,
            color: TaraTheme.roseText,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: TaraTheme.roseText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthButtonContent extends StatelessWidget {
  const AuthButtonContent({
    required this.isLoading,
    required this.label,
    this.loadingLabel,
    this.icon = Icons.arrow_forward_rounded,
    super.key,
  });

  final bool isLoading;
  final String label;
  final String? loadingLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Text(loadingLabel ?? label),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(label),
        const SizedBox(width: 8),
        Icon(icon, size: 18),
      ],
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      padding: const EdgeInsets.fromLTRB(40, 42, 40, 42),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x100F172A),
            blurRadius: 40,
            offset: Offset(0, 24),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const TaraBrandLockup(
            markSize: 28,
            textSize: 28,
            taraFillColor: TaraTheme.brandNavy,
            senseColor: TaraTheme.textPrimary,
          ),
          const Spacer(),
          Text(
            'Sensory workspace access built for teams, stations, and study participants.',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              height: 1.08,
              color: TaraTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sign in, register, or jump to the main dashboard preview from one calm, responsive entry point.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: TaraTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 26),
          const Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              _InfoPill(label: 'Projects'),
              _InfoPill(label: 'Studies'),
              _InfoPill(label: 'FIC Queue'),
              _InfoPill(label: 'Consumer Access'),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormPanel extends StatelessWidget {
  const _FormPanel({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final List<String> titleLines = title.split('\n');
    final String primaryLine = titleLines.first;
    final String accentLine = titleLines.length > 1
        ? titleLines.skip(1).join('\n')
        : '';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF8),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF1E7DA)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 32,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 26),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFFFFF7F0), Color(0xFFFDF9F5)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(31)),
              border: Border(
                bottom: BorderSide(color: Color(0xFFF1E7DA)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const TaraBrandLockup(
                      markSize: 16,
                      textSize: 16,
                      taraFillColor: TaraTheme.brandNavy,
                      senseColor: TaraTheme.textPrimary,
                    ),
                    const Spacer(),
                    Container(
                      height: 34,
                      width: 34,
                      decoration: BoxDecoration(
                        color: TaraTheme.primaryTint,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFFD8B5)),
                      ),
                      child: const Icon(
                        Icons.waving_hand_rounded,
                        color: TaraTheme.primary,
                        size: 17,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  primaryLine,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.04,
                    letterSpacing: -0.3,
                  ),
                ),
                if (accentLine.isNotEmpty)
                  Text(
                    accentLine,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: TaraTheme.primary,
                      fontWeight: FontWeight.w900,
                      height: 1.04,
                      letterSpacing: -0.3,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TaraTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: TaraTheme.primaryTint,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFF5D6BA)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: TaraTheme.primaryDark,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _AuthLoadingScreen extends StatefulWidget {
  const _AuthLoadingScreen({required this.message});

  final String message;

  @override
  State<_AuthLoadingScreen> createState() => _AuthLoadingScreenState();
}

class _AuthLoadingScreenState extends State<_AuthLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _turns;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    _turns = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: <Widget>[
          ModalBarrier(
            dismissible: false,
            color: Colors.white.withValues(alpha: 0.92),
          ),
          Center(
            child: Container(
              width: 260,
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
              decoration: BoxDecoration(
                color: TaraTheme.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: TaraTheme.border),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x180F172A),
                    blurRadius: 30,
                    offset: Offset(0, 18),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ScaleTransition(
                    scale: _scale,
                    child: RotationTransition(
                      turns: _turns,
                      child: const _TaraLoadingMark(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: TaraTheme.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Connecting to TARAsense...',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
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

class _TaraLoadingMark extends StatelessWidget {
  const _TaraLoadingMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      width: 70,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: const SweepGradient(
                colors: <Color>[
                  TaraTheme.primary,
                  Color(0xFFFFC48A),
                  TaraTheme.primary,
                ],
              ),
            ),
          ),
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: TaraTheme.surface,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: TaraTheme.primaryTint,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(
              Icons.lock_open_rounded,
              color: TaraTheme.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthSuccessScreen extends StatelessWidget {
  const _AuthSuccessScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: <Widget>[
          ModalBarrier(
            dismissible: false,
            color: Colors.white.withValues(alpha: 0.92),
          ),
          Center(
            child: Container(
              width: 280,
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
              decoration: BoxDecoration(
                color: TaraTheme.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: TaraTheme.border),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x180F172A),
                    blurRadius: 30,
                    offset: Offset(0, 18),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    height: 58,
                    width: 58,
                    decoration: BoxDecoration(
                      color: TaraTheme.mint,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: TaraTheme.mintText,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: TaraTheme.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Preparing your workspace...',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
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

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow({
    required this.alignment,
    required this.size,
    required this.color,
  });

  final Alignment alignment;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(size),
        ),
      ),
    );
  }
}
