import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class EveSpeechToTextService extends ChangeNotifier {
  final SpeechToText _speech = SpeechToText();

  bool _initialized = false;
  bool _available = false;
  bool _listening = false;
  String _transcript = '';
  String? _error;

  bool get available => _available;
  bool get listening => _listening;
  String get transcript => _transcript;
  String? get error => _error;

  Future<bool> initialize() async {
    if (_initialized) return _available;

    _available = await _speech.initialize(
      onStatus: (status) {
        _listening = status == 'listening';
        notifyListeners();
      },
      onError: (error) {
        _error = error.errorMsg;
        _listening = false;
        notifyListeners();
      },
    );
    _initialized = true;
    notifyListeners();
    return _available;
  }

  Future<void> start({String? localeId}) async {
    _error = null;
    final ok = await initialize();
    if (!ok) {
      _error = 'Speech recognition is unavailable or microphone permission was denied.';
      notifyListeners();
      return;
    }

    _transcript = '';
    await _speech.listen(
      localeId: localeId,
      partialResults: true,
      onResult: _onResult,
    );
    _listening = true;
    notifyListeners();
  }

  Future<void> stop() async {
    await _speech.stop();
    _listening = false;
    notifyListeners();
  }

  Future<void> cancel() async {
    await _speech.cancel();
    _listening = false;
    _transcript = '';
    notifyListeners();
  }

  void clear() {
    _transcript = '';
    _error = null;
    notifyListeners();
  }

  void _onResult(SpeechRecognitionResult result) {
    _transcript = result.recognizedWords;
    notifyListeners();
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }
}
