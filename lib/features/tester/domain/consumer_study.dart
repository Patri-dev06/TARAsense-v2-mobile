class ConsumerStudy {
  const ConsumerStudy({
    required this.id,
    required this.title,
    required this.owner,
    required this.category,
    required this.stage,
    required this.status,
    required this.session,
    required this.selected,
    required this.capacity,
    required this.sampleCount,
    required this.sampleCodes,
    required this.attributes,
    required this.commentQuestions,
    required this.myParticipation,
    this.participantId = '',
  });

  final String id;
  final String title;
  final String owner;
  final String category;
  final String stage;
  final String status;
  final String session;
  final int selected;
  final int capacity;
  final int sampleCount;
  final List<String> sampleCodes;
  final List<ConsumerStudyAttribute> attributes;
  final List<String> commentQuestions;
  final ConsumerStudyParticipation? myParticipation;
  final String participantId;

  int get slotsLeft => (capacity - selected).clamp(0, 9999);

  bool matches(String query) {
    final String normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return true;
    }
    return title.toLowerCase().contains(normalized) ||
        owner.toLowerCase().contains(normalized) ||
        category.toLowerCase().contains(normalized) ||
        stage.toLowerCase().contains(normalized) ||
        status.toLowerCase().contains(normalized);
  }

  factory ConsumerStudy.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> ownerMap = _asMap(
      json['owner'] ??
          json['msme'] ??
          json['createdBy'] ??
          json['organization'],
    );
    final Map<String, dynamic> sessionMap = _scheduleMapFromStudy(json);
    final ConsumerStudyParticipation? participation =
        ConsumerStudyParticipation.fromJsonOrNull(
          json['myParticipation'] ??
              json['participation'] ??
              json['participant'] ??
              json['myParticipant'] ??
              json['consumerParticipant'],
        );
    final int remainingCount = _firstInt(sessionMap, const <String>[
      'remainingCount',
      'remaining_count',
      'slotsLeft',
      'slots_left',
      'availableCount',
      'available_count',
    ]);
    final int reservedCount = _firstInt(sessionMap, const <String>[
      'reservedCount',
      'reserved_count',
      'participantCount',
      'participant_count',
      'selectedCount',
      'selected_count',
    ]);
    final int slotCapacity = _firstInt(sessionMap, const <String>[
      'capacity',
      'slotCapacity',
      'slot_capacity',
    ]);

    final String productName = _firstString(json, const <String>[
      'productName',
      'product',
    ]);
    final String title = _firstNonEmptyString(<String>[
      _firstString(json, const <String>[
        'title',
        'studyTitle',
        'name',
        'projectTitle',
      ]),
      productName.isEmpty ? '' : '$productName - Consumer Test',
      'Untitled study',
    ]);

    return ConsumerStudy(
      id: _firstString(json, const <String>['id', 'studyId', '_id']),
      title: title,
      owner: _firstNonEmptyString(<String>[
        _firstString(json, const <String>[
          'ownerName',
          'msmeName',
          'businessName',
          'organizationName',
        ]),
        _firstString(ownerMap, const <String>[
          'name',
          'businessName',
          'organization',
          'email',
        ]),
        'TARAsense',
      ]),
      category: _firstNonEmptyString(<String>[
        _firstString(json, const <String>[
          'category',
          'productCategory',
          'categoryCode',
          'studyType',
        ]),
        '-',
      ]),
      stage: _firstNonEmptyString(<String>[
        _firstString(json, const <String>[
          'stage',
          'developmentStage',
          'consumerObjective',
          'sensoryStudyType',
        ]),
        '-',
      ]),
      status: _firstNonEmptyString(<String>[
        _firstString(json, const <String>['status', 'statusLabel']),
        'AVAILABLE',
      ]).toUpperCase(),
      session: _sessionLabel(json, sessionMap),
      selected: _firstPositiveInt(<int>[
        reservedCount,
        _firstInt(json, const <String>[
          'selected',
          'selectedCount',
          'participantCount',
          'registeredCount',
          'joinedCount',
          'responseCount',
        ]),
      ]),
      capacity: _firstPositiveInt(<int>[
        if (remainingCount > 0) reservedCount + remainingCount,
        slotCapacity,
        _firstInt(json, const <String>[
          'capacity',
          'sampleSize',
          'targetParticipants',
          'maxParticipants',
          'targetResponses',
        ]),
      ]),
      sampleCount: _sampleCount(json),
      sampleCodes: _sampleCodes(json),
      attributes: parseConsumerStudyAttributes(
        json['attributes'] ?? json['sensoryAttributes'] ?? json['questions'],
      ),
      commentQuestions: _openEndedQuestions(
        json['attributes'] ?? json['sensoryAttributes'] ?? json['questions'],
      ),
      myParticipation: participation,
      participantId: _firstNonEmptyString(<String>[
        _firstString(json, const <String>[
          'participantId',
          'participationId',
          'consumerParticipantId',
          'panelistId',
        ]),
        participation?.id ?? '',
      ]),
    );
  }
}

