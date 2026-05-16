class AppSettings {
  const AppSettings({
    required this.tokenRouterApiKey,
    required this.selectedModel,
    required this.language,
    required this.themeName,
    required this.reminderEnabled,
    required this.reminderTime,
  });

  static const availableModels = [
    'anthropic/claude-haiku-4.5',
    'moonshotai/kimi-k2.6',
    'qwen/qwen3.6-plus',
    'google/gemini-3-flash-preview',
    'z-ai/glm-5',
    'openai/gpt-5-mini',
  ];

  final String tokenRouterApiKey;
  final String selectedModel;
  final String language;
  final String themeName;
  final bool reminderEnabled;
  final String reminderTime;

  bool get hasStoredApiKey => tokenRouterApiKey.trim().isNotEmpty;

  AppSettings copyWith({
    String? tokenRouterApiKey,
    String? selectedModel,
    String? language,
    String? themeName,
    bool? reminderEnabled,
    String? reminderTime,
  }) {
    return AppSettings(
      tokenRouterApiKey: tokenRouterApiKey ?? this.tokenRouterApiKey,
      selectedModel: selectedModel ?? this.selectedModel,
      language: language ?? this.language,
      themeName: themeName ?? this.themeName,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }

  factory AppSettings.defaults() {
    return const AppSettings(
      tokenRouterApiKey: '',
      selectedModel: 'anthropic/claude-haiku-4.5',
      language: 'Indonesia',
      themeName: 'Midnight',
      reminderEnabled: true,
      reminderTime: '06:30',
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final model = json['selected_model'] as String? ??
        AppSettings.defaults().selectedModel;
    return AppSettings(
      tokenRouterApiKey: json['tokenrouter_api_key'] as String? ?? '',
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
      'tokenrouter_api_key': tokenRouterApiKey,
      'selected_model': selectedModel,
      'language': language,
      'theme_name': themeName,
      'reminder_enabled': reminderEnabled,
      'reminder_time': reminderTime,
    };
  }
}
