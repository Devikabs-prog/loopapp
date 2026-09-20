class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.studyLevel,
  });

  final String id;
  final String email;
  final String displayName;
  final String studyLevel;

  UserProfile copyWith({String? displayName, String? studyLevel}) =>
      UserProfile(
        id: id,
        email: email,
        displayName: displayName ?? this.displayName,
        studyLevel: studyLevel ?? this.studyLevel,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'displayName': displayName,
    'studyLevel': studyLevel,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String,
    email: json['email'] as String? ?? '',
    displayName: json['displayName'] as String? ?? 'Student',
    studyLevel: json['studyLevel'] as String? ?? '',
  );
}
