import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tarasense_mobile/core/theme/tara_theme.dart';
import 'package:tarasense_mobile/features/auth/state/auth_providers.dart';
import 'package:tarasense_mobile/features/auth/state/auth_state.dart';
import 'package:tarasense_mobile/features/auth/ui/auth_scaffold.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String _selectedRole = 'MSME';
  bool _registrationSucceeded = false;
  bool _redirectScheduled = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _registrationSucceeded = false);

    await ref
        .read(authControllerProvider.notifier)
        .register(
          name: _nameController.text.trim(),
          organization: null,
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          role: _selectedRole,
        );
  }

  void _handleRegistrationSuccess(AuthState next) {
    if (_redirectScheduled) {
      return;
    }

    _redirectScheduled = true;
    ScaffoldMessenger.of(context).clearSnackBars();
    setState(() => _registrationSucceeded = true);

    Future<void>.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) {
        return;
      }
      context.go(next.session?.user.homePath ?? '/dashboard');
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (previous?.status != AuthStatus.authenticated &&
          next.status == AuthStatus.authenticated) {
        _handleRegistrationSuccess(next);
      } else if (next.errorMessage != null &&
          previous?.errorMessage != next.errorMessage) {
        _redirectScheduled = false;
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
        title: 'Create your\naccount.',
        subtitle: 'Set up your TARAsense access in a few quick steps.',
        isLoading: authState.isBusy,
        loadingMessage: 'Creating account...',
        isSuccess: _registrationSucceeded,
        successMessage: 'Account created successfully.',
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _AuthTextField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  autofillHints: const <String>[AutofillHints.name],
                  hintText: 'Full name',
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (String? value) {
                    if ((value ?? '').trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                Text('Account type', style: theme.textTheme.labelMedium),
                const SizedBox(height: 8),
                _AccountTypeSelector(
                  selectedRole: _selectedRole,
                  onChanged: (String value) {
                    setState(() => _selectedRole = value);
                  },
                ),
                const SizedBox(height: 14),
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
                  autofillHints: const <String>[AutofillHints.newPassword],
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F2EA),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE9DDCE)),
                  ),
                  child: Text(
                    'Use your real details so your profile, workspace access, and study applications stay in sync across mobile and web.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: TaraTheme.textPrimary,
                    ),
                  ),
                ),
                if (authState.errorMessage != null) ...<Widget>[
                  const SizedBox(height: 14),
                  AuthErrorMessage(message: authState.errorMessage!),
                ],
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: authState.isBusy ? null : _submit,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(58),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: AuthButtonContent(
                      isLoading: authState.isBusy,
                      label: 'Create account',
                      loadingLabel: 'Creating account...',
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const _AuthDivider(label: 'or continue with'),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: authState.isBusy ? null : () => context.go('/login'),
                    style: _secondaryButtonStyle(),
                    child: const Text('Back to log in'),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Text(
                        'Already have an account? ',
                        style: theme.textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: authState.isBusy ? null : () => context.go('/login'),
                        child: const Text('Log in'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: authState.isBusy ? null : () => context.go('/'),
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

class _AccountTypeSelector extends StatelessWidget {
  const _AccountTypeSelector({
    required this.selectedRole,
    required this.onChanged,
  });

  final String selectedRole;
  final ValueChanged<String> onChanged;

  static const List<_AccountTypeOption> _options = <_AccountTypeOption>[
    _AccountTypeOption(
      value: 'MSME',
      label: 'MSME',
      icon: Icons.storefront_outlined,
    ),
    _AccountTypeOption(
      value: 'FIC',
      label: 'FIC',
      icon: Icons.science_outlined,
    ),
    _AccountTypeOption(
      value: 'CONSUMER',
      label: 'Consumer',
      icon: Icons.person_search_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Row(
        children: _options.map((option) {
          final bool selected = option.value == selectedRole;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: InkWell(
                onTap: () => onChanged(option.value),
                borderRadius: BorderRadius.circular(999),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  decoration: BoxDecoration(
                    color: selected ? TaraTheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        selected ? Icons.check_rounded : option.icon,
                        size: 14,
                        color: selected ? Colors.white : TaraTheme.textPrimary,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          option.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selected ? Colors.white : TaraTheme.textPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AccountTypeOption {
  const _AccountTypeOption({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;
}
