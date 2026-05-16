class DreamInterpretation {
  const DreamInterpretation({
    required this.interpretation,
    required this.symbols,
    required this.primaryEmotion,
    required this.secondaryEmotions,
    required this.reflectionQuestion,
  });

  final String interpretation;
  final List<String> symbols;
  final String primaryEmotion;
  final List<String> secondaryEmotions;
  final String reflectionQuestion;

  factory DreamInterpretation.fromJson(Map<String, dynamic> json) {
    return DreamInterpretation(
      interpretation: json['interpretation'] as String? ?? '',
      symbols: _stringList(json['symbols']),
      primaryEmotion: json['primary_emotion'] as String? ?? 'peace',
      secondaryEmotions: _stringList(json['secondary_emotions']),
      reflectionQuestion: json['reflection_question'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'interpretation': interpretation,
      'symbols': symbols,
      'primary_emotion': primaryEmotion,
      'secondary_emotions': secondaryEmotions,
      'reflection_question': reflectionQuestion,
    };
  }

  static List<String> _stringList(Object? value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return const [];
  }
}
