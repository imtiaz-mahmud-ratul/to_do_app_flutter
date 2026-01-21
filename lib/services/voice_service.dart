import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  Future<bool> initSpeech() async {
    return await _speech.initialize();
  }

  Future<void> speak(String text) async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.95);
    await _tts.setPitch(1.1);
    await _tts
        .setVoice({'name': 'en-us-x-sfg#female_1-local', 'locale': 'en-US'});
    await _tts.speak(text);
  }

  Future<void> stopSpeak() async {
    await _tts.stop();
  }

  Future<void> listen({
    required Function(String) onResult,
  }) async {
    await _speech.listen(
      onResult: (res) {
        if (res.finalResult) onResult(res.recognizedWords);
      },
      listenMode: stt.ListenMode.confirmation,
      localeId: 'en_US',
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }
}
