import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarasense_mobile/core/config/app_config.dart';
import 'package:tarasense_mobile/core/network/api_error_formatter.dart';
import 'package:tarasense_mobile/core/theme/tara_theme.dart';
import 'package:tarasense_mobile/core/widgets/dost_logo_mark.dart';
import 'package:tarasense_mobile/core/widgets/tara_brand_lockup.dart';
import 'package:tarasense_mobile/features/auth/state/auth_providers.dart';
import 'package:tarasense_mobile/features/auth/ui/auth_loading_dialog.dart';
import 'package:tarasense_mobile/features/msme/data/msme_api.dart';
import 'package:tarasense_mobile/features/msme/domain/msme_models.dart';

part 'msme_navigation.dart';
part 'msme_dashboard_tab.dart';
part 'msme_create_study_tab.dart';
part 'msme_profile_tab.dart';
part 'msme_shared_widgets.dart';
part 'msme_preview_data.dart';

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
                    authBusy: authState.isBusy,
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
                    onLogout: () => showLogoutLoadingAndRun(
                      context,
                      () => ref.read(authControllerProvider.notifier).logout(),
                    ),
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
                  _StudyHistoryTab(
                    isLoading: _isLoadingDashboard,
                    error: _dashboardError,
                    dashboard: _dashboard,
                    onRefresh: () => _loadDashboard(),
                    onRetry: () => _loadDashboard(),
                    onOpenCreateStudy: () =>
                        setState(() => _currentTabIndex = 1),
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
        onResults: () => setState(() => _currentTabIndex = 3),
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
