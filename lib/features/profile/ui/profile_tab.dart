import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarasense_mobile/core/network/api_error_formatter.dart';
import 'package:tarasense_mobile/core/theme/tara_theme.dart';
import 'package:tarasense_mobile/features/auth/state/auth_providers.dart';
import 'package:tarasense_mobile/features/msme/data/msme_api.dart';
import 'package:tarasense_mobile/features/msme/domain/msme_models.dart';

// ─── Public widget ────────────────────────────────────────────────────────────

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({
    super.key,
    required this.workspaceLabel,
    required this.onLogout,
  });

  final String workspaceLabel;
  final VoidCallback onLogout;

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _organizationController =
      TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  MsmeProfileData? _profile;
  String _selectedGender = 'PREFER_NOT_SAY';
  final Set<String> _selectedLifestyle = <String>{};
  final Set<String> _selectedDietaryPrefs = <String>{};
  final Set<String> _selectedConsumption = <String>{};

  static const List<SelectOption> _consumptionOptions = <SelectOption>[
    SelectOption(value: 'coffeeDrinker', label: 'Coffee drinker'),
    SelectOption(value: 'snackConsumer', label: 'Snack consumer'),
    SelectOption(value: 'energyDrinkConsumer', label: 'Energy drink consumer'),
  ];

  String? get _accessToken =>
      ref.read(authControllerProvider).session?.tokens.accessToken;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _organizationController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final String? token = _accessToken;
    if (token == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final raw = await ref.read(msmeApiProvider).fetchProfile(token);
      if (!mounted) return;
      final profile = _enrich(raw);
      _hydrate(profile);
      setState(() => _profile = profile);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = formatApiError(e, includeUri: true));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    final String? token = _accessToken;
    if (token == null) return;

    setState(() => _isSaving = true);

    try {
      final raw = await ref.read(msmeApiProvider).updateProfile(
        token,
        payload: <String, dynamic>{
          'name': _nameController.text.trim(),
          'organization': _organizationController.text.trim(),
          'age': int.tryParse(_ageController.text.trim()) ?? 0,
          'gender': _selectedGender,
          'location': _locationController.text.trim(),
          'occupation': _occupationController.text.trim(),
          'lifestyle': _selectedLifestyle.toList(),
          'dietaryPrefs': _selectedDietaryPrefs.toList(),
          'coffeeDrinker': _selectedConsumption.contains('coffeeDrinker'),
          'snackConsumer': _selectedConsumption.contains('snackConsumer'),
          'energyDrinkConsumer':
              _selectedConsumption.contains('energyDrinkConsumer'),
        },
      );
      if (!mounted) return;
      final profile = _enrich(raw);
      _hydrate(profile);
      setState(() {
        _profile = profile;
        _error = null;
      });
      await ref.read(authControllerProvider.notifier).refreshProfile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = formatApiError(e, includeUri: true));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  MsmeProfileData _enrich(MsmeProfileData raw) {
    final user = ref.read(authControllerProvider).session?.user;
    return MsmeProfileData(
      eyebrow: raw.eyebrow,
      title: raw.title,
      subtitle: raw.subtitle,
      name: raw.name.trim().isNotEmpty ? raw.name : (user?.name ?? ''),
      email: raw.email.trim().isNotEmpty ? raw.email : (user?.email ?? ''),
      organization: raw.organization.trim().isNotEmpty
          ? raw.organization
          : (user?.organization ?? ''),
      age: raw.age,
      gender: raw.gender,
      location: raw.location,
      occupation: raw.occupation,
      lifestyle: raw.lifestyle,
      dietaryPrefs: raw.dietaryPrefs,
      coffeeDrinker: raw.coffeeDrinker,
      snackConsumer: raw.snackConsumer,
      energyDrinkConsumer: raw.energyDrinkConsumer,
      history: raw.history,
      metadata: ProfileMetadata(
        role: raw.metadata.role.trim().isNotEmpty
            ? raw.metadata.role
            : (user?.role ?? ''),
        joinedAt: raw.metadata.joinedAt,
        panelistCreatedAt: raw.metadata.panelistCreatedAt,
        lastActive: raw.metadata.lastActive,
      ),
      genderOptions: raw.genderOptions.isNotEmpty
          ? raw.genderOptions
          : const <SelectOption>[
              SelectOption(value: 'FEMALE', label: 'Female'),
              SelectOption(value: 'MALE', label: 'Male'),
              SelectOption(value: 'PREFER_NOT_SAY', label: 'Prefer not to say'),
            ],
      lifestyleOptions: raw.lifestyleOptions.isNotEmpty
          ? raw.lifestyleOptions
          : const <SelectOption>[
              SelectOption(
                value: 'BUSY_PROFESSIONAL',
                label: 'Busy professional',
              ),
              SelectOption(
                value: 'HEALTH_CONSCIOUS',
                label: 'Health conscious',
              ),
              SelectOption(
                value: 'FOOD_ADVENTUROUS',
                label: 'Food adventurous',
              ),
              SelectOption(value: 'BUDGET_MINDED', label: 'Budget-minded'),
            ],
      dietaryOptions: raw.dietaryOptions.isNotEmpty
          ? raw.dietaryOptions
          : const <SelectOption>[
              SelectOption(value: 'LOW_SUGAR', label: 'Low sugar'),
              SelectOption(value: 'LOW_SODIUM', label: 'Low sodium'),
              SelectOption(value: 'VEGETARIAN', label: 'Vegetarian'),
              SelectOption(
                value: 'NO_RESTRICTIONS',
                label: 'No restrictions',
              ),
            ],
    );
  }

  void _hydrate(MsmeProfileData p) {
    _nameController.text = p.name;
    _organizationController.text = p.organization;
    _ageController.text = p.age.toString();
    _locationController.text = p.location;
    _occupationController.text = p.occupation;
    _selectedGender = p.gender.trim().isEmpty ? 'PREFER_NOT_SAY' : p.gender;
    _selectedLifestyle
      ..clear()
      ..addAll(p.lifestyle);
    _selectedDietaryPrefs
      ..clear()
      ..addAll(p.dietaryPrefs);
    _selectedConsumption
      ..clear()
      ..addAll(<String>[
        if (p.coffeeDrinker) 'coffeeDrinker',
        if (p.snackConsumer) 'snackConsumer',
        if (p.energyDrinkConsumer) 'energyDrinkConsumer',
      ]);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final profile = _profile;

    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        children: <Widget>[
          _PageHeader(
            label: widget.workspaceLabel,
            title: profile?.name.trim().isEmpty ?? true
                ? 'My Profile'
                : profile!.name,
            subtitle: profile?.subtitle.trim().isEmpty ?? true
                ? 'Maintain your panelist data for better matching in future studies.'
                : profile!.subtitle,
            icon: Icons.person_rounded,
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const _LoadingCard()
          else if (_error != null && profile == null)
            _ErrorCard(
              message: _error!,
              onRetry: () => unawaited(_loadProfile()),
            )
          else if (profile != null) ...<Widget>[
            if (_error != null) _ErrorBanner(message: _error!),
            if (_error != null) const SizedBox(height: 14),
            _SectionCard(
              title: 'Basic Information',
              subtitle:
                  'Keep your profile aligned with your account details.',
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: profile.email,
                    readOnly: true,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Email (Read-only)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _organizationController,
                    decoration: const InputDecoration(
                      labelText: 'Organization',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Age'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    key: ValueKey(_selectedGender),
                    initialValue: profile.genderOptions
                            .any(
                              (SelectOption o) => o.value == _selectedGender,
                            )
                        ? _selectedGender
                        : (profile.genderOptions.isNotEmpty
                            ? profile.genderOptions.first.value
                            : null),
                    items: profile.genderOptions
                        .map(
                          (SelectOption o) => DropdownMenuItem<String>(
                            value: o.value,
                            child: Text(o.label),
                          ),
                        )
                        .toList(),
                    onChanged: (String? v) {
                      if (v != null) setState(() => _selectedGender = v);
                    },
                    decoration: const InputDecoration(labelText: 'Gender'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Location'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _occupationController,
                    decoration: const InputDecoration(
                      labelText: 'Occupation',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SelectionSection(
              title: 'Lifestyle Attributes',
              options: profile.lifestyleOptions,
              selectedValues: _selectedLifestyle,
              onChanged: (String v, bool sel) => setState(() {
                if (sel) {
                  _selectedLifestyle.add(v);
                } else {
                  _selectedLifestyle.remove(v);
                }
              }),
            ),
            const SizedBox(height: 14),
            _SelectionSection(
              title: 'Dietary Information',
              options: profile.dietaryOptions,
              selectedValues: _selectedDietaryPrefs,
              onChanged: (String v, bool sel) => setState(() {
                if (sel) {
                  _selectedDietaryPrefs.add(v);
                } else {
                  _selectedDietaryPrefs.remove(v);
                }
              }),
            ),
            const SizedBox(height: 14),
            _SelectionSection(
              title: 'Consumption Behavior',
              subtitle:
                  'These details help TARAsense improve participant matching for future studies.',
              options: _consumptionOptions,
              selectedValues: _selectedConsumption,
              onChanged: (String v, bool sel) => setState(() {
                if (sel) {
                  _selectedConsumption.add(v);
                } else {
                  _selectedConsumption.remove(v);
                }
              }),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Participation History',
              subtitle:
                  'Previous participation records are used to improve participant matching for future studies.',
              child: profile.history.isEmpty
                  ? const _EmptyCard(
                      title: 'No participation records yet',
                      message:
                          'Your completed or assigned studies will appear here.',
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: TaraTheme.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: TaraTheme.border),
                      ),
                      child: Column(
                        children: <Widget>[
                          for (int i = 0; i < profile.history.length; i++) ...<Widget>[
                            if (i > 0)
                              const Divider(height: 1, thickness: 1),
                            _HistoryRow(entry: profile.history[i]),
                          ],
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSaving ? null : () => unawaited(_saveProfile()),
                style: FilledButton.styleFrom(
                  backgroundColor: TaraTheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                child: Text(_isSaving ? 'Saving...' : 'Save Profile'),
              ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Account',
              subtitle: 'Manage account status and workspace access.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _MetaGrid(
                    fields: <_MetaField>[
                      _MetaField(label: 'Name', value: profile.name),
                      _MetaField(label: 'Email', value: profile.email),
                      _MetaField(
                        label: 'Organization',
                        value: profile.organization,
                      ),
                      _MetaField(
                        label: 'Account Role',
                        value: profile.metadata.role,
                      ),
                      _MetaField(
                        label: 'Joined',
                        value: profile.metadata.joinedAt == null
                            ? '-'
                            : _formatShortDate(profile.metadata.joinedAt!),
                      ),
                      _MetaField(
                        label: 'Panelist profile created',
                        value: profile.metadata.panelistCreatedAt == null
                            ? '-'
                            : _formatShortDate(
                                profile.metadata.panelistCreatedAt!,
                              ),
                      ),
                      _MetaField(
                        label: 'Last active',
                        value: profile.metadata.lastActive == null
                            ? '-'
                            : _formatLongDateTime(profile.metadata.lastActive!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed:
                          authState.isBusy ? null : widget.onLogout,
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Log out'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: TaraTheme.roseText,
                        side: const BorderSide(color: Color(0xFFFECDD3)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Private helper widgets ───────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String label;
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFFB923C), TaraTheme.primaryDark],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x28F97316),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: const Color(0x33FFFFFF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0x44FFFFFF)),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xCCFFFFFF),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -0.3,
                  ),
                ),
                if (subtitle.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xB3FFFFFF),
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SelectionSection extends StatelessWidget {
  const _SelectionSection({
    required this.title,
    required this.options,
    required this.selectedValues,
    required this.onChanged,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<SelectOption> options;
  final Set<String> selectedValues;
  final void Function(String value, bool selected) onChanged;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: title,
      subtitle: subtitle ??
          'Tap each option to keep your panelist profile accurate.',
      child: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.1,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: options.map((SelectOption option) {
          final bool selected = selectedValues.contains(option.value);
          return GestureDetector(
            onTap: () => onChanged(option.value, !selected),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: selected ? TaraTheme.primaryTint : TaraTheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected ? TaraTheme.primary : TaraTheme.border,
                  width: selected ? 1.4 : 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    selected
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                    size: 16,
                    color: selected
                        ? TaraTheme.primary
                        : TaraTheme.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      option.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected
                            ? TaraTheme.primaryDark
                            : TaraTheme.textPrimary,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MetaGrid extends StatelessWidget {
  const _MetaGrid({required this.fields});

  final List<_MetaField> fields;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool twoColumns = constraints.maxWidth >= 620;
        final double fieldWidth = twoColumns
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: fields
              .map(
                (_MetaField f) => SizedBox(
                  width: fieldWidth,
                  child: TextFormField(
                    initialValue: f.value.isEmpty ? '-' : f.value,
                    readOnly: true,
                    decoration: InputDecoration(labelText: f.label),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _MetaField {
  const _MetaField({required this.label, required this.value});

  final String label;
  final String value;
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: TaraTheme.border),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        children: <Widget>[
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: TaraTheme.roseText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Try Again')),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: TaraTheme.roseText,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TaraTheme.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        children: <Widget>[
          const Icon(
            Icons.folder_open_rounded,
            color: TaraTheme.primaryDark,
            size: 34,
          ),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry});

  final ProfileHistoryItem entry;

  static Color _dotColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return const Color(0xFF10B981);
      case 'SELECTED':
      case 'ASSIGNED':
        return const Color(0xFFF97316);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String status = entry.status;
    final Color dot = _dotColor(status);
    final String meta = <String>[
      if (entry.productName.trim().isNotEmpty) entry.productName.trim(),
      if (entry.stage.trim().isNotEmpty) _humanizeLabel(entry.stage),
    ].join(' • ');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dot,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        entry.studyTitle.trim().isEmpty
                            ? 'Untitled study'
                            : entry.studyTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: dot.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _humanizeLabel(status),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: dot,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                if (meta.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 3),
                  Text(
                    meta,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: TaraTheme.textSecondary,
                    ),
                  ),
                ],
                if (entry.completedAt != null) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    'Completed ${_formatShortDate(entry.completedAt!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Formatting helpers ───────────────────────────────────────────────────────

String _humanizeLabel(String value) {
  return value
      .toLowerCase()
      .split('_')
      .map((String part) {
        if (part.isEmpty) return part;
        return '${part[0].toUpperCase()}${part.substring(1)}';
      })
      .join(' ');
}

String _formatShortDate(DateTime value) {
  return '${value.month}/${value.day}/${value.year}';
}

String _formatLongDateTime(DateTime value) {
  final int hour = value.hour > 12
      ? value.hour - 12
      : (value.hour == 0 ? 12 : value.hour);
  final String minute = value.minute.toString().padLeft(2, '0');
  final String period = value.hour >= 12 ? 'PM' : 'AM';
  return '${value.month}/${value.day}/${value.year}, $hour:$minute $period';
}
