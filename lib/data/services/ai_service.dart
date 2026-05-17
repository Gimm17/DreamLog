import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/dream_entry.dart';
import '../models/dream_interpretation.dart';
import '../models/dream_symbol_catalog.dart';
import '../models/weekly_report.dart';

class AiService {
  AiService({
    Dio? dio,
    String? apiKey,
    String? model,
  })  : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://api.tokenrouter.com/v1',
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 45),
              ),
            ),
        _apiKey = apiKey ?? const String.fromEnvironment('TOKENROUTER_API_KEY'),
        _model = model ?? 'anthropic/claude-haiku-4.5';

  final Dio _dio;
  final String _apiKey;
  final String _model;

  bool get isConfigured => _apiKey.trim().isNotEmpty;
  String get model => _model;

  Future<DreamInterpretation> interpretDream(String dreamText) async {
    if (!isConfigured) {
      return _fallbackInterpretation(dreamText);
    }

    try {
      final text = await _chatCompletion(
        system: _dreamSystemPrompt,
        user: dreamText,
        maxTokens: 1100,
      );
      return _normalizeInterpretation(
        DreamInterpretation.fromJson(_jsonObject(text)),
        dreamText,
      );
    } catch (_) {
      return _fallbackInterpretation(dreamText);
    }
  }

  Future<WeeklyReport> generateWeeklyReport(List<DreamEntry> entries) async {
    if (!isConfigured || entries.isEmpty) {
      return _fallbackWeeklyReport(entries);
    }

    try {
      final text = await _chatCompletion(
        system: _weeklySystemPrompt,
        user: jsonEncode(
            entries.take(14).map((entry) => entry.toJson()).toList()),
        maxTokens: 1400,
      );
      return _normalizeWeeklyReport(
        WeeklyReport.fromJson(_jsonObject(text)),
        entries,
      );
    } catch (_) {
      return _fallbackWeeklyReport(entries);
    }
  }

  Future<String> _chatCompletion({
    required String system,
    required String user,
    required int maxTokens,
  }) async {
    final response = await _dio.post<dynamic>(
      '/chat/completions',
      options: Options(
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'model': _model,
        'temperature': 0.55,
        'max_tokens': maxTokens,
        'messages': [
          {'role': 'system', 'content': system},
          {'role': 'user', 'content': user},
        ],
      },
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('AI response was not an object.');
    }
    final choices = data['choices'];
    if (choices is! List || choices.isEmpty) {
      throw const FormatException('AI response did not include choices.');
    }
    final first = choices.first;
    if (first is! Map) {
      throw const FormatException('AI choice was not an object.');
    }
    final message = first['message'];
    if (message is! Map) {
      throw const FormatException('AI choice did not include a message.');
    }
    final content = message['content'];
    if (content is String) {
      return content;
    }
    if (content is List) {
      return content.map((part) {
        if (part is Map && part['text'] != null) {
          return part['text'].toString();
        }
        return part.toString();
      }).join('\n');
    }
    throw const FormatException('AI message content was empty.');
  }

  Map<String, dynamic> _jsonObject(String raw) {
    final stripped = raw
        .replaceAll(RegExp(r'```json', caseSensitive: false), '')
        .replaceAll('```', '')
        .trim();

    try {
      return Map<String, dynamic>.from(jsonDecode(stripped) as Map);
    } catch (_) {
      final start = stripped.indexOf('{');
      final end = stripped.lastIndexOf('}');
      if (start >= 0 && end > start) {
        return Map<String, dynamic>.from(
          jsonDecode(stripped.substring(start, end + 1)) as Map,
        );
      }
      rethrow;
    }
  }

  DreamInterpretation _normalizeInterpretation(
    DreamInterpretation interpretation,
    String dreamText,
  ) {
    return DreamInterpretation(
      interpretation: interpretation.interpretation,
      symbols: normalizeDreamSymbols(interpretation.symbols, dreamText),
      primaryEmotion: interpretation.primaryEmotion,
      secondaryEmotions: interpretation.secondaryEmotions,
      reflectionQuestion: interpretation.reflectionQuestion,
    );
  }

  WeeklyReport _normalizeWeeklyReport(
    WeeklyReport report,
    List<DreamEntry> entries,
  ) {
    final dreamText = entries.map((entry) => entry.content).join('\n');
    return WeeklyReport(
      weekSummary: report.weekSummary,
      dominantTheme: report.dominantTheme,
      recurringSymbols: normalizeDreamSymbols(
        report.recurringSymbols,
        dreamText,
      ),
      emotionalJourney: report.emotionalJourney,
      insight: report.insight,
      affirmation: report.affirmation,
    );
  }

  DreamInterpretation _fallbackInterpretation(String dreamText) {
    final lower = dreamText.toLowerCase();
    final symbols = normalizeDreamSymbols(const [], dreamText);

    return DreamInterpretation(
      interpretation:
          'Mimpi ini mengarah pada proses memahami emosi yang sedang berubah. Beberapa simbol terasa seperti ajakan untuk memperhatikan bagian hidup yang ingin dibuka, dilepas, atau dipahami dengan lebih tenang.',
      symbols: symbols,
      primaryEmotion: lower.contains('run') ||
              lower.contains('test') ||
              lower.contains('lari') ||
              lower.contains('takut')
          ? 'Anxious'
          : 'Peaceful',
      secondaryEmotions: const ['Curious', 'Reflective'],
      reflectionQuestion:
          'Bagian mana dari mimpi ini yang paling terasa dekat dengan hidupmu saat ini?',
    );
  }

  WeeklyReport _fallbackWeeklyReport(List<DreamEntry> entries) {
    if (entries.isEmpty) {
      return const WeeklyReport(
        weekSummary:
            'No saved dreams yet. Weekly patterns will appear after real journal entries are available.',
        dominantTheme: 'No dreams saved yet',
        recurringSymbols: [],
        emotionalJourney: 'Record dreams to build an emotional timeline.',
        insight: 'DreamLog needs saved dreams before it can identify patterns.',
        affirmation: 'My real patterns will emerge as I keep recording.',
      );
    }

    final symbolCounts = <String, int>{};
    for (final entry in entries) {
      for (final symbol in entry.symbols) {
        final canonical = canonicalDreamSymbol(symbol)?.name ?? symbol;
        symbolCounts.update(canonical, (value) => value + 1, ifAbsent: () => 1);
      }
    }
    final recurring = symbolCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return WeeklyReport(
      weekSummary:
          'Mimpi-mimpi terbaru menunjukkan pola emosi yang sedang mencari bentuk. Simbol yang berulang dapat menjadi petunjuk tentang kebutuhan untuk merasa aman, memahami perubahan, dan memberi ruang pada intuisi.',
      dominantTheme:
          entries.isEmpty ? 'A Quiet Beginning' : 'A Week of Hidden Signals',
      recurringSymbols: recurring.isEmpty
          ? normalizeDreamSymbols(
              const [], entries.map((e) => e.content).join('\n'))
          : recurring.take(5).map((entry) => entry.key).toList(),
      emotionalJourney:
          'Perjalanan emosinya bergerak dari observasi, rasa ingin tahu, lalu kebutuhan untuk menemukan kejelasan.',
      insight:
          'Pola terkuat minggu ini adalah dorongan untuk memahami sesuatu tanpa memaksakan jawaban terlalu cepat.',
      affirmation: 'Aku boleh bergerak pelan dan tetap menuju kejelasan.',
    );
  }
}

