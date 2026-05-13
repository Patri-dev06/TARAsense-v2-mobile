class FicStats {
  const FicStats({
    required this.bookingNotifications,
    required this.upcomingSessions,
    required this.pendingConfirmation,
    required this.uploadedStudies,
    required this.activeStudies,
    required this.totalResponses,
  });

  final int bookingNotifications;
  final int upcomingSessions;
  final int pendingConfirmation;
  final int uploadedStudies;
  final int activeStudies;
  final int totalResponses;

  factory FicStats.fromJson(Map<String, dynamic> json) {
    return FicStats(
      bookingNotifications: _firstPositiveInt(<int>[
        _firstInt(json, const <String>[
          'bookingNotifications',
          'bookingCount',
          'newBookings',
        ]),
      ]),
      upcomingSessions: _firstPositiveInt(<int>[
        _firstInt(json, const <String>[
          'upcomingSessions',
          'upcomingSessionCount',
          'confirmedSessions',
        ]),
      ]),
      pendingConfirmation: _firstPositiveInt(<int>[
        _firstInt(json, const <String>[
          'pendingConfirmation',
          'pendingCount',
          'awaitingConfirmation',
        ]),
      ]),
      uploadedStudies: _firstPositiveInt(<int>[
        _firstInt(json, const <String>[
          'uploadedStudies',
          'totalStudies',
          'studyCount',
        ]),
      ]),
      activeStudies: _firstPositiveInt(<int>[
        _firstInt(json, const <String>[
          'activeStudies',
          'liveStudies',
          'runningStudies',
        ]),
      ]),
      totalResponses: _firstPositiveInt(<int>[
        _firstInt(json, const <String>[
          'totalResponses',
          'responseCount',
          'responses',
        ]),
      ]),
    );
  }
}

class FicDashboardData {
  const FicDashboardData({
    required this.activeSessions,
    required this.nextTitle,
    required this.nextTime,
    required this.studies,
    required this.calendar,
    this.stats,
  });

  final int activeSessions;
  final String nextTitle;
  final String nextTime;
  final List<FicStudy> studies;
  final List<FicCalendarItem> calendar;
  final FicStats? stats;

  factory FicDashboardData.fromJson(dynamic value) {
    final Map<String, dynamic> json = _asMap(value);
    final List<FicStudy> studies = parseFicStudies(
      json['studies'] ??
          json['studyQueue'] ??
          json['queue'] ??
          json['activeStudies'],
    );
    final List<FicCalendarItem> calendar = parseFicCalendarItems(
      json['calendar'] ??
          json['events'] ??
          json['sessions'] ??
          json['todaySessions'],
    );
    final FicCalendarItem? nextCalendar = calendar.isEmpty
        ? null
        : calendar.first;
    final FicStudy? nextStudy = studies.isEmpty ? null : studies.first;

    final dynamic rawStats = json['stats'] ?? json['summary'] ?? json;
    final FicStats stats = FicStats.fromJson(_asMap(rawStats));

    return FicDashboardData(
      activeSessions: _firstPositiveInt(<int>[
        _firstInt(json, const <String>[
          'activeSessions',
          'activeSessionCount',
          'todaySessions',
          'todaySessionCount',
          'sessionCount',
          'liveCount',
        ]),
        calendar.where((FicCalendarItem item) => item.isToday).length,
      ]),
      nextTitle: _firstNonEmptyString(<String>[
        _firstString(json, const <String>[
          'nextTitle',
          'nextSessionTitle',
          'nextStudyTitle',
        ]),
        nextCalendar?.title ?? '',
        nextStudy?.title ?? '',
      ]),
      nextTime: _firstNonEmptyString(<String>[
        _firstString(json, const <String>[
          'nextTime',
          'nextSessionTime',
          'nextStartsAt',
        ]),
        nextCalendar?.timeLabel ?? '',
        nextStudy?.timeLabel ?? '',
      ]),
      studies: studies,
      calendar: calendar,
      stats: stats,
    );
  }
}

class FicStudy {
  const FicStudy({
    required this.id,
    required this.title,
    required this.productName,
    required this.ownerName,
    required this.category,
    required this.status,
    required this.location,
    required this.participantCount,
    required this.targetCount,
    required this.responseCount,
    this.startsAt,
    this.endsAt,
  });

  final String id;
  final String title;
  final String productName;
  final String ownerName;
  final String category;
  final String status;
  final String location;
  final int participantCount;
  final int targetCount;
  final int responseCount;
  final DateTime? startsAt;
  final DateTime? endsAt;

  String get progressLabel {
    if (targetCount > 0) {
      return '$participantCount/$targetCount participants';
    }
    if (participantCount > 0) {
      return '$participantCount participants';
    }
    return 'Participants pending';
  }

  String get scheduleLabel {
    final String date = _formatDate(startsAt);
    final String time = timeLabel;
    if (date.isNotEmpty && time.isNotEmpty) {
      return '$date - $time';
    }
    return date.isNotEmpty ? date : 'Schedule pending';
  }

