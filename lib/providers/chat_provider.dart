import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';
import '../services/xai_service.dart';
import '../services/storage_service.dart';
import 'settings_provider.dart';

class ChatProvider extends ChangeNotifier {
  final XaiService _xai;
  final SettingsProvider _settings;
  final StorageService _storage;
  final _uuid = const Uuid();

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  String? _error;

  ChatProvider(this._xai, this._settings, this._storage) {
    _loadHistory();
  }

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  String? get error => _error;
  bool get hasApiKey => _xai.hasApiKey;

  Future<void> _loadHistory() async {
    final saved = await _storage.loadMessages();
    _messages.addAll(saved);
    notifyListeners();
  }

  Future<void> setApiKey(String key) async {
    _xai.setApiKey(key);
    await _storage.saveApiKey(key);
    notifyListeners();
  }

  Future<void> sendText(String text) async {
    if (text.trim().isEmpty) return;
    _error = null;

    final userMsg = ChatMessage(
      id: _uuid.v4(),
      role: MessageRole.user,
      content: text.trim(),
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);
    _isLoading = true;
    notifyListeners();

    try {
      final history = _messages
          .where((m) => m.role != MessageRole.system)
          .map((m) => {
                'role': m.role == MessageRole.user ? 'user' : 'assistant',
                'content': m.content,
              })
          .toList();

      final reply = await _xai.chatCompletion(
        messages: history,
        systemPrompt: _settings.systemPrompt,
      );

      final assistantMsg = ChatMessage(
        id: _uuid.v4(),
        role: MessageRole.assistant,
        content: reply,
        timestamp: DateTime.now(),
      );
      _messages.add(assistantMsg);

      // Optionally speak the reply
      // await _speak(reply);

      await _storage.saveMessages(_messages);
    } catch (e, stack) {
      print('CHAT ERROR: $e');
      print(stack);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearHistory() async {
    _messages.clear();
    await _storage.clearMessages();
    notifyListeners();
  }

  void setListening(bool value) {
    _isListening = value;
    notifyListeners();
  }

  void setSpeaking(bool value) {
    _isSpeaking = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Placeholder for full realtime voice loop
  // In a complete implementation this would:
  // 1. Start microphone stream
  // 2. Connect to xAI realtime WebSocket
  // 3. Stream audio chunks
  // 4. Play back response audio
  Future<void> startVoiceConversation() async {
    // TODO: implement full realtime pipeline
    // For now the UI will show that voice is coming
  }

  Future<void> stopVoiceConversation() async {
    _xai.disconnectRealtime();
    setListening(false);
    setSpeaking(false);
  }
}
