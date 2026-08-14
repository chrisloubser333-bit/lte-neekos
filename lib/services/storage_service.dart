import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';

class StorageService {
  static const _keyApiKey = 'xai_api_key';
  static const _keyLanguage = 'preferred_language';
  static const _keyVoiceId = 'selected_voice_id';
  static const _keyDarkMode = 'dark_mode';
  static const _keyMessages = 'chat_messages';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // API Key
  Future<void> saveApiKey(String key) async {
    await _prefs.setString(_keyApiKey, key);
  }

  Future<String?> getApiKey() async {
    return _prefs.getString(_keyApiKey);
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
}
