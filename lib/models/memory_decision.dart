import 'eve_memory.dart';

class MemoryDecision {
  final String operation;
  final EveMemoryType type;
  final String content;
  final double importance;
  final double confidence;
  final String targetHint;

  const MemoryDecision({
    required this.operation,
    required this.type,
    required this.content,
    required this.importance,
    required this.confidence,
    required this.targetHint,
  });

  factory MemoryDecision.fromJson(Map<String, dynamic> json) {
    final rawType = (json['type'] ?? 'semantic').toString().toLowerCase();
    final type = EveMemoryType.values.firstWhere(
      (e) => e.name == rawType,
      orElse: () => EveMemoryType.semantic,
    );
    double number(dynamic value, double fallback) =>
        value is num ? value.toDouble().clamp(0, 1).toDouble() : fallback;

    return MemoryDecision(
      operation: (json['operation'] ?? 'ignore').toString().toLowerCase(),
      type: type,
      content: (json['content'] ?? '').toString().trim(),
      importance: number(json['importance'], .5),
      confidence: number(json['confidence'], .7),
      targetHint: (json['target_hint'] ?? '').toString().trim(),
    );
  }
}
