part of 'landing_page.dart';

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.onGetStarted});

  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 62),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool stack = constraints.maxWidth < 860;
          final Widget copy = _HeroCopy(onGetStarted: onGetStarted);
          const Widget visual = _HeroLabVisual();
          if (stack) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                copy,
                const SizedBox(height: 34),
                visual,
              ],
            );
          }
          return Row(
            children: <Widget>[
              Expanded(child: copy),
              const SizedBox(width: 70),
              const Expanded(child: visual),
            ],
          );
        },
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.onGetStarted});

  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double titleSize = screenWidth < 420
        ? 44
        : screenWidth < 760
            ? 56
            : 72;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _Eyebrow('ENTERPRISE MARKET INTELLIGENCE'),
        const SizedBox(height: 18),
        Text(
          'Test. Analyze.\nRefine.\nAdvance.',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: const Color(0xFF1C2030),
                fontSize: titleSize,
                height: 0.98,
                letterSpacing: 0,
              ),
        ),
        const SizedBox(height: 30),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 570),
          child: Text(
            'Sensory and consumer driven food innovation platform that connects MSMEs, Consumer and Government support networks in one smart digital platform.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF606B82),
                  fontSize: 18,
                  height: 1.8,
                ),
          ),
        ),
        const SizedBox(height: 40),
        FilledButton.icon(
          onPressed: onGetStarted,
          iconAlignment: IconAlignment.end,
          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          label: const Text('Get Started'),
          style: FilledButton.styleFrom(
            backgroundColor: TaraTheme.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(172, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          ),
        ),
      ],
    );
  }
}

class _FicPartner {
  const _FicPartner({
    required this.shortName,
    required this.description,
    required this.asset,
  });

  final String shortName;
  final String description;
  final String asset;
}

class _FicStrip extends StatefulWidget {
  const _FicStrip();

  static const List<_FicPartner> partners = <_FicPartner>[
    _FicPartner(
      shortName: 'DOST-XIII',
      description: 'Dept. of Science & Technology – Region XIII',
      asset: 'assets/images/dost-logo.png',
    ),
    _FicPartner(
      shortName: 'CSU Main',
      description: 'Caraga State University – Main Campus',
      asset: 'assets/images/CSU-MAIN.png',
    ),
    _FicPartner(
      shortName: 'CSU Cabadbaran',
      description: 'Caraga State University – Cabadbaran',
      asset: 'assets/images/CSU-CBR.png',
    ),
    _FicPartner(
      shortName: 'SNSU',
      description: 'Surigao del Norte State University',
      asset: 'assets/images/SNSU.png',
    ),
    _FicPartner(
      shortName: 'NEMSU',
      description: 'N.E. Mindanao State University',
      asset: 'assets/images/NEMSU.png',
    ),
    _FicPartner(
      shortName: 'ADSSU',
      description: 'Agusan del Sur State University',
      asset: 'assets/images/ADSSU.png',
    ),
  ];

  @override
  State<_FicStrip> createState() => _FicStripState();
}

class _FicStripState extends State<_FicStrip> {
  static const int _kLoopCount = 10000;

  late final PageController _pageController;
  int _activeIndex = 0;
  Timer? _timer;

