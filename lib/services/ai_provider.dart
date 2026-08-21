import '../models/ai_model_option.dart';

class AiChatRequest {
  final String model;
  final List<Map<String, String>> messages;
  final String? systemPrompt;
  const AiChatRequest({required this.model, required this.messages, this.systemPrompt});
}

abstract class AiProvider {
  AiProviderId get id;
  bool get isConfigured;
  Future<String> chat(AiChatRequest request);
  void setApiKey(String key) {}
}

class AiProviderRegistry {
  final Map<AiProviderId, AiProvider> _providers;
  AiProviderRegistry(Iterable<AiProvider> providers)
      : _providers = {for (final p in providers) p.id: p};

  AiProvider providerFor(AiProviderId id) {
    final provider = _providers[id];
    if (provider == null) throw StateError('No AI provider registered for $id');
    return provider;
  }

  Future<String> chat(AiChatRequest request, AiProviderId provider) =>
      providerFor(provider).chat(request);

  bool configured(AiProviderId provider) => _providers[provider]?.isConfigured ?? false;
  void setApiKey(AiProviderId provider, String key) => _providers[provider]?.setApiKey(key);
}
