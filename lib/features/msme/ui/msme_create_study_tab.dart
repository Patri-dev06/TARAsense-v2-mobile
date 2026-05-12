part of 'msme_workspace_page.dart';

class _CreateStudyTab extends StatelessWidget {
  const _CreateStudyTab({
    required this.isLoading,
    required this.error,
    required this.isSubmitting,
    required this.options,
    required this.studyMode,
    required this.coordinationMode,
    required this.sensoryStudyType,
    required this.consumerObjective,
    required this.selectedRegion,
    required this.selectedFacility,
    required this.selectedProfileKey,
    required this.attributes,
    required this.customAttributeController,
    required this.customAttributeDimension,
    required this.customAttributeActionable,
    required this.productNameController,
    required this.targetResponsesController,
    required this.durationController,
    required this.sampleCountController,
    required this.testingStartDate,
    required this.sessions,
    required this.sampleSetups,
    required this.onRefresh,
    required this.onStudyModeChanged,
    required this.onCoordinationChanged,
    required this.onSensoryStudyTypeChanged,
    required this.onConsumerObjectiveChanged,
    required this.onRegionChanged,
    required this.onFacilityChanged,
    required this.onProfileChanged,
    required this.onAttributeChanged,
    required this.onAddCustomAttribute,
    required this.onCustomDimensionChanged,
    required this.onCustomActionableChanged,
    required this.onTestingDateChanged,
    required this.onAddSession,
    required this.onSessionChanged,
    required this.onRemoveSession,
    required this.onSampleCountChanged,
    required this.onSampleChanged,
    required this.onSubmit,
  });

