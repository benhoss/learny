class ChildProfile {
  const ChildProfile({
    required this.id,
    required this.name,
    required this.gradeLabel,
    this.age,
    this.schoolClass,
    this.preferredLanguage,
    this.gender,
    this.learningStylePreferences = const [],
    this.supportNeeds = const {},
    this.confidenceBySubject = const [],
  });

  final String id;
  final String name;
  final String gradeLabel;
  final int? age;
  final String? schoolClass;
  final String? preferredLanguage;
  final String? gender;
  final List<String> learningStylePreferences;
  final Map<String, dynamic> supportNeeds;
  final List<Map<String, dynamic>> confidenceBySubject;

  static ChildProfile? fromJson(Map<String, dynamic> json) {
    final rawId = json['_id'] ?? json['id'];
    String? id;
    if (rawId is Map) {
      id = (rawId[r'$oid'] ?? rawId['oid'])?.toString();
    } else {
      id = rawId?.toString();
    }
    if (id == null || id.isEmpty) {
      return null;
    }

    final learningStylePreferences =
        (json['learning_style_preferences'] as List<dynamic>? ?? const [])
            .map((item) => item.toString())
            .toList();
    final supportNeedsRaw = json['support_needs'];
    final supportNeeds = supportNeedsRaw is Map
        ? Map<String, dynamic>.from(supportNeedsRaw)
        : const <String, dynamic>{};
    final confidenceBySubject =
        (json['confidence_by_subject'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map((entry) => Map<String, dynamic>.from(entry))
            .toList();

    return ChildProfile(
      id: id,
      name: json['name']?.toString() ?? 'Child',
      gradeLabel: json['grade_level']?.toString() ?? '',
      age: (json['age'] as num?)?.toInt(),
      schoolClass: json['school_class']?.toString(),
      preferredLanguage: json['preferred_language']?.toString(),
      gender: json['gender']?.toString(),
      learningStylePreferences: learningStylePreferences,
      supportNeeds: supportNeeds,
      confidenceBySubject: confidenceBySubject,
    );
  }
}
