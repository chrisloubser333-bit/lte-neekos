import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;

class EmbeddingResult {
  final List<double> vector;
  final String provider;
  final String model;
  const EmbeddingResult(this.vector, this.provider, this.model);
}

/// Production semantic embeddings with a deterministic offline fallback.
/// OpenAI text-embedding-3-small is the default production index.
class EmbeddingService {
  String? openAiApiKey;
  final http.Client client;
  static const productionModel = 'text-embedding-3-small';
  static const localModel = 'local-hash-v1';
  static const localDimensions = 128;

  EmbeddingService(this.openAiApiKey, [http.Client? client]) : client = client ?? http.Client();

  void setApiKey(String key) => openAiApiKey = key.trim();

  bool get hasProductionEmbeddings => openAiApiKey != null && openAiApiKey!.trim().isNotEmpty;

  Future<EmbeddingResult> embed(String text) async {
    final clean = text.trim();
    if (hasProductionEmbeddings) {
      try {
        final response = await client.post(
          Uri.parse('https://api.openai.com/v1/embeddings'),
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${openAiApiKey!}'},
          body: jsonEncode({'model': productionModel, 'input': clean, 'encoding_format': 'float'}),
        );
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final vector = List<num>.from(data['data'][0]['embedding']).map((e) => e.toDouble()).toList();
          return EmbeddingResult(vector, 'openai', productionModel);
        }
      } catch (_) {}
    }
    return EmbeddingResult(_localEmbed(clean), 'local', localModel);
  }

  Future<List<EmbeddingResult>> embedBatch(List<String> texts) async {
    if (texts.isEmpty) return const [];
    if (hasProductionEmbeddings) {
      try {
        final response = await client.post(
          Uri.parse('https://api.openai.com/v1/embeddings'),
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${openAiApiKey!}'},
          body: jsonEncode({'model': productionModel, 'input': texts, 'encoding_format': 'float'}),
        );
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final items = List<Map<String, dynamic>>.from(data['data']);
          items.sort((a, b) => (a['index'] as int).compareTo(b['index'] as int));
          return items.map((item) => EmbeddingResult(
            List<num>.from(item['embedding']).map((e) => e.toDouble()).toList(), 'openai', productionModel,
          )).toList();
        }
      } catch (_) {}
    }
    return texts.map((t) => EmbeddingResult(_localEmbed(t), 'local', localModel)).toList();
  }

  List<double> _localEmbed(String text) {
    final vector = List<double>.filled(localDimensions, 0);
    final tokens = text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), ' ').split(RegExp(r'\s+')).where((t) => t.length > 2);
    for (final token in tokens) {
      final h = _hash(token);
      vector[h % localDimensions] += 1;
      vector[_hash('$token:${token.length}') % localDimensions] += .35;
    }
    final norm = math.sqrt(vector.fold<double>(0, (s, v) => s + v * v));
    return norm == 0 ? vector : vector.map((v) => v / norm).toList();
  }

  int _hash(String value) {
    var hash = 2166136261;
    for (final c in value.codeUnits) { hash ^= c; hash = (hash * 16777619) & 0x7fffffff; }
    return hash;
  }
}