  final bool isLoading;
  final String? error;
  final bool isSubmitting;
  final StudyBuilderOptionsData? options;
  final String studyMode;
  final String coordinationMode;
  final String sensoryStudyType;
  final String consumerObjective;
  final String? selectedRegion;
  final String? selectedFacility;
  final String? selectedProfileKey;
  final List<_StudyAttributeDraft> attributes;
  final TextEditingController customAttributeController;
  final String customAttributeDimension;
  final bool customAttributeActionable;
  final TextEditingController productNameController;
  final TextEditingController targetResponsesController;
  final TextEditingController durationController;
  final TextEditingController sampleCountController;
  final DateTime testingStartDate;
  final List<_SessionDraft> sessions;
  final List<_SampleSetupDraft> sampleSetups;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onStudyModeChanged;
  final ValueChanged<String> onCoordinationChanged;
  final ValueChanged<String> onSensoryStudyTypeChanged;
  final ValueChanged<String> onConsumerObjectiveChanged;
  final ValueChanged<String> onRegionChanged;
  final ValueChanged<String> onFacilityChanged;
  final ValueChanged<String> onProfileChanged;
  final void Function(int index, _StudyAttributeDraft value) onAttributeChanged;
  final VoidCallback onAddCustomAttribute;
  final ValueChanged<String> onCustomDimensionChanged;
  final ValueChanged<bool> onCustomActionableChanged;
  final ValueChanged<DateTime> onTestingDateChanged;
  final VoidCallback onAddSession;
  final void Function(int index, _SessionDraft value) onSessionChanged;
  final ValueChanged<int> onRemoveSession;
  final ValueChanged<String> onSampleCountChanged;
  final void Function(int index, _SampleSetupDraft value) onSampleChanged;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
        children: <Widget>[
          _MsmePageHeader(
            label: 'MSME WORKSPACE',
            title: options?.title.trim().isEmpty ?? true
                ? 'Create Study'
                : options!.title,
            subtitle: options?.subtitle.trim().isEmpty ?? true
                ? 'Configure Market or Sensory studies and generate a QR-linked form.'
                : options!.subtitle,
            icon: Icons.add_circle_rounded,
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const _LoadingCard()
          else ...<Widget>[
            if (error != null) ...<Widget>[
              _ErrorBanner(message: error!),
              const SizedBox(height: 12),
            ],
            if (options != null) ...<Widget>[
              _SectionCard(
                title: 'Study Type',
                subtitle:
                    'Choose the MSME workflow and how you want to coordinate it.',
                child: Column(
                  children: <Widget>[
                    _ChoiceWrap(
                      options: options!.studyTypes,
                      selectedValue: studyMode,
                      onSelected: onStudyModeChanged,
                    ),
                    const SizedBox(height: 12),
                    _ChoiceWrap(
                      options: options!.coordinationModes,
                      selectedValue: coordinationMode,
                      onSelected: onCoordinationChanged,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Study Setup',
                subtitle:
                    'Start with the facility, product, and sensory study details.',
                child: Column(
                  children: <Widget>[
                    DropdownButtonFormField<String>(
                      initialValue: selectedRegion,
                      items: options!.regions
                          .map(
                            (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          onRegionChanged(value);
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Region'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      key: ValueKey(selectedFacility),
                      initialValue: selectedFacility,
                      items:
                          (selectedRegion == null
                                  ? <String>[]
                                  : options!.facilitiesByRegion[selectedRegion] ??
                                        <String>[])
                              .map(
                                (String value) => DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          onFacilityChanged(value);
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Facility Type',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: productNameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        hintText: 'Enter the product being tested',
                      ),
                    ),
                    if (studyMode == 'SENSORY') ...<Widget>[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: sensoryStudyType,
                        items: options!.sensoryStudyTypes
                            .map(
                              (SelectOption option) => DropdownMenuItem<String>(
                                value: option.value,
                                child: Text(option.label),
                              ),
                            )
                            .toList(),
                        onChanged: (String? value) {
                          if (value != null) {
                            onSensoryStudyTypeChanged(value);
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: 'Sensory Study',
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: consumerObjective,
                        items: options!.consumerObjectives
                            .map(
                              (SelectOption option) => DropdownMenuItem<String>(
                                value: option.value,
                                child: Text(option.label),
                              ),
                            )
                            .toList(),
                        onChanged: (String? value) {
                          if (value != null) {
                            onConsumerObjectiveChanged(value);
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: 'What do you want to do with this test?',
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedProfileKey,
                      items: options!.categoryProfiles
                          .map(
                            (CategoryProfileOption option) =>
                                DropdownMenuItem<String>(
                                  value: option.key,
                                  child: Text(option.label),
                                ),
                          )
                          .toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          onProfileChanged(value);
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Category Profile',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Choose What To Test',
                subtitle:
                    'Pick the priority attributes that should drive the questionnaire.',
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FBFF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: TaraTheme.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: options!.questionnaireNotes
                            .map(
                              (String note) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  note,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...attributes.asMap().entries.map(
                      (MapEntry<int, _StudyAttributeDraft> entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AttributeEditor(
                          attribute: entry.value,
                          dimensionOptions: options!.attributeDimensions,
                          onChanged: (_StudyAttributeDraft value) {
                            onAttributeChanged(entry.key, value);
                          },
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: TaraTheme.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: TaraTheme.border),
                      ),
                      child: Column(
                        children: <Widget>[
                          TextField(
                            controller: customAttributeController,
                            decoration: const InputDecoration(
                              labelText: 'Custom attribute name (max 2 words)',
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: customAttributeDimension,
                            items: options!.attributeDimensions
                                .map(
                                  (String value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  ),
                                )
                                .toList(),
                            onChanged: (String? value) {
                              if (value != null) {
                                onCustomDimensionChanged(value);
                              }
                            },
                            decoration: const InputDecoration(
                              labelText: 'Attribute type',
                            ),
                          ),
                          const SizedBox(height: 12),
                          SwitchListTile.adaptive(
                            value: customAttributeActionable,
                            onChanged: onCustomActionableChanged,
                            activeThumbColor: TaraTheme.primary,
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'This attribute is actionable and can be adjusted in formulation.',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton(
                              onPressed: onAddCustomAttribute,
                              child: const Text('Add Custom Attribute'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Schedule And Capacity',
                subtitle:
                    'Set the target responses and the testing sessions for this study.',
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: targetResponsesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Number of Target Responses',
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: testingStartDate,
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 30),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          onTestingDateChanged(picked);
                        }
                      },
                      borderRadius: BorderRadius.circular(22),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Testing Start Date',
                        ),
                        child: Text(_formatLongDate(testingStartDate)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: durationController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Testing Duration (Days)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    _MobileFacilityCalendar(
                      startDate: testingStartDate,
                      durationDays:
                          int.tryParse(durationController.text.trim()) ?? 1,
                      selectedFacility: selectedFacility,
                      sessions: sessions,
                      onDateSelected: onTestingDateChanged,
                    ),
                    const SizedBox(height: 12),
                    ...sessions.asMap().entries.map(
                      (MapEntry<int, _SessionDraft> entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SessionEditor(
                          session: entry.value,
                          index: entry.key,
                          onChanged: (_SessionDraft value) {
                            onSessionChanged(entry.key, value);
                          },
                          durationDays:
                              int.tryParse(durationController.text.trim()) ?? 1,
                          onRemove: sessions.length <= 1
                              ? null
                              : () => onRemoveSession(entry.key),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton(
                        onPressed: onAddSession,
                        child: const Text('Add Session'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Sample Setups',
                subtitle:
                    'Describe the product variants or formulations used in the study.',
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: sampleCountController,
                      keyboardType: TextInputType.number,
                      onChanged: onSampleCountChanged,
                      decoration: const InputDecoration(
                        labelText: 'No. of Sample Setups',
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...sampleSetups.asMap().entries.map(
                      (MapEntry<int, _SampleSetupDraft> entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SampleSetupEditor(
                          index: entry.key,
                          setup: entry.value,
                          onChanged: (_SampleSetupDraft value) {
                            onSampleChanged(entry.key, value);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isSubmitting ? null : () => unawaited(onSubmit()),
                  child: Text(
                    isSubmitting
                        ? 'Creating Study...'
                        : 'Generate Study Form and QR',
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

