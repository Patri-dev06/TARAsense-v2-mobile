part of 'msme_workspace_page.dart';

class _MsmePortalNavBar extends StatelessWidget {
  const _MsmePortalNavBar({
    required this.currentTabIndex,
    required this.onDashboard,
    required this.onCreateStudy,
    required this.onHistory,
    required this.onEvaluate,
    required this.onProfile,
    required this.evaluateCount,
    required this.historyCount,
  });

  final int currentTabIndex;
  final VoidCallback onDashboard;
  final VoidCallback onCreateStudy;
  final VoidCallback onHistory;
  final VoidCallback onEvaluate;
  final VoidCallback onProfile;
  final int evaluateCount;
  final int historyCount;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: TaraTheme.surface,
        border: Border(top: BorderSide(color: TaraTheme.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _PortalNavItem(
                icon: Icons.dashboard_rounded,
                label: 'Dashboard',
                selected: currentTabIndex == 0,
                onTap: onDashboard,
              ),
              _PortalNavItem(
                icon: Icons.assignment_rounded,
                label: 'History',
                selected: currentTabIndex == 3,
                badge: historyCount,
                onTap: onHistory,
              ),
              _PortalNavItem(
                icon: Icons.add_circle_rounded,
                label: 'Create',
                selected: currentTabIndex == 1,
                onTap: onCreateStudy,
              ),
              _PortalNavItem(
                icon: Icons.compass_calibration_rounded,
                label: 'Evaluate',
                selected: currentTabIndex == 4,
                badge: evaluateCount,
                onTap: onEvaluate,
              ),
              _PortalNavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                selected: currentTabIndex == 2,
                onTap: onProfile,
              ),
            ],
          ),
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
    this.badge,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final Color color =
        selected ? TaraTheme.primary : TaraTheme.textSecondary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Icon(icon, color: color, size: 20),
                  if (badge != null && badge! > 0)
                    Positioned(
                      top: -5,
                      right: -8,
                      child: Container(
                        height: 14,
                        constraints: const BoxConstraints(minWidth: 14),
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: TaraTheme.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Center(
                          child: Text(
                            badge.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}
