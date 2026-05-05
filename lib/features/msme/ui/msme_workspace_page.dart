import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarasense_mobile/core/config/app_config.dart';
import 'package:tarasense_mobile/core/network/api_error_formatter.dart';
import 'package:tarasense_mobile/core/theme/tara_theme.dart';
import 'package:tarasense_mobile/core/widgets/dost_logo_mark.dart';
import 'package:tarasense_mobile/core/widgets/tara_brand_lockup.dart';
import 'package:tarasense_mobile/features/auth/state/auth_providers.dart';
import 'package:tarasense_mobile/features/msme/data/msme_api.dart';
import 'package:tarasense_mobile/features/msme/domain/msme_models.dart';

class MsmeWorkspacePage extends ConsumerStatefulWidget {
  const MsmeWorkspacePage({super.key});

  @override
  ConsumerState<MsmeWorkspacePage> createState() => _MsmeWorkspacePageState();
}

class _MsmeWorkspacePageState extends ConsumerState<MsmeWorkspacePage> {
  final TextEditingController _profileNameController = TextEditingController();
  final TextEditingController _profileOrganizationController =
      TextEditingController();
  final TextEditingController _profileAgeController = TextEditingController();
  final TextEditingController _profileLocationController =
      TextEditingController();
  final TextEditingController _profileOccupationController =
      TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _targetResponsesController =
      TextEditingController(text: '30');
  final TextEditingController _customAttributeController =
      TextEditingController();
  final TextEditingController _durationController = TextEditingController(
    text: '1',
  );
  final TextEditingController _sampleCountController = TextEditingController(
    text: '1',
  );

  int _currentTabIndex = 0;
  bool _isLoadingDashboard = true;
  bool _isLoadingProfile = true;
  bool _isLoadingBuilder = true;
  bool _isSavingProfile = false;
  bool _isCreatingStudy = false;

  String? _dashboardError;
  String? _profileError;
  String? _builderError;

  MsmeDashboardData? _dashboard;
  MsmeProfileData? _profile;
  StudyBuilderOptionsData? _builderOptions;

  String _searchQuery = '';
  String _studyMode = 'SENSORY';
  String _coordinationMode = 'FIC';
  String _sensoryStudyType = 'CONSUMER_TEST';
  String _consumerObjective = 'FAST_ITERATION';
  String _selectedGender = 'PREFER_NOT_SAY';
  String? _selectedRegion;
  String? _selectedFacility;
  String? _selectedProfileKey;
  String _customAttributeDimension = 'Taste';
  DateTime _testingStartDate = DateTime.now();
  final Set<String> _selectedLifestyle = <String>{};
  final Set<String> _selectedDietaryPrefs = <String>{};
  bool _coffeeDrinker = false;
  bool _snackConsumer = false;
  bool _energyDrinkConsumer = false;
  bool _customAttributeActionable = false;

