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
}
