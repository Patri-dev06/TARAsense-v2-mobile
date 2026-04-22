class DashboardStats {
  const DashboardStats({
    required this.ficBookings,
    required this.totalStudies,
    required this.totalResponses,
    required this.activeStudies,
  });

  final int ficBookings;
  final int totalStudies;
  final int totalResponses;
  final int activeStudies;

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      ficBookings: _asInt(json['ficBookings']),
      totalStudies: _asInt(json['totalStudies']),
      totalResponses: _asInt(json['totalResponses']),
      activeStudies: _asInt(json['activeStudies']),
    );
  }
}

class MsmeStudyItem {
  const MsmeStudyItem({
    required this.id,
    required this.title,
    required this.productName,
    required this.location,
    required this.category,
    required this.stage,
    required this.status,
    required this.sampleSize,
    required this.responseCount,
    required this.participantCount,
    required this.statusLabel,
  });

  final String id;
  final String title;
  final String productName;
  final String location;
  final String category;
  final String stage;
  final String status;
  final int sampleSize;
  final int responseCount;
  final int participantCount;
  final String statusLabel;

  double get progress {
    if (sampleSize <= 0) {
      return 0;
    }
    return (responseCount / sampleSize).clamp(0, 1).toDouble();
  }

  factory MsmeStudyItem.fromJson(Map<String, dynamic> json) {
    return MsmeStudyItem(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      productName: (json['productName'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      stage: (json['stage'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      sampleSize: _asInt(json['sampleSize']),
      responseCount: _asInt(json['responseCount']),
      participantCount: _asInt(json['participantCount']),
      statusLabel: (json['statusLabel'] ?? '').toString(),
    );
  }
}

class MsmeDashboardData {
  const MsmeDashboardData({
    required this.workspaceLabel,
    required this.title,
    required this.subtitle,
    required this.stats,
    required this.studies,
  });

  final String workspaceLabel;
  final String title;
  final String subtitle;
  final DashboardStats stats;
  final List<MsmeStudyItem> studies;

  factory MsmeDashboardData.fromJson(Map<String, dynamic> json) {
    final rawStudies = (json['studies'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map>()
        .map((Map item) => MsmeStudyItem.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    return MsmeDashboardData(
      workspaceLabel: (json['workspaceLabel'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      stats: DashboardStats.fromJson(
        Map<String, dynamic>.from(json['stats'] as Map? ?? <String, dynamic>{}),
      ),
      studies: rawStudies,
    );
  }
}

class SelectOption {
  const SelectOption({
    required this.value,
    required this.label,
    this.max,
    this.defaultTarget,
  });

  final String value;
  final String label;
  final int? max;
  final int? defaultTarget;

  factory SelectOption.fromJson(Map<String, dynamic> json) {
    return SelectOption(
      value: (json['value'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      max: json['max'] == null ? null : _asInt(json['max']),
      defaultTarget: json['defaultTarget'] == null
          ? null
          : _asInt(json['defaultTarget']),
    );
  }
}

class StudyAttributeSeed {
  const StudyAttributeSeed({required this.name, required this.dimension});

  final String name;
  final String dimension;

  factory StudyAttributeSeed.fromJson(Map<String, dynamic> json) {
    return StudyAttributeSeed(
      name: (json['name'] ?? '').toString(),
      dimension: (json['dimension'] ?? '').toString(),
    );
  }
}

class CategoryProfileOption {
  const CategoryProfileOption({
    required this.key,
    required this.label,
    required this.categoryCode,
    required this.attributes,
  });

  final String key;
  final String label;
  final String categoryCode;
  final List<StudyAttributeSeed> attributes;

  factory CategoryProfileOption.fromJson(Map<String, dynamic> json) {
    final rawAttributes = (json['attributes'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map>()
        .map(
          (Map item) => StudyAttributeSeed.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();

    return CategoryProfileOption(
      key: (json['key'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      categoryCode: (json['categoryCode'] ?? '').toString(),
      attributes: rawAttributes,
    );
  }
}

class SessionTemplateOption {
  const SessionTemplateOption({
    required this.label,
    required this.startTime,
    required this.endTime,
    required this.capacity,
  });

  final String label;
  final String startTime;
  final String endTime;
  final int capacity;

  factory SessionTemplateOption.fromJson(Map<String, dynamic> json) {
    return SessionTemplateOption(
      label: (json['label'] ?? '').toString(),
      startTime: (json['startTime'] ?? '').toString(),
      endTime: (json['endTime'] ?? '').toString(),
      capacity: _asInt(json['capacity']),
    );
  }
}

class StudyBuilderOptionsData {
  const StudyBuilderOptionsData({
    required this.workspaceLabel,
    required this.title,
    required this.subtitle,
    required this.studyTypes,
    required this.coordinationModes,
    required this.sensoryStudyTypes,
    required this.consumerObjectives,
    required this.attributeDimensions,
    required this.categoryProfiles,
    required this.regions,
    required this.facilitiesByRegion,
    required this.questionnaireNotes,
    required this.sessionTemplates,
  });

  final String workspaceLabel;
  final String title;
  final String subtitle;
  final List<SelectOption> studyTypes;
  final List<SelectOption> coordinationModes;
  final List<SelectOption> sensoryStudyTypes;
  final List<SelectOption> consumerObjectives;
  final List<String> attributeDimensions;
  final List<CategoryProfileOption> categoryProfiles;
  final List<String> regions;
  final Map<String, List<String>> facilitiesByRegion;
  final List<String> questionnaireNotes;
  final List<SessionTemplateOption> sessionTemplates;

  factory StudyBuilderOptionsData.fromJson(Map<String, dynamic> json) {
    return StudyBuilderOptionsData(
      workspaceLabel: (json['workspaceLabel'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      studyTypes: _parseOptions(json['studyTypes']),
      coordinationModes: _parseOptions(json['coordinationModes']),
      sensoryStudyTypes: _parseOptions(json['sensoryStudyTypes']),
      consumerObjectives: _parseOptions(json['consumerObjectives']),
      attributeDimensions: _parseStringList(json['attributeDimensions']),
      categoryProfiles: (json['categoryProfiles'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map>()
          .map(
            (Map item) =>
                CategoryProfileOption.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      regions: _parseStringList(json['regions']),
      facilitiesByRegion: _parseStringMap(json['facilitiesByRegion']),
      questionnaireNotes: _parseStringList(json['questionnaireNotes']),
      sessionTemplates: (json['sessionTemplates'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map>()
          .map(
            (Map item) =>
                SessionTemplateOption.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
    );
  }
}

class ProfileHistoryItem {
  const ProfileHistoryItem({
    required this.id,
    required this.studyTitle,
    required this.productName,
    required this.stage,
    required this.status,
    this.completedAt,
  });

  final String id;
  final String studyTitle;
  final String productName;
  final String stage;
  final String status;
  final DateTime? completedAt;

  factory ProfileHistoryItem.fromJson(Map<String, dynamic> json) {
    return ProfileHistoryItem(
      id: (json['id'] ?? '').toString(),
      studyTitle: (json['studyTitle'] ?? '').toString(),
      productName: (json['productName'] ?? '').toString(),
      stage: (json['stage'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      completedAt: _asDateTime(json['completedAt']),
    );
  }
}

class ProfileMetadata {
  const ProfileMetadata({
    required this.role,
    required this.joinedAt,
    this.panelistCreatedAt,
    this.lastActive,
  });

  final String role;
  final DateTime? joinedAt;
  final DateTime? panelistCreatedAt;
  final DateTime? lastActive;

  factory ProfileMetadata.fromJson(Map<String, dynamic> json) {
    return ProfileMetadata(
      role: (json['role'] ?? '').toString(),
      joinedAt: _asDateTime(json['joinedAt']),
      panelistCreatedAt: _asDateTime(json['panelistCreatedAt']),
      lastActive: _asDateTime(json['lastActive']),
    );
  }
}

class MsmeProfileData {
  const MsmeProfileData({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.name,
    required this.email,
    required this.organization,
    required this.age,
    required this.gender,
    required this.location,
    required this.occupation,
    required this.lifestyle,
    required this.dietaryPrefs,
    required this.coffeeDrinker,
    required this.snackConsumer,
    required this.energyDrinkConsumer,
    required this.history,
    required this.metadata,
    required this.lifestyleOptions,
    required this.dietaryOptions,
    required this.genderOptions,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final String name;
  final String email;
  final String organization;
  final int age;
  final String gender;
  final String location;
  final String occupation;
  final List<String> lifestyle;
  final List<String> dietaryPrefs;
  final bool coffeeDrinker;
  final bool snackConsumer;
  final bool energyDrinkConsumer;
  final List<ProfileHistoryItem> history;
  final ProfileMetadata metadata;
  final List<SelectOption> lifestyleOptions;
  final List<SelectOption> dietaryOptions;
  final List<SelectOption> genderOptions;

  factory MsmeProfileData.fromJson(Map<String, dynamic> json) {
    final header = Map<String, dynamic>.from(
      json['header'] as Map? ?? <String, dynamic>{},
    );
    final basic = Map<String, dynamic>.from(
      json['basicInformation'] as Map? ?? <String, dynamic>{},
    );
    final preferences = Map<String, dynamic>.from(
      json['preferences'] as Map? ?? <String, dynamic>{},
    );
    final consumption = Map<String, dynamic>.from(
      preferences['consumption'] as Map? ?? <String, dynamic>{},
    );
    final options = Map<String, dynamic>.from(
      json['options'] as Map? ?? <String, dynamic>{},
    );

    return MsmeProfileData(
      eyebrow: (header['eyebrow'] ?? '').toString(),
      title: (header['title'] ?? '').toString(),
      subtitle: (header['subtitle'] ?? '').toString(),
      name: (basic['name'] ?? '').toString(),
      email: (basic['email'] ?? '').toString(),
      organization: (basic['organization'] ?? '').toString(),
      age: _asInt(basic['age']),
      gender: (basic['gender'] ?? '').toString(),
      location: (basic['location'] ?? '').toString(),
      occupation: (basic['occupation'] ?? '').toString(),
      lifestyle: _parseStringList(preferences['lifestyle']),
      dietaryPrefs: _parseStringList(preferences['dietaryPrefs']),
      coffeeDrinker: consumption['coffeeDrinker'] == true,
      snackConsumer: consumption['snackConsumer'] == true,
      energyDrinkConsumer: consumption['energyDrinkConsumer'] == true,
      history: (json['participationHistory'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map>()
          .map(
            (Map item) =>
                ProfileHistoryItem.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      metadata: ProfileMetadata.fromJson(
        Map<String, dynamic>.from(json['metadata'] as Map? ?? <String, dynamic>{}),
      ),
      lifestyleOptions: _parseOptions(options['lifestyles']),
      dietaryOptions: _parseOptions(options['dietaryPrefs']),
      genderOptions: _parseOptions(options['genders']),
    );
  }
}

List<SelectOption> _parseOptions(dynamic value) {
  return (value as List<dynamic>? ?? <dynamic>[])
      .whereType<Map>()
      .map((Map item) => SelectOption.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

List<String> _parseStringList(dynamic value) {
  return (value as List<dynamic>? ?? <dynamic>[])
      .map((dynamic item) => item.toString())
      .toList();
}

Map<String, List<String>> _parseStringMap(dynamic value) {
  final Map<String, List<String>> output = <String, List<String>>{};
  final rawMap = Map<String, dynamic>.from(value as Map? ?? <String, dynamic>{});
  for (final MapEntry<String, dynamic> entry in rawMap.entries) {
    output[entry.key] = _parseStringList(entry.value);
  }
  return output;
}

int _asInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _asDateTime(dynamic value) {
  final raw = value?.toString();
  if (raw == null || raw.isEmpty) {
    return null;
  }
  return DateTime.tryParse(raw);
}