  List<_StudyAttributeDraft> _attributes = <_StudyAttributeDraft>[];
  List<_SessionDraft> _sessions = <_SessionDraft>[];
  List<_SampleSetupDraft> _sampleSetups = <_SampleSetupDraft>[
    _SampleSetupDraft.empty(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWorkspace();
    });
  }

  @override
  void dispose() {
    _profileNameController.dispose();
    _profileOrganizationController.dispose();
    _profileAgeController.dispose();
    _profileLocationController.dispose();
    _profileOccupationController.dispose();
    _productNameController.dispose();
    _targetResponsesController.dispose();
    _customAttributeController.dispose();
    _durationController.dispose();
    _sampleCountController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkspace() async {
    if (AppConfig.uiPreviewMode) {
      _loadPreviewWorkspace();
      return;
    }
    await Future.wait(<Future<void>>[
      _loadDashboard(),
      _loadProfile(),
      _loadBuilderOptions(),
    ]);
  }

  String? get _accessToken =>
      ref.read(authControllerProvider).session?.tokens.accessToken;

  Future<void> _loadDashboard({String? query}) async {
    if (AppConfig.uiPreviewMode) {
      setState(() {
        _dashboard = _previewDashboard;
        _dashboardError = null;
        _isLoadingDashboard = false;
        _searchQuery = query ?? _searchQuery;
      });
      return;
    }

    final String? accessToken = _accessToken;
    if (accessToken == null) {
      return;
    }

    setState(() {
      _isLoadingDashboard = true;
      _dashboardError = null;
    });

    try {
      final dashboard = await ref
          .read(msmeApiProvider)
          .fetchDashboard(accessToken, query: query ?? _searchQuery);
      if (!mounted) {
        return;
      }
      setState(() {
        _dashboard = dashboard;
        _searchQuery = query ?? _searchQuery;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _dashboardError = _friendlyMessage(error));
    } finally {
      if (mounted) {
        setState(() => _isLoadingDashboard = false);
      }
    }
  }

  Future<void> _loadProfile() async {
    if (AppConfig.uiPreviewMode) {
      final profile = _previewProfile;
      _hydrateProfileForm(profile);
      setState(() {
        _profile = profile;
        _profileError = null;
        _isLoadingProfile = false;
      });
      return;
    }

    final String? accessToken = _accessToken;
    if (accessToken == null) {
      return;
    }

    setState(() {
      _isLoadingProfile = true;
      _profileError = null;
    });

    try {
      final profile = await ref.read(msmeApiProvider).fetchProfile(accessToken);
      if (!mounted) {
        return;
      }
      _hydrateProfileForm(profile);
      setState(() => _profile = profile);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _profileError = _friendlyMessage(error));
    } finally {
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }
  }

  Future<void> _loadBuilderOptions() async {
    if (AppConfig.uiPreviewMode) {
      final options = _previewBuilderOptions;
      _hydrateStudyForm(options);
      setState(() {
        _builderOptions = options;
        _builderError = null;
        _isLoadingBuilder = false;
      });
      return;
    }

    final String? accessToken = _accessToken;
    if (accessToken == null) {
      return;
    }

    setState(() {
      _isLoadingBuilder = true;
      _builderError = null;
    });

    try {
      final options = await ref
          .read(msmeApiProvider)
          .fetchStudyBuilderOptions(accessToken);
      if (!mounted) {
        return;
      }
      _hydrateStudyForm(options);
      setState(() => _builderOptions = options);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _builderError = _friendlyMessage(error));
    } finally {
      if (mounted) {
        setState(() => _isLoadingBuilder = false);
      }
    }
  }

  void _hydrateProfileForm(MsmeProfileData profile) {
    _profileNameController.text = profile.name;
    _profileOrganizationController.text = profile.organization;
    _profileAgeController.text = profile.age.toString();
    _profileLocationController.text = profile.location;
    _profileOccupationController.text = profile.occupation;
    _selectedGender = profile.gender;
    _selectedLifestyle
      ..clear()
      ..addAll(profile.lifestyle);
    _selectedDietaryPrefs
      ..clear()
      ..addAll(profile.dietaryPrefs);
    _coffeeDrinker = profile.coffeeDrinker;
    _snackConsumer = profile.snackConsumer;
    _energyDrinkConsumer = profile.energyDrinkConsumer;
  }

  void _hydrateStudyForm(StudyBuilderOptionsData options) {
    if (options.consumerObjectives.isNotEmpty) {
      _consumerObjective = options.consumerObjectives.first.value;
      _targetResponsesController.text =
          (options.consumerObjectives.first.defaultTarget ?? 30).toString();
    }
    if (options.regions.isNotEmpty) {
      _selectedRegion = options.regions.first;
      _selectedFacility = options.facilitiesByRegion[_selectedRegion!]?.first;
    }
    if (options.categoryProfiles.isNotEmpty) {
      _selectedProfileKey = options.categoryProfiles.first.key;
      _attributes = options.categoryProfiles.first.attributes
          .asMap()
          .entries
          .map(
            (MapEntry<int, StudyAttributeSeed> entry) => _StudyAttributeDraft(
              name: entry.value.name,
              dimension: entry.value.dimension,
              isJarTarget: entry.key < 2,
              isCustom: false,
              actionable: true,
            ),
          )
          .toList();
    }
    if (options.sessionTemplates.isNotEmpty) {
      _sessions = <_SessionDraft>[
        _SessionDraft.fromTemplate(options.sessionTemplates.first),
      ];
    }
  }

  Future<void> _saveProfile() async {
    if (AppConfig.uiPreviewMode) {
      setState(() {
        _profileError = null;
        _isSavingProfile = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preview mode: profile changes are local only.'),
        ),
      );
      return;
    }

    final String? accessToken = _accessToken;
    if (accessToken == null) {
      return;
    }

    setState(() => _isSavingProfile = true);

    try {
      final profile = await ref
          .read(msmeApiProvider)
          .updateProfile(
            accessToken,
            payload: <String, dynamic>{
              'name': _profileNameController.text.trim(),
              'organization': _profileOrganizationController.text.trim(),
              'age': int.tryParse(_profileAgeController.text.trim()) ?? 0,
              'gender': _selectedGender,
              'location': _profileLocationController.text.trim(),
              'occupation': _profileOccupationController.text.trim(),
              'lifestyle': _selectedLifestyle.toList(),
              'dietaryPrefs': _selectedDietaryPrefs.toList(),
              'coffeeDrinker': _coffeeDrinker,
              'snackConsumer': _snackConsumer,
              'energyDrinkConsumer': _energyDrinkConsumer,
            },
          );

      if (!mounted) {
        return;
      }

      setState(() {
        _profile = profile;
        _profileError = null;
      });
      await ref.read(authControllerProvider.notifier).refreshProfile();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _profileError = _friendlyMessage(error));
    } finally {
      if (mounted) {
        setState(() => _isSavingProfile = false);
      }
    }
  }

  Future<void> _submitStudy() async {
    if (AppConfig.uiPreviewMode) {
      setState(() {
        _builderError = null;
        _currentTabIndex = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preview mode: study submission is disabled for now.'),
        ),
      );
      return;
    }

    final String? accessToken = _accessToken;
    final StudyBuilderOptionsData? options = _builderOptions;
    if (accessToken == null || options == null) {
      return;
    }

    final profile = _selectedCategoryProfile;
    if (_selectedFacility == null ||
        _selectedFacility!.trim().isEmpty ||
        profile == null ||
        _productNameController.text.trim().isEmpty) {
      setState(() {
        _builderError =
            'Complete the product name, category profile, region, and facility first.';
      });
      return;
    }

    if (_attributes.where((attribute) => attribute.isJarTarget).length > 3) {
      setState(
        () => _builderError =
            'Only the top 3 attributes can be marked as priority.',
      );
      return;
    }

    setState(() {
      _isCreatingStudy = true;
      _builderError = null;
    });

    try {
      final int sampleCount =
          int.tryParse(_sampleCountController.text.trim()) ?? 1;
      final int targetResponses =
          int.tryParse(_targetResponsesController.text.trim()) ?? 30;
      final int durationDays =
          int.tryParse(_durationController.text.trim()) ?? 1;

      final result = await ref
          .read(msmeApiProvider)
          .createStudy(
            accessToken,
            payload: <String, dynamic>{
              'studyMode': _studyMode,
              'sensoryStudyType': _studyMode == 'SENSORY'
                  ? _sensoryStudyType
                  : null,
              'marketStudyType': _studyMode == 'MARKET'
                  ? 'PRODUCT_INTENT'
                  : null,
              'sensoryMethod': _sensoryStudyType == 'CONSUMER_TEST'
                  ? 'Consumer Test'
                  : _sensoryStudyType.replaceAll('_', ' '),
              'consumerObjective': _studyMode == 'SENSORY'
                  ? _consumerObjective
                  : null,
              'studyTitle': _buildStudyTitle(),
              'purpose': _buildStudyPurpose(),
              'facilityType': _selectedFacility,
              'numberOfSamples': sampleCount,
              'targetResponses': targetResponses,
              'productName': _productNameController.text.trim(),
              'categoryCode': profile.categoryCode,
              'categoryLabel': profile.label,
              'attributes': _attributes
                  .where((attribute) => attribute.name.trim().isNotEmpty)
                  .map((attribute) => attribute.toJson())
                  .toList(),
              'sampleSetups': _sampleSetups
                  .take(sampleCount)
                  .map((_SampleSetupDraft setup) => setup.toJson())
                  .toList(),
              'testingStartDate': _formatDateOnly(_testingStartDate),
              'testingDurationDays': durationDays,
              'sessionSlots': _sessions
                  .map(
                    (_SessionDraft session) =>
                        session.toJson(_testingStartDate),
                  )
                  .toList(),
              'questions': const <String>[],
            },
          );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Study created successfully${result['studyId'] == null ? '' : ' (${result['studyId']})'}.',
          ),
        ),
      );
      _resetStudyForm();
      await _loadDashboard();
      setState(() => _currentTabIndex = 0);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _builderError = _friendlyMessage(error));
    } finally {
      if (mounted) {
        setState(() => _isCreatingStudy = false);
      }
    }
  }

  void _resetStudyForm() {
    final StudyBuilderOptionsData? options = _builderOptions;
    if (options == null) {
      return;
    }
    _productNameController.clear();
    _customAttributeController.clear();
    _customAttributeActionable = false;
    _studyMode = 'SENSORY';
    _coordinationMode = 'FIC';
    _sensoryStudyType = 'CONSUMER_TEST';
    _testingStartDate = DateTime.now();
    _durationController.text = '1';
    _sampleCountController.text = '1';
    _sampleSetups = <_SampleSetupDraft>[_SampleSetupDraft.empty()];
    _hydrateStudyForm(options);
    setState(() {});
  }

  CategoryProfileOption? get _selectedCategoryProfile {
    final options = _builderOptions;
    if (options == null || _selectedProfileKey == null) {
      return null;
    }
    for (final profile in options.categoryProfiles) {
      if (profile.key == _selectedProfileKey) {
        return profile;
      }
    }
    return null;
  }

  String _buildStudyTitle() {
    if (_studyMode == 'MARKET') {
      return 'Product Intent Study';
    }
    final String product = _productNameController.text.trim().isEmpty
        ? 'Sensory Product'
        : _productNameController.text.trim();
    return '$product - ${_humanize(_sensoryStudyType)}';
  }

  String _buildStudyPurpose() {
    final String product = _productNameController.text.trim().isEmpty
        ? 'the product'
        : _productNameController.text.trim();
    if (_studyMode == 'MARKET') {
      return 'Market study for product intent to guide product and positioning decisions.';
    }
    if (_sensoryStudyType == 'CONSUMER_TEST') {
      return 'Consumer sensory test for $product focused on ${_humanize(_consumerObjective).toLowerCase()}.';
    }
    return '${_humanize(_sensoryStudyType)} sensory assessment for $product.';
  }

  String _humanize(String value) {
    return value
        .toLowerCase()
        .split('_')
        .map((String part) {
          if (part.isEmpty) {
            return part;
          }
          return '${part[0].toUpperCase()}${part.substring(1)}';
        })
        .join(' ');
  }

  String _friendlyMessage(Object error) {
    return formatApiError(error, includeUri: true);
  }

  void _loadPreviewWorkspace() {
    final profile = _previewProfile;
    final options = _previewBuilderOptions;
    _hydrateProfileForm(profile);
    _hydrateStudyForm(options);
    setState(() {
      _dashboard = _previewDashboard;
      _profile = profile;
      _builderOptions = options;
      _dashboardError = null;
      _profileError = null;
      _builderError = null;
      _isLoadingDashboard = false;
      _isLoadingProfile = false;
      _isLoadingBuilder = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final session = authState.session;

    if (session == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bool isSupportedRole =
        session.user.role.toUpperCase().contains('MSME') ||
        session.user.role.toUpperCase().contains('ADMIN');

    if (!isSupportedRole) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const TaraBrandLockup(),
                  const SizedBox(height: 18),
                  Text(
                    'This refreshed workspace is available for MSME accounts first.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _WorkspaceHeader(
              currentTabIndex: _currentTabIndex,
              userName: session.user.name,
              onCreateStudy: () => setState(() => _currentTabIndex = 1),
              onLogout: authState.isBusy
                  ? null
                  : () => ref.read(authControllerProvider.notifier).logout(),
            ),
            Expanded(
              child: IndexedStack(
                index: _currentTabIndex,
                children: <Widget>[
                  _DashboardTab(
                    isLoading: _isLoadingDashboard,
                    error: _dashboardError,
                    dashboard: _dashboard,
                    onRefresh: () => _loadDashboard(),
                    onRetry: () => _loadDashboard(),
                    onOpenCreateStudy: () =>
                        setState(() => _currentTabIndex = 1),
                  ),
                  _CreateStudyTab(
                    isLoading: _isLoadingBuilder,
                    error: _builderError,
                    isSubmitting: _isCreatingStudy,
                    options: _builderOptions,
                    studyMode: _studyMode,
                    coordinationMode: _coordinationMode,
                    sensoryStudyType: _sensoryStudyType,
                    consumerObjective: _consumerObjective,
                    selectedRegion: _selectedRegion,
                    selectedFacility: _selectedFacility,
                    selectedProfileKey: _selectedProfileKey,
                    attributes: _attributes,
                    customAttributeController: _customAttributeController,
                    customAttributeDimension: _customAttributeDimension,
                    customAttributeActionable: _customAttributeActionable,
                    productNameController: _productNameController,
                    targetResponsesController: _targetResponsesController,
                    durationController: _durationController,
                    sampleCountController: _sampleCountController,
                    testingStartDate: _testingStartDate,
                    sessions: _sessions,
                    sampleSetups: _sampleSetups,
                    onRefresh: _loadBuilderOptions,
                    onStudyModeChanged: (String value) {
                      setState(() => _studyMode = value);
                    },
                    onCoordinationChanged: (String value) {
                      setState(() => _coordinationMode = value);
                    },
                    onSensoryStudyTypeChanged: (String value) {
                      setState(() => _sensoryStudyType = value);
                    },
                    onConsumerObjectiveChanged: (String value) {
                      SelectOption? option;
                      final List<SelectOption> objectives =
                          _builderOptions?.consumerObjectives ??
                          <SelectOption>[];
                      for (final SelectOption item in objectives) {
                        if (item.value == value) {
                          option = item;
                          break;
                        }
                      }
                      setState(() {
                        _consumerObjective = value;
                        if (option?.defaultTarget != null) {
                          _targetResponsesController.text = option!
                              .defaultTarget!
                              .toString();
                        }
                      });
                    },
                    onRegionChanged: (String value) {
                      setState(() {
                        _selectedRegion = value;
                        _selectedFacility =
                            _builderOptions?.facilitiesByRegion[value]?.first;
                      });
                    },
                    onFacilityChanged: (String value) {
                      setState(() => _selectedFacility = value);
                    },
                    onProfileChanged: (String value) {
                      CategoryProfileOption? profile;
                      final List<CategoryProfileOption> profiles =
                          _builderOptions?.categoryProfiles ??
                          <CategoryProfileOption>[];
                      for (final CategoryProfileOption item in profiles) {
                        if (item.key == value) {
                          profile = item;
                          break;
                        }
                      }
                      if (profile == null) {
                        return;
                      }
                      final CategoryProfileOption selectedProfile = profile;
                      setState(() {
                        _selectedProfileKey = value;
                        _attributes = selectedProfile.attributes
                            .asMap()
                            .entries
                            .map(
                              (MapEntry<int, StudyAttributeSeed> entry) =>
                                  _StudyAttributeDraft(
                                    name: entry.value.name,
                                    dimension: entry.value.dimension,
                                    isJarTarget: entry.key < 2,
                                    isCustom: false,
                                    actionable: true,
                                  ),
                            )
                            .toList();
                      });
                    },
                    onAttributeChanged:
                        (int index, _StudyAttributeDraft value) {
                          setState(() => _attributes[index] = value);
                        },
                    onAddCustomAttribute: _addCustomAttribute,
                    onCustomDimensionChanged: (String value) {
                      setState(() => _customAttributeDimension = value);
                    },
                    onCustomActionableChanged: (bool value) {
                      setState(() => _customAttributeActionable = value);
                    },
                    onTestingDateChanged: (DateTime value) {
                      setState(() => _testingStartDate = value);
                    },
                    onAddSession: _addSession,
                    onSessionChanged: (int index, _SessionDraft value) {
                      setState(() => _sessions[index] = value);
                    },
                    onRemoveSession: (int index) {
                      if (_sessions.length <= 1) {
                        return;
                      }
                      setState(() => _sessions.removeAt(index));
                    },
                    onSampleCountChanged: _syncSampleSetupCount,
                    onSampleChanged: (int index, _SampleSetupDraft value) {
                      setState(() => _sampleSetups[index] = value);
                    },
                    onSubmit: _submitStudy,
                  ),
                  _ProfileTab(
                    isLoading: _isLoadingProfile,
                    error: _profileError,
                    isSaving: _isSavingProfile,
                    profile: _profile,
                    nameController: _profileNameController,
                    organizationController: _profileOrganizationController,
                    ageController: _profileAgeController,
                    locationController: _profileLocationController,
                    occupationController: _profileOccupationController,
                    selectedGender: _selectedGender,
                    selectedLifestyle: _selectedLifestyle,
                    selectedDietaryPrefs: _selectedDietaryPrefs,
                    coffeeDrinker: _coffeeDrinker,
                    snackConsumer: _snackConsumer,
                    energyDrinkConsumer: _energyDrinkConsumer,
                    onRefresh: _loadProfile,
                    onGenderChanged: (String value) {
                      setState(() => _selectedGender = value);
                    },
                    onLifestyleChanged: (String value, bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedLifestyle.add(value);
                        } else {
                          _selectedLifestyle.remove(value);
                        }
                      });
                    },
                    onDietaryChanged: (String value, bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedDietaryPrefs.add(value);
                        } else {
                          _selectedDietaryPrefs.remove(value);
                        }
                      });
                    },
                    onCoffeeChanged: (bool value) {
                      setState(() => _coffeeDrinker = value);
                    },
                    onSnackChanged: (bool value) {
                      setState(() => _snackConsumer = value);
                    },
                    onEnergyChanged: (bool value) {
                      setState(() => _energyDrinkConsumer = value);
                    },
                    onSave: _saveProfile,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _MsmePortalNavBar(
        currentTabIndex: _currentTabIndex,
        onStudies: () => setState(() => _currentTabIndex = 0),
        onResults: () => setState(() => _currentTabIndex = 0),
        onNew: () => setState(() => _currentTabIndex = 1),
        onFic: () => setState(() => _currentTabIndex = 1),
        onProfile: () => setState(() => _currentTabIndex = 2),
      ),
    );
  }

  void _syncSampleSetupCount(String rawValue) {
    final int count = int.tryParse(rawValue.trim()) ?? 1;
    final int nextCount = count.clamp(1, 5);
    setState(() {
      while (_sampleSetups.length < nextCount) {
        _sampleSetups.add(_SampleSetupDraft.empty());
      }
      if (_sampleSetups.length > nextCount) {
        _sampleSetups = _sampleSetups.take(nextCount).toList();
      }
    });
  }

  void _addSession() {
    final StudyBuilderOptionsData? options = _builderOptions;
    final SessionTemplateOption? template =
        options?.sessionTemplates.isNotEmpty == true
        ? options!.sessionTemplates[_sessions.length %
              options.sessionTemplates.length]
        : null;
    setState(() {
      _sessions.add(
        template == null
            ? _SessionDraft(label: 'Session ${_sessions.length + 1}')
            : _SessionDraft.fromTemplate(template),
      );
    });
  }

  void _addCustomAttribute() {
    final String name = _customAttributeController.text.trim();
    if (name.isEmpty) {
      setState(() => _builderError = 'Enter a custom attribute name first.');
      return;
    }
    if (!_customAttributeActionable) {
      setState(
        () => _builderError =
            'Mark the custom attribute as actionable before adding it.',
      );
      return;
    }
    if (_attributes.any((_StudyAttributeDraft item) => item.isCustom)) {
      setState(() => _builderError = 'Only one custom attribute is allowed.');
      return;
    }
    if (_attributes.length >= 5) {
      setState(
        () => _builderError = 'A maximum of five attributes can be used.',
      );
      return;
    }
    setState(() {
      _builderError = null;
      _attributes.add(
        _StudyAttributeDraft(
          name: name,
          dimension: _customAttributeDimension,
          isJarTarget: false,
          isCustom: true,
          actionable: true,
        ),
      );
      _customAttributeController.clear();
      _customAttributeActionable = false;
    });
  }
}

