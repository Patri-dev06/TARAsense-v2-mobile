class StudyAnalysis {
  const StudyAnalysis({
    required this.id,
    required this.studyId,
    required this.study,
    required this.responseCount,
    required this.attributeStats,
    required this.penaltyAnalysis,
    required this.perSampleResults,
    required this.meanDropAnalysis,
    required this.overallLiking,
    this.generatedAt,
    this.updatedAt,
    this.comparativeAnalysis,
    this.automaticInterpretation,
    this.aiInterpretation,
    this.aiRecommendation,
    this.decisionFlag,
  });

  final String id;
  final String studyId;
  final StudyAnalysisStudy study;
  final int responseCount;
  final DateTime? generatedAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> overallLiking;
  final List<Map<String, dynamic>> attributeStats;
  final List<Map<String, dynamic>> penaltyAnalysis;
  final List<Map<String, dynamic>> perSampleResults;
  final Map<String, dynamic>? comparativeAnalysis;
  final List<Map<String, dynamic>> meanDropAnalysis;
  final String? automaticInterpretation;
  final String? aiInterpretation;
  final String? aiRecommendation;
  final String? decisionFlag;

  bool get hasAiInterpretation => _firstNonEmptyString(<String>[
    aiRecommendation ?? '',
    aiInterpretation ?? '',
    automaticInterpretation ?? '',
  ]).isNotEmpty;

  String get interpretationText => _firstNonEmptyString(<String>[
    aiRecommendation ?? '',
    aiInterpretation ?? '',
    automaticInterpretation ?? '',
    'AI interpretation is not available yet.',
  ]);

  factory StudyAnalysis.fromJson(Map<String, dynamic> json) {
    // The API nests most analysis data inside overallLiking.
    // Merge it with the top-level map so key lookups find fields in either place.
    final Map<String, dynamic> ol = _asMap(json['overallLiking']);
    final Map<String, dynamic> studyOverview = _asMap(ol['studyOverview']);
    final Map<String, dynamic> merged = <String, dynamic>{...json, ...ol};

    return StudyAnalysis(
      id: _firstString(json, const <String>['id', 'analysisId', '_id']),
      studyId: _firstString(json, const <String>['studyId', 'study_id']),
      study: StudyAnalysisStudy.fromJson(<String, dynamic>{
        'id': _firstString(json, const <String>['studyId', 'study_id', 'id']),
        ...studyOverview,
      }),
      responseCount: _firstInt(merged, const <String>[
        'n',
        'numberOfConsumers',
        'responseCount',
        'responses',
        'totalResponses',
        'consumerCount',
        'participantCount',
        'totalParticipants',
      ]),
      generatedAt: _asDateTime(
        studyOverview['generatedAt'] ??
            studyOverview['dateConducted'] ??
            json['generatedAt'] ??
            json['createdAt'],
      ),
      updatedAt: _asDateTime(json['updatedAt'] ?? studyOverview['updatedAt']),
      overallLiking: ol.isNotEmpty ? ol : _firstMapOf(json, const <String>['overall', 'overallStats']),
      attributeStats: _mapListFirstOf(merged, const <String>[
        'attributeStats',
        'attributeStatistics',
        'attributes',
        'overallAttributeStats',
        'globalAttributeStats',
      ]),
      penaltyAnalysis: _mapListFirstOf(merged, const <String>[
        'penaltyAnalysis',
        'penalty',
        'jarPenalty',
        'jarResults',
        'jarAnalysis',
        'overallPenalty',
      ]),
      perSampleResults: _mapListFirstOf(merged, const <String>[
        'perSampleResults',
        'bySample',
        'samples',
        'sampleResults',
        'sampleTabs',
        'perSampleTabs',
        'sampleData',
        'perSample',
        'results',
      ]),
      comparativeAnalysis: _nullableMap(
        merged['comparativeAnalysis'] ?? merged['comparative'],
      ),
      meanDropAnalysis: _mapListFirstOf(merged, const <String>[
        'meanDropAnalysis',
        'meanDrop',
        'dropAnalysis',
      ]),
      automaticInterpretation: _nullableString(
        merged['automaticInterpretation'] ?? merged['interpretation'],
      ),
      aiInterpretation: _nullableString(merged['aiInterpretation']),
      aiRecommendation: _nullableString(
        merged['aiRecommendation'] ?? merged['recommendation'],
      ),
      decisionFlag: _nullableString(merged['decisionFlag'] ?? merged['decision']),
    );
  }
}

class StudyAnalysisStudy {
  const StudyAnalysisStudy({
    required this.id,
    required this.title,
    required this.productName,
    required this.location,
    required this.status,
  });

  final String id;
  final String title;
  final String productName;
  final String location;
  final String status;

  factory StudyAnalysisStudy.fromJson(Map<String, dynamic> json) {
    return StudyAnalysisStudy(
      id: _firstString(json, const <String>['id', 'studyId']),
      title: _firstString(json, const <String>['title', 'studyTitle', 'name']),
      productName: _firstString(json, const <String>['productName', 'product']),
      location: _firstString(json, const <String>['location', 'facility']),
      status: _firstString(json, const <String>['status', 'state']),
    );
  }
}

String analysisString(Map<String, dynamic> json, List<String> keys) {
  return _firstString(json, keys);
}

int analysisInt(Map<String, dynamic> json, List<String> keys) {
  return _firstInt(json, keys);
}

double analysisDouble(Map<String, dynamic> json, List<String> keys) {
  for (final String key in keys) {
    final double? value = _asDoubleOrNull(json[key]);
    if (value != null) {
      return value;
    }
  }
  return 0;
}

Map<String, dynamic> _firstMapOf(
  Map<String, dynamic> json,
  List<String> keys,
) {
  for (final String key in keys) {
    final Map<String, dynamic> m = _asMap(json[key]);
    if (m.isNotEmpty) return m;
  }
  return <String, dynamic>{};
}

List<Map<String, dynamic>> _mapListFirstOf(
  Map<String, dynamic> json,
  List<String> keys,
) {
  for (final String key in keys) {
    final List<Map<String, dynamic>> result = _mapList(json[key]);
    if (result.isNotEmpty) return result;
  }
  return <Map<String, dynamic>>[];
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}

Map<String, dynamic>? _nullableMap(dynamic value) {
  final Map<String, dynamic> map = _asMap(value);
  return map.isEmpty ? null : map;
}

List<Map<String, dynamic>> _mapList(dynamic value) {
  return (value as List<dynamic>? ?? <dynamic>[])
      .whereType<Map>()
      .map((Map item) => Map<String, dynamic>.from(item))
      .toList();
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

String? _nullableString(dynamic value) {
  if (value == null || value is Map || value is List) {
    return null;
  }
  final String stringValue = value.toString().trim();
  if (stringValue.isEmpty || stringValue.toLowerCase() == 'null') {
    return null;
  }
  return stringValue;
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

int? _asIntOrNull(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '');
}

double? _asDoubleOrNull(dynamic value) {
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '');
}

DateTime? _asDateTime(dynamic value) {
  final String raw = value?.toString().trim() ?? '';
  if (raw.isEmpty) {
    return null;
  }
  return DateTime.tryParse(raw);
}
