class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.avatarAsset,
    required this.gradeLabel,
    required this.planName,
  });

  final String id;
  final String name;
  final String avatarAsset;
  final String gradeLabel;
  final String planName;

  UserProfile copyWith({
    String? id,
    String? name,
    String? avatarAsset,
    String? gradeLabel,
    String? planName,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarAsset: avatarAsset ?? this.avatarAsset,
      gradeLabel: gradeLabel ?? this.gradeLabel,
      planName: planName ?? this.planName,
    );
  }
}
