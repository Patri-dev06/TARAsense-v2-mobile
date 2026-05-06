import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarasense_mobile/core/theme/tara_theme.dart';
import 'package:tarasense_mobile/features/auth/state/auth_providers.dart';

part 'tester_mobile_portal.dart';
part 'tester_desktop_shell.dart';
part 'tester_panels.dart';
part 'tester_shared_widgets.dart';
part 'tester_data.dart';


enum _ConsumerView {
  dashboard,
  profile,
  availableSurveys,
  completedSurveys,
  roleApplications,
  settings,
}

class TesterWorkspacePage extends ConsumerStatefulWidget {
  const TesterWorkspacePage({super.key});

  @override
  ConsumerState<TesterWorkspacePage> createState() =>
      _TesterWorkspacePageState();
}

class _TesterWorkspacePageState extends ConsumerState<TesterWorkspacePage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _msmeReasonController = TextEditingController();
  final TextEditingController _ficReasonController = TextEditingController();

  _ConsumerView _currentView = _ConsumerView.dashboard;

  @override
  void dispose() {
    _searchController.dispose();
    _msmeReasonController.dispose();
    _ficReasonController.dispose();
    super.dispose();
  }

  void _submitRoleApplication(String role) {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$role application is ready to submit.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final session = authState.session;
    final bool useSidebar = MediaQuery.sizeOf(context).width >= 980;

    if (!useSidebar) {
      return _ConsumerMobilePortal(
        currentView: _currentView,
        userName: session?.user.name ?? 'Consumer',
        searchController: _searchController,
        onViewChanged: (view) => setState(() => _currentView = view),
        authBusy: authState.isBusy,
        onLogout: authState.isBusy
            ? null
            : () => ref.read(authControllerProvider.notifier).logout(),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Row(
          children: <Widget>[
            _ConsumerSidebar(
              currentView: _currentView,
              onViewChanged: (view) => setState(() => _currentView = view),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  _ConsumerTopBar(
                    searchController: _searchController,
                    showMobileBrand: !useSidebar,
                  ),
                  Expanded(
                    child: _ConsumerContent(
                      currentView: _currentView,
                      userName: session?.user.name ?? 'Consumer',
                      email: session?.user.email ?? '',
                      organization: session?.user.organization,
                      msmeReasonController: _msmeReasonController,
                      ficReasonController: _ficReasonController,
                      onViewChanged: (view) =>
                          setState(() => _currentView = view),
                      onSubmitApplication: _submitRoleApplication,
                      authBusy: authState.isBusy,
                      onLogout: () =>
                          ref.read(authControllerProvider.notifier).logout(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
