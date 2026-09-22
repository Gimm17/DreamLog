import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/dream_entry.dart';
import '../models/dream_interpretation.dart';
import '../models/dream_symbol_catalog.dart';
import '../models/weekly_report.dart';

/// Injected at build time: `flutter run --dart-define=LIMITROUTER_API_KEY=sk-lr-...`
/// Never hardcode a key here, and never write it to device storage.
const _apiKey = String.fromEnvironment('LIMITROUTER_API_KEY');

class AiService {
  AiService({
    Dio? dio,
    String? model,
  })  : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://limitrouter.com/v1',
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 45),
              ),
            ),
        _model = model ?? defaultModel;

  static const defaultModel = 'gemini-3.8-flash';

  final Dio _dio;
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
          'Mimpi ini masih hangat di tepi ingatan, dan seperti kabut yang belum '
          'tersentuh fajar, ia belum ingin dibaca terlalu cepat. Ada bagian '
          'dirimu yang sedang menaruh sesuatu di ambang pintu - mungkin ingin '
          'dibuka, mungkin hanya ingin ditemani sebentar. Biarkan jawabannya '
          'datang pelan.',
      symbols: symbols,
      primaryEmotion: lower.contains('run') ||
              lower.contains('test') ||
              lower.contains('lari') ||
              lower.contains('takut')
          ? 'Anxious'
          : 'Peaceful',
      secondaryEmotions: const ['Curious', 'Reflective'],
      reflectionQuestion:
          'Kalau mimpi ini sebuah pintu, apa yang kamu dengar dari baliknya?',
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
          'Minggu ini mimpi-mimpimu berjalan seperti sungai yang mencari '
          'lautnya sendiri - berkelok, sempat berhenti, lalu bergerak lagi. '
          'Ada yang ingin kamu dengar dari arusnya, meski belum tentu dalam '
          'bentuk kalimat.',
      dominantTheme:
          entries.isEmpty ? 'Awal yang Masih Bisu' : 'Jejak yang Berulang',
      recurringSymbols: recurring.isEmpty
          ? normalizeDreamSymbols(
              const [], entries.map((e) => e.content).join('\n'))
          : recurring.take(5).map((entry) => entry.key).toList(),
      emotionalJourney:
          'Dari keingintahuan yang masih malu-malu, menuju sesuatu yang mulai '
          'berani menampakkan wajahnya. Perjalanannya belum selesai - dan itu '
          'tidak apa-apa.',
      insight:
          'Yang paling sering kembali bukan jawaban, melainkan pertanyaan yang '
          'sama, diulang dengan cara berbeda. Mungkin itu bukan kebetulan.',
      affirmation: 'Aku tidak harus tahu sekarang. Aku cukup hadir.',
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

VOICE AND STYLE - this matters as much as the analysis:
- Write like a poet who happens to know Jung, not like a clinician filing a
  report. The reader is half-awake, holding a fading image; meet them there.
- Use one or two small metaphors or images of your own, drawn from the dream's
  own imagery. Let a well-chosen figure carry the meaning instead of
  explaining it. Prefer "sumur itu menyimpan sesuatu yang belum siap
  dipanggil" over "sumur melambangkan kedalaman alam bawah sadar".
- Allow rhythm and cadence. Vary sentence length; a short sentence after a
  long one lands like a breath. A fragment is allowed.
- In Bahasa Indonesia, choose diction with warmth and literary texture
  (senyap, jejak, samar, rindu, hening, fajar) rather than bureaucratic
  phrasing (proses, mengindikasikan, berkaitan dengan, aspek).
- Never use these stiff connectors: "hal ini menunjukkan bahwa",
  "dapat diartikan sebagai", "berkaitan dengan", "merupakan simbol dari",
  "mencerminkan adanya". Show the image instead of labelling it.
- The reflection question should feel like something a friend whispers, not an
  intake form. It may itself be poetic.

Hard limits:
- Do not become vague or mystical to the point of saying nothing. Every image
  must still trace back to something actually in the dream.
- Still name the emotion plainly; lyricism is for the interpretation, not for
  the primary_emotion field.
- Do not diagnose medical or mental-health conditions.

Respond only as valid JSON with this exact shape:
{
  "interpretation": "...",
  "symbols": ["...", "..."],
  "primary_emotion": "...",
  "secondary_emotions": ["...", "..."],
  "reflection_question": "..."
}
''';

const _weeklySystemPrompt = '''
You are DreamLog AI generating a weekly dream pattern report.
You will receive an array of dream entries. Respond only as valid JSON:
Use recurring_symbols only from this allowed taxonomy:
$dreamSymbolCatalogPrompt

VOICE AND STYLE:
- Write like a poet reading someone's week of dreams, not like an analyst
  summarising a dataset. The reader is meeting themselves here.
- "dominant_theme" is a small title: 3-7 words, evocative and concrete, no
  clinical nouns. Think "Hujan yang Belum Selesai" rather than "Pola Emosional
  Mingguan".
- "affirmation" is one first-person line the reader could almost whisper.
  Let it carry an image; avoid vague self-help phrasing.
- Use one or two metaphors per section, drawn from the week's own symbols.
  Prefer showing the image over naming the mechanism.
- In Bahasa Indonesia, choose diction with warmth and literary texture
  (senyap, jejak, samar, rindu, hening, fajar, ampas, akar) over bureaucratic
  phrasing (proses, mengindikasikan, berkaitan dengan, aspek, terkait).
- Never use: "hal ini menunjukkan bahwa", "dapat diartikan sebagai",
  "berkaitan dengan", "merupakan simbol dari", "mencerminkan adanya".
- Vary sentence length. A short sentence after a long one lands like a breath.

Hard limits:
- Every image must trace back to something actually in the dreams. Do not
  invent symbols or events that are not present.
- recurring_symbols must still be exact taxonomy names, not poetic inventions.
- Keep it grounded: do not drift into vague mysticism.
- Do not diagnose medical or mental-health conditions.

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
