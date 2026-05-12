part of 'msme_workspace_page.dart';

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({
    required this.isLoading,
    required this.error,
    required this.isSaving,
    required this.authBusy,
    required this.profile,
    required this.nameController,
    required this.organizationController,
    required this.ageController,
    required this.locationController,
    required this.occupationController,
    required this.selectedGender,
    required this.selectedLifestyle,
    required this.selectedDietaryPrefs,
    required this.coffeeDrinker,
    required this.snackConsumer,
    required this.energyDrinkConsumer,
    required this.onRefresh,
    required this.onLogout,
    required this.onGenderChanged,
    required this.onLifestyleChanged,
    required this.onDietaryChanged,
    required this.onCoffeeChanged,
    required this.onSnackChanged,
    required this.onEnergyChanged,
    required this.onSave,
  });

  final bool isLoading;
  final String? error;
  final bool isSaving;
  final bool authBusy;
  final MsmeProfileData? profile;
  final TextEditingController nameController;
  final TextEditingController organizationController;
  final TextEditingController ageController;
  final TextEditingController locationController;
  final TextEditingController occupationController;
  final String selectedGender;
  final Set<String> selectedLifestyle;
  final Set<String> selectedDietaryPrefs;
  final bool coffeeDrinker;
  final bool snackConsumer;
  final bool energyDrinkConsumer;
  final Future<void> Function() onRefresh;
  final VoidCallback onLogout;
  final ValueChanged<String> onGenderChanged;
  final void Function(String value, bool selected) onLifestyleChanged;
  final void Function(String value, bool selected) onDietaryChanged;
  final ValueChanged<bool> onCoffeeChanged;
  final ValueChanged<bool> onSnackChanged;
  final ValueChanged<bool> onEnergyChanged;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        children: <Widget>[
          _MsmePageHeader(
            label: 'MSME WORKSPACE',
            title: profile?.name.trim().isEmpty ?? true
                ? 'My Profile'
                : profile!.name,
            subtitle: profile?.subtitle.trim().isEmpty ?? true
                ? 'Maintain your panelist data for better matching in future studies.'
                : profile!.subtitle,
            icon: Icons.person_rounded,
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const _LoadingCard()
          else if (error != null)
            _ErrorCard(message: error!, onRetry: () => unawaited(onRefresh()))
          else if (profile != null) ...<Widget>[
            _SectionCard(
              title: 'Basic Information',
              subtitle:
                  'Keep the mobile profile aligned with your MSME account details.',
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: profile!.email,
                    readOnly: true,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Email (Read-only)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: organizationController,
                    decoration: const InputDecoration(
                      labelText: 'Organization',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Age'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    key: ValueKey(selectedGender),
                    initialValue: profile!.genderOptions
                            .any((SelectOption o) => o.value == selectedGender)
                        ? selectedGender
                        : (profile!.genderOptions.isNotEmpty
                            ? profile!.genderOptions.first.value
                            : null),
                    items: profile!.genderOptions
                        .map(
                          (SelectOption option) => DropdownMenuItem<String>(
                            value: option.value,
                            child: Text(option.label),
                          ),
                        )
                        .toList(),
                    onChanged: (String? value) {
                      if (value != null) {
                        onGenderChanged(value);
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Gender'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(labelText: 'Location'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: occupationController,
                    decoration: const InputDecoration(labelText: 'Occupation'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SelectionSection(
              title: 'Lifestyle Attributes',
              options: profile!.lifestyleOptions,
              selectedValues: selectedLifestyle,
              onChanged: onLifestyleChanged,
            ),
            const SizedBox(height: 14),
            _SelectionSection(
              title: 'Dietary Information',
              options: profile!.dietaryOptions,
              selectedValues: selectedDietaryPrefs,
              onChanged: onDietaryChanged,
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Consumption Behavior',
              subtitle:
                  'These details help TARAsense improve participant matching for future studies.',
              child: Column(
                children: <Widget>[
                  SwitchListTile.adaptive(
                    value: coffeeDrinker,
                    onChanged: onCoffeeChanged,
                    title: const Text('Coffee drinker'),
                    activeThumbColor: TaraTheme.primary,
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile.adaptive(
                    value: snackConsumer,
                    onChanged: onSnackChanged,
                    title: const Text('Snack consumer'),
                    activeThumbColor: TaraTheme.primary,
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile.adaptive(
                    value: energyDrinkConsumer,
                    onChanged: onEnergyChanged,
                    title: const Text('Energy drink consumer'),
                    activeThumbColor: TaraTheme.primary,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Participation History',
              subtitle:
                  'Previous participation records are used to improve participant matching for future studies.',
              child: profile!.history.isEmpty
                  ? const _EmptyCard(
                      title: 'No participation records yet',
                      message:
                          'Your completed or assigned studies will appear here.',
                    )
                  : Column(
                      children: profile!.history
                          .map(
                            (ProfileHistoryItem entry) => Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: TaraTheme.background,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: TaraTheme.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    entry.studyTitle,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${entry.productName} • ${_humanizeLabel(entry.stage)} • ${_humanizeLabel(entry.status)}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  if (entry.completedAt != null) ...<Widget>[
                                    const SizedBox(height: 6),
                                    Text(
                                      'Completed ${_formatLongDateTime(entry.completedAt!)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isSaving ? null : () => unawaited(onSave()),
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
                child: Text(isSaving ? 'Saving...' : 'Save Profile'),
              ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Profile',
              subtitle: 'Manage account status and workspace access.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _ProfileSettingsFormGrid(
                    fields: <_ProfileSettingsField>[
                      _ProfileSettingsField(
                        label: 'Name',
                        value: profile!.name,
                      ),
                      _ProfileSettingsField(
                        label: 'Email',
                        value: profile!.email,
                      ),
                      _ProfileSettingsField(
                        label: 'Organization',
                        value: profile!.organization,
                      ),
                      _ProfileSettingsField(
                        label: 'Account Role',
                        value: profile!.metadata.role,
                      ),
                      _ProfileSettingsField(
                        label: 'Joined',
                        value: profile!.metadata.joinedAt == null
                            ? '-'
                            : _formatShortDate(profile!.metadata.joinedAt!),
                      ),
                      _ProfileSettingsField(
                        label: 'Panelist profile created',
                        value: profile!.metadata.panelistCreatedAt == null
                            ? '-'
                            : _formatShortDate(
                                profile!.metadata.panelistCreatedAt!,
                              ),
                      ),
                      _ProfileSettingsField(
                        label: 'Last active',
                        value: profile!.metadata.lastActive == null
                            ? '-'
                            : _formatLongDateTime(
                                profile!.metadata.lastActive!,
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: authBusy ? null : onLogout,
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

class _ProfileSettingsFormGrid extends StatelessWidget {
  const _ProfileSettingsFormGrid({required this.fields});

  final List<_ProfileSettingsField> fields;

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
                (_ProfileSettingsField field) => SizedBox(
                  width: fieldWidth,
                  child: TextFormField(
                    initialValue: field.value.isEmpty ? '-' : field.value,
                    readOnly: true,
                    decoration: InputDecoration(labelText: field.label),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _ProfileSettingsField {
  const _ProfileSettingsField({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

