import 'dart:convert';
import '../models/eve_memory.dart';
import '../models/memory_decision.dart';
import 'ai_provider.dart';
import '../models/ai_model_option.dart';

/// AI-powered memory extraction independent of any single model vendor.
class MemoryIntelligenceService {
  final AiProviderRegistry _providers;
  MemoryIntelligenceService(this._providers);

  Future<List<MemoryDecision>> analyzeTurn({
    required String userText,
    required List<EveMemory> relevantMemories,
    required String model,
    required AiProviderId provider,
  }) async {
    if (!userText.trim().isNotEmpty || !_providers.configured(provider)) return const [];
    final memoryContext = relevantMemories.isEmpty
        ? 'No relevant stored memories were retrieved.'
        : relevantMemories.map((m) => '${m.id} | ${m.type.name} | ${m.content} | confidence=${m.confidence.toStringAsFixed(2)}').join('\n');
    final system = '''You are Eve's private memory extraction engine.\nDo NOT answer the user. Analyze the latest message for durable information worth storing, updating, reinforcing, or forgetting.\nReturn ONLY valid JSON: {"decisions":[...]}\nEach decision: operation=create|reinforce|update|forget|ignore; type=semantic|preference|episodic|relationship|skill; content=concise third-person memory statement; importance=0..1; confidence=0..1; target_hint=memory id or short phrase.\nRules: be conservative; never invent facts; don't store transient requests. Never automatically store health/medical, political, religious, sexual, criminal, financial-account, password, identity-number or similarly sensitive information unless the user explicitly asks Eve to remember it. If a preference/fact changes, update instead of duplicating. If nothing durable is present, return {"decisions":[]}.\nRelevant memories:\n$memoryContext''';
    final raw = await _providers.chat(
      AiChatRequest(model: model, messages: [{'role': 'user', 'content': userText.trim()}], systemPrompt: system),
      provider,
    );
    return parseDecisions(raw);
  }

  static List<MemoryDecision> parseDecisions(String raw) {
    var text = raw.trim().replaceFirst(RegExp(r'^```(?:json)?\s*', caseSensitive: false), '').replaceFirst(RegExp(r'\s*```$'), '');
    try {
      final decoded = jsonDecode(text);
      final list = decoded is Map<String, dynamic> ? decoded['decisions'] : decoded;
      if (list is! List) return const [];
      return list.whereType<Map>().map((item) => MemoryDecision.fromJson(Map<String, dynamic>.from(item))).take(5).toList();
    } catch (_) {
      final start = text.indexOf('{'), end = text.lastIndexOf('}');
      if (start >= 0 && end > start) {
        try {
          final decoded = jsonDecode(text.substring(start, end + 1));
          final list = decoded is Map<String, dynamic> ? decoded['decisions'] : null;
          if (list is List) return list.whereType<Map>().map((item) => MemoryDecision.fromJson(Map<String, dynamic>.from(item))).take(5).toList();
        } catch (_) {}
      }
      return const [];
    }
  }
}
