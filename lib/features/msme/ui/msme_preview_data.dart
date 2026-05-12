part of 'msme_workspace_page.dart';

const MsmeDashboardData _previewDashboard = MsmeDashboardData(
  workspaceLabel: 'UI Preview',
  title: 'MSME Dashboard',
  subtitle:
      'Review the mobile workspace with sample studies while authentication and live APIs are paused.',
  stats: DashboardStats(
    ficBookings: 3,
    totalStudies: 8,
    totalResponses: 246,
    activeStudies: 2,
  ),
  studies: <MsmeStudyItem>[
    MsmeStudyItem(
      id: 'preview-study-1',
      title: 'Calamansi Spark Sensory Check',
      productName: 'Calamansi Spark',
      location: 'Butuan City FIC',
      category: 'Beverage',
      stage: 'Prototype Check',
      status: 'RECRUITING',
      sampleSize: 80,
      responseCount: 42,
      participantCount: 56,
      statusLabel: 'Recruiting',
    ),
    MsmeStudyItem(
      id: 'preview-study-2',
      title: 'Cacao Nib Snack Preference Test',
      productName: 'Cacao Nib Bites',
      location: 'Caraga State University',
      category: 'Snack',
      stage: 'Refinement',
      status: 'ACTIVE',
      sampleSize: 60,
      responseCount: 51,
      participantCount: 58,
      statusLabel: 'Active',
    ),
    MsmeStudyItem(
      id: 'preview-study-3',
      title: 'Turmeric Tea Market Readiness',
      productName: 'Golden Root Tea',
      location: 'DOST Caraga',
      category: 'Beverage',
      stage: 'Market Readiness',
      status: 'COMPLETED',
      sampleSize: 100,
      responseCount: 100,
      participantCount: 100,
      statusLabel: 'Completed',
    ),
  ],
);

const List<EvaluatePeerStudyItem> _previewEvaluateStudies = <EvaluatePeerStudyItem>[
  EvaluatePeerStudyItem(
    id: 'eval-preview-1',
    title: 'Coconut Water Preference Study',
    productName: 'Pure Coco Refresh',
    creatorName: 'Maria Santos',
    creatorOrganization: 'Santos Natural Foods',
    category: 'Beverage',
    stage: 'Market Readiness',
    status: 'RECRUITING',
    sampleSize: 50,
    responseCount: 12,
    hasStarted: false,
  ),
  EvaluatePeerStudyItem(
    id: 'eval-preview-2',
    title: 'Banana Chips Texture Evaluation',
    productName: 'Crunch Bana',
    creatorName: 'Jose Reyes',
    creatorOrganization: 'Reyes Snack Co.',
    category: 'Snack',
    stage: 'Refinement',
    status: 'ACTIVE',
    sampleSize: 40,
    responseCount: 28,
    hasStarted: true,
  ),
  EvaluatePeerStudyItem(
    id: 'eval-preview-3',
    title: 'Turmeric Latte Consumer Test',
    productName: 'Golden Latte Mix',
    creatorName: 'Ana Cruz',
    creatorOrganization: 'Cruz Wellness Co.',
    category: 'Functional Food',
    stage: 'Prototype Check',
    status: 'RECRUITING',
    sampleSize: 60,
    responseCount: 5,
    hasStarted: false,
  ),
];

