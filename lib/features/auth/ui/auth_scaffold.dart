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
            colors: <Color>[Color(0xFFF7FAFD), TaraTheme.backgroundAlt],
          ),
        ),
        child: Stack(
          children: <Widget>[
            const _BackgroundGlow(
              alignment: Alignment.topLeft,
              size: 280,
              color: Color(0x33F97316),
            ),
            const _BackgroundGlow(
              alignment: Alignment.bottomRight,
              size: 340,
              color: Color(0x14FDBA74),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  if (constraints.maxWidth >= 980) {
                    return Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(36, 36, 18, 36),
                            child: const _BrandStoryPanel(),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(18, 36, 36, 36),
                            child: _FormPanel(
                              title: title,
                              subtitle: subtitle,
                              child: child,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    child: Column(
                      children: <Widget>[
                        const _CompactBrandHeader(),
                        const SizedBox(height: 14),
                        _FormPanel(
                          title: title,
                          subtitle: subtitle,
                          child: child,
                        ),
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
        borderRadius: BorderRadius.circular(16),
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
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
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
            color: Colors.white.withValues(alpha: 0.9),
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
                    child: SizedBox(
                      height: 58,
                      width: 58,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          const SizedBox.expand(
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                              color: TaraTheme.primary,
                            ),
                          ),
                          Container(
                            height: 34,
                            width: 34,
                            decoration: BoxDecoration(
                              color: TaraTheme.primaryTint,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Icon(
                              Icons.lock_open_rounded,
                              color: TaraTheme.primary,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
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

class _CompactBrandHeader extends StatelessWidget {
  const _CompactBrandHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFF97316), Color(0xFFFF9A45)],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x24F97316),
            blurRadius: 32,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          TaraBrandLockup(
            markSize: 26,
            textSize: 26,
            taraFillColor: TaraTheme.dostBlue,
            senseColor: Colors.white,
          ),
          SizedBox(height: 18),
          Text(
            'Sensory research, project setup, and support coordination in one mobile workspace.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              _InfoPill(label: 'Projects'),
              _InfoPill(label: 'Tests'),
              _InfoPill(label: 'FIC Support'),
            ],
          ),
        ],
      ),
    );
  }
}

class _BrandStoryPanel extends StatelessWidget {
  const _BrandStoryPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFF97316), Color(0xFFFFA24D)],
        ),
        borderRadius: BorderRadius.circular(38),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x24F97316),
            blurRadius: 36,
            offset: Offset(0, 20),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(34, 34, 34, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const TaraBrandLockup(
            markSize: 30,
            textSize: 30,
            taraFillColor: TaraTheme.dostBlue,
            senseColor: Colors.white,
          ),
          const Spacer(),
          Text(
            'Build projects, configure tests, and keep your sensory workflow moving.',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'The refreshed mobile experience follows the latest TARAsense web content while keeping a focused, touch-first layout.',
            style: TextStyle(color: Colors.white, fontSize: 16, height: 1.6),
          ),
          const SizedBox(height: 28),
          const Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              _FeatureChip(
                icon: Icons.inventory_2_outlined,
                title: 'Create Projects',
                subtitle: 'Start and organize work',
              ),
              _FeatureChip(
                icon: Icons.tune_rounded,
                title: 'Configure Tests',
                subtitle: 'Set categories and stages',
              ),
              _FeatureChip(
                icon: Icons.handshake_outlined,
                title: 'Request Support',
                subtitle: 'Coordinate with FIC teams',
              ),
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: TaraTheme.border),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 30,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Account Access',
              style: TextStyle(
                color: TaraTheme.primaryDark,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: TaraTheme.textSecondary),
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
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
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.45,
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
