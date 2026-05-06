part of 'msme_workspace_page.dart';

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
                label: 'History',
                selected: currentTabIndex == 3,
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
                icon: Icons.settings_outlined,
                label: 'Settings',
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

