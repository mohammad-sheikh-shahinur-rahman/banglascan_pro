
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

enum TtsState { playing, stopped, paused }

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  TtsState _ttsState = TtsState.stopped;

  TtsState get ttsState => _ttsState;

  /// Initializes the TTS engine with professional settings
  Future<void> initTts() async {
    try {
      // Primary language for this app is Bengali
      await _flutterTts.setLanguage("bn-BD");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() {
        _ttsState = TtsState.playing;
      });

      _flutterTts.setCompletionHandler(() {
        _ttsState = TtsState.stopped;
      });

      _flutterTts.setErrorHandler((msg) {
        _ttsState = TtsState.stopped;
        debugPrint("TTS_ERROR: $msg");
      });

      _flutterTts.setCancelHandler(() {
        _ttsState = TtsState.stopped;
      });

    } catch (e) {
      debugPrint("TTS_INIT_ERROR: $e");
    }
  }

  /// Speaks the given text, automatically detects if it should use English or Bengali
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;

    // Detect if text contains mostly English characters to switch language dynamically
    bool isEnglish = !RegExp(r'[\u0980-\u09FF]').hasMatch(text);
    if (isEnglish) {
      await _flutterTts.setLanguage("en-US");
    } else {
      await _flutterTts.setLanguage("bn-BD");
    }

    _ttsState = TtsState.playing;
    await _flutterTts.speak(text);
  }

  /// Stops the speech
  Future<void> stop() async {
    await _flutterTts.stop();
    _ttsState = TtsState.stopped;
  }
}
