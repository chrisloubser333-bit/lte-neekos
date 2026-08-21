import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/message.dart';
import '../models/eve_memory.dart';

class StorageService {
  static const _keyApiKey = 'xai_api_key';
  static String providerKey(String provider) => 'ai_api_key_$provider';
  static const _keyLanguage = 'preferred_language';
  static const _keyVoiceId = 'selected_voice_id';
  static const _keyModelId = 'selected_model_id';
  static const _keyAvatarPath = 'avatar_path';
  static const _keyDarkMode = 'dark_mode';
  static const _keyMessages = 'chat_messages';
  static const _keyMemories = 'eve_long_term_memories_v1';

  late SharedPreferences _prefs;
  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Migrate an older API key from SharedPreferences into encrypted storage.
    final legacyKey = _prefs.getString(_keyApiKey);
    final secureKey = await _secure.read(key: _keyApiKey);
    if ((secureKey == null || secureKey.isEmpty) && legacyKey != null && legacyKey.isNotEmpty) {
      await _secure.write(key: _keyApiKey, value: legacyKey);
      await _secure.write(key: providerKey('xai'), value: legacyKey);
      await _prefs.remove(_keyApiKey);
    }
  }

  // API Key
  Future<void> saveApiKey(String key) async {
    await _secure.write(key: _keyApiKey, value: key);
    await saveProviderApiKey('xai', key);
  }

  Future<String?> getApiKey() async {
    return _secure.read(key: _keyApiKey);
  }


  Future<void> saveProviderApiKey(String provider, String key) async {
    final storageKey = providerKey(provider);
    if (key.trim().isEmpty) {
      await _secure.delete(key: storageKey);
    } else {
      await _secure.write(key: storageKey, value: key.trim());
    }
  }

  Future<String?> getProviderApiKey(String provider) async {
    return _secure.read(key: providerKey(provider));
  }

  // Language: 'en' or 'af'
  Future<void> saveLanguage(String lang) async {
    await _prefs.setString(_keyLanguage, lang);
  }

  Future<String> getLanguage() async {
    return _prefs.getString(_keyLanguage) ?? 'en';
  }

  // Voice
  Future<void> saveVoiceId(String voiceId) async {
    await _prefs.setString(_keyVoiceId, voiceId);
  }

  Future<String> getVoiceId() async {
    return _prefs.getString(_keyVoiceId) ?? 'eve';
  }

  Future<void> saveModelId(String modelId) async {
    await _prefs.setString(_keyModelId, modelId);
  }

  Future<String> getModelId() async {
    return _prefs.getString(_keyModelId) ?? 'grok-4.5';
  }

  Future<void> saveAvatarPath(String? path) async {
    if (path == null || path.isEmpty) {
      await _prefs.remove(_keyAvatarPath);
    } else {
      await _prefs.setString(_keyAvatarPath, path);
    }
  }

  Future<String?> getAvatarPath() async {
    return _prefs.getString(_keyAvatarPath);
  }

  // Dark mode
  Future<void> saveDarkMode(bool value) async {
    await _prefs.setBool(_keyDarkMode, value);
  }

  Future<bool> getDarkMode() async {
    return _prefs.getBool(_keyDarkMode) ?? true;
  }

  // Chat history (simple local persistence)
  Future<void> saveMessages(List<ChatMessage> messages) async {
    final list = messages.map((m) => m.toJson()).toList();
    await _prefs.setString(_keyMessages, jsonEncode(list));
  }

  Future<List<ChatMessage>> loadMessages() async {
    final raw = _prefs.getString(_keyMessages);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> clearMessages() async {
    await _prefs.remove(_keyMessages);
  }

  // Eve long-term memory
  Future<void> saveMemories(List<EveMemory> memories) async {
    final list = memories.map((m) => m.toJson()).toList();
    await _secure.write(key: _keyMemories, value: jsonEncode(list));
  }

  Future<List<EveMemory>> loadMemories() async {
    final raw = await _secure.read(key: _keyMemories);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => EveMemory.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> clearMemories() async {
    await _secure.delete(key: _keyMemories);
  }

}
