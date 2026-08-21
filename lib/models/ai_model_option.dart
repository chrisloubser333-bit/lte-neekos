enum AiProviderId { xai, openai, anthropic, google }

class AiModelOption {
  final String id;
  final String name;
  final AiProviderId provider;
  final String description;

  const AiModelOption({
    required this.id,
    required this.name,
    required this.provider,
    required this.description,
  });

  static const defaults = [
    AiModelOption(id: 'grok-4.5', name: 'Grok 4.5', provider: AiProviderId.xai, description: 'Fast conversational reasoning'),
    AiModelOption(id: 'grok-4.1-fast', name: 'Grok Fast', provider: AiProviderId.xai, description: 'Low-latency conversations'),
    AiModelOption(id: 'gpt-5.6', name: 'GPT-5.6', provider: AiProviderId.openai, description: 'Advanced general intelligence'),
    AiModelOption(id: 'gpt-5.6-mini', name: 'GPT-5.6 Mini', provider: AiProviderId.openai, description: 'Fast and cost-efficient'),
    AiModelOption(id: 'claude-sonnet-4-20250514', name: 'Claude Sonnet', provider: AiProviderId.anthropic, description: 'Strong writing and reasoning'),
    AiModelOption(id: 'gemini-2.5-pro', name: 'Gemini Pro', provider: AiProviderId.google, description: 'Multimodal reasoning option'),
  ];
}
