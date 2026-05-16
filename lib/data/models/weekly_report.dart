class WeeklyReport {
  const WeeklyReport({
    required this.weekSummary,
    required this.dominantTheme,
    required this.recurringSymbols,
    required this.emotionalJourney,
    required this.insight,
    required this.affirmation,
  });

  final String weekSummary;
  final String dominantTheme;
  final List<String> recurringSymbols;
  final String emotionalJourney;
  final String insight;
  final String affirmation;

  factory WeeklyReport.fromJson(Map<String, dynamic> json) {
    return WeeklyReport(
      weekSummary: json['week_summary'] as String? ?? '',
      dominantTheme: json['dominant_theme'] as String? ?? '',
      recurringSymbols: _stringList(json['recurring_symbols']),
      emotionalJourney: json['emotional_journey'] as String? ?? '',
      insight: json['insight'] as String? ?? '',
      affirmation: json['affirmation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'week_summary': weekSummary,
      'dominant_theme': dominantTheme,
      'recurring_symbols': recurringSymbols,
      'emotional_journey': emotionalJourney,
      'insight': insight,
      'affirmation': affirmation,
    };
  }

  static List<String> _stringList(Object? value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return const [];
  }
}