  String get timeLabel {
    final String start = _formatTime(startsAt);
    final String end = _formatTime(endsAt);
    if (start.isNotEmpty && end.isNotEmpty) {
      return '$start - $end';
    }
    return start;
  }

  factory FicStudy.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> slot = _firstSessionSlot(json);
    final Map<String, dynamic> owner = _asMap(
      json['owner'] ??
          json['msme'] ??
          json['createdBy'] ??
          json['organization'],
    );
    final String productName = _firstString(json, const <String>[
      'productName',
      'product',
    ]);
    return FicStudy(
      id: _firstString(json, const <String>['id', 'studyId', '_id']),
      title: _firstNonEmptyString(<String>[
        _firstString(json, const <String>['title', 'studyTitle', 'name']),
        productName.isEmpty ? '' : '$productName - Consumer Test',
        'Untitled study',
      ]),
      productName: productName,
      ownerName: _firstNonEmptyString(<String>[
        _firstString(json, const <String>[
          'ownerName',
          'msmeName',
          'businessName',
          'organizationName',
          'uploadedBy',
        ]),
        _firstString(owner, const <String>[
          'name',
          'businessName',
          'organization',
          'email',
        ]),
        'MSME user',
      ]),
      category: _firstNonEmptyString(<String>[
        _firstString(json, const <String>[
          'category',
          'productCategory',
          'categoryCode',
          'categoryLabel',
        ]),
        'Consumer Test',
      ]),
      status: _firstNonEmptyString(<String>[
        _firstString(json, const <String>['status', 'state', 'phase']),
        'UPCOMING',
      ]),
      location: _firstNonEmptyString(<String>[
        _firstString(json, const <String>[
          'location',
          'venue',
          'facility',
          'ficName',
          'station',
        ]),
        _firstString(slot, const <String>['location', 'venue', 'facility']),
        'FIC station',
      ]),
      participantCount: _firstPositiveInt(<int>[
        _firstInt(json, const <String>[
          'participantCount',
          'reservedCount',
          'registeredCount',
        ]),
        _firstInt(slot, const <String>['reservedCount', 'participantCount']),
      ]),
      responseCount: _firstInt(json, const <String>[
        'responseCount',
        'responses',
        'submittedCount',
        'completedCount',
      ]),
      targetCount: _firstPositiveInt(<int>[
        _firstInt(json, const <String>[
          'sampleSize',
          'targetParticipants',
          'targetResponses',
          'capacity',
        ]),
        _firstInt(slot, const <String>['capacity']),
      ]),
      startsAt:
          _firstDateTime(json, const <String>[
            'startsAt',
            'startAt',
            'startDateTime',
            'testingStartDate',
            'scheduledAt',
          ]) ??
          _firstDateTime(slot, const <String>[
            'startsAt',
            'startAt',
            'startDateTime',
            'scheduledAt',
          ]),
      endsAt:
          _firstDateTime(json, const <String>[
            'endsAt',
            'endAt',
            'endDateTime',
          ]) ??
          _firstDateTime(slot, const <String>[
            'endsAt',
            'endAt',
            'endDateTime',
          ]),
    );
  }
}

class FicCalendarItem {
  const FicCalendarItem({
    required this.id,
    required this.title,
    required this.status,
    this.startsAt,
    this.endsAt,
  });

  final String id;
  final String title;
  final String status;
  final DateTime? startsAt;
  final DateTime? endsAt;

  bool get isToday {
    final DateTime? start = startsAt?.toLocal();
    if (start == null) {
      return false;
    }
    final DateTime now = DateTime.now();
    return start.year == now.year &&
        start.month == now.month &&
        start.day == now.day;
  }

  String get detailLabel {
    final String date = _formatDate(startsAt);
    final String time = timeLabel;
    if (date.isNotEmpty && time.isNotEmpty) {
      return '$date - $time';
    }
    return date.isNotEmpty ? date : 'Schedule pending';
  }

  String get timeLabel {
    final String start = _formatTime(startsAt);
    final String end = _formatTime(endsAt);
    if (start.isNotEmpty && end.isNotEmpty) {
      return '$start - $end';
    }
    return start;
  }

  factory FicCalendarItem.fromJson(Map<String, dynamic> json) {
    return FicCalendarItem(
      id: _firstString(json, const <String>['id', 'studyId', '_id']),
      title: _firstNonEmptyString(<String>[
        _firstString(json, const <String>[
          'title',
          'studyTitle',
          'name',
          'productName',
        ]),
        'Scheduled study',
      ]),
      status: _firstNonEmptyString(<String>[
        _firstString(json, const <String>['status', 'state']),
        'SCHEDULED',
      ]),
      startsAt: _firstDateTime(json, const <String>[
        'startsAt',
        'startAt',
        'startDateTime',
        'scheduledAt',
        'date',
      ]),
      endsAt: _firstDateTime(json, const <String>[
        'endsAt',
        'endAt',
        'endDateTime',
      ]),
    );
  }
}

class FicAvailabilityDay {
  const FicAvailabilityDay({
    required this.date,
    required this.status,
    required this.available,
  });

