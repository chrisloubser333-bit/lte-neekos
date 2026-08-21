import 'package:flutter_test/flutter_test.dart';
import 'package:listen_with_eve/models/ai_model_option.dart';
import 'package:listen_with_eve/services/ai_provider.dart';

class FakeProvider implements AiProvider {
  @override final AiProviderId id;
  @override final bool isConfigured;
  FakeProvider(this.id, {this.isConfigured = true});
  @override Future<String> chat(AiChatRequest request) async => '${id.name}:${request.model}';
}

void main() {
  test('routes a model to its provider', () async {
    final registry = AiProviderRegistry([
      FakeProvider(AiProviderId.openai),
      FakeProvider(AiProviderId.anthropic),
    ]);
    final result = await registry.chat(
      const AiChatRequest(model: 'gpt-5.6', messages: []),
      AiProviderId.openai,
    );
    expect(result, 'openai:gpt-5.6');
  });

  test('all selectable models declare a provider', () {
    expect(AiModelOption.defaults, isNotEmpty);
    expect(AiModelOption.defaults.every((m) => AiModelOption.defaults.any((x) => x.provider == m.provider)), isTrue);
  });
}