final MsmeProfileData _previewProfile = MsmeProfileData(
  eyebrow: 'UI Preview',
  title: 'My Profile',
  subtitle:
      'Sample MSME profile data for visual review. Changes are not saved while preview mode is enabled.',
  name: 'Preview MSME',
  email: 'preview@tarasense.local',
  organization: 'Caraga Food Innovation Lab',
  age: 32,
  gender: 'PREFER_NOT_SAY',
  location: 'Butuan City',
  occupation: 'Product Developer',
  lifestyle: const <String>['BUSY_PROFESSIONAL', 'HEALTH_CONSCIOUS'],
  dietaryPrefs: const <String>['LOW_SUGAR'],
  coffeeDrinker: true,
  snackConsumer: true,
  energyDrinkConsumer: false,
  history: <ProfileHistoryItem>[
    ProfileHistoryItem(
      id: 'history-1',
      studyTitle: 'Cacao Nib Snack Preference Test',
      productName: 'Cacao Nib Bites',
      stage: 'Refinement',
      status: 'Completed',
      completedAt: DateTime(2026, 4, 18),
    ),
    ProfileHistoryItem(
      id: 'history-2',
      studyTitle: 'Calamansi Spark Sensory Check',
      productName: 'Calamansi Spark',
      stage: 'Prototype Check',
      status: 'In Progress',
      completedAt: null,
    ),
  ],
  metadata: ProfileMetadata(
    role: 'MSME',
    joinedAt: DateTime(2026, 1, 15),
    panelistCreatedAt: DateTime(2026, 1, 16),
    lastActive: DateTime(2026, 4, 29),
  ),
  lifestyleOptions: const <SelectOption>[
    SelectOption(value: 'BUSY_PROFESSIONAL', label: 'Busy professional'),
    SelectOption(value: 'HEALTH_CONSCIOUS', label: 'Health conscious'),
    SelectOption(value: 'FOOD_ADVENTUROUS', label: 'Food adventurous'),
    SelectOption(value: 'BUDGET_MINDED', label: 'Budget-minded'),
  ],
  dietaryOptions: const <SelectOption>[
    SelectOption(value: 'LOW_SUGAR', label: 'Low sugar'),
    SelectOption(value: 'LOW_SODIUM', label: 'Low sodium'),
    SelectOption(value: 'VEGETARIAN', label: 'Vegetarian'),
    SelectOption(value: 'NO_RESTRICTIONS', label: 'No restrictions'),
  ],
  genderOptions: const <SelectOption>[
    SelectOption(value: 'FEMALE', label: 'Female'),
    SelectOption(value: 'MALE', label: 'Male'),
    SelectOption(value: 'PREFER_NOT_SAY', label: 'Prefer not to say'),
  ],
);

const StudyBuilderOptionsData _previewBuilderOptions = StudyBuilderOptionsData(
  workspaceLabel: 'UI Preview',
  title: 'Create Study',
  subtitle:
      'Configure a sample sensory or market study without sending anything to the backend.',
  studyTypes: <SelectOption>[
    SelectOption(value: 'SENSORY', label: 'Sensory Study'),
    SelectOption(value: 'MARKET', label: 'Market Study'),
  ],
  coordinationModes: <SelectOption>[
    SelectOption(value: 'FIC', label: 'Book with FIC'),
    SelectOption(value: 'SELF_MANAGED', label: 'Self-managed'),
  ],
  sensoryStudyTypes: <SelectOption>[
    SelectOption(value: 'CONSUMER_TEST', label: 'Consumer Test'),
    SelectOption(value: 'DESCRIPTIVE_TEST', label: 'Descriptive Test'),
    SelectOption(value: 'DISCRIMINATION_TEST', label: 'Discrimination Test'),
  ],
  consumerObjectives: <SelectOption>[
    SelectOption(
      value: 'FAST_ITERATION',
      label: 'Fast iteration',
      defaultTarget: 30,
    ),
    SelectOption(
      value: 'MARKET_READINESS',
      label: 'Market readiness',
      defaultTarget: 80,
    ),
    SelectOption(
      value: 'PRODUCT_REFINEMENT',
      label: 'Product refinement',
      defaultTarget: 50,
    ),
  ],
  attributeDimensions: <String>['Taste', 'Aroma', 'Texture', 'Appearance'],
  categoryProfiles: <CategoryProfileOption>[
    CategoryProfileOption(
      key: 'beverage',
      label: 'Beverage',
      categoryCode: 'BEVERAGE',
      attributes: <StudyAttributeSeed>[
        StudyAttributeSeed(name: 'Sweetness', dimension: 'Taste'),
        StudyAttributeSeed(name: 'Sourness', dimension: 'Taste'),
        StudyAttributeSeed(name: 'Aroma intensity', dimension: 'Aroma'),
        StudyAttributeSeed(name: 'Color appeal', dimension: 'Appearance'),
      ],
    ),
    CategoryProfileOption(
      key: 'snack',
      label: 'Snack',
      categoryCode: 'SNACK',
      attributes: <StudyAttributeSeed>[
        StudyAttributeSeed(name: 'Crunchiness', dimension: 'Texture'),
        StudyAttributeSeed(name: 'Saltiness', dimension: 'Taste'),
        StudyAttributeSeed(name: 'Aftertaste', dimension: 'Taste'),
        StudyAttributeSeed(name: 'Visual appeal', dimension: 'Appearance'),
      ],
    ),
  ],
  regions: <String>['Caraga', 'Northern Mindanao'],
  facilitiesByRegion: <String, List<String>>{
    'Caraga': <String>['Butuan City FIC', 'DOST Caraga Sensory Lab'],
    'Northern Mindanao': <String>['CDO Food Innovation Center'],
  },
  questionnaireNotes: <String>[
    'Use clear sensory attribute labels.',
    'Keep participant instructions concise.',
    'Review allergens before publishing.',
  ],
  sessionTemplates: <SessionTemplateOption>[
    SessionTemplateOption(
      label: 'Morning Session',
      startTime: '09:00',
      endTime: '11:30',
      capacity: 15,
    ),
    SessionTemplateOption(
      label: 'Afternoon Session',
      startTime: '13:30',
      endTime: '16:00',
      capacity: 15,
    ),
  ],
);

