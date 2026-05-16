import 'dream_interpretation.dart';

class DreamEntry {
  const DreamEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.clarity,
    required this.interpretation,
    this.isBookmarked = false,
  });

  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final double clarity;
  final DreamInterpretation interpretation;
  final bool isBookmarked;

  String get primaryEmotion => interpretation.primaryEmotion;
  List<String> get symbols => interpretation.symbols;

  DreamEntry copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    double? clarity,
    DreamInterpretation? interpretation,
    bool? isBookmarked,
  }) {
    return DreamEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      clarity: clarity ?? this.clarity,
      interpretation: interpretation ?? this.interpretation,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  factory DreamEntry.fromJson(Map<String, dynamic> json) {
    return DreamEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      clarity: (json['clarity'] as num).toDouble(),
      interpretation: DreamInterpretation.fromJson(
        Map<String, dynamic>.from(json['interpretation'] as Map),
      ),
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'clarity': clarity,
      'interpretation': interpretation.toJson(),
      'is_bookmarked': isBookmarked,
    };
  }
}