  final DateTime date;
  final String status;
  final bool available;

  bool get booked {
    final String normalized = status.toUpperCase();
    return normalized.contains('BOOK') ||
        normalized.contains('RESERV') ||
        normalized.contains('UNAVAILABLE');
  }

  factory FicAvailabilityDay.fromJson(Map<String, dynamic> json) {
    final DateTime date =
        _firstDateTime(json, const <String>[
          'date',
          'day',
          'availabilityDate',
          'availability_date',
          'startsAt',
        ]) ??
        DateTime.now();
    final String status = _firstNonEmptyString(<String>[
      _firstString(json, const <String>['status', 'state', 'availability']),
      _asBool(json['available']) ? 'AVAILABLE' : '',
      'IDLE',
    ]);
    return FicAvailabilityDay(
      date: date,
      status: status,
      available:
          _asBool(json['available']) ||
          status.toUpperCase().contains('AVAILABLE'),
    );
  }
}

List<FicStudy> parseFicStudies(dynamic value) {
  return _listFrom(value, const <String>[
        'studies',
        'items',
        'data',
        'results',
        'queue',
      ])
      .whereType<Map>()
      .map((Map item) => FicStudy.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

List<FicCalendarItem> parseFicCalendarItems(dynamic value) {
  return _listFrom(value, const <String>[
        'calendar',
        'events',
        'sessions',
        'items',
        'data',
        'results',
      ])
      .whereType<Map>()
      .map(
        (Map item) => FicCalendarItem.fromJson(Map<String, dynamic>.from(item)),
      )
      .toList();
}

List<FicAvailabilityDay> parseFicAvailability(dynamic value) {
  return _listFrom(value, const <String>[
        'availability',
        'days',
        'items',
        'data',
        'results',
      ])
      .whereType<Map>()
      .map(
        (Map item) =>
            FicAvailabilityDay.fromJson(Map<String, dynamic>.from(item)),
      )
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));
}

List<dynamic> _listFrom(dynamic value, List<String> keys) {
  if (value is List) {
    return value;
  }
  final Map<String, dynamic> map = _asMap(value);
  for (final String key in keys) {
    final dynamic nested = map[key];
    if (nested is List) {
      return nested;
    }
    if (nested is Map) {
      final List<dynamic> nestedItems = _listFrom(nested, keys);
      if (nestedItems.isNotEmpty) {
        return nestedItems;
      }
    }
  }
  return <dynamic>[];
}

Map<String, dynamic> _firstSessionSlot(Map<String, dynamic> json) {
  final Map<String, dynamic> schedule = _asMap(
    json['sessionSchedule'] ?? json['session_schedule'],
  );
  final List<dynamic> slots = _listFrom(
    schedule.isEmpty ? json['slots'] : schedule['slots'],
    const <String>['slots', 'items', 'data'],
  );
  for (final dynamic slot in slots) {
    final Map<String, dynamic> map = _asMap(slot);
    if (map.isNotEmpty) {
      return map;
    }
  }
  return <String, dynamic>{};
}

String _firstString(Map<String, dynamic> json, List<String> keys) {
  for (final String key in keys) {
    final dynamic value = json[key];
    if (value == null || value is Map || value is List) {
      continue;
    }
    final String stringValue = value.toString().trim();
    if (stringValue.isNotEmpty && stringValue.toLowerCase() != 'null') {
      return stringValue;
    }
  }
  return '';
}

String _firstNonEmptyString(List<String> values) {
  for (final String value in values) {
    final String trimmed = value.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
  }
  return '';
}

int _firstInt(Map<String, dynamic> json, List<String> keys) {
  for (final String key in keys) {
    final int? value = _asIntOrNull(json[key]);
    if (value != null) {
      return value;
    }
  }
  return 0;
}

int _firstPositiveInt(List<int> values) {
  for (final int value in values) {
    if (value > 0) {
      return value;
    }
  }
  return 0;
}

DateTime? _firstDateTime(Map<String, dynamic> json, List<String> keys) {
  for (final String key in keys) {
    final DateTime? value = _asDateTime(json[key]);
    if (value != null) {
      return value;
    }
  }
  return null;
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}

int? _asIntOrNull(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '');
}

bool _asBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  final String normalized = value?.toString().trim().toLowerCase() ?? '';
  return normalized == 'true' || normalized == '1' || normalized == 'yes';
}

DateTime? _asDateTime(dynamic value) {
  final String raw = value?.toString().trim() ?? '';
  if (raw.isEmpty) {
    return null;
  }
  return DateTime.tryParse(raw);
}

String _formatDate(DateTime? value) {
  if (value == null) {
    return '';
  }
  final DateTime local = value.toLocal();
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
  return '${months[local.month - 1]} ${local.day}';
}

String _formatTime(DateTime? value) {
  if (value == null) {
    return '';
  }
  final DateTime local = value.toLocal();
  final int hour = local.hour == 0
      ? 12
      : local.hour > 12
      ? local.hour - 12
      : local.hour;
  final String minute = local.minute.toString().padLeft(2, '0');
  final String suffix = local.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $suffix';
}
