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
    <_ConsumerApplication>[];

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
