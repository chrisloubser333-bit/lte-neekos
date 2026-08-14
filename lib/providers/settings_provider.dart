import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';
import '../models/voice_option.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storage;

  String _language = 'en'; // 'en' or 'af'
  String _voiceId = 'eve';
  bool _darkMode = true;
  List<VoiceOption> _customVoices = [];

  SettingsProvider(this._storage) {
    _load();
  }

  String get language => _language;
  String get voiceId => _voiceId;
  bool get darkMode => _darkMode;
  List<VoiceOption> get customVoices => _customVoices;

  List<VoiceOption> get allVoices => [
        ...VoiceOption.defaults,
        ..._customVoices,
      ];

  VoiceOption get selectedVoice {
    return allVoices.firstWhere(
      (v) => v.id == _voiceId,
      orElse: () => VoiceOption.defaults.first,
    );
  }

  Future<void> _load() async {
    _language = await _storage.getLanguage();
    _voiceId = await _storage.getVoiceId();
    _darkMode = await _storage.getDarkMode();
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    await _storage.saveLanguage(lang);
    notifyListeners();
  }

  Future<void> setVoiceId(String id) async {
    _voiceId = id;
    await _storage.saveVoiceId(id);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    await _storage.saveDarkMode(value);
    notifyListeners();
  }

  void addCustomVoice(VoiceOption voice) {
    _customVoices = [..._customVoices, voice];
    notifyListeners();
  }

  String get systemPrompt {
    if (_language == 'af') {
      return '''
Jy is Grok, 'n behulpsame, eerlike en maksimaal waarheidsoekende KI gebou deur xAI.
Antwoord altyd in Afrikaans tensy die gebruiker spesifiek in Engels vra.
Wees direk, duidelik en vriendelik. Moenie onnodige woorde gebruik nie.
''';
    }
    return '''
You are Grok, a helpful, honest and maximally truth-seeking AI built by xAI.
Always reply in English unless the user explicitly asks for Afrikaans.
Be direct, clear and friendly. Avoid unnecessary filler.
''';
  }
}
