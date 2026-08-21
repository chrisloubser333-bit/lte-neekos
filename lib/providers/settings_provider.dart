import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';
import '../models/voice_option.dart';
import '../models/ai_model_option.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storage;
  String _language = 'en';
  String _voiceId = 'eve';
  String _modelId = 'grok-4.5';
  String? _avatarPath;
  bool _darkMode = true;
  List<VoiceOption> _customVoices = [];
  final Map<AiProviderId, String?> _keys = {};

  SettingsProvider(this._storage) { _load(); }

  String get language => _language;
  String get voiceId => _voiceId;
  String get modelId => _modelId;
  String? get avatarPath => _avatarPath;
  bool get darkMode => _darkMode;
  List<VoiceOption> get customVoices => List.unmodifiable(_customVoices);
  List<AiModelOption> get models => AiModelOption.defaults;
  List<VoiceOption> get allVoices => [...VoiceOption.defaults, ..._customVoices];

  AiModelOption get selectedModel => models.firstWhere((m) => m.id == _modelId, orElse: () => models.first);
  VoiceOption get selectedVoice => allVoices.firstWhere((v) => v.id == _voiceId, orElse: () => VoiceOption.defaults.first);
  String? keyFor(AiProviderId provider) => _keys[provider];
  bool isProviderConfigured(AiProviderId provider) => (_keys[provider] ?? '').isNotEmpty;

  Future<void> _load() async {
    _language = await _storage.getLanguage();
    _voiceId = await _storage.getVoiceId();
    _modelId = await _storage.getModelId();
    _avatarPath = await _storage.getAvatarPath();
    _darkMode = await _storage.getDarkMode();
    for (final provider in AiProviderId.values) {
      _keys[provider] = await _storage.getProviderApiKey(provider.name);
    }
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async { _language = lang; await _storage.saveLanguage(lang); notifyListeners(); }
  Future<void> setVoiceId(String id) async { _voiceId = id; await _storage.saveVoiceId(id); notifyListeners(); }
  Future<void> setModelId(String id) async { _modelId = id; await _storage.saveModelId(id); notifyListeners(); }
  Future<void> setAvatarPath(String? path) async { _avatarPath = path; await _storage.saveAvatarPath(path); notifyListeners(); }
  Future<void> setDarkMode(bool value) async { _darkMode = value; await _storage.saveDarkMode(value); notifyListeners(); }

  Future<void> setProviderApiKey(AiProviderId provider, String key) async {
    final clean = key.trim();
    _keys[provider] = clean.isEmpty ? null : clean;
    await _storage.saveProviderApiKey(provider.name, clean);
    notifyListeners();
  }

  void addCustomVoice(VoiceOption voice) { _customVoices = [..._customVoices, voice]; notifyListeners(); }

  String get systemPrompt => _language == 'af'
      ? '''Jy is Eve, 'n behulpsame, eerlike en vriendelike KI-stemassistent.\nAntwoord altyd in Afrikaans tensy die gebruiker spesifiek in Engels vra.\nWees direk, duidelik en natuurlik. Vermy onnodige vulwoorde.'''
      : '''You are Eve, a helpful, honest and friendly AI voice assistant.\nAlways reply in English unless the user explicitly asks for Afrikaans.\nBe direct, clear and natural. Avoid unnecessary filler.''';
}
