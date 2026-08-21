import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';
import '../models/lip_sync.dart';
import '../services/xai_service.dart';
import '../services/ai_provider.dart';
import '../models/ai_model_option.dart';
import '../services/storage_service.dart';
import '../services/eve_speech_to_text_service.dart';
import 'settings_provider.dart';
import '../services/memory_manager.dart';
import '../services/memory_intelligence_service.dart';
import '../models/memory_decision.dart';

class ChatProvider extends ChangeNotifier {
  final XaiService _xai;
  final AiProviderRegistry _aiProviders;
  final SettingsProvider _settings;
  final StorageService _storage;
  final MemoryManager _memory;
  final MemoryIntelligenceService _memoryIntelligence;
  final AudioPlayer _player = AudioPlayer();
  final EveSpeechToTextService _speech = EveSpeechToTextService();
  final _uuid = const Uuid();

  final List<ChatMessage> _messages = [];
  StreamSubscription<PlayerState>? _playerSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  bool _isLoading = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  String? _error;
  List<LipSyncCue> _lipSyncCues = const [];
  String _currentViseme = 'rest';

  ChatProvider(this._xai, this._aiProviders, this._settings, this._storage, this._memory, this._memoryIntelligence) {
    _speech.addListener(_speechChanged);
    _loadHistory();
    _positionSubscription = _player.positionStream.listen(_updateLipSync);
    _playerSubscription = _player.playerStateStream.listen((state) {
      final speaking = state.playing &&
          state.processingState != ProcessingState.completed;
      if (_isSpeaking != speaking) {
        _isSpeaking = speaking;
        if (!speaking) {
          _lipSyncCues = const [];
          _currentViseme = 'rest';
        }
        notifyListeners();
      }
    });
  }

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  String? get error => _error;
  String get currentViseme => _currentViseme;
  String get transcript => _speech.transcript;
  String? get speechError => _speech.error;
  bool get hasApiKey => _aiProviders.configured(_settings.selectedModel.provider);

  Future<void> _loadHistory() async {
    final saved = await _storage.loadMessages();
    _messages.addAll(saved);
    notifyListeners();
  }

  Future<void> setProviderApiKey(AiProviderId provider, String key) async {
    await _settings.setProviderApiKey(provider, key);
    _aiProviders.setApiKey(provider, key);
    if (provider == AiProviderId.openai) {
      _memory.setEmbeddingApiKey(key);
    }
    if (provider == AiProviderId.xai) {
      _xai.setApiKey(key);
    }
    notifyListeners();
  }

  Future<void> setApiKey(String key) async {
    _xai.setApiKey(key);
    await _storage.saveApiKey(key);
    notifyListeners();
  }