const _dreamSystemPrompt = '''
You are DreamLog AI, an empathetic dream analyst with knowledge of Jungian
psychology, symbolism, and emotional pattern recognition.
Support Bahasa Indonesia and English, matching the user's language.
You must choose dream symbols from the allowed taxonomy below.
Rules for symbols:
- Return 2-5 symbols.
- Use only exact names from the allowed taxonomy.
- Prefer concrete symbols that literally appear in the dream narrative.
- Do not over-infer metaphors. For example, choose "Key/Lock" only if the
  dream explicitly mentions a key, lock, locked door, gembok, kunci, or unlock.
- If the user mentions a garden, flowers, or taman, choose "Garden/Flowers",
  not "Key/Lock".
- If a symbol is not present in the dream text, do not include it just because
  it sounds psychologically relevant.

$dreamSymbolCatalogPrompt

Respond only as valid JSON with this exact shape:
{
  "interpretation": "...",
  "symbols": ["...", "..."],
  "primary_emotion": "...",
  "secondary_emotions": ["...", "..."],
  "reflection_question": "..."
}
Keep the tone warm, curious, and non-judgmental. Do not diagnose medical or
mental-health conditions.
''';

const _weeklySystemPrompt = '''
You are DreamLog AI generating a weekly dream pattern report.
You will receive an array of dream entries. Respond only as valid JSON:
Use recurring_symbols only from this allowed taxonomy:
$dreamSymbolCatalogPrompt

{
  "week_summary": "...",
  "dominant_theme": "...",
  "recurring_symbols": ["..."],
  "emotional_journey": "...",
  "insight": "...",
  "affirmation": "..."
}
Support Bahasa Indonesia and English, matching the user's dream language.
''';
