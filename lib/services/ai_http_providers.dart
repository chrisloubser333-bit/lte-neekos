import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ai_provider.dart';
import '../models/ai_model_option.dart';

abstract class _HttpProviderBase implements AiProvider {
  String? apiKey;
  final http.Client client;
  _HttpProviderBase(this.apiKey, [http.Client? client]) : client = client ?? http.Client();
  @override
  void setApiKey(String key) => apiKey = key.trim();
  @override
  bool get isConfigured => apiKey != null && apiKey!.trim().isNotEmpty;
  void requireKey() { if (!isConfigured) throw StateError('API key not configured for $id'); }
  Map<String, String> bearerHeaders() => {'Content-Type': 'application/json', 'Authorization': 'Bearer ${apiKey!}'};
}

class OpenAiProvider extends _HttpProviderBase {
  OpenAiProvider(super.apiKey, [super.client]);
  @override AiProviderId get id => AiProviderId.openai;

  @override
  Future<String> chat(AiChatRequest request) async {
    requireKey();
    final input = <Map<String, String>>[
      if (request.systemPrompt != null) {'role': 'developer', 'content': request.systemPrompt!},
      ...request.messages,
    ];
    final response = await client.post(
      Uri.parse('https://api.openai.com/v1/responses'),
      headers: bearerHeaders(),
      body: jsonEncode({'model': request.model, 'input': input}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('OpenAI error ${response.statusCode}: ${response.body}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final outputText = data['output_text'];
    if (outputText is String) return outputText;
    final output = data['output'];
    if (output is List) {
      for (final item in output) {
        if (item is Map && item['content'] is List) {
          for (final part in item['content']) {
            if (part is Map && part['text'] is String) return part['text'] as String;
          }
        }
      }
    }
    throw Exception('OpenAI returned no text output');
  }
}

class AnthropicProvider extends _HttpProviderBase {
  AnthropicProvider(super.apiKey, [super.client]);
  @override AiProviderId get id => AiProviderId.anthropic;

  @override
  Future<String> chat(AiChatRequest request) async {
    requireKey();
    final response = await client.post(
      Uri.parse('https://api.anthropic.com/v1/messages'),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey!,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': request.model,
        'max_tokens': 2048,
        if (request.systemPrompt != null) 'system': request.systemPrompt,
        'messages': request.messages,
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Anthropic error ${response.statusCode}: ${response.body}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content = data['content'];
    if (content is List) {
      for (final part in content) {
        if (part is Map && part['text'] is String) return part['text'] as String;
      }
    }
    throw Exception('Anthropic returned no text output');
  }
}

class GoogleGeminiProvider extends _HttpProviderBase {
  GoogleGeminiProvider(super.apiKey, [super.client]);
  @override AiProviderId get id => AiProviderId.google;

  @override
  Future<String> chat(AiChatRequest request) async {
    requireKey();
    final contents = request.messages.map((m) => {
      'role': m['role'] == 'assistant' ? 'model' : 'user',
      'parts': [{'text': m['content'] ?? ''}],
    }).toList();
    final response = await client.post(
      Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/${request.model}:generateContent?key=${Uri.encodeQueryComponent(apiKey!)}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        if (request.systemPrompt != null) 'systemInstruction': {'parts': [{'text': request.systemPrompt}]},
        'contents': contents,
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gemini error ${response.statusCode}: ${response.body}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'];
    if (candidates is List && candidates.isNotEmpty) {
      final parts = candidates.first['content']?['parts'];
      if (parts is List) {
        for (final part in parts) {
          if (part is Map && part['text'] is String) return part['text'] as String;
        }
      }
    }
    throw Exception('Gemini returned no text output');
  }
}