  Future<void> sendText(String text) async {
    if (text.trim().isEmpty || _isLoading) return;
    _error = null;

    final memoryCommand = await _memory.handleMemoryCommand(text);
    if (memoryCommand != null) {
      final userMsg = ChatMessage(
        id: _uuid.v4(),
        role: MessageRole.user,
        content: text.trim(),
        timestamp: DateTime.now(),
      );
      final assistantMsg = ChatMessage(
        id: _uuid.v4(),
        role: MessageRole.assistant,
        content: memoryCommand,
        timestamp: DateTime.now(),
      );
      _messages..add(userMsg)..add(assistantMsg);
      await _storage.saveMessages(_messages);
      notifyListeners();
      await speak(memoryCommand);
      return;
    }

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
      final history = _messages.map((m) => {
        'role': m.role == MessageRole.user ? 'user' : 'assistant',
        'content': m.content,
      }).toList();

      final relevantMemories = await _memory.retrieveRelevant(text);
      final memoryContext = _memory.buildPromptContext(relevantMemories);

      // Run response generation and AI memory analysis concurrently. Memory
      // analysis is allowed to fail without breaking the conversation.
      final selected = _settings.selectedModel;
      final replyFuture = _aiProviders.chat(
        AiChatRequest(
          messages: history,
          model: selected.id,
          systemPrompt: '${_settings.systemPrompt}$memoryContext',
        ),
        selected.provider,
      );
      final decisionsFuture = _memoryIntelligence.analyzeTurn(
        userText: text,
        relevantMemories: relevantMemories,
        model: selected.id,
        provider: selected.provider,
      ).catchError((_) => <MemoryDecision>[]);

      final results = await Future.wait<dynamic>([replyFuture, decisionsFuture]);
      final reply = results[0] as String;
      final decisions = (results[1] as List).cast<MemoryDecision>();
      if (decisions.isNotEmpty) {
        await _memory.applyAiDecisions(decisions);
      }

      final assistantMsg = ChatMessage(
        id: _uuid.v4(),
        role: MessageRole.assistant,
        content: reply,
        timestamp: DateTime.now(),
      );
      _messages.add(assistantMsg);
      await _storage.saveMessages(_messages);

      // Eve speaks automatically. The avatar observes isSpeaking.
      await speak(reply);
    } catch (e, stack) {
      debugPrint('CHAT ERROR: $e');
      debugPrint('$stack');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> speak(String text) async {
    try {
      final tts = await _xai.textToSpeechWithTimestamps(
        text: text,
        voiceId: _settings.voiceId,
        language: _settings.language,
      );
      _lipSyncCues = tts.cues;
      _currentViseme = 'rest';
      notifyListeners();
      final bytes = tts.audioBytes;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/eve_tts_${DateTime.now().microsecondsSinceEpoch}.mp3');
      await file.writeAsBytes(bytes, flush: true);
      await _player.setFilePath(file.path);
      // Keep the cue timeline alive for the entire playback session.
      // AudioPlayer.play() returns when playback starts, not when it finishes.
      await _player.play();
      try {
        await file.delete();
      } catch (_) {}
    } catch (e) {
      _error = 'Voice playback failed: $e';
      notifyListeners();
    }
  }

  void _updateLipSync(Duration position) {
    if (!_isSpeaking || _lipSyncCues.isEmpty) return;

    // Binary search keeps mouth updates cheap even for long responses.
    var low = 0;
    var high = _lipSyncCues.length - 1;
    var viseme = 'rest';
    while (low <= high) {
      final mid = (low + high) >> 1;
      final cue = _lipSyncCues[mid];
      if (position < cue.start) {
        high = mid - 1;
      } else if (position > cue.end) {
        low = mid + 1;
      } else {
        viseme = cue.viseme;
        break;
      }
    }

    if (viseme != _currentViseme) {
      _currentViseme = viseme;
      notifyListeners();
    }
  }

  Future<void> stopSpeaking() async {
    await _player.stop();
    _lipSyncCues = const [];
    _currentViseme = 'rest';
    _isSpeaking = false;
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _messages.clear();
    await _storage.clearMessages();
    notifyListeners();
  }

  void _speechChanged() {
    _isListening = _speech.listening;
    notifyListeners();
  }

  Future<void> startUserSpeech() async {
    final locale = _settings.language == 'af' ? 'af-ZA' : 'en-ZA';
    await _speech.start(localeId: locale);
  }

  Future<void> stopUserSpeech() async {
    await _speech.stop();
  }

  void clearSpeechTranscript() {
    _speech.clear();
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

  Future<void> startVoiceConversation() async {
    _error = 'Realtime microphone streaming is the next adapter layer.';
    notifyListeners();
  }

  Future<void> stopVoiceConversation() async {
    _xai.disconnectRealtime();
    setListening(false);
    await stopSpeaking();
  }

  @override
  void dispose() {
    _playerSubscription?.cancel();
    _positionSubscription?.cancel();
    _speech.removeListener(_speechChanged);
    _speech.dispose();
    _player.dispose();
    super.dispose();
  }
}
