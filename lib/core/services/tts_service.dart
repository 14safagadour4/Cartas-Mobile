import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io' show Platform;

class TtsService {
  static final TtsService _instance = TtsService._internal();
  final FlutterTts _flutterTts = FlutterTts();
  final Completer<void> _initCompleter = Completer<void>();

  factory TtsService() {
    return _instance;
  }

  TtsService._internal() {
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      // Small delay to allow the engine to bind natively
      await Future.delayed(const Duration(milliseconds: 500));
      
      await _configureEngine();
      
      if (!_initCompleter.isCompleted) {
        _initCompleter.complete();
      }
    } catch (e) {
      print("TTS Init Error: $e");
      if (!_initCompleter.isCompleted) {
        _initCompleter.completeError(e);
      }
    }
  }

  Future<void> _configureEngine() async {
    try {
      // Force Android to list languages (this often triggers the native binding)
      final dynamic languages = await _flutterTts.getLanguages;
      print("Available TTS languages: $languages");
      
      if (languages == null || (languages is List && languages.isEmpty)) {
        print("WARNING: No TTS engines or languages found on this device.");
      }

      await _flutterTts.setLanguage("ar-SA");
      await _flutterTts.setPitch(1.1);
      await _flutterTts.setSpeechRate(0.5);

      if (Platform.isIOS) {
        await _flutterTts.setSharedInstance(true);
        await _flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playAndRecord,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
            IosTextToSpeechAudioCategoryOptions.defaultToSpeaker
          ],
        );
      }
    } catch (e) {
      print("Error configuring TTS engine: $e");
    }
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    try {
      // Wait for initialization (with a fallback timeout of 2 seconds)
      await _initCompleter.future.timeout(const Duration(seconds: 2), onTimeout: () {
        print("TTS Initialization taking longer than expected...");
      });

      await _flutterTts.speak(text);
    } catch (e) {
      print("TTS Speak failed or timed out: $e");
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  void dispose() {
    _flutterTts.stop();
  }
}
