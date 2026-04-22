import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarasense_mobile/core/theme/tara_theme.dart';
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
  final TextEditingController _searchController = TextEditingController();
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
  final TextEditingController _durationController =
      TextEditingController(text: '1');
  final TextEditingController _sampleCountController =
      TextEditingController(text: '1');

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
    _searchController.dispose();
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
    await Future.wait(<Future<void>>[
      _loadDashboard(),
      _loadProfile(),
      _loadBuilderOptions(),
    ]);
  }

  String? get _accessToken =>
      ref.read(authControllerProvider).session?.tokens.accessToken;

  Future<void> _loadDashboard({String? query}) async {
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
    final String? accessToken = _accessToken;
    if (accessToken == null) {
      return;
    }

    setState(() => _isSavingProfile = true);

    try {
      final profile = await ref.read(msmeApiProvider).updateProfile(
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
      setState(() => _builderError = 'Only the top 3 attributes can be marked as priority.');
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

      final result = await ref.read(msmeApiProvider).createStudy(
        accessToken,
        payload: <String, dynamic>{
          'studyMode': _studyMode,
          'sensoryStudyType': _studyMode == 'SENSORY' ? _sensoryStudyType : null,
          'marketStudyType': _studyMode == 'MARKET'
              ? 'PRODUCT_INTENT'
              : null,
          'sensoryMethod': _sensoryStudyType == 'CONSUMER_TEST'
              ? 'Consumer Test'
              : _sensoryStudyType.replaceAll('_', ' '),
          'consumerObjective':
              _studyMode == 'SENSORY' ? _consumerObjective : null,
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
              .map((_SessionDraft session) => session.toJson(_testingStartDate))
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
    if (error is DioException) {
      final dynamic data = error.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      return error.message ?? 'Request failed.';
    }
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final session = authState.session;

    if (session == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bool isSupportedRole = session.user.role.toUpperCase().contains('MSME') ||
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
              searchController: _searchController,
              currentTabIndex: _currentTabIndex,
              userName: session.user.name,
              onSearchSubmitted: () => _loadDashboard(
                query: _searchController.text.trim(),
              ),
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
                    onOpenCreateStudy: () => setState(() => _currentTabIndex = 1),
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
                          _builderOptions?.consumerObjectives ?? <SelectOption>[];
                      for (final SelectOption item in objectives) {
                        if (item.value == value) {
                          option = item;
                          break;
                        }
                      }
                      setState(() {
                        _consumerObjective = value;
                        if (option?.defaultTarget != null) {
                          _targetResponsesController.text =
                              option!.defaultTarget!.toString();
                        }
                      });
                    },
                    onRegionChanged: (String value) {
                      setState(() {
                        _selectedRegion = value;
                        _selectedFacility = _builderOptions
                            ?.facilitiesByRegion[value]
                            ?.first;
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
                    onAttributeChanged: (int index, _StudyAttributeDraft value) {
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
      bottomNavigationBar: NavigationBar(
        height: 72,
        selectedIndex: _currentTabIndex,
        onDestinationSelected: (int index) {
          setState(() => _currentTabIndex = index);
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline_rounded),
            selectedIcon: Icon(Icons.add_circle_rounded),
            label: 'Create Study',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
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
    final SessionTemplateOption? template = options?.sessionTemplates.isNotEmpty == true
        ? options!.sessionTemplates[_sessions.length % options.sessionTemplates.length]
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
      setState(() => _builderError = 'Mark the custom attribute as actionable before adding it.');
      return;
    }
    if (_attributes.any((_StudyAttributeDraft item) => item.isCustom)) {
      setState(() => _builderError = 'Only one custom attribute is allowed.');
      return;
    }
    if (_attributes.length >= 5) {
      setState(() => _builderError = 'A maximum of five attributes can be used.');
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
    required this.searchController,
    required this.currentTabIndex,
    required this.userName,
    required this.onSearchSubmitted,
    required this.onLogout,
  });

  final TextEditingController searchController;
  final int currentTabIndex;
  final String userName;
  final VoidCallback onSearchSubmitted;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final List<String> titles = <String>[
      'MSME Dashboard',
      'Create Study',
      'My Profile',
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const TaraBrandLockup(markSize: 18, textSize: 20),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: TaraTheme.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: TaraTheme.border),
                ),
                child: Text(
                  _formatHeaderDate(DateTime.now()),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: TaraTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onLogout,
                icon: const Icon(Icons.logout_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: TaraTheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: TaraTheme.border),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: TaraTheme.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: TaraTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  titles[currentTabIndex],
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  'Welcome back, ${userName.trim().split(' ').first}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => onSearchSubmitted(),
                  decoration: InputDecoration(
                    hintText: 'Search your studies and response status',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: IconButton(
                      onPressed: onSearchSubmitted,
                      icon: const Icon(Icons.arrow_forward_rounded),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
        children: <Widget>[
          _HeroWorkspaceCard(
            title: dashboard?.title ?? 'MSME Dashboard',
            subtitle: dashboard?.subtitle ??
                'Create and manage studies, coordinate with FIC, and monitor response progress in one view.',
            actionLabel: 'Create Study',
            onAction: onOpenCreateStudy,
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const _LoadingCard()
          else if (error != null)
            _ErrorCard(message: error!, onRetry: onRetry)
          else if (dashboard != null) ...<Widget>[
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                _StatCard(
                  label: 'Book to FIC',
                  value: dashboard!.stats.ficBookings.toString(),
                  subtitle: 'Studies using FIC facilities',
                  tint: const Color(0xFFFFF3D4),
                  icon: Icons.assignment_turned_in_outlined,
                ),
                _StatCard(
                  label: 'Recent / History',
                  value: dashboard!.stats.totalStudies.toString(),
                  subtitle: 'Total studies created',
                  tint: const Color(0xFFEAF2FF),
                  icon: Icons.grid_view_rounded,
                ),
                _StatCard(
                  label: 'Survey Responses',
                  value: dashboard!.stats.totalResponses.toString(),
                  subtitle: 'Responses collected',
                  tint: const Color(0xFFE6FBF4),
                  icon: Icons.assignment_rounded,
                ),
                _StatCard(
                  label: 'Active Studies',
                  value: dashboard!.stats.activeStudies.toString(),
                  subtitle: 'Recruiting or ongoing studies',
                  tint: const Color(0xFFF1F5F9),
                  icon: Icons.add_circle_outline_rounded,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: TaraTheme.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: TaraTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        'MSME Study List',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(width: 10),
                      _CounterBadge(value: dashboard!.studies.length.toString()),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (dashboard!.studies.isEmpty)
                    const _EmptyCard(
                      title: 'No studies yet',
                      message:
                          'Create your first MSME study to start collecting responses.',
                    )
                  else
                    ...dashboard!.studies.map(
                      (MsmeStudyItem study) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _StudyCard(study: study),
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
            subtitle: options?.subtitle ??
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
                subtitle: 'Choose the MSME workflow and how you want to coordinate it.',
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
                subtitle: 'Start with the facility, product, and sensory study details.',
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
                      items: (selectedRegion == null
                              ? <String>[]
                              : options!.facilitiesByRegion[selectedRegion] ?? <String>[])
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
                      decoration: const InputDecoration(labelText: 'Facility Type'),
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
                subtitle: 'Pick the priority attributes that should drive the questionnaire.',
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
                      (MapEntry<int, _StudyAttributeDraft> entry) =>
                          Padding(
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
                subtitle: 'Set the target responses and the testing sessions for this study.',
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
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FBFF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: TaraTheme.border),
                      ),
                      child: Row(
                        children: <Widget>[
                          const Icon(
                            Icons.calendar_month_outlined,
                            color: TaraTheme.primaryDark,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Facility booking and session scheduling are ready on mobile. Each session becomes part of the created study.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
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
                subtitle: 'Describe the product variants or formulations used in the study.',
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
            subtitle: profile?.subtitle ??
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
              subtitle: 'Keep the mobile profile aligned with your MSME account details.',
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
                    decoration: const InputDecoration(labelText: 'Organization'),
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
                      message: 'Your completed or assigned studies will appear here.',
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
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${entry.productName} • ${_humanizeLabel(entry.stage)} • ${_humanizeLabel(entry.status)}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  if (entry.completedAt != null) ...<Widget>[
                                    const SizedBox(height: 6),
                                    Text(
                                      'Completed ${_formatLongDateTime(entry.completedAt!)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(fontWeight: FontWeight.w700),
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
                  _MetadataRow(label: 'Account Role', value: profile!.metadata.role),
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
                        : _formatShortDate(profile!.metadata.panelistCreatedAt!),
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFF97316), Color(0xFFFF9F57)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x22F97316),
            blurRadius: 24,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'MSME WORKSPACE',
            style: TextStyle(
              color: Colors.white70,
              letterSpacing: 2.2,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white,
              height: 1.5,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: TaraTheme.primaryDark,
              ),
              child: Text(actionLabel),
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.tint,
    required this.icon,
  });

  final String label;
  final String value;
  final String subtitle;
  final Color tint;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 164,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: TaraTheme.primaryDark),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: TaraTheme.textSecondary,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _CounterBadge extends StatelessWidget {
  const _CounterBadge({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: TaraTheme.primaryTint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: TaraTheme.primaryDark,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StudyCard extends StatelessWidget {
  const _StudyCard({required this.study});

  final MsmeStudyItem study;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TaraTheme.background,
        borderRadius: BorderRadius.circular(24),
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
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      study.productName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              _StatusPill(
                label: _humanizeLabel(study.status),
                color: _statusColor(study.status),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _InfoChip(label: _humanizeLabel(study.category)),
              _InfoChip(label: _humanizeLabel(study.stage)),
              _InfoChip(label: study.location),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: study.progress,
              minHeight: 10,
              backgroundColor: TaraTheme.primarySoft,
              valueColor: const AlwaysStoppedAnimation<Color>(TaraTheme.primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${study.responseCount}/${study.sampleSize} responses',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 6),
          Text(
            study.statusLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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

class _SessionEditor extends StatelessWidget {
  const _SessionEditor({
    required this.session,
    required this.index,
    required this.onChanged,
    this.onRemove,
  });

  final _SessionDraft session;
  final int index;
  final ValueChanged<_SessionDraft> onChanged;
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
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: TaraTheme.primaryTint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: TaraTheme.primaryDark,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
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
  }) {
    return _SessionDraft(
      label: label ?? this.label,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      capacity: capacity ?? this.capacity,
      dayOffset: dayOffset,
    );
  }

  Map<String, dynamic> toJson(DateTime date) {
    return <String, dynamic>{
      'dayOffset': dayOffset,
      'label': label.trim().isEmpty ? 'Session' : label.trim(),
      'startDateTime': _combineDateAndTime(date, startTime),
      'endDateTime': _combineDateAndTime(date, endTime),
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
      'description': description.trim().isEmpty ? 'Sample setup' : description.trim(),
      'ingredient': ingredient.trim(),
      'allergen': allergen.trim().isEmpty ? 'N/A' : allergen.trim(),
    };
  }
}

Color _statusColor(String value) {
  final String normalized = value.toUpperCase();
  if (normalized == 'ACTIVE' || normalized == 'RECRUITING') {
    return TaraTheme.mintText;
  }
  if (normalized == 'DRAFT') {
    return TaraTheme.lavenderText;
  }
  if (normalized == 'COMPLETED' || normalized == 'ARCHIVED') {
    return TaraTheme.roseText;
  }
  return TaraTheme.textSecondary;
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

String _formatHeaderDate(DateTime value) {
  const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[value.month - 1]} ${value.day}, ${value.year}';
}

String _formatLongDate(DateTime value) {
  return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
}

String _formatShortDate(DateTime value) {
  return '${value.month}/${value.day}/${value.year}';
}

String _formatLongDateTime(DateTime value) {
  final int hour = value.hour > 12 ? value.hour - 12 : (value.hour == 0 ? 12 : value.hour);
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