  int get _initialPage => _FicStrip.partners.length * (_kLoopCount ~/ 2);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.82,
      initialPage: _initialPage,
    );
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _advance());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _advance() {
    if (!mounted) return;
    _pageController.nextPage(
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOutCubic,
    );
  }

  void _jumpToLogical(int logicalIndex) {
    if (!mounted) return;
    final int count = _FicStrip.partners.length;
    final int currentPage = _pageController.page?.round() ?? _initialPage;
    final int delta = (logicalIndex - _activeIndex + count) % count;
    _pageController.animateToPage(
      currentPage + delta,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'FOOD INNOVATION CENTER PARTNERS',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(0xFF606B82),
            fontWeight: FontWeight.w800,
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Powered by DOST-XIII and its network of Food Innovation Centers across the Caraga region.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF9AA0B2),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth >= 720) {
              return _FicLogoRow(partners: _FicStrip.partners);
            }
            final int count = _FicStrip.partners.length;
            return Column(
              children: <Widget>[
                SizedBox(
                  height: 162,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: count * _kLoopCount,
                    onPageChanged: (int i) =>
                        setState(() => _activeIndex = i % count),
                    itemBuilder: (BuildContext context, int index) {
                      final int logical = index % count;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: _PartnerLogoCard(
                          partner: _FicStrip.partners[logical],
                          highlighted: logical == _activeIndex,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(
                    count,
                    (int i) {
                      final bool sel = i == _activeIndex;
                      return GestureDetector(
                        onTap: () => _jumpToLogical(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 6,
                          width: sel ? 22 : 7,
                          decoration: BoxDecoration(
                            color: sel ? TaraTheme.primary : const Color(0xFFD7DEEA),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _FicLogoRow extends StatelessWidget {
  const _FicLogoRow({required this.partners});

  final List<_FicPartner> partners;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: partners.asMap().entries.map((MapEntry<int, _FicPartner> e) {
        final bool isLast = e.key == partners.length - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 12),
            child: _PartnerLogoCard(partner: e.value),
          ),
        );
      }).toList(),
    );
  }
}

class _PartnerLogoCard extends StatelessWidget {
  const _PartnerLogoCard({
    required this.partner,
    this.highlighted = false,
  });

  final _FicPartner partner;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFFFF7F2) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: highlighted ? const Color(0xFFFFB282) : const Color(0xFFE4EAF5),
          width: highlighted ? 1.5 : 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: highlighted
                ? const Color(0x18FF6B1A)
                : const Color(0x0C1A2440),
            blurRadius: highlighted ? 22 : 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 62,
            width: 62,
            child: Image.asset(
              partner.asset,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stack) => Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_rounded,
                  color: Color(0xFFCCD2E0),
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            partner.shortName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF252938),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            partner.description,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF9AA0B2),
              fontSize: 9.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaFeatureSection extends StatelessWidget {
  const _MediaFeatureSection({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.bullets,
    required this.buttonLabel,
    required this.visual,
    this.reverse = false,
  });

  final String eyebrow;
  final String title;
  final String body;
  final List<String> bullets;
  final String buttonLabel;
  final Widget visual;
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool stack = constraints.maxWidth < 860;
        final Widget copy = _FeatureCopy(
          eyebrow: eyebrow,
          title: title,
          body: body,
          bullets: bullets,
          buttonLabel: buttonLabel,
        );
        if (stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[copy, const SizedBox(height: 28), visual],
          );
        }
        return Row(
          children: reverse
              ? <Widget>[
                  Expanded(child: visual),
                  const SizedBox(width: 66),
                  Expanded(child: copy),
                ]
              : <Widget>[
                  Expanded(child: copy),
                  const SizedBox(width: 66),
                  Expanded(child: visual),
                ],
        );
      },
    );
  }
}

class _FeatureCopy extends StatelessWidget {
  const _FeatureCopy({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.bullets,
    required this.buttonLabel,
  });

  final String eyebrow;
  final String title;
  final String body;
  final List<String> bullets;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double titleSize = screenWidth < 420
        ? 36
        : screenWidth < 760
            ? 42
            : 48;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _Eyebrow(eyebrow),
        const SizedBox(height: 18),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: const Color(0xFF1C2030),
                fontSize: titleSize,
                letterSpacing: 0,
              ),
        ),
        const SizedBox(height: 22),
        Text(
          body,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF606B82),
                fontSize: 18,
                height: 1.8,
              ),
        ),
        const SizedBox(height: 30),
        ...bullets.map(
          (bullet) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _BulletLine(text: bullet),
          ),
        ),
        const SizedBox(height: 22),
        OutlinedButton.icon(
          onPressed: () {},
          iconAlignment: IconAlignment.end,
          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          label: Text(buttonLabel),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: TaraTheme.textPrimary,
            side: const BorderSide(color: TaraTheme.border),
            minimumSize: const Size(250, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          ),
        ),
      ],
    );
  }
}

