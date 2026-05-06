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
        title: 'Create an account',
        subtitle:
            'Use your name, email, password, and account type to get started.',
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: TaraTheme.primaryTint,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Latest web app flow',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: TaraTheme.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Create your account once, then continue project setup and sensory work across web and mobile.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text('Full name', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  autofillHints: const <String>[AutofillHints.name],
                  decoration: const InputDecoration(
                    hintText: 'Juan Dela Cruz',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  validator: (String? value) {
                    if ((value ?? '').trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                Text('Account type', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                _AccountTypeSelector(
                  selectedRole: _selectedRole,
                  onChanged: (String value) {
                    setState(() => _selectedRole = value);
                  },
                ),
                const SizedBox(height: 14),
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
                  autofillHints: const <String>[AutofillHints.newPassword],
                  decoration: InputDecoration(
                    hintText: 'At least 6 characters',
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
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: TaraTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Before you continue',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const _ChecklistItem(
                        text:
                            'Use your real name for a cleaner workspace profile.',
                      ),
                      const _ChecklistItem(
                        text:
                            'Choose Consumer if you are applying for available studies.',
                      ),
                      const _ChecklistItem(
                        text:
                            'Your mobile and web account credentials stay the same.',
                      ),
                    ],
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
                      label: 'Create account',
                      loadingLabel: 'Creating account...',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: authState.isBusy ? null : () => context.go('/login'),
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

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 4),
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              color: TaraTheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: TaraTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
