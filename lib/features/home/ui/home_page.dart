import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tarasense_mobile/core/theme/tara_theme.dart';
import 'package:tarasense_mobile/core/widgets/tara_brand_lockup.dart';
import 'package:tarasense_mobile/features/auth/state/auth_providers.dart';
import 'package:tarasense_mobile/features/auth/ui/auth_loading_dialog.dart';
import 'package:tarasense_mobile/features/home/data/system_api.dart';

enum _WorkspaceRole { msme, fic, participant, admin, other }

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final GlobalKey _projectSectionKey = GlobalKey();
  final GlobalKey<FormState> _projectFormKey = GlobalKey<FormState>();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productCategoryController =
      TextEditingController();
  final TextEditingController _developmentStageController =
      TextEditingController();
  final TextEditingController _partnerFicIdController = TextEditingController();

  String? _healthStatus;
  bool _checkingHealth = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkHealth();
    });
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _productCategoryController.dispose();
    _developmentStageController.dispose();
    _partnerFicIdController.dispose();
    super.dispose();
  }

  Future<void> _checkHealth() async {
    if (_checkingHealth) {
      return;
    }
    setState(() => _checkingHealth = true);

    try {
      final String status = await ref.read(systemApiProvider).checkHealth();
      if (!mounted) {
        return;
      }
      setState(() => _healthStatus = status);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _healthStatus = _healthErrorMessage(error));
    } finally {
      if (mounted) {
        setState(() => _checkingHealth = false);
      }
    }
  }

  String _healthErrorMessage(Object error) {
    if (error is DioException) {
      final int? statusCode = error.response?.statusCode;
      final String? message = error.message?.trim();
      final String statusLabel = statusCode == null ? '' : 'HTTP $statusCode';

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'timeout';
        case DioExceptionType.badResponse:
          return statusLabel.isEmpty ? 'request failed' : statusLabel;
        case DioExceptionType.connectionError:
          if (message != null && message.isNotEmpty) {
            return message;
          }
          return 'connection failed';
        default:
          if (message != null && message.isNotEmpty) {
            return message;
          }
          return statusLabel.isEmpty ? 'unreachable' : statusLabel;
      }
    }
    return 'unreachable';
  }

  Future<void> _refreshProfile() async {
    await ref.read(authControllerProvider.notifier).refreshProfile();
  }

  Future<void> _scrollToProjectForm() async {
    final BuildContext? targetContext = _projectSectionKey.currentContext;
    if (targetContext == null) {
      return;
    }

    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _clearProjectForm() {
    _productNameController.clear();
    _productCategoryController.clear();
    _developmentStageController.clear();
    _partnerFicIdController.clear();
  }

  void _submitProjectForm() {
    if (!_projectFormKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Project setup UI is ready. Mobile submission will be wired to the backend next.',
        ),
      ),
    );
  }

  _WorkspaceRole _resolveRole(String rawRole) {
    final String normalized = rawRole.toLowerCase().trim();
    if (normalized.contains('msme')) {
      return _WorkspaceRole.msme;
    }
    if (normalized.contains('fic')) {
      return _WorkspaceRole.fic;
    }
    if (normalized.contains('participant') || normalized.contains('consumer')) {
      return _WorkspaceRole.participant;
    }
    if (normalized.contains('admin')) {
      return _WorkspaceRole.admin;
    }
    return _WorkspaceRole.other;
  }

  String _dashboardTitle(_WorkspaceRole role) {
    switch (role) {
      case _WorkspaceRole.msme:
        return 'MSME Dashboard';
      case _WorkspaceRole.fic:
        return 'FIC Workspace';
      case _WorkspaceRole.participant:
        return 'Participant Workspace';
      case _WorkspaceRole.admin:
        return 'Admin Dashboard';
      case _WorkspaceRole.other:
        return 'Dashboard';
    }
  }

  String _dashboardDescription(_WorkspaceRole role) {
    switch (role) {
      case _WorkspaceRole.msme:
        return 'Create projects, configure tests, then request FIC sensory support.';
      case _WorkspaceRole.fic:
        return 'Review support requests and keep sensory coordination moving.';
      case _WorkspaceRole.participant:
        return 'Track your survey access and stay ready for upcoming research activities.';
      case _WorkspaceRole.admin:
        return 'Monitor access, system readiness, and the current TARAsense workspace flow.';
      case _WorkspaceRole.other:
        return 'Keep your account, system status, and workspace activity in one place.';
    }
  }

  String _roleLabel(_WorkspaceRole role, String rawRole) {
    switch (role) {
      case _WorkspaceRole.msme:
        return 'MSME';
      case _WorkspaceRole.fic:
        return 'FIC';
      case _WorkspaceRole.participant:
        return 'Participant';
      case _WorkspaceRole.admin:
        return 'Admin';
      case _WorkspaceRole.other:
        final String trimmed = rawRole.trim();
        return trimmed.isEmpty ? 'Member' : trimmed;
    }
  }

  _StatusPalette _healthPalette(String? health) {
    final String normalized = (health ?? '').toLowerCase();
    if (normalized == 'ok') {
      return const _StatusPalette(
        label: 'Operational',
        background: TaraTheme.mint,
        foreground: TaraTheme.mintText,
      );
    }
    if (normalized.isEmpty) {
      return const _StatusPalette(
        label: 'Checking',
        background: Color(0xFFE5E7EB),
        foreground: Color(0xFF4B5563),
      );
    }
    return const _StatusPalette(
      label: 'Attention',
      background: TaraTheme.rose,
      foreground: TaraTheme.roseText,
    );
  }

  List<_HeroMetric> _heroMetrics(_WorkspaceRole role, String statusLabel) {
    switch (role) {
      case _WorkspaceRole.msme:
      case _WorkspaceRole.admin:
        return <_HeroMetric>[
          const _HeroMetric(
            label: 'Project',
            value: 'Step 1',
            icon: Icons.inventory_2_outlined,
          ),
          const _HeroMetric(
            label: 'Tests',
            value: 'Step 2',
            icon: Icons.tune_rounded,
          ),
          const _HeroMetric(
            label: 'FIC',
            value: 'Step 3',
            icon: Icons.handshake_outlined,
          ),
          _HeroMetric(
            label: 'System',
            value: statusLabel,
            icon: Icons.monitor_heart_outlined,
          ),
        ];
      case _WorkspaceRole.fic:
        return <_HeroMetric>[
          const _HeroMetric(
            label: 'Support',
            value: 'Live',
            icon: Icons.support_agent_outlined,
          ),
          const _HeroMetric(
            label: 'Projects',
            value: 'Review',
            icon: Icons.folder_open_outlined,
          ),
          const _HeroMetric(
            label: 'Partners',
            value: 'Ready',
            icon: Icons.groups_outlined,
          ),
          _HeroMetric(
            label: 'System',
            value: statusLabel,
            icon: Icons.monitor_heart_outlined,
          ),
        ];
      case _WorkspaceRole.participant:
        return <_HeroMetric>[
          const _HeroMetric(
            label: 'Surveys',
            value: 'Ready',
            icon: Icons.rate_review_outlined,
          ),
          const _HeroMetric(
            label: 'Profile',
            value: 'Active',
            icon: Icons.verified_user_outlined,
          ),
          const _HeroMetric(
            label: 'Access',
            value: 'Mobile',
            icon: Icons.phone_android_outlined,
          ),
          _HeroMetric(
            label: 'System',
            value: statusLabel,
            icon: Icons.monitor_heart_outlined,
          ),
        ];
      case _WorkspaceRole.other:
        return <_HeroMetric>[
          const _HeroMetric(
            label: 'Workspace',
            value: 'Ready',
            icon: Icons.dashboard_customize_outlined,
          ),
          const _HeroMetric(
            label: 'Account',
            value: 'Active',
            icon: Icons.person_outline_rounded,
          ),
          const _HeroMetric(
            label: 'Access',
            value: 'Mobile',
            icon: Icons.phone_android_outlined,
          ),
          _HeroMetric(
            label: 'System',
            value: statusLabel,
            icon: Icons.monitor_heart_outlined,
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final session = authState.session;

    if (session == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final String firstName = session.user.name.trim().split(' ').first;
    final _WorkspaceRole role = _resolveRole(session.user.role);
    final String title = _dashboardTitle(role);
    final String description = _dashboardDescription(role);
    final String roleLabel = _roleLabel(role, session.user.role);
    final _StatusPalette healthPalette = _healthPalette(_healthStatus);
    final String healthLabel = _healthStatus == null
        ? 'Checking'
        : _healthStatus!;
    final List<_HeroMetric> heroMetrics = _heroMetrics(role, healthLabel);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 74,
        titleSpacing: 18,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 2),
            Text(
              'Latest web app content in a refreshed mobile layout',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () => context.go('/api-test'),
            icon: const Icon(Icons.api_rounded),
            tooltip: 'API test',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _refreshProfile();
          await _checkHealth();
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 30),
          children: <Widget>[
            _HeroSection(
              firstName: firstName,
              description: description,
              roleLabel: roleLabel,
              organization: session.user.organization,
              metrics: heroMetrics,
              onPrimaryAction:
                  role == _WorkspaceRole.msme || role == _WorkspaceRole.admin
                  ? _scrollToProjectForm
                  : _refreshProfile,
              primaryActionLabel:
                  role == _WorkspaceRole.msme || role == _WorkspaceRole.admin
                  ? 'Create New Project'
                  : 'Refresh Profile',
              onSecondaryAction: _checkHealth,
              secondaryActionLabel: _checkingHealth
                  ? 'Checking...'
                  : 'Check System',
            ),
            if (authState.errorMessage != null) ...<Widget>[
              const SizedBox(height: 16),
              _MessageCard(
                background: const Color(0xFFFFF1F2),
                border: const Color(0xFFFECDD3),
                child: Text(
                  authState.errorMessage!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: TaraTheme.roseText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),
            _MessageCard(
              background: TaraTheme.surface,
              border: TaraTheme.border,
              child: Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: healthPalette.background,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (_checkingHealth)
                          SizedBox(
                            height: 12,
                            width: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: healthPalette.foreground,
                            ),
                          )
                        else
                          Icon(
                            Icons.circle,
                            size: 10,
                            color: healthPalette.foreground,
                          ),
                        const SizedBox(width: 8),
                        Text(
                          healthPalette.label,
                          style: TextStyle(
                            color: healthPalette.foreground,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'System status: $healthLabel',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            if (role == _WorkspaceRole.msme ||
                role == _WorkspaceRole.admin) ...<Widget>[
              _CreateProjectSection(
                sectionKey: _projectSectionKey,
                formKey: _projectFormKey,
                productNameController: _productNameController,
                productCategoryController: _productCategoryController,
                developmentStageController: _developmentStageController,
                partnerFicIdController: _partnerFicIdController,
                onSubmit: _submitProjectForm,
                onClear: _clearProjectForm,
              ),
              const SizedBox(height: 22),
              _ProjectsSection(onStartProject: _scrollToProjectForm),
            ] else ...<Widget>[_RoleFocusSection(role: role)],
            const SizedBox(height: 22),
            _WorkspaceToolsSection(
              name: session.user.name,
              email: session.user.email,
              role: roleLabel,
              organization: session.user.organization,
              authBusy: authState.isBusy,
              checkingHealth: _checkingHealth,
              onRefreshProfile: _refreshProfile,
              onCheckHealth: _checkHealth,
              onOpenApiTest: () => context.go('/api-test'),
              onLogout: () => showLogoutLoadingAndRun(
                context,
                () => ref.read(authControllerProvider.notifier).logout(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.firstName,
    required this.description,
    required this.roleLabel,
    required this.organization,
    required this.metrics,
    required this.onPrimaryAction,
    required this.primaryActionLabel,
    required this.onSecondaryAction,
    required this.secondaryActionLabel,
  });

  final String firstName;
  final String description;
  final String roleLabel;
  final String? organization;
  final List<_HeroMetric> metrics;
  final Future<void> Function() onPrimaryAction;
  final String primaryActionLabel;
  final Future<void> Function() onSecondaryAction;
  final String secondaryActionLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFF97316), Color(0xFFFFA24D)],
        ),
        borderRadius: BorderRadius.circular(34),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x24F97316),
            blurRadius: 34,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const TaraBrandLockup(
            markSize: 22,
            textSize: 24,
            taraFillColor: TaraTheme.dostBlue,
            senseColor: Colors.white,
          ),
          const SizedBox(height: 18),
          Text(
            'Welcome back, $firstName',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              height: 1.04,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              _HeroPill(label: roleLabel),
              if (organization != null && organization!.trim().isNotEmpty)
                _HeroPill(label: organization!.trim()),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: metrics
                .map((_HeroMetric metric) => _HeroMetricCard(metric: metric))
                .toList(),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                onPrimaryAction();
              },
              style: FilledButton.styleFrom(
                backgroundColor: TaraTheme.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(primaryActionLabel),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                onSecondaryAction();
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: TaraTheme.primaryDark,
                foregroundColor: Colors.white,
                side: const BorderSide(color: TaraTheme.primaryDark),
              ),
              child: Text(secondaryActionLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateProjectSection extends StatelessWidget {
  const _CreateProjectSection({
    required this.sectionKey,
    required this.formKey,
    required this.productNameController,
    required this.productCategoryController,
    required this.developmentStageController,
    required this.partnerFicIdController,
    required this.onSubmit,
    required this.onClear,
  });

  final Key sectionKey;
  final GlobalKey<FormState> formKey;
  final TextEditingController productNameController;
  final TextEditingController productCategoryController;
  final TextEditingController developmentStageController;
  final TextEditingController partnerFicIdController;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: sectionKey,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _SectionHeader(
              title: 'Create a Project',
              description:
                  'Start here. You\'ll set purpose, samples, and attributes next.',
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: productNameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                hintText: 'e.g., Calamansi Soda',
                prefixIcon: Icon(Icons.local_drink_outlined),
              ),
              validator: (String? value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Enter a product name';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: productCategoryController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Product Category',
                hintText: 'e.g., carbonated_drinks',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              validator: (String? value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Enter a product category';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: developmentStageController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Development Stage',
                hintText: 'e.g., Prototype',
                prefixIcon: Icon(Icons.timeline_outlined),
              ),
              validator: (String? value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Enter a development stage';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: partnerFicIdController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                labelText: 'Partner FIC User ID',
                hintText: 'Temporary optional value',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TaraTheme.primaryTint,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                'This mobile redesign now mirrors the latest web app project setup content. Submission will be connected to the backend in the next step.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: TaraTheme.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onSubmit,
                child: const Text('Create Project'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onClear,
                child: const Text('Clear Form'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectsSection extends StatelessWidget {
  const _ProjectsSection({required this.onStartProject});

  final Future<void> Function() onStartProject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _SectionHeader(
            title: 'My Projects',
            description: 'No projects yet.',
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: TaraTheme.border),
            ),
            child: Column(
              children: <Widget>[
                Container(
                  height: 58,
                  width: 58,
                  decoration: BoxDecoration(
                    color: TaraTheme.primaryTint,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.folder_open_outlined,
                    color: TaraTheme.primaryDark,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'No projects yet.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your first project to continue with setup, samples, and sensory attributes.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      onStartProject();
                    },
                    child: const Text('Start a Project'),
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

class _RoleFocusSection extends StatelessWidget {
  const _RoleFocusSection({required this.role});

  final _WorkspaceRole role;

  List<_FocusItem> _items() {
    switch (role) {
      case _WorkspaceRole.fic:
        return const <_FocusItem>[
          _FocusItem(
            icon: Icons.assignment_turned_in_outlined,
            title: 'Review partner requests',
            description: 'Keep incoming MSME work visible and easy to assess.',
          ),
          _FocusItem(
            icon: Icons.handshake_outlined,
            title: 'Coordinate sensory support',
            description: 'Track the support step in the same mobile workspace.',
          ),
          _FocusItem(
            icon: Icons.monitor_heart_outlined,
            title: 'Watch system readiness',
            description: 'Use quick checks before moving work forward.',
          ),
        ];
      case _WorkspaceRole.participant:
        return const <_FocusItem>[
          _FocusItem(
            icon: Icons.rate_review_outlined,
            title: 'Stay ready for survey access',
            description:
                'Participant flows will continue to expand from the web app structure.',
          ),
          _FocusItem(
            icon: Icons.verified_user_outlined,
            title: 'Keep your account updated',
            description:
                'Refresh your profile and verify your mobile session quickly.',
          ),
          _FocusItem(
            icon: Icons.phone_android_outlined,
            title: 'Use the simplified mobile layout',
            description:
                'The refreshed UI keeps the next steps clear on smaller screens.',
          ),
        ];
      case _WorkspaceRole.admin:
      case _WorkspaceRole.msme:
      case _WorkspaceRole.other:
        return const <_FocusItem>[
          _FocusItem(
            icon: Icons.dashboard_customize_outlined,
            title: 'Monitor workspace readiness',
            description: 'Keep account and system actions within easy reach.',
          ),
          _FocusItem(
            icon: Icons.refresh_rounded,
            title: 'Refresh live account data',
            description:
                'Pull the latest profile information into the mobile workspace.',
          ),
          _FocusItem(
            icon: Icons.api_rounded,
            title: 'Verify service connectivity',
            description:
                'Use API tools and status checks without leaving the app.',
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<_FocusItem> items = _items();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _SectionHeader(
            title: 'Workspace Focus',
            description:
                'The refreshed mobile layout keeps the current role workflow clearer.',
          ),
          const SizedBox(height: 18),
          ...items.map(
            (_FocusItem item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FocusTile(item: item),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceToolsSection extends StatelessWidget {
  const _WorkspaceToolsSection({
    required this.name,
    required this.email,
    required this.role,
    required this.organization,
    required this.authBusy,
    required this.checkingHealth,
    required this.onRefreshProfile,
    required this.onCheckHealth,
    required this.onOpenApiTest,
    required this.onLogout,
  });

  final String name;
  final String email;
  final String role;
  final String? organization;
  final bool authBusy;
  final bool checkingHealth;
  final Future<void> Function() onRefreshProfile;
  final Future<void> Function() onCheckHealth;
  final VoidCallback onOpenApiTest;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: TaraTheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _SectionHeader(
            title: 'Profile',
            description:
                'Review your account details and mobile-safe workspace tools.',
          ),
          const SizedBox(height: 18),
          _SettingsIdentityCard(
            name: name,
            email: email,
            role: role,
            organization: organization,
          ),
          const SizedBox(height: 12),
          _ToolButton(
            icon: Icons.refresh_rounded,
            label: 'Refresh Profile',
            onPressed: authBusy
                ? null
                : () {
                    onRefreshProfile();
                  },
          ),
          const SizedBox(height: 12),
          _ToolButton(
            icon: checkingHealth
                ? Icons.hourglass_bottom_rounded
                : Icons.monitor_heart_outlined,
            label: checkingHealth ? 'Checking System' : 'Check System',
            onPressed: () {
              onCheckHealth();
            },
          ),
          const SizedBox(height: 12),
          _ToolButton(
            icon: Icons.api_rounded,
            label: 'Open API Test',
            onPressed: onOpenApiTest,
          ),
          const SizedBox(height: 12),
          _ToolButton(
            icon: Icons.logout_rounded,
            label: 'Log out',
            onPressed: authBusy ? null : onLogout,
            destructive: true,
          ),
        ],
      ),
    );
  }
}

class _SettingsIdentityCard extends StatelessWidget {
  const _SettingsIdentityCard({
    required this.name,
    required this.email,
    required this.role,
    required this.organization,
  });

  final String name;
  final String email;
  final String role;
  final String? organization;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TaraTheme.background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SettingsFormGrid(
            fields: <_SettingsField>[
              _SettingsField(label: 'Name', value: name),
              _SettingsField(label: 'Email', value: email),
              _SettingsField(label: 'Role', value: role),
              if (organization != null && organization!.trim().isNotEmpty)
                _SettingsField(
                  label: 'Organization',
                  value: organization!.trim(),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsFormGrid extends StatelessWidget {
  const _SettingsFormGrid({required this.fields});

  final List<_SettingsField> fields;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool twoColumns = constraints.maxWidth >= 560;
        final double width = twoColumns
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: fields
              .map(
                (_SettingsField field) => SizedBox(
                  width: width,
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

class _SettingsField {
  const _SettingsField({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.background,
    required this.border,
    required this.child,
  });

  final Color background;
  final Color border;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(description, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final Color foreground = destructive
        ? TaraTheme.roseText
        : TaraTheme.textPrimary;
    final Color background = destructive
        ? const Color(0xFFFFF1F2)
        : TaraTheme.background;
    final Color border = destructive
        ? const Color(0xFFFECDD3)
        : TaraTheme.border;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: border),
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, color: foreground),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: foreground),
          ],
        ),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _HeroMetric {
  const _HeroMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}

class _HeroMetricCard extends StatelessWidget {
  const _HeroMetricCard({required this.metric});

  final _HeroMetric metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(metric.icon, color: Colors.white),
          ),
          const SizedBox(height: 14),
          Text(
            metric.label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            metric.value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusItem {
  const _FocusItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

class _FocusTile extends StatelessWidget {
  const _FocusTile({required this.item});

  final _FocusItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TaraTheme.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: TaraTheme.primaryTint,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(item.icon, color: TaraTheme.primaryDark),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  item.description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPalette {
  const _StatusPalette({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;
}
