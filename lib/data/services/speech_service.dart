import 'package:speech_to_text/speech_to_text.dart';

/// Locale ids the recorder offers. Matched first against what the device
/// recognizer actually reports, so an uninstalled language degrades to the
/// system default instead of failing silently.
const speechLocaleIds = {
  'Indonesia': 'id_ID',
  'English': 'en_US',
};

class SpeechService {
  SpeechService({SpeechToText? speech}) : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;

  /// [appLanguage] is the Settings choice ('Indonesia' / 'English').
  /// Without a locale the recognizer guesses from the device, which is why
  /// Indonesian speech used to come back as English-looking gibberish.
  Future<bool> initialize({String? appLanguage}) async {
    _localeId = await _resolveLocale(appLanguage);
    return _speech.initialize();
  }

  String? _localeId;

  String? get localeId => _localeId;

  Future<String?> _resolveLocale(String? appLanguage) async {
    final wanted = speechLocaleIds[appLanguage];
    if (wanted == null) {
      return null;
    }
    try {
      final available = await _speech.locales();
      for (final locale in available) {
        if (locale.localeId.replaceAll('-', '_') == wanted) {
          return locale.localeId;
        }
      }
      // No exact match: accept any variant of the same base language
      // (e.g. id-ID when only id_ID is offered).
      final base = wanted.split('_').first;
      for (final locale in available) {
        if (locale.localeId.split(RegExp('[-_]')).first == base) {
          return locale.localeId;
        }
      }
    } catch (_) {
      // locales() is unsupported on some platforms; fall through and let
      // listen() try the requested id directly.
    }
    return wanted;
  }

  bool get isAvailable => _speech.isAvailable;

  Future<void> listen({
    required void Function(String text) onText,
    void Function()? onDone,
    void Function(String error)? onError,
  }) async {
    await _speech.listen(
      localeId: _localeId,
      listenOptions: SpeechListenOptions(
        partialResults: true,
        listenMode: ListenMode.dictation,
      ),
      // Keeps the session alive through natural pauses mid-dream-recall.
      listenFor: const Duration(minutes: 5),
      pauseFor: const Duration(seconds: 5),
      onResult: (result) {
        onText(result.recognizedWords);
        if (result.finalResult) {
          onDone?.call();
        }
      },
    );
  }

  Future<void> stop() => _speech.stop();

  bool get isListening => _speech.isListening;
}
