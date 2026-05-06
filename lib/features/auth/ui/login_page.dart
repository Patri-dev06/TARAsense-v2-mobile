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

    if (!mounted ||
        ref.read(authControllerProvider).status == AuthStatus.authenticated) {
      return;
    }

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    });

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AuthScaffold(
        title: 'Log in to your account',
        subtitle: 'Enter your email and password below to log in.',
        isLoading: authState.isBusy || _isSubmittingLogin,
        loadingMessage: 'Logging in...',
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: TaraTheme.primaryTint,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: TaraTheme.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.lock_outline_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Secure access',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: TaraTheme.primaryDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Use the same account you use on the latest TARAsense web app.',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text('Email address', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const <String>[
                    AutofillHints.username,
                    AutofillHints.email,
                  ],
                  decoration: const InputDecoration(
                    hintText: 'email@example.com',
                    prefixIcon: Icon(Icons.mail_outline_rounded),
                  ),
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
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
                Text('Password', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const <String>[AutofillHints.password],
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
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
                  ),
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
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
                const SizedBox(height: 10),
                InkWell(
                  onTap: () {
                    setState(() {
                      _rememberMe = !_rememberMe;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: <Widget>[
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (bool? value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Remember me on this device',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      _showComingSoon(
                        'Forgot password will be added to the mobile flow next.',
                      );
                    },
                    child: const Text('Forgot password?'),
                  ),
                ),
                if (authState.errorMessage != null) ...<Widget>[
                  const SizedBox(height: 14),
                  AuthErrorMessage(message: authState.errorMessage!),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: authState.isBusy || _isSubmittingLogin
                        ? null
                        : _submit,
                    child: AuthButtonContent(
                      isLoading: authState.isBusy || _isSubmittingLogin,
                      label: 'Log in',
                      loadingLabel: 'Logging in...',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: authState.isBusy || _isSubmittingLogin
                        ? null
                        : () => context.go('/register'),
                    child: const Text('Create account'),
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
                        style: theme.textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: authState.isBusy || _isSubmittingLogin
                            ? null
                            : () => context.go('/register'),
                        child: const Text('Sign up'),
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
                    icon: const Icon(Icons.dashboard_outlined),
                    label: const Text('Back to main dashboard'),
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