class ConsumerStudyParticipation {
  const ConsumerStudyParticipation({
    required this.id,
    required this.status,
    required this.panelistNumber,
    this.completedAt,
    this.submittedAt,
    this.responseId,
  });

  final String id;
  final String status;
  final int panelistNumber;
  final DateTime? completedAt;
  final DateTime? submittedAt;
  final String? responseId;

  factory ConsumerStudyParticipation.fromJson(Map<String, dynamic> json) {
    return ConsumerStudyParticipation(
      id: _firstString(json, const <String>['id', 'participantId']),
      status: _firstString(json, const <String>['status']),
      panelistNumber: _firstInt(json, const <String>['panelistNumber']),
      completedAt: _asDateTime(json['completedAt']),
      submittedAt: _asDateTime(json['submittedAt']),
      responseId: _firstString(json, const <String>['responseId']),
    );
  }

  static ConsumerStudyParticipation? fromJsonOrNull(dynamic value) {
    final Map<String, dynamic> map = _asMap(value);
    if (map.isEmpty) {
      return null;
    }
    return ConsumerStudyParticipation.fromJson(map);
  }
}

class ConsumerStudyResponseSubmission {
  const ConsumerStudyResponseSubmission({
    required this.success,
    required this.alreadySubmitted,
    required this.participantStatus,
    this.participantId,
    this.responseId,
  });

  final bool success;
  final bool alreadySubmitted;
  final String? participantId;
  final String participantStatus;
  final String? responseId;

  factory ConsumerStudyResponseSubmission.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> participant = _asMap(json['participant']);
    return ConsumerStudyResponseSubmission(
      success: _asBool(json['success']),
      alreadySubmitted: _asBool(json['alreadySubmitted']),
      participantId: _firstString(participant, const <String>['id']),
      participantStatus: _firstNonEmptyString(<String>[
        _firstString(participant, const <String>['status']),
        _firstString(json, const <String>['participantStatus', 'status']),
      ]),
      responseId: _firstString(json, const <String>['responseId', 'id']),
    );
  }
}

class ConsumerStudyAttribute {
  const ConsumerStudyAttribute({
    required this.name,
    required this.type,
    this.jarOptions = const <String>[],
  });

  final String name;
  final String type;
  final List<String> jarOptions;

  bool get isJar => type.toUpperCase().contains('JAR');

  bool get isOverallLiking =>
      name.toUpperCase().contains('OVERALL') ||
      type.toUpperCase().contains('OVERALL');

  bool get isOpenEnded => type.toUpperCase().contains('OPEN');

