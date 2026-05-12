import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tarasense_mobile/core/theme/tara_theme.dart';
import 'package:tarasense_mobile/features/auth/state/auth_providers.dart';
import 'package:tarasense_mobile/features/auth/state/auth_state.dart';
import 'package:tarasense_mobile/features/auth/ui/auth_scaffold.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isSubmittingLogin = false;
  bool _isNavigatingAfterLogin = false;
  DateTime? _loginAnimationStartedAt;
  bool _loginDialogVisible = false;

  static const Duration _minimumLoginAnimationDuration = Duration(
    milliseconds: 850,
  );

  @override
  void dispose() {
    _hideLoginOverlay();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmittingLogin = true;
      _loginAnimationStartedAt = DateTime.now();
    });
    _showLoginOverlay();
    await WidgetsBinding.instance.endOfFrame;

    await ref
        .read(authControllerProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

    // Success is handled by ref.listen → _completeSuccessfulLogin.
    // Only run cleanup here when login failed and the widget is still alive.
    if (!mounted) return;
    await _waitForMinimumLoginAnimation();
    if (mounted) {
      _hideLoginOverlay();
      setState(() => _isSubmittingLogin = false);
    }
  }

  void _showLoginOverlay() {
    if (_loginDialogVisible) {
      return;
    }
    _loginDialogVisible = true;
    unawaited(
      showGeneralDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierLabel: 'Logging in',
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 120),
        pageBuilder: (context, animation, secondaryAnimation) {
          return const _LoginLoadingOverlay(message: 'Logging in...');
        },
      ).whenComplete(() => _loginDialogVisible = false),
    );
  }

  void _hideLoginOverlay() {
    if (!_loginDialogVisible || !mounted) {
      return;
    }
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
    _loginDialogVisible = false;
  }

  Future<void> _waitForMinimumLoginAnimation() async {
    final DateTime startedAt = _loginAnimationStartedAt ?? DateTime.now();
    final Duration elapsed = DateTime.now().difference(startedAt);
    final Duration remaining = _minimumLoginAnimationDuration - elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }
  }

  Future<void> _completeSuccessfulLogin(AuthState next) async {
    if (_isNavigatingAfterLogin) {
      return;
    }
    _isNavigatingAfterLogin = true;
    await _waitForMinimumLoginAnimation();
    if (!mounted) {
      return;
    }
    _hideLoginOverlay();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged in successfully.')),
    );
    context.go(next.session?.user.homePath ?? '/dashboard');
  }

  void _showComingSoon(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (previous?.status != AuthStatus.authenticated &&
          next.status == AuthStatus.authenticated) {
        unawaited(_completeSuccessfulLogin(next));
      } else if (next.errorMessage != null &&
          previous?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(
                next.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
              backgroundColor: const Color(0xFF1F2937),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              margin: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              duration: const Duration(seconds: 4),
            ),
          );
      }
    });

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AuthScaffold(
        title: 'Welcome\nback.',
        subtitle: 'Sign in to your sensory workspace.',
        isLoading: false,
        loadingMessage: 'Logging in...',
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _AuthTextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const <String>[
                    AutofillHints.username,
                    AutofillHints.email,
                  ],
                  hintText: 'Email address',
                  prefixIcon: Icons.mail_outline_rounded,
                  validator: (String? value) {
                    final text = (value ?? '').trim();
                    if (text.isEmpty) {
                      return 'Enter your email address';
                    }
                    if (!text.contains('@')) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _AuthTextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const <String>[AutofillHints.password],
                  hintText: 'Password',
                  prefixIcon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                  onFieldSubmitted: (_) {
                    if (!authState.isBusy) {
                      _submit();
                    }
                  },
                  validator: (String? value) {
                    final text = (value ?? '').trim();
                    if (text.isEmpty) {
                      return 'Enter your password';
                    }
                    if (text.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _rememberMe = !_rememberMe;
                          });
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: <Widget>[
                              Checkbox(
                                value: _rememberMe,
                                visualDensity: VisualDensity.compact,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Remember me',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: TaraTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _showComingSoon(
                          'Forgot password will be added to the mobile flow next.',
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: TaraTheme.primaryDark,
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text('Forgot password?'),
                    ),
                  ],
                ),
                if (authState.errorMessage != null) ...<Widget>[
                  const SizedBox(height: 14),
                  AuthErrorMessage(message: authState.errorMessage!),
                ],
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: authState.isBusy || _isSubmittingLogin
                        ? null
                        : _submit,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(58),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: AuthButtonContent(
                      isLoading: authState.isBusy || _isSubmittingLogin,
                      label: 'Log in',
                      loadingLabel: 'Logging in...',
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const _AuthDivider(label: 'or continue with'),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: authState.isBusy || _isSubmittingLogin
                        ? null
                        : () => context.go('/register'),
                    style: _secondaryButtonStyle(),
                    child: const Text('Create new account'),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Text(
                        'Don\'t have an account? ',
                        style: theme.textTheme.bodySmall,
                      ),
                      TextButton(
                        onPressed: authState.isBusy || _isSubmittingLogin
                            ? null
                            : () => context.go('/register'),
                        child: const Text('Sign up free'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: authState.isBusy || _isSubmittingLogin
                        ? null
                        : () => context.go('/'),
                    style: _secondaryButtonStyle(
                      foregroundColor: TaraTheme.textPrimary,
                    ),
                    icon: const Icon(Icons.dashboard_outlined),
                    label: const Text('Go to main dashboard'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

ButtonStyle _secondaryButtonStyle({Color? foregroundColor}) {
  return OutlinedButton.styleFrom(
    backgroundColor: Colors.transparent,
    foregroundColor: foregroundColor ?? TaraTheme.textPrimary,
    minimumSize: const Size.fromHeight(56),
    side: const BorderSide(color: TaraTheme.border),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
  );
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    required this.validator,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.obscureText = false,
    this.suffixIcon,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      obscureText: obscureText,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon,
        fillColor: const Color(0xFFF6F1EA),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE6DDD0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE6DDD0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: TaraTheme.primary, width: 1.4),
        ),
      ),
    );
  }
}

class _AuthDivider extends StatelessWidget {
  const _AuthDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final TextStyle? textStyle = Theme.of(context).textTheme.bodySmall;
    return Row(
      children: <Widget>[
        const Expanded(child: Divider(color: TaraTheme.border, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label, style: textStyle),
        ),
        const Expanded(child: Divider(color: TaraTheme.border, height: 1)),
      ],
    );
  }
}

class _LoginLoadingOverlay extends StatefulWidget {
  const _LoginLoadingOverlay({required this.message});

  final String message;

  @override
  State<_LoginLoadingOverlay> createState() => _LoginLoadingOverlayState();
}

class _LoginLoadingOverlayState extends State<_LoginLoadingOverlay>
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
                  child: const SizedBox(
                    height: 64,
                    width: 64,
                    child: CircularProgressIndicator(
                      strokeWidth: 5,
                      color: TaraTheme.primary,
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
                  'Preparing your workspace...',
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
