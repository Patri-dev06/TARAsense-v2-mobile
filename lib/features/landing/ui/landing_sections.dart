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

class _FicStrip extends StatefulWidget {
  const _FicStrip();

  static const List<String> centers = <String>[
    'Department of\nScience and\nTechnology -\nRegion XIII',
    'FIC CSU Main\nCampus',
    'FIC CSU\nCabadbaran\nCampus',
    'FICSNSU del\nCarmen\nCampus',
    'FIC NEMSU\nCantilan\nCampus',
  ];

  @override
  State<_FicStrip> createState() => _FicStripState();
}

class _FicStripState extends State<_FicStrip> {
  static const Duration _spinInterval = Duration(seconds: 3);

  Timer? _timer;
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_spinInterval, (_) => _showNext());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showNext() {
    if (!mounted) {
      return;
    }
    setState(() {
      _activeIndex = (_activeIndex + 1) % _FicStrip.centers.length;
    });
  }

  void _jumpTo(int index) {
    setState(() {
      _activeIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _SoftPanel(
      padding: const EdgeInsets.fromLTRB(32, 22, 32, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'FOOD INNOVATION CENTERS',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF606B82),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final int visibleCount = constraints.maxWidth < 560
                  ? 1
                  : constraints.maxWidth < 900
                      ? 2
                      : 4;
              const double gap = 14;
              final double cardWidth = (constraints.maxWidth - (gap * (visibleCount - 1))) / visibleCount;

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 420),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final Animation<Offset> offset = Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: offset, child: child),
                  );
                },
                child: Row(
                  key: ValueKey<int>(_activeIndex),
                  children: List<Widget>.generate(visibleCount, (position) {
                    final int centerIndex = (_activeIndex + position) % _FicStrip.centers.length;
                    final bool isLast = position == visibleCount - 1;
                    return Padding(
                      padding: EdgeInsets.only(right: isLast ? 0 : gap),
                      child: SizedBox(
                        width: cardWidth,
                        child: _FicCenterCard(
                          label: _FicStrip.centers[centerIndex],
                          faded: centerIndex == 0,
                          highlighted: position == 0,
                        ),
                      ),
                    );
                  }),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List<Widget>.generate(_FicStrip.centers.length, (index) {
                final bool selected = index == _activeIndex;
                return GestureDetector(
                  onTap: () => _jumpTo(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 6,
                    width: selected ? 22 : 7,
                    decoration: BoxDecoration(
                      color: selected ? TaraTheme.primary : const Color(0xFFD7DEEA),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _FicCenterCard extends StatelessWidget {
  const _FicCenterCard({
    required this.label,
    this.faded = false,
    this.highlighted = false,
  });

  final String label;
  final bool faded;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      height: 98,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFFFF7F2) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: highlighted ? const Color(0xFFFFB282) : TaraTheme.border),
        boxShadow: highlighted
            ? const <BoxShadow>[
                BoxShadow(
                  color: Color(0x1AFF6B1A),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Row(
        children: <Widget>[
          if (!faded) ...<Widget>[
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: TaraTheme.primaryTint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.account_balance_rounded, color: TaraTheme.primaryDark),
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: faded ? const Color(0x331C2030) : const Color(0xFF252938),
                fontSize: 13,
                fontWeight: FontWeight.w900,
                height: 1.22,
              ),
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool stack = constraints.maxWidth < 920;
        final double titleSize = constraints.maxWidth < 520
            ? 36
            : constraints.maxWidth < 760
                ? 42
                : 48;
        final Widget copy = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const _Eyebrow('ENTERPRISE MEMORY'),
            const SizedBox(height: 18),
            Text(
              'Turn every project into\nreusable intelligence for\nthe next launch.',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFF1C2030),
                    fontSize: titleSize,
                    height: 1.02,
                    letterSpacing: 0,
                  ),
            ),
            const SizedBox(height: 24),
            Text(
              'Store winning messages, rejected concepts, and emerging demand signals in a system that keeps strategy teams aligned across markets, regions, and product lines.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF606B82),
                    fontSize: 18,
                    height: 1.75,
                  ),
            ),
            const SizedBox(height: 28),
            const _BulletLine(text: 'Insight archives'),
            const SizedBox(height: 14),
            const _BulletLine(text: 'Governed templates'),
            const SizedBox(height: 14),
            const _BulletLine(text: 'Cross-market learnings'),
            const SizedBox(height: 28),
            OutlinedButton.icon(
              onPressed: () {},
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.arrow_forward_rounded),
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
        const Widget visual = _InsightDashboardVisual();
        if (stack) {
          return Column(children: <Widget>[copy, const SizedBox(height: 30), visual]);
        }
        return Row(
          children: <Widget>[
            Expanded(child: copy),
            const SizedBox(width: 76),
            const Expanded(child: visual),
          ],
        );
      },
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