class _MemorySection extends StatelessWidget {
  const _MemorySection();

  static const List<_MemoryFeatureDatum> _features = <_MemoryFeatureDatum>[
    _MemoryFeatureDatum(
      icon: Icons.archive_outlined,
      title: 'Insight archives',
      body: 'Every study, every signal, organized and searchable across your team.',
    ),
    _MemoryFeatureDatum(
      icon: Icons.rule_folder_outlined,
      title: 'Governed templates',
      body: 'Standards that keep global teams aligned, consistent, and compliant.',
    ),
    _MemoryFeatureDatum(
      icon: Icons.public_rounded,
      title: 'Cross-market learnings',
      body: 'Surface patterns across campaigns, regions, and time automatically.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final double titleSize = width < 420 ? 34 : width < 760 ? 42 : 52;

    return Column(
      children: <Widget>[
        _Eyebrow('ENTERPRISE MEMORY'),
        const SizedBox(height: 18),
        Text(
          'Turn every project into\nreusable intelligence.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF1C2030),
            fontSize: titleSize,
            fontWeight: FontWeight.w800,
            height: 1.02,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            'Store winning messages, rejected concepts, and demand signals in a system that keeps strategy teams aligned across markets, regions, and product lines.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF606B82),
              fontSize: 17,
              height: 1.75,
            ),
          ),
        ),
        const SizedBox(height: 48),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool stack = constraints.maxWidth < 720;
            if (stack) {
              return Column(
                children: _features
                    .map(
                      (_MemoryFeatureDatum f) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _MemoryFeatureCard(datum: f),
                      ),
                    )
                    .toList(),
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _features.asMap().entries.map((MapEntry<int, _MemoryFeatureDatum> e) {
                final bool isLast = e.key == _features.length - 1;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: isLast ? 0 : 16),
                    child: _MemoryFeatureCard(datum: e.value),
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 40),
        OutlinedButton.icon(
          onPressed: () {},
          iconAlignment: IconAlignment.end,
          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          label: const Text('See knowledge flows'),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: TaraTheme.textPrimary,
            side: const BorderSide(color: TaraTheme.border),
            minimumSize: const Size(240, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          ),
        ),
      ],
    );
  }
}

