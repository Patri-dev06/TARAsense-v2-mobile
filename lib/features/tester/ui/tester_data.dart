part of 'tester_workspace_page.dart';

class _ConsumerStat {
  const _ConsumerStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.subtitle,
    required this.tint,
    required this.iconColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final String subtitle;
  final Color tint;
  final Color iconColor;
}

class _ConsumerSurvey {
  const _ConsumerSurvey({
    required this.title,
    required this.owner,
    required this.category,
    required this.stage,
    required this.status,
    required this.session,
    required this.selected,
    required this.capacity,
    this.showSessionPicker = false,
  });

  final String title;
  final String owner;
  final String category;
  final String stage;
  final String status;
  final String session;
  final int selected;
  final int capacity;
  final bool showSessionPicker;
}

const List<_ConsumerSurvey> _availableSurveys = <_ConsumerSurvey>[
  _ConsumerSurvey(
    title: 'InnovBars - Consumer Test',
    owner: 'InnovBars',
    category: 'BAKERY',
    stage: 'PROTOTYPE_CHECK',
    status: 'RECRUITING',
    session: 'Tue, Apr 21 | Auto timestamp session | 1:20 PM - 11:59 PM',
    selected: 0,
    capacity: 30,
    showSessionPicker: true,
  ),
  _ConsumerSurvey(
    title: 'Product Intent Study',
    owner: 'PRODUCT INTENT',
    category: 'FUNCTIONAL_FOOD',
    stage: 'MARKET_READINESS',
    status: 'RECRUITING',
    session: 'Wed, Apr 22 | Product feedback session | 9:00 AM - 4:00 PM',
    selected: 8,
    capacity: 30,
  ),
  _ConsumerSurvey(
    title: 'Snack Preference Survey',
    owner: 'Caraga Food Innovation Lab',
    category: 'SNACKS',
    stage: 'SENSORY_CHECK',
    status: 'RECRUITING',
    session: 'Thu, Apr 23 | Preference test | 10:00 AM - 3:00 PM',
    selected: 12,
    capacity: 30,
  ),
];

class _ConsumerApplication {
  const _ConsumerApplication({
    required this.title,
    required this.owner,
    required this.schedule,
    required this.status,
    required this.note,
  });

  final String title;
  final String owner;
  final String schedule;
  final String status;
  final String note;

  bool get isConfirmed => status.toUpperCase() == 'CONFIRMED';

  bool get isPending => status.toUpperCase() == 'PENDING';
}

const List<_ConsumerApplication> _consumerApplications =
    <_ConsumerApplication>[
      _ConsumerApplication(
        title: 'Coconut Vinegar Taste Test',
        owner: 'Caraga Food Innovation Lab',
        schedule: 'May 12, 10:00 AM',
        status: 'Confirmed',
        note: 'Please arrive 10 minutes before the session.',
      ),
      _ConsumerApplication(
        title: 'Bagoong Flavor Panel',
        owner: 'InnovBars',
        schedule: 'Awaiting schedule confirmation',
        status: 'Pending',
        note: 'You will receive a follow-up once slots are finalized.',
      ),
      _ConsumerApplication(
        title: 'Dried Mango Texture Evaluation',
        owner: 'Davao FIC Station',
        schedule: 'May 18, 2:00 PM',
        status: 'Accepted',
        note: 'Session details are ready for final confirmation.',
      ),
    ];

String _consumerInitials(String value) {
  final List<String> parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((String part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) {
    return 'AS';
  }
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
      .toUpperCase();
}