class _WorkspaceHeader extends StatelessWidget {
  const _WorkspaceHeader({
    required this.currentTabIndex,
    required this.userName,
    required this.onCreateStudy,
    required this.onLogout,
  });

  final int currentTabIndex;
  final String userName;
  final VoidCallback onCreateStudy;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final List<String> titles = <String>[
      'My studies',
      'New study',
      'Profile',
    ];
    final String initials = _initialsFor(userName);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      Icons.more_horiz_rounded,
                      color: TaraTheme.textPrimary.withValues(alpha: 0.68),
                      size: 20,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      titles[currentTabIndex],
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'MSME portal',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onCreateStudy,
                icon: const Icon(Icons.add_rounded),
                color: Colors.white,
                style: IconButton.styleFrom(
                  backgroundColor: TaraTheme.primary,
                  fixedSize: const Size(36, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: onLogout,
                icon: Text(
                  initials,
                  style: const TextStyle(
                    color: TaraTheme.primaryDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: IconButton.styleFrom(
                  backgroundColor: TaraTheme.primaryTint,
                  fixedSize: const Size(36, 36),
                  shape: const CircleBorder(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MsmePortalNavBar extends StatelessWidget {
  const _MsmePortalNavBar({
    required this.currentTabIndex,
    required this.onStudies,
    required this.onResults,
    required this.onNew,
    required this.onFic,
    required this.onProfile,
  });

  final int currentTabIndex;
  final VoidCallback onStudies;
  final VoidCallback onResults;
  final VoidCallback onNew;
  final VoidCallback onFic;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: TaraTheme.surface,
        border: Border(top: BorderSide(color: TaraTheme.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: <Widget>[
            Expanded(
              child: _PortalNavItem(
                icon: Icons.grid_view_rounded,
                label: 'Studies',
                selected: currentTabIndex == 0,
                onTap: onStudies,
              ),
            ),
            Expanded(
              child: _PortalNavItem(
                icon: Icons.done_rounded,
                label: 'Results',
                selected: false,
                onTap: onResults,
              ),
            ),
            Expanded(
              child: Center(
                child: Transform.translate(
                  offset: const Offset(0, -14),
                  child: Material(
                    color: TaraTheme.primary,
                    shape: const CircleBorder(),
                    elevation: 3,
                    child: InkWell(
                      onTap: onNew,
                      customBorder: const CircleBorder(),
                      child: const SizedBox(
                        height: 42,
                        width: 42,
                        child: Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _PortalNavItem(
                icon: Icons.format_align_center_rounded,
                label: 'FIC',
                selected: currentTabIndex == 1,
                onTap: onFic,
              ),
            ),
            Expanded(
              child: _PortalNavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                selected: currentTabIndex == 2,
                onTap: onProfile,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PortalNavItem extends StatelessWidget {
  const _PortalNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = selected ? TaraTheme.primary : TaraTheme.textSecondary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontSize: 8,
                height: 1,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({
    required this.isLoading,
    required this.error,
    required this.dashboard,
    required this.onRefresh,
    required this.onRetry,
    required this.onOpenCreateStudy,
  });

  final bool isLoading;
  final String? error;
  final MsmeDashboardData? dashboard;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final VoidCallback onOpenCreateStudy;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
        children: <Widget>[
          if (isLoading)
            const _LoadingCard()
          else if (error != null)
            _ErrorCard(message: error!, onRetry: onRetry)
          else if (dashboard != null) ...<Widget>[
            const _StudyFilterRail(),
            const SizedBox(height: 10),
            if (dashboard!.studies.isEmpty)
              const _EmptyCard(
                title: 'No studies yet',
                message:
                    'Create your first MSME study to start collecting responses.',
              )
            else
              ...dashboard!.studies.map(
                (MsmeStudyItem study) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _StudyCard(study: study),
                ),
              ),
            const SizedBox(height: 4),
            Text(
              'QUICK ACTIONS',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: TaraTheme.textPrimary,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: _QuickActionButton(
                    title: 'New study',
                    subtitle: 'Launch study builder',
                    icon: Icons.north_east_rounded,
                    backgroundColor: TaraTheme.primary,
                    foregroundColor: Colors.white,
                    onTap: onOpenCreateStudy,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuickActionButton(
                    title: 'Book FIC',
                    subtitle: 'View availability',
                    icon: Icons.north_east_rounded,
                    backgroundColor: const Color(0xFF111111),
                    foregroundColor: Colors.white,
                    onTap: onOpenCreateStudy,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

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
          _HeroWorkspaceCard(
            title: options?.title ?? 'Create Study',
            subtitle:
                options?.subtitle ??
                'Configure Market or Sensory studies and generate a form with QR code.',
            actionLabel: isSubmitting ? 'Creating...' : 'Generate Study Form',
            onAction: isSubmitting ? null : () => unawaited(onSubmit()),
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

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({
    required this.isLoading,
    required this.error,
    required this.isSaving,
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
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
        children: <Widget>[
          _HeroWorkspaceCard(
            title: profile?.title ?? 'My Profile',
            subtitle:
                profile?.subtitle ??
                'Maintain your panelist data for better matching in future studies.',
            actionLabel: isSaving ? 'Saving...' : 'Save Profile',
            onAction: isSaving ? null : () => unawaited(onSave()),
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
                    initialValue: selectedGender,
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
            _SectionCard(
              title: 'Account Details',
              subtitle: 'Quick account status for this MSME workspace.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _MetadataRow(
                    label: 'Account Role',
                    value: profile!.metadata.role,
                  ),
                  _MetadataRow(
                    label: 'Joined',
                    value: profile!.metadata.joinedAt == null
                        ? '-'
                        : _formatShortDate(profile!.metadata.joinedAt!),
                  ),
                  _MetadataRow(
                    label: 'Panelist profile created',
                    value: profile!.metadata.panelistCreatedAt == null
                        ? '-'
                        : _formatShortDate(
                            profile!.metadata.panelistCreatedAt!,
                          ),
                  ),
                  _MetadataRow(
                    label: 'Last active',
                    value: profile!.metadata.lastActive == null
                        ? '-'
                        : _formatLongDateTime(profile!.metadata.lastActive!),
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

class _HeroWorkspaceCard extends StatelessWidget {
  const _HeroWorkspaceCard({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: TaraTheme.border),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x120057A8),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const DostLogoMark(size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const TaraBrandLockup(markSize: 20, textSize: 22),
                    const SizedBox(height: 8),
                    Text(
                      'Sensory and consumer driven food innovation platform',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: TaraTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Test. Analyze. Refine. Advance.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: TaraTheme.textPrimary,
              height: 1.08,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: TaraTheme.dostBlue,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: TaraTheme.textSecondary,
              height: 1.5,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 18),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _HeroSignalPill(label: 'Food Innovation Centers'),
              _HeroSignalPill(label: 'MSME studies'),
              _HeroSignalPill(label: 'Consumer feedback'),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: TaraTheme.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSignalPill extends StatelessWidget {
  const _HeroSignalPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: TaraTheme.primaryTint,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: TaraTheme.primarySoft),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: TaraTheme.dostBlueDark,
          fontWeight: FontWeight.w800,
        ),
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

class _StudyFilterRail extends StatelessWidget {
  const _StudyFilterRail();

  @override
  Widget build(BuildContext context) {
    const List<String> filters = <String>['All', 'Active', 'Draft', 'Completed'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((String label) {
          final bool selected = label == 'All';
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
              decoration: BoxDecoration(
                color: selected ? TaraTheme.primaryTint : TaraTheme.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selected ? TaraTheme.primary : TaraTheme.border,
                ),
              ),
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: selected ? TaraTheme.primaryDark : TaraTheme.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StudyCard extends StatelessWidget {
  const _StudyCard({required this.study});

  final MsmeStudyItem study;

  @override
  Widget build(BuildContext context) {
    final String normalizedStatus = study.status.toUpperCase();
    final bool draft = normalizedStatus.contains('DRAFT');
    final bool active =
        normalizedStatus.contains('ACTIVE') || normalizedStatus.contains('RECRUIT');
    final bool ficPending =
        normalizedStatus.contains('PENDING') ||
        study.statusLabel.toUpperCase().contains('FIC');
    final List<String> tags = <String>[
      if (study.category.trim().isNotEmpty) _humanizeLabel(study.category),
      if (study.stage.trim().isNotEmpty) _humanizeLabel(study.stage),
      if (study.location.trim().isNotEmpty) study.location,
    ].take(3).toList();
    final String responseLabel = draft ? 'Target panelists' : 'Responses';
    final String responseValue = draft
        ? study.sampleSize.toString()
        : '${study.responseCount} / ${study.sampleSize}';

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 10),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      study.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 13,
                        height: 1.12,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _studySubtitle(study),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: TaraTheme.textPrimary,
                        fontSize: 10,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              _CompactStatusPill(
                label: ficPending
                    ? 'Pending FIC'
                    : active
                    ? 'Active'
                    : draft
                    ? 'Draft'
                    : _humanizeLabel(study.status),
                color: ficPending
                    ? TaraTheme.primaryDark
                    : active
                    ? TaraTheme.mintText
                    : TaraTheme.textSecondary,
                backgroundColor: ficPending
                    ? TaraTheme.primaryTint
                    : active
                    ? const Color(0xFFEAF8D9)
                    : const Color(0xFFF3F4F6),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: tags
                .map((String label) => _MiniTag(label: label))
                .toList(),
          ),
          const SizedBox(height: 9),
          Text(
            responseLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 9,
              height: 1,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: <Widget>[
              if (!draft)
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: study.progress,
                      minHeight: 3,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        TaraTheme.primary,
                      ),
                    ),
                  ),
                )
              else
                const Spacer(),
              const SizedBox(width: 10),
              Text(
                responseValue,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: TaraTheme.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompactStatusPill extends StatelessWidget {
  const _CompactStatusPill({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: TaraTheme.textPrimary,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 11, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: foregroundColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Icon(icon, color: foregroundColor, size: 14),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: foregroundColor.withValues(alpha: 0.72),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceWrap extends StatelessWidget {
  const _ChoiceWrap({
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  final List<SelectOption> options;
  final String selectedValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options
          .map(
            (SelectOption option) => ChoiceChip(
              label: Text(option.label),
              selected: selectedValue == option.value,
              onSelected: (_) => onSelected(option.value),
              selectedColor: TaraTheme.primarySoft,
              side: const BorderSide(color: TaraTheme.border),
              labelStyle: TextStyle(
                color: selectedValue == option.value
                    ? TaraTheme.primaryDark
                    : TaraTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _AttributeEditor extends StatelessWidget {
  const _AttributeEditor({
    required this.attribute,
    required this.dimensionOptions,
    required this.onChanged,
  });

  final _StudyAttributeDraft attribute;
  final List<String> dimensionOptions;
  final ValueChanged<_StudyAttributeDraft> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TaraTheme.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        children: <Widget>[
          TextFormField(
            initialValue: attribute.name,
            onChanged: (String value) =>
                onChanged(attribute.copyWith(name: value)),
            decoration: const InputDecoration(labelText: 'Attribute'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: attribute.dimension,
            items: dimensionOptions
                .map(
                  (String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  ),
                )
                .toList(),
            onChanged: (String? value) {
              if (value != null) {
                onChanged(attribute.copyWith(dimension: value));
              }
            },
            decoration: const InputDecoration(labelText: 'Type'),
          ),
          const SizedBox(height: 10),
          CheckboxListTile(
            value: attribute.isJarTarget,
            onChanged: (bool? value) =>
                onChanged(attribute.copyWith(isJarTarget: value ?? false)),
            contentPadding: EdgeInsets.zero,
            title: const Text('Priority'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }
}

class _MobileFacilityCalendar extends StatelessWidget {
  const _MobileFacilityCalendar({
    required this.startDate,
    required this.durationDays,
    required this.selectedFacility,
    required this.sessions,
    required this.onDateSelected,
  });

  final DateTime startDate;
  final int durationDays;
  final String? selectedFacility;
  final List<_SessionDraft> sessions;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final int safeDuration = durationDays < 1 ? 1 : durationDays;
    final DateTime today = DateTime.now();
    final DateTime firstDate = DateTime(today.year, today.month, today.day);
    final DateTime selectedDate = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final DateTime rangeStart = selectedDate.isBefore(firstDate)
        ? selectedDate
        : firstDate;
    final List<DateTime> visibleDates = List<DateTime>.generate(
      14,
      (int index) => rangeStart.add(Duration(days: index)),
    );
    final int totalCapacity = sessions.fold<int>(
      0,
      (int total, _SessionDraft session) => total + session.capacity,
    );
    final String facilityName = selectedFacility?.trim().isEmpty ?? true
        ? 'No facility selected'
        : selectedFacility!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: TaraTheme.primaryTint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.calendar_month_outlined,
                  color: TaraTheme.primaryDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Facility Calendar',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      facilityName,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: visibleDates.map((DateTime date) {
                final int dayOffset = date.difference(selectedDate).inDays;
                final bool selected = dayOffset >= 0 && dayOffset < safeDuration;
                final bool past = date.isBefore(firstDate);
                final bool hasSessions = sessions.any(
                  (_SessionDraft session) => session.dayOffset == dayOffset,
                );
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _CalendarDateChip(
                    date: date,
                    selected: selected,
                    disabled: past,
                    hasSessions: hasSessions,
                    onTap: past ? null : () => onDateSelected(date),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: _CalendarMetric(
                  label: 'Selected',
                  value: '$safeDuration day${safeDuration == 1 ? '' : 's'}',
                  icon: Icons.event_available_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CalendarMetric(
                  label: 'Capacity',
                  value: '$totalCapacity seats',
                  icon: Icons.groups_2_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _CalendarLegendDot(
                label: 'Testing date',
                color: TaraTheme.primary,
              ),
              const _CalendarLegendDot(
                label: 'Has session',
                color: TaraTheme.dostBlue,
              ),
              _CalendarLegendDot(
                label: 'Unavailable',
                color: TaraTheme.textSecondary.withValues(alpha: 0.38),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalendarDateChip extends StatelessWidget {
  const _CalendarDateChip({
    required this.date,
    required this.selected,
    required this.disabled,
    required this.hasSessions,
    required this.onTap,
  });

  final DateTime date;
  final bool selected;
  final bool disabled;
  final bool hasSessions;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = selected ? TaraTheme.primary : TaraTheme.border;
    final Color textColor = disabled
        ? TaraTheme.textSecondary.withValues(alpha: 0.55)
        : selected
        ? TaraTheme.primaryDark
        : TaraTheme.textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 74,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: disabled
              ? TaraTheme.background
              : selected
              ? TaraTheme.primaryTint
              : TaraTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
        ),
        child: Column(
          children: <Widget>[
            Text(
              _formatWeekday(date),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              date.day.toString(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: textColor,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 6,
              width: 6,
              decoration: BoxDecoration(
                color: hasSessions ? TaraTheme.dostBlue : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarMetric extends StatelessWidget {
  const _CalendarMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: TaraTheme.primaryDark, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(value, style: Theme.of(context).textTheme.titleMedium),
                Text(label, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarLegendDot extends StatelessWidget {
  const _CalendarLegendDot({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 8,
          width: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _SessionEditor extends StatelessWidget {
  const _SessionEditor({
    required this.session,
    required this.index,
    required this.onChanged,
    required this.durationDays,
    this.onRemove,
  });

  final _SessionDraft session;
  final int index;
  final ValueChanged<_SessionDraft> onChanged;
  final int durationDays;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TaraTheme.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Session ${index + 1}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (onRemove != null)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
            ],
          ),
          TextFormField(
            initialValue: session.label,
            onChanged: (String value) =>
                onChanged(session.copyWith(label: value)),
            decoration: const InputDecoration(labelText: 'Session Label'),
          ),
          const SizedBox(height: 12),
          if (durationDays > 1) ...<Widget>[
            DropdownButtonFormField<int>(
              initialValue: session.dayOffset
                  .clamp(0, durationDays - 1)
                  .toInt(),
              items: List<DropdownMenuItem<int>>.generate(
                durationDays,
                (int index) => DropdownMenuItem<int>(
                  value: index,
                  child: Text('Day ${index + 1}'),
                ),
              ),
              onChanged: (int? value) {
                if (value != null) {
                  onChanged(session.copyWith(dayOffset: value));
                }
              },
              decoration: const InputDecoration(labelText: 'Testing Day'),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  initialValue: session.startTime,
                  onChanged: (String value) =>
                      onChanged(session.copyWith(startTime: value)),
                  decoration: const InputDecoration(labelText: 'Start'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  initialValue: session.endTime,
                  onChanged: (String value) =>
                      onChanged(session.copyWith(endTime: value)),
                  decoration: const InputDecoration(labelText: 'End'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: session.capacity.toString(),
            keyboardType: TextInputType.number,
            onChanged: (String value) => onChanged(
              session.copyWith(
                capacity: int.tryParse(value.trim()) ?? session.capacity,
              ),
            ),
            decoration: const InputDecoration(labelText: 'Session Capacity'),
          ),
        ],
      ),
    );
  }
}

class _SampleSetupEditor extends StatelessWidget {
  const _SampleSetupEditor({
    required this.index,
    required this.setup,
    required this.onChanged,
  });

  final int index;
  final _SampleSetupDraft setup;
  final ValueChanged<_SampleSetupDraft> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            'Sample Set-up ${index + 1}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: setup.description,
            onChanged: (String value) =>
                onChanged(setup.copyWith(description: value)),
            decoration: const InputDecoration(
              labelText: 'General Description / Formulation Notes',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: setup.ingredient,
            onChanged: (String value) =>
                onChanged(setup.copyWith(ingredient: value)),
            decoration: const InputDecoration(
              labelText: 'Ingredient (Optional)',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: setup.allergen,
            onChanged: (String value) =>
                onChanged(setup.copyWith(allergen: value)),
            decoration: const InputDecoration(labelText: 'Allergen'),
          ),
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
  });

  final String title;
  final List<SelectOption> options;
  final Set<String> selectedValues;
  final void Function(String value, bool selected) onChanged;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: title,
      subtitle: 'Tap each option to keep your panelist profile accurate.',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: options
            .map(
              (SelectOption option) => FilterChip(
                label: Text(option.label),
                selected: selectedValues.contains(option.value),
                onSelected: (bool selected) =>
                    onChanged(option.value, selected),
                selectedColor: TaraTheme.primarySoft,
                side: const BorderSide(color: TaraTheme.border),
                labelStyle: TextStyle(
                  color: selectedValues.contains(option.value)
                      ? TaraTheme.primaryDark
                      : TaraTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 150,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
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

const MsmeDashboardData _previewDashboard = MsmeDashboardData(
  workspaceLabel: 'UI Preview',
  title: 'MSME Dashboard',
  subtitle:
      'Review the mobile workspace with sample studies while authentication and live APIs are paused.',
  stats: DashboardStats(
    ficBookings: 3,
    totalStudies: 8,
    totalResponses: 246,
    activeStudies: 2,
  ),
  studies: <MsmeStudyItem>[
    MsmeStudyItem(
      id: 'preview-study-1',
      title: 'Calamansi Spark Sensory Check',
      productName: 'Calamansi Spark',
      location: 'Butuan City FIC',
      category: 'Beverage',
      stage: 'Prototype Check',
      status: 'RECRUITING',
      sampleSize: 80,
      responseCount: 42,
      participantCount: 56,
      statusLabel: 'Recruiting',
    ),
    MsmeStudyItem(
      id: 'preview-study-2',
      title: 'Cacao Nib Snack Preference Test',
      productName: 'Cacao Nib Bites',
      location: 'Caraga State University',
      category: 'Snack',
      stage: 'Refinement',
      status: 'ACTIVE',
      sampleSize: 60,
      responseCount: 51,
      participantCount: 58,
      statusLabel: 'Active',
    ),
    MsmeStudyItem(
      id: 'preview-study-3',
      title: 'Turmeric Tea Market Readiness',
      productName: 'Golden Root Tea',
      location: 'DOST Caraga',
      category: 'Beverage',
      stage: 'Market Readiness',
      status: 'COMPLETED',
      sampleSize: 100,
      responseCount: 100,
      participantCount: 100,
      statusLabel: 'Completed',
    ),
  ],
);

final MsmeProfileData _previewProfile = MsmeProfileData(
  eyebrow: 'UI Preview',
  title: 'My Profile',
  subtitle:
      'Sample MSME profile data for visual review. Changes are not saved while preview mode is enabled.',
  name: 'Preview MSME',
  email: 'preview@tarasense.local',
  organization: 'Caraga Food Innovation Lab',
  age: 32,
  gender: 'PREFER_NOT_SAY',
  location: 'Butuan City',
  occupation: 'Product Developer',
  lifestyle: const <String>['BUSY_PROFESSIONAL', 'HEALTH_CONSCIOUS'],
  dietaryPrefs: const <String>['LOW_SUGAR'],
  coffeeDrinker: true,
  snackConsumer: true,
  energyDrinkConsumer: false,
  history: <ProfileHistoryItem>[
    ProfileHistoryItem(
      id: 'history-1',
      studyTitle: 'Cacao Nib Snack Preference Test',
      productName: 'Cacao Nib Bites',
      stage: 'Refinement',
      status: 'Completed',
      completedAt: DateTime(2026, 4, 18),
    ),
    ProfileHistoryItem(
      id: 'history-2',
      studyTitle: 'Calamansi Spark Sensory Check',
      productName: 'Calamansi Spark',
      stage: 'Prototype Check',
      status: 'In Progress',
      completedAt: null,
    ),
  ],
  metadata: ProfileMetadata(
    role: 'MSME',
    joinedAt: DateTime(2026, 1, 15),
    panelistCreatedAt: DateTime(2026, 1, 16),
    lastActive: DateTime(2026, 4, 29),
  ),
  lifestyleOptions: const <SelectOption>[
    SelectOption(value: 'BUSY_PROFESSIONAL', label: 'Busy professional'),
    SelectOption(value: 'HEALTH_CONSCIOUS', label: 'Health conscious'),
    SelectOption(value: 'FOOD_ADVENTUROUS', label: 'Food adventurous'),
    SelectOption(value: 'BUDGET_MINDED', label: 'Budget-minded'),
  ],
  dietaryOptions: const <SelectOption>[
    SelectOption(value: 'LOW_SUGAR', label: 'Low sugar'),
    SelectOption(value: 'LOW_SODIUM', label: 'Low sodium'),
    SelectOption(value: 'VEGETARIAN', label: 'Vegetarian'),
    SelectOption(value: 'NO_RESTRICTIONS', label: 'No restrictions'),
  ],
  genderOptions: const <SelectOption>[
    SelectOption(value: 'FEMALE', label: 'Female'),
    SelectOption(value: 'MALE', label: 'Male'),
    SelectOption(value: 'PREFER_NOT_SAY', label: 'Prefer not to say'),
  ],
);

const StudyBuilderOptionsData _previewBuilderOptions = StudyBuilderOptionsData(
  workspaceLabel: 'UI Preview',
  title: 'Create Study',
  subtitle:
      'Configure a sample sensory or market study without sending anything to the backend.',
  studyTypes: <SelectOption>[
    SelectOption(value: 'SENSORY', label: 'Sensory Study'),
    SelectOption(value: 'MARKET', label: 'Market Study'),
  ],
  coordinationModes: <SelectOption>[
    SelectOption(value: 'FIC', label: 'Book with FIC'),
    SelectOption(value: 'SELF_MANAGED', label: 'Self-managed'),
  ],
  sensoryStudyTypes: <SelectOption>[
    SelectOption(value: 'CONSUMER_TEST', label: 'Consumer Test'),
    SelectOption(value: 'DESCRIPTIVE_TEST', label: 'Descriptive Test'),
    SelectOption(value: 'DISCRIMINATION_TEST', label: 'Discrimination Test'),
  ],
  consumerObjectives: <SelectOption>[
    SelectOption(
      value: 'FAST_ITERATION',
      label: 'Fast iteration',
      defaultTarget: 30,
    ),
    SelectOption(
      value: 'MARKET_READINESS',
      label: 'Market readiness',
      defaultTarget: 80,
    ),
    SelectOption(
      value: 'PRODUCT_REFINEMENT',
      label: 'Product refinement',
      defaultTarget: 50,
    ),
  ],
  attributeDimensions: <String>['Taste', 'Aroma', 'Texture', 'Appearance'],
  categoryProfiles: <CategoryProfileOption>[
    CategoryProfileOption(
      key: 'beverage',
      label: 'Beverage',
      categoryCode: 'BEVERAGE',
      attributes: <StudyAttributeSeed>[
        StudyAttributeSeed(name: 'Sweetness', dimension: 'Taste'),
        StudyAttributeSeed(name: 'Sourness', dimension: 'Taste'),
        StudyAttributeSeed(name: 'Aroma intensity', dimension: 'Aroma'),
        StudyAttributeSeed(name: 'Color appeal', dimension: 'Appearance'),
      ],
    ),
    CategoryProfileOption(
      key: 'snack',
      label: 'Snack',
      categoryCode: 'SNACK',
      attributes: <StudyAttributeSeed>[
        StudyAttributeSeed(name: 'Crunchiness', dimension: 'Texture'),
        StudyAttributeSeed(name: 'Saltiness', dimension: 'Taste'),
        StudyAttributeSeed(name: 'Aftertaste', dimension: 'Taste'),
        StudyAttributeSeed(name: 'Visual appeal', dimension: 'Appearance'),
      ],
    ),
  ],
  regions: <String>['Caraga', 'Northern Mindanao'],
  facilitiesByRegion: <String, List<String>>{
    'Caraga': <String>['Butuan City FIC', 'DOST Caraga Sensory Lab'],
    'Northern Mindanao': <String>['CDO Food Innovation Center'],
  },
  questionnaireNotes: <String>[
    'Use clear sensory attribute labels.',
    'Keep participant instructions concise.',
    'Review allergens before publishing.',
  ],
  sessionTemplates: <SessionTemplateOption>[
    SessionTemplateOption(
      label: 'Morning Session',
      startTime: '09:00',
      endTime: '11:30',
      capacity: 15,
    ),
    SessionTemplateOption(
      label: 'Afternoon Session',
      startTime: '13:30',
      endTime: '16:00',
      capacity: 15,
    ),
  ],
);

class _StudyAttributeDraft {
  const _StudyAttributeDraft({
    required this.name,
    required this.dimension,
    required this.isJarTarget,
    required this.isCustom,
    required this.actionable,
  });

  final String name;
  final String dimension;
  final bool isJarTarget;
  final bool isCustom;
  final bool actionable;

  _StudyAttributeDraft copyWith({
    String? name,
    String? dimension,
    bool? isJarTarget,
  }) {
    return _StudyAttributeDraft(
      name: name ?? this.name,
      dimension: dimension ?? this.dimension,
      isJarTarget: isJarTarget ?? this.isJarTarget,
      isCustom: isCustom,
      actionable: actionable,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name.trim(),
      'dimension': dimension,
      'isJarTarget': isJarTarget,
      'isCustom': isCustom,
      'actionable': actionable,
    };
  }
}

class _SessionDraft {
  const _SessionDraft({
    required this.label,
    this.startTime = '09:00',
    this.endTime = '11:30',
    this.capacity = 10,
    this.dayOffset = 0,
  });

  final String label;
  final String startTime;
  final String endTime;
  final int capacity;
  final int dayOffset;

  factory _SessionDraft.fromTemplate(SessionTemplateOption template) {
    return _SessionDraft(
      label: template.label,
      startTime: template.startTime,
      endTime: template.endTime,
      capacity: template.capacity,
    );
  }

  _SessionDraft copyWith({
    String? label,
    String? startTime,
    String? endTime,
    int? capacity,
    int? dayOffset,
  }) {
    return _SessionDraft(
      label: label ?? this.label,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      capacity: capacity ?? this.capacity,
      dayOffset: dayOffset ?? this.dayOffset,
    );
  }

  Map<String, dynamic> toJson(DateTime date) {
    final DateTime sessionDate = date.add(Duration(days: dayOffset));
    return <String, dynamic>{
      'dayOffset': dayOffset,
      'label': label.trim().isEmpty ? 'Session' : label.trim(),
      'startDateTime': _combineDateAndTime(sessionDate, startTime),
      'endDateTime': _combineDateAndTime(sessionDate, endTime),
      'capacity': capacity,
    };
  }
}

class _SampleSetupDraft {
  const _SampleSetupDraft({
    required this.description,
    required this.ingredient,
    required this.allergen,
  });

  factory _SampleSetupDraft.empty() {
    return const _SampleSetupDraft(
      description: '',
      ingredient: '',
      allergen: 'N/A',
    );
  }

  final String description;
  final String ingredient;
  final String allergen;

  _SampleSetupDraft copyWith({
    String? description,
    String? ingredient,
    String? allergen,
  }) {
    return _SampleSetupDraft(
      description: description ?? this.description,
      ingredient: ingredient ?? this.ingredient,
      allergen: allergen ?? this.allergen,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'description': description.trim().isEmpty
          ? 'Sample setup'
          : description.trim(),
      'ingredient': ingredient.trim(),
      'allergen': allergen.trim().isEmpty ? 'N/A' : allergen.trim(),
    };
  }
}

String _humanizeLabel(String value) {
  return value
      .toLowerCase()
      .split('_')
      .map((String part) {
        if (part.isEmpty) {
          return part;
        }
        return '${part[0].toUpperCase()}${part.substring(1)}';
      })
      .join(' ');
}

String _studySubtitle(MsmeStudyItem study) {
  if (study.location.trim().isNotEmpty) {
    return 'FIC: ${study.location.trim()}';
  }
  if (study.productName.trim().isNotEmpty) {
    return study.productName.trim();
  }
  return 'Self-administered';
}

String _initialsFor(String value) {
  final List<String> parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((String part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) {
    return 'MS';
  }
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
      .toUpperCase();
}

String _formatLongDate(DateTime value) {
  return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
}

String _formatShortDate(DateTime value) {
  return '${value.month}/${value.day}/${value.year}';
}

String _formatWeekday(DateTime value) {
  const List<String> weekdays = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  return weekdays[value.weekday - 1];
}

String _formatLongDateTime(DateTime value) {
  final int hour = value.hour > 12
      ? value.hour - 12
      : (value.hour == 0 ? 12 : value.hour);
  final String minute = value.minute.toString().padLeft(2, '0');
  final String period = value.hour >= 12 ? 'PM' : 'AM';
  return '${value.month}/${value.day}/${value.year}, $hour:$minute $period';
}

String _formatDateOnly(DateTime value) {
  return '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}

String _combineDateAndTime(DateTime date, String time) {
  final List<String> parts = time.split(':');
  final int hour = int.tryParse(parts.isNotEmpty ? parts[0] : '0') ?? 0;
  final int minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
  final DateTime value = DateTime.utc(
    date.year,
    date.month,
    date.day,
    hour,
    minute,
  );
  return value.toIso8601String();
}
