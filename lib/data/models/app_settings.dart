class AppSettings {
  const AppSettings({
    required this.selectedModel,
    required this.language,
    required this.themeName,
    required this.reminderEnabled,
    required this.reminderTime,
  });

  static const defaultModel = 'gemini-3.8-flash';
  static const availableModels = [
    'gemini-3.8-flash',
    'deepseek-v4.1-flash',
    'gpt-oss-120b',
    'claude-sonnet-4.5',
  ];

  final String selectedModel;
  final String language;
  final String themeName;
  final bool reminderEnabled;
  final String reminderTime;

  AppSettings copyWith({
    String? selectedModel,
    String? language,
    String? themeName,
    bool? reminderEnabled,
    String? reminderTime,
  }) {
    return AppSettings(
      selectedModel: selectedModel ?? this.selectedModel,
      language: language ?? this.language,
      themeName: themeName ?? this.themeName,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }

  factory AppSettings.defaults() {
    return const AppSettings(
      selectedModel: defaultModel,
      language: 'Indonesia',
      themeName: 'Midnight',
      reminderEnabled: true,
      reminderTime: '06:30',
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final model =
        json['selected_model'] as String? ?? AppSettings.defaults().selectedModel;
    return AppSettings(
      selectedModel: availableModels.contains(model)
          ? model
          : AppSettings.defaults().selectedModel,
      language: json['language'] as String? ?? 'Indonesia',
      themeName: json['theme_name'] as String? ?? 'Midnight',
      reminderEnabled: json['reminder_enabled'] as bool? ?? true,
      reminderTime: json['reminder_time'] as String? ?? '06:30',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selected_model': selectedModel,
      'language': language,
      'theme_name': themeName,
      'reminder_enabled': reminderEnabled,
      'reminder_time': reminderTime,
    };
  }
}