  factory ConsumerStudyAttribute.fromJson(Map<String, dynamic> json) {
    return ConsumerStudyAttribute(
      name: _firstNonEmptyString(<String>[
        _firstString(json, const <String>[
          'name',
          'label',
          'attributeName',
          'question',
          'questionText',
        ]),
        'Overall Liking',
      ]),
      type: _firstNonEmptyString(<String>[
        _firstString(json, const <String>[
          'type',
          'questionType',
          'attributeType',
          'scaleType',
        ]),
        'ATTRIBUTE_LIKING',
      ]),
      jarOptions: _parseStringList(json['jarOptions'] ?? json['options']),
    );
  }
}

List<ConsumerStudy> parseConsumerStudies(dynamic value) {
  final List<dynamic> rawStudies = _studyListFrom(value);
  return rawStudies
      .whereType<Map>()
      .map(
        (Map item) => ConsumerStudy.fromJson(Map<String, dynamic>.from(item)),
      )
      .toList();
}

ConsumerStudy parseConsumerStudy(dynamic value) {
  final Map<String, dynamic> map = _singleStudyMapFrom(value);
  if (map.isEmpty) {
    throw const FormatException('Expected a study object from the API.');
  }
  return ConsumerStudy.fromJson(map);
}

Map<String, dynamic> _singleStudyMapFrom(dynamic value) {
  final Map<String, dynamic> map = _asMap(value);
  if (map.isEmpty) {
    return <String, dynamic>{};
  }
  for (final String key in const <String>['study', 'data', 'item', 'result']) {
    final Map<String, dynamic> nested = _asMap(map[key]);
    if (nested.isEmpty) {
      continue;
    }
    final Map<String, dynamic> nestedStudy = _singleStudyMapFrom(nested);
    final Map<String, dynamic> studyMap = nestedStudy.isEmpty
        ? nested
        : nestedStudy;
    final Map<String, dynamic> parent = Map<String, dynamic>.from(map)
      ..remove(key);
    return <String, dynamic>{
      ...parent,
      ...studyMap,
      if (parent['participant'] != null && studyMap['myParticipation'] == null)
        'myParticipation': parent['participant'],
      if (parent['participation'] != null &&
          studyMap['myParticipation'] == null)
        'myParticipation': parent['participation'],
    };
  }
  return map;
}