class _StudyAttributeDraft {
  const _StudyAttributeDraft({
    required this.name,
    required this.dimension,
    required this.isJarTarget,
    required this.isCustom,
    required this.actionable,
  });

  final String name;
  final String dimension;
  final bool isJarTarget;
  final bool isCustom;
  final bool actionable;

  _StudyAttributeDraft copyWith({
    String? name,
    String? dimension,
    bool? isJarTarget,
  }) {
    return _StudyAttributeDraft(
      name: name ?? this.name,
      dimension: dimension ?? this.dimension,
      isJarTarget: isJarTarget ?? this.isJarTarget,
      isCustom: isCustom,
      actionable: actionable,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name.trim(),
      'dimension': dimension,
      'isJarTarget': isJarTarget,
      'isCustom': isCustom,
      'actionable': actionable,
    };
  }
}

class _SessionDraft {
  const _SessionDraft({
    required this.label,
    this.startTime = '09:00',
    this.endTime = '11:30',
    this.capacity = 10,
    this.dayOffset = 0,
  });

  final String label;
  final String startTime;
  final String endTime;
  final int capacity;
  final int dayOffset;

  factory _SessionDraft.fromTemplate(SessionTemplateOption template) {
    return _SessionDraft(
      label: template.label,
      startTime: template.startTime,
      endTime: template.endTime,
      capacity: template.capacity,
    );
  }

  _SessionDraft copyWith({
    String? label,
    String? startTime,
    String? endTime,
    int? capacity,
    int? dayOffset,
  }) {
    return _SessionDraft(
      label: label ?? this.label,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      capacity: capacity ?? this.capacity,
      dayOffset: dayOffset ?? this.dayOffset,
    );
  }

  Map<String, dynamic> toJson(DateTime date) {
    final DateTime sessionDate = date.add(Duration(days: dayOffset));
    return <String, dynamic>{
      'dayOffset': dayOffset,
      'label': label.trim().isEmpty ? 'Session' : label.trim(),
      'startDateTime': _combineDateAndTime(sessionDate, startTime),
      'endDateTime': _combineDateAndTime(sessionDate, endTime),
      'capacity': capacity,
    };
  }
}

class _SampleSetupDraft {
  const _SampleSetupDraft({
    required this.description,
    required this.ingredient,
    required this.allergen,
  });

  factory _SampleSetupDraft.empty() {
    return const _SampleSetupDraft(
      description: '',
      ingredient: '',
      allergen: 'N/A',
    );
  }

  final String description;
  final String ingredient;
  final String allergen;

  _SampleSetupDraft copyWith({
    String? description,
    String? ingredient,
    String? allergen,
  }) {
    return _SampleSetupDraft(
      description: description ?? this.description,
      ingredient: ingredient ?? this.ingredient,
      allergen: allergen ?? this.allergen,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'description': description.trim().isEmpty
          ? 'Sample setup'
          : description.trim(),
      'ingredient': ingredient.trim(),
      'allergen': allergen.trim().isEmpty ? 'N/A' : allergen.trim(),
    };
  }
}

String _humanizeLabel(String value) {
  return value
      .toLowerCase()
      .split('_')
      .map((String part) {
        if (part.isEmpty) {
          return part;
        }
        return '${part[0].toUpperCase()}${part.substring(1)}';
      })
      .join(' ');
}

String _formatLongDate(DateTime value) {
  return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
}

String _formatShortDate(DateTime value) {
  return '${value.month}/${value.day}/${value.year}';
}

String _formatLongDateTime(DateTime value) {
  final int hour = value.hour > 12
      ? value.hour - 12
      : (value.hour == 0 ? 12 : value.hour);
  final String minute = value.minute.toString().padLeft(2, '0');
  final String period = value.hour >= 12 ? 'PM' : 'AM';
  return '${value.month}/${value.day}/${value.year}, $hour:$minute $period';
}

String _formatDateOnly(DateTime value) {
  return '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}

String _combineDateAndTime(DateTime date, String time) {
  final List<String> parts = time.split(':');
  final int hour = int.tryParse(parts.isNotEmpty ? parts[0] : '0') ?? 0;
  final int minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
  final DateTime value = DateTime.utc(
    date.year,
    date.month,
    date.day,
    hour,
    minute,
  );
  return value.toIso8601String();
}
