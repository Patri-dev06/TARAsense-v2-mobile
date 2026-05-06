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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    await ref
        .read(authControllerProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged in successfully.')),
        );
        context.go(next.session?.user.homePath ?? '/dashboard');
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
        isLoading: authState.isBusy,
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
                    onPressed: authState.isBusy ? null : _submit,
                    child: AuthButtonContent(
                      isLoading: authState.isBusy,
                      label: 'Log in',
                      loadingLabel: 'Logging in...',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: authState.isBusy ? null : () => context.go('/register'),
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
                        onPressed: authState.isBusy ? null : () => context.go('/register'),
                        child: const Text('Sign up'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: authState.isBusy ? null : () => context.go('/'),
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