List<ConsumerStudyAttribute> parseConsumerStudyAttributes(dynamic value) {
  final List<ConsumerStudyAttribute> attributes =
      (value as List<dynamic>? ?? <dynamic>[])
          .whereType<Map>()
          .map(
            (Map item) => ConsumerStudyAttribute.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .where((ConsumerStudyAttribute attribute) => !attribute.isOpenEnded)
          .toList();

  if (attributes.isNotEmpty) {
    return _sortStudyAttributes(attributes);
  }
  return const <ConsumerStudyAttribute>[
    ConsumerStudyAttribute(name: 'Overall Liking', type: 'OVERALL_LIKING'),
  ];
}

List<ConsumerStudyAttribute> _sortStudyAttributes(
  List<ConsumerStudyAttribute> attributes,
) {
  final List<ConsumerStudyAttribute> overall = attributes
      .where((ConsumerStudyAttribute attribute) => attribute.isOverallLiking)
      .toList();
  final List<ConsumerStudyAttribute> others = attributes
      .where((ConsumerStudyAttribute attribute) => !attribute.isOverallLiking)
      .toList();
  others.sort((a, b) {
    final int jarOrder = b.isJar.toString().compareTo(a.isJar.toString());
    if (jarOrder != 0) {
      return jarOrder;
    }
    return a.name.compareTo(b.name);
  });
  return <ConsumerStudyAttribute>[
    ...others,
    if (overall.isEmpty)
      const ConsumerStudyAttribute(
        name: 'Overall Liking',
        type: 'OVERALL_LIKING',
      )
    else
      ...overall,
  ];
}

List<dynamic> _studyListFrom(dynamic value) {
  if (value is List) {
    return value;
  }
  final Map<String, dynamic> map = _asMap(value);
  for (final String key in const <String>[
    'studies',
    'data',
    'items',
    'results',
  ]) {
    final dynamic nested = map[key];
    if (nested is List) {
      return nested;
    }
    if (nested is Map) {
      final List<dynamic> nestedStudies = _studyListFrom(nested);
      if (nestedStudies.isNotEmpty) {
        return nestedStudies;
      }
    }
  }
  return <dynamic>[];
}

String _sessionLabel(Map<String, dynamic> json, Map<String, dynamic> session) {
  final String direct = _firstString(json, const <String>[
    'session',
    'schedule',
    'sessionLabel',
    'scheduleLabel',
    'testingSchedule',
    'testSchedule',
    'testingScheduleLabel',
    'scheduleText',
    'schedule_text',
    'schedule_label',
    'testing_schedule',
  ]);
  if (direct.isNotEmpty && _looksLikeScheduleLabel(direct)) {
    return direct;
  }

  final String date = _firstNonEmptyString(<String>[
    _formatDateLabel(
      _firstString(session, const <String>[
        'date',
        'scheduledDate',
        'sessionDate',
        'testingDate',
        'testing_date',
        'testDate',
        'test_date',
        'scheduledAt',
        'scheduled_at',
        'startsAt',
        'starts_at',
        'startAt',
        'start_at',
        'startDate',
        'start_date',
        'startDateTime',
        'start_date_time',
        'testingStartDate',
        'testing_start_date',
        'testingDateTime',
        'testing_date_time',
        'scheduledStart',
        'scheduled_start',
        'scheduledStartDate',
        'scheduled_start_date',
      ]),
    ),
    _formatDateLabel(
      _firstString(json, const <String>[
        'date',
        'scheduledDate',
        'sessionDate',
        'testingDate',
        'testing_date',
        'testDate',
        'test_date',
        'testingStartDate',
        'testing_start_date',
        'scheduledAt',
        'scheduled_at',
        'startsAt',
        'starts_at',
        'startAt',
        'start_at',
        'startDate',
        'start_date',
        'startDateTime',
        'start_date_time',
        'testingDateTime',
        'testing_date_time',
        'scheduledStart',
        'scheduled_start',
        'scheduledStartDate',
        'scheduled_start_date',
      ]),
    ),
    'Schedule to be announced',
  ]);
  final String name = _firstNonEmptyString(<String>[
    _firstString(session, const <String>[
      'title',
      'name',
      'label',
      'facility',
      'facilityName',
      'facility_name',
      'location',
      'site',
      'siteName',
      'site_name',
      'venue',
      'venueName',
      'venue_name',
      'fic',
      'ficName',
      'fic_name',
      'station',
    ]),
    _firstString(json, const <String>[
      'sessionName',
      'sessionTitle',
      'facility',
      'facilityName',
      'facility_name',
      'location',
      'site',
      'siteName',
      'site_name',
      'venue',
      'venueName',
      'venue_name',
      'ficName',
      'fic_name',
      'partnerFicName',
      'partner_fic_name',
      'station',
    ]),
    _nestedString(session, const <String>['facility', 'fic', 'venue', 'site']),
    _nestedString(json, const <String>['facility', 'fic', 'venue', 'site']),
    direct.isNotEmpty ? direct : '',
    'Study session',
  ]);
  final String start = _firstString(session, const <String>[
    'startTime',
    'start_time',
    'startDateTime',
    'start_date_time',
    'testingStartTime',
    'testing_start_time',
    'testingDateTime',
    'testing_date_time',
    'sessionStartTime',
    'session_start_time',
    'scheduledStart',
    'scheduled_start',
    'start',
    'startsAt',
    'starts_at',
    'startAt',
    'start_at',
  ]);
  final String end = _firstString(session, const <String>[
    'endTime',
    'end_time',
    'endDateTime',
    'end_date_time',
    'testingEndTime',
    'testing_end_time',
    'sessionEndTime',
    'session_end_time',
    'scheduledEnd',
    'scheduled_end',
    'end',
    'endsAt',
    'ends_at',
    'endAt',
    'end_at',
  ]);
  final String startLabel = _formatTimeLabel(start);
  final String endLabel = _formatTimeLabel(end);
  final String time = start.isEmpty && end.isEmpty
      ? _formatTimeLabel(
          _firstString(json, const <String>[
            'time',
            'timeLabel',
            'time_label',
            'testingTime',
            'testing_time',
            'sessionTime',
            'session_time',
            'scheduleTime',
            'schedule_time',
          ]),
        )
      : <String>[
          startLabel,
          endLabel,
        ].where((String part) => part.trim().isNotEmpty).join(' - ');

  return <String>[
    date,
    name,
    time,
  ].where((String part) => part.trim().isNotEmpty).join(' | ');
}

bool _looksLikeScheduleLabel(String value) {
  final String trimmed = value.trim();
  if (trimmed.isEmpty) {
    return false;
  }
  final String lower = trimmed.toLowerCase();
  if (lower == 'schedule to be announced' ||
      lower == 'schedule date unavailable') {
    return true;
  }
  return _looksLikeDateLabel(trimmed) || _looksLikeTimeLabel(trimmed);
}

bool _looksLikeDateLabel(String value) {
  final String trimmed = value.trim();
  return RegExp(
        r'\b(?:jan|feb|mar|apr|may|jun|jul|aug|sep|sept|oct|nov|dec)[a-z]*\b',
        caseSensitive: false,
      ).hasMatch(trimmed) ||
      RegExp(r'\b20\d{2}[-/]\d{1,2}[-/]\d{1,2}').hasMatch(trimmed) ||
      RegExp(r'\b\d{1,2}[-/]\d{1,2}[-/](?:\d{2}|\d{4})\b').hasMatch(trimmed);
}

bool _looksLikeTimeLabel(String value) {
  final String trimmed = value.trim();
  return RegExp(
        r'\b\d{1,2}:\d{2}\s*(?:am|pm)?\b',
        caseSensitive: false,
      ).hasMatch(trimmed) ||
      RegExp(
        r'\b\d{1,2}\s*(?:am|pm)\b',
        caseSensitive: false,
      ).hasMatch(trimmed);
}

Map<String, dynamic> _scheduleMapFromStudy(Map<String, dynamic> json) {
  for (final dynamic source in <dynamic>[
    json['sessionSchedule'],
    json['session_schedule'],
    json['sessionSlots'],
    json['session_slots'],
    json['sessions'],
    json['studySessions'],
    json['study_sessions'],
    json['availableSessions'],
    json['available_sessions'],
    json['testingSessions'],
    json['testing_sessions'],
    json['testingSlots'],
    json['testing_slots'],
    json['slots'],
    json['testingSchedule'],
    json['testSchedule'],
    json['schedule'],
    json['session'],
  ]) {
    final Map<String, dynamic> session = _scheduleMapFrom(source);
    if (session.isNotEmpty) {
      return session;
    }
  }
  return <String, dynamic>{};
}

Map<String, dynamic> _scheduleMapFrom(dynamic value) {
  if (value is List) {
    return _firstMap(value);
  }
  final Map<String, dynamic> map = _asMap(value);
  if (map.isEmpty) {
    return <String, dynamic>{};
  }
  for (final String key in const <String>[
    'sessionSchedule',
    'session_schedule',
    'sessionSlots',
    'session_slots',
    'sessions',
    'studySessions',
    'study_sessions',
    'availableSessions',
    'available_sessions',
    'testingSessions',
    'testing_sessions',
    'slots',
    'testingSlots',
    'testing_slots',
  ]) {
    final Map<String, dynamic> nested = _firstMap(map[key]);
    if (nested.isNotEmpty) {
      return <String, dynamic>{...map, ...nested};
    }
  }
  return map;
}

String _formatDateLabel(String value) {
  if (value.trim().isEmpty) {
    return '';
  }
  final DateTime? parsed = DateTime.tryParse(value);
  if (parsed == null) {
    return _looksLikeDateLabel(value) ? value : '';
  }
  final DateTime local = parsed.toLocal();
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
  return '${months[local.month - 1]} ${local.day}, ${local.year}';
}

String _formatTimeLabel(String value) {
  final String trimmed = value.trim();
  if (trimmed.isEmpty) {
    return '';
  }
  final DateTime? parsed = DateTime.tryParse(trimmed);
  if (parsed == null) {
    return _looksLikeTimeLabel(trimmed) ? trimmed : '';
  }
  if (!_looksLikeTimeLabel(trimmed) &&
      parsed.hour == 0 &&
      parsed.minute == 0 &&
      parsed.second == 0) {
    return '';
  }
  final DateTime local = parsed.toLocal();
  final int hour = local.hour == 0
      ? 12
      : local.hour > 12
      ? local.hour - 12
      : local.hour;
  final String minute = local.minute.toString().padLeft(2, '0');
  final String suffix = local.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $suffix';
}

Map<String, dynamic> _firstMap(dynamic value) {
  if (value is List) {
    for (final dynamic item in value) {
      final Map<String, dynamic> map = _asMap(item);
      if (map.isNotEmpty) {
        return map;
      }
    }
    return <String, dynamic>{};
  }
  return _asMap(value);
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}

String _nestedString(Map<String, dynamic> json, List<String> keys) {
  for (final String key in keys) {
    final Map<String, dynamic> nested = _asMap(json[key]);
    if (nested.isEmpty) {
      continue;
    }
    final String value = _firstString(nested, const <String>[
      'name',
      'label',
      'title',
      'facilityName',
      'venueName',
      'siteName',
    ]);
    if (value.isNotEmpty) {
      return value;
    }
  }
  return '';
}

String _firstString(Map<String, dynamic> json, List<String> keys) {
  for (final String key in keys) {
    final dynamic value = json[key];
    if (value == null) {
      continue;
    }
    if (value is Map || value is List) {
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

int _sampleCount(Map<String, dynamic> json) {
  final int explicit = _firstInt(json, const <String>[
    'sampleCount',
    'numberOfSamples',
    'samples',
  ]);
  if (explicit > 0) {
    return explicit;
  }
  final List<String> codes = _sampleCodes(json);
  return codes.isEmpty ? 1 : codes.length;
}

List<String> _sampleCodes(Map<String, dynamic> json) {
  final dynamic raw =
      json['sampleCodes'] ??
      json['randomizedCodes'] ??
      json['samplePlan'] ??
      json['samples'];
  if (raw is List) {
    return raw
        .map((dynamic item) {
          if (item is Map) {
            return _firstNonEmptyString(<String>[
              _firstString(Map<String, dynamic>.from(item), const <String>[
                'code',
                'sampleCode',
                'label',
              ]),
              item.toString(),
            ]);
          }
          return item.toString();
        })
        .where((String item) => item.trim().isNotEmpty)
        .toList();
  }
  return <String>[];
}

List<String> _openEndedQuestions(dynamic value) {
  return (value as List<dynamic>? ?? <dynamic>[])
      .whereType<Map>()
      .map(
        (Map item) =>
            ConsumerStudyAttribute.fromJson(Map<String, dynamic>.from(item)),
      )
      .where((ConsumerStudyAttribute attribute) => attribute.isOpenEnded)
      .map((ConsumerStudyAttribute attribute) => attribute.name)
      .where((String name) => name.trim().isNotEmpty)
      .toList();
}

List<String> _parseStringList(dynamic value) {
  return (value as List<dynamic>? ?? <dynamic>[])
      .map((dynamic item) => item.toString())
      .where((String item) => item.trim().isNotEmpty)
      .toList();
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
