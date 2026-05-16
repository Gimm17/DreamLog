import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  SpeechService({SpeechToText? speech}) : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;

  Future<bool> initialize() => _speech.initialize();

  Future<void> listen({
    required void Function(String text) onText,
    void Function()? onDone,
  }) async {
    await _speech.listen(
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
