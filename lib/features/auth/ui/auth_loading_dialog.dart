import 'package:flutter/material.dart';
import 'package:tarasense_mobile/core/theme/tara_theme.dart';

final ValueNotifier<bool> authOperationOverlayVisible =
    ValueNotifier<bool>(false);

Future<void> showLogoutLoadingAndRun(
  BuildContext context,
  Future<void> Function() logout,
) async {
  if (!context.mounted) {
    return;
  }

  authOperationOverlayVisible.value = true;
  await WidgetsBinding.instance.endOfFrame;
  await Future<void>.delayed(const Duration(milliseconds: 850));

  await logout();
  await WidgetsBinding.instance.endOfFrame;
  await Future<void>.delayed(const Duration(milliseconds: 220));
  authOperationOverlayVisible.value = false;
}

class AuthOperationLoadingOverlay extends StatefulWidget {
  const AuthOperationLoadingOverlay({
    required this.message,
    required this.subtitle,
    required this.icon,
    super.key,
  });

  final String message;
  final String subtitle;
  final IconData icon;

  @override
  State<AuthOperationLoadingOverlay> createState() =>
      _AuthOperationLoadingOverlayState();
}

class _AuthOperationLoadingOverlayState
    extends State<AuthOperationLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.94, end: 1.06).animate(
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
    return SizedBox.expand(
      child: Material(
        color: Colors.white.withValues(alpha: 0.92),
        child: Center(
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
                ScaleTransition(
                  scale: _scale,
                  child: SizedBox(
                    height: 64,
                    width: 64,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        const SizedBox.expand(
                          child: CircularProgressIndicator(
                            strokeWidth: 5,
                            color: TaraTheme.primary,
                          ),
                        ),
                        Icon(
                          widget.icon,
                          color: TaraTheme.primary,
                          size: 22,
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
                  widget.subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