class _MemoryFeatureDatum {
  const _MemoryFeatureDatum({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

class _MemoryFeatureCard extends StatelessWidget {
  const _MemoryFeatureCard({required this.datum});

  final _MemoryFeatureDatum datum;

  @override
  Widget build(BuildContext context) {
    return _SoftPanel(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE9EDFF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(datum.icon, color: const Color(0xFF2452FF), size: 20),
          ),
          const SizedBox(height: 18),
          Text(
            datum.title,
            style: const TextStyle(
              color: Color(0xFF1C2030),
              fontWeight: FontWeight.w800,
              fontSize: 17,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            datum.body,
            style: const TextStyle(
              color: Color(0xFF606B82),
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlatformSection extends StatelessWidget {
  const _PlatformSection();

  static const List<_PlatformCardData> cards = <_PlatformCardData>[
    _PlatformCardData(Icons.auto_awesome_outlined, 'Executive-ready narratives', 'Summaries are structured for decisions, not dashboards full of noise.'),
    _PlatformCardData(Icons.hub_outlined, 'Continuous validation', 'Keep the consumer in the loop from idea framing to post-launch refinement.'),
    _PlatformCardData(Icons.insert_chart_outlined_rounded, 'High-signal benchmarking', 'Compare markets, campaigns, and concepts with consistent enterprise scoring.'),
    _PlatformCardData(Icons.psychology_alt_outlined, 'AI that guides action', 'Get sharp next-step recommendations built directly into every workspace.'),
    _PlatformCardData(Icons.security_outlined, 'Governance by design', 'Permissions, templates, and evidence trails keep global teams aligned and secure.'),
    _PlatformCardData(Icons.chat_outlined, 'Human-centered collaboration', 'Share clips, comments, and customer truths without losing the story behind the data.'),
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double titleSize = screenWidth < 420
        ? 34
        : screenWidth < 760
            ? 42
            : 48;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _Eyebrow('WHY TEAMS CHOOSE TARASENSE'),
        const SizedBox(height: 18),
        Text(
          'A platform designed for\nenterprise confidence, not\ndashboard fatigue.',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: const Color(0xFF1C2030),
                fontSize: titleSize,
                height: 1.03,
                letterSpacing: 0,
              ),
        ),
        const SizedBox(height: 24),
        Text(
          'Every interaction is built to feel strategic, quick, and premium from first signal to final recommendation.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF606B82),
                fontSize: 18,
                height: 1.7,
              ),
        ),
        const SizedBox(height: 54),
        LayoutBuilder(
          builder: (context, constraints) {
            final int columns = constraints.maxWidth < 760
                ? 1
                : constraints.maxWidth < 1040
                    ? 2
                    : 3;
            final double width = (constraints.maxWidth - (22 * (columns - 1))) / columns;
            return Wrap(
              spacing: 22,
              runSpacing: 22,
              children: cards.map((card) => _PlatformCard(card: card, width: width)).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _PlatformCardData {
  const _PlatformCardData(this.icon, this.title, this.body);

  final IconData icon;
  final String title;
  final String body;
}

class _PlatformCard extends StatelessWidget {
  const _PlatformCard({required this.card, required this.width});

  final _PlatformCardData card;
  final double width;

  @override
  Widget build(BuildContext context) {
    return _SoftPanel(
      width: width,
      padding: const EdgeInsets.all(26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE9EDFF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(card.icon, color: const Color(0xFF2452FF)),
          ),
          const SizedBox(height: 30),
          Text(
            card.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF1C2030),
                  fontSize: 24,
                  letterSpacing: 0,
                ),
          ),
          const SizedBox(height: 18),
          Text(
            card.body,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF606B82),
                  height: 1.7,
                ),
          ),
          const SizedBox(height: 26),
          const Text(
            'Learn more  ->',
            style: TextStyle(
              color: Color(0xFF2452FF),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProofSection extends StatefulWidget {
  const _ProofSection();

  @override
  State<_ProofSection> createState() => _ProofSectionState();
}

class _ProofSectionState extends State<_ProofSection> {
  late final PageController _pageController;
  int _currentIndex = 0;

  static const List<_ProofFeedback> _feedback = <_ProofFeedback>[
    _ProofFeedback(
      title: 'Regional alignment',
      quote:
          '"The platform made insight feel operational. Regional teams could act locally while leadership still saw one coherent system."',
      person: 'Rachel Morgan',
      company: 'Global Brand Director - Vodafone',
      pill: '12 markets working from one source of truth',
      initial: 'R',
    ),
    _ProofFeedback(
      title: 'Launch confidence',
      quote:
          '"TARAsense gave our insights team the credibility of a strategy function. We now walk into launch reviews with proof, not just perspective."',
      person: 'Stephan Gans',
      company: 'PepsiCo',
      pill: '+30% creative effectiveness',
      initial: 'S',
    ),
    _ProofFeedback(
      title: 'Decision speed',
      quote:
          '"We replaced fragmented reporting with one connected view of demand, brand signal, and campaign readiness. Decision speed changed immediately."',
      person: 'Amanda Addison',
      company: 'McDonald\'s',
      pill: '4 weeks saved per campaign cycle',
      initial: 'A',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToFeedback(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double titleSize = constraints.maxWidth < 520
            ? 34
            : constraints.maxWidth < 760
                ? 42
                : 48;
        final double cardHeight = constraints.maxWidth < 520 ? 430 : 360;

        return _SoftPanel(
          padding: EdgeInsets.all(constraints.maxWidth < 600 ? 24 : 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const _Eyebrow('CUSTOMER PROOF'),
              const SizedBox(height: 18),
              Text(
                'Feedback from teams using TARAsense.',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF1C2030),
                      fontSize: titleSize,
                      height: 1.04,
                      letterSpacing: 0,
                    ),
              ),
              const SizedBox(height: 18),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Text(
                  'Each card captures a different customer signal, from regional alignment to faster launch decisions.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF606B82),
                        fontSize: 18,
                        height: 1.7,
                      ),
                ),
              ),
              const SizedBox(height: 34),
              SizedBox(
                height: cardHeight,
                child: PageView.builder(
                  controller: _pageController,
                  padEnds: false,
                  itemCount: _feedback.length,
                  onPageChanged: (int index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index == _feedback.length - 1 ? 0 : 18,
                      ),
                      child: _ProofFeedbackCard(feedback: _feedback[index]),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(_feedback.length, (index) {
                  final bool selected = index == _currentIndex;
                  return GestureDetector(
                    onTap: () => _goToFeedback(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 7,
                      width: selected ? 26 : 8,
                      decoration: BoxDecoration(
                        color: selected ? TaraTheme.primary : const Color(0xFFD7DEEA),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProofFeedback {
  const _ProofFeedback({
    required this.title,
    required this.quote,
    required this.person,
    required this.company,
    required this.pill,
    required this.initial,
  });

  final String title;
  final String quote;
  final String person;
  final String company;
  final String pill;
  final String initial;
}

class _ProofFeedbackCard extends StatelessWidget {
  const _ProofFeedbackCard({required this.feedback});

  final _ProofFeedback feedback;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double quoteSize = screenWidth < 520 ? 21 : 26;

    return Container(
      padding: EdgeInsets.all(screenWidth < 520 ? 22 : 30),
      decoration: BoxDecoration(
        color: const Color(0xFFFEFEFD),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: TaraTheme.border),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x101A2440),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            feedback.title.toUpperCase(),
            style: const TextStyle(
              color: TaraTheme.primary,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            fit: FlexFit.loose,
            child: Text(
              feedback.quote,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF1C2030),
                    fontSize: quoteSize,
                    height: 1.25,
                    letterSpacing: 0,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          _NeutralPill(feedback.pill),
          const Spacer(),
          const Divider(height: 26, color: TaraTheme.border),
          Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: const Color(0xFF2452FF),
                child: Text(
                  feedback.initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  '${feedback.person}\n${feedback.company}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: TaraTheme.textPrimary,
                    fontWeight: FontWeight.w900,
                    height: 1.45,
                  ),
                ),
              ),
              if (screenWidth >= 520) ...<Widget>[
                const SizedBox(width: 12),
                Container(
                  height: 34,
                  width: 34,
                  decoration: BoxDecoration(
                    color: TaraTheme.primaryTint,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Icon(
                    Icons.format_quote_rounded,
                    color: TaraTheme.primaryDark,
                    size: 18,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _CtaPanel extends StatelessWidget {
  const _CtaPanel({required this.onGetStarted});

  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double titleSize = screenWidth < 420
        ? 36
        : screenWidth < 760
            ? 46
            : 58;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth < 600 ? 28 : 56),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFFE9EDFF), Color(0xFFFFEEF2)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: TaraTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _Eyebrow('READY WHEN YOUR TEAM IS'),
          const SizedBox(height: 24),
          Text(
          'Build a sharper growth\nengine around what\ncustomers actually\nsignal.',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: const Color(0xFF1C2030),
                fontSize: titleSize,
                height: 1.02,
                letterSpacing: 0,
                ),
          ),
          const SizedBox(height: 30),
          FilledButton.icon(
            onPressed: onGetStarted,
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Get Started'),
            style: FilledButton.styleFrom(
              backgroundColor: TaraTheme.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(170, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
          ),
        ],
      ),
    );
  }
}

