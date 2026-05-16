class UserProfile {
  const UserProfile({
    required this.name,
    required this.onboardingComplete,
    this.avatarPath,
  });

  final String name;
  final bool onboardingComplete;
  final String? avatarPath;

  String get displayName {
    final trimmed = name.trim();
    return trimmed.isEmpty ? 'Dreamer' : trimmed;
  }

  String get initial {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) {
      return 'D';
    }
    return trimmed[0].toUpperCase();
  }

  UserProfile copyWith({
    String? name,
    bool? onboardingComplete,
    String? avatarPath,
    bool clearAvatar = false,
  }) {
    return UserProfile(
      name: name ?? this.name,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      avatarPath: clearAvatar ? null : avatarPath ?? this.avatarPath,
    );
  }

  factory UserProfile.defaults() {
    return const UserProfile(
      name: 'Dreamer',
      onboardingComplete: false,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? 'Dreamer',
      onboardingComplete: json['onboarding_complete'] as bool? ?? false,
      avatarPath: json['avatar_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'onboarding_complete': onboardingComplete,
      'avatar_path': avatarPath,
    };
  }
}
