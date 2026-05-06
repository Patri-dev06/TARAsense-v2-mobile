part of 'landing_page.dart';

class _LandingNav extends StatelessWidget {
  const _LandingNav({required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: TaraTheme.border)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool compact = constraints.maxWidth < 980;
          if (compact) {
            return Stack(
              alignment: Alignment.center,
              children: <Widget>[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: _DostNavMark(),
                ),
                const _TextBrand(),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onSignIn,
                    child: const Text('Sign in'),
                  ),
                ),
              ],
            );
          }

          return Row(
            children: <Widget>[
              const SizedBox(width: 120, child: _DostNavMark()),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    _NavTextButton(
                      label: 'Resources',
                      icon: Icons.keyboard_arrow_down_rounded,
                    ),
                    SizedBox(width: 34),
                    _NavTextButton(label: 'Customers'),
                    SizedBox(width: 34),
                    _NavTextButton(label: 'Company'),
                    SizedBox(width: 78),
                    _TextBrand(),
                  ],
                ),
              ),
              SizedBox(
                width: 120,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onSignIn,
                    child: const Text('Sign in'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DostNavMark extends StatelessWidget {
  const _DostNavMark();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        DostLogoMark(size: 40),
        SizedBox(height: 2),
        Text(
          'DOST',
          style: TextStyle(
            color: Colors.black,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _NavTextButton extends StatelessWidget {
  const _NavTextButton({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            color: TaraTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (icon != null) ...<Widget>[
          const SizedBox(width: 6),
          Icon(icon, size: 18, color: TaraTheme.textSecondary),
        ],
      ],
    );
  }
}

class _TextBrand extends StatelessWidget {
  const _TextBrand();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'TARA',
          style: TextStyle(
            color: Color(0xFF2452FF),
            fontSize: 20,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        Text(
          'sense',
          style: TextStyle(
            color: TaraTheme.primary,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _PageShell extends StatelessWidget {
  const _PageShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1220),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double width = MediaQuery.sizeOf(context).width;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: width < 720 ? 18 : 24),
              child: child,
            );
          },
        ),
      ),
    );
  }
}

