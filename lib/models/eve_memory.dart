import 'dart:math' as math;

enum EveMemoryType {
  semantic,
  preference,
  episodic,
  relationship,
  skill,
}

class EveMemory {
  final String id;
  final EveMemoryType type;
  final String content;
  final double importance;
  final double confidence;
  final int reinforcementCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastUsedAt;
  final String source;
  final bool pinned;
  final bool archived;
  final List<double> embedding;
  final String embeddingProvider;
  final String embeddingModel;

  const EveMemory({
    required this.id,
    required this.type,
    required this.content,
    required this.importance,
    required this.confidence,
    required this.reinforcementCount,
    required this.createdAt,
    required this.updatedAt,
    required this.lastUsedAt,
    required this.source,
    required this.pinned,
    required this.archived,
    required this.embedding,
    this.embeddingProvider = 'local',
    this.embeddingModel = 'local-hash-v1',
  });

  EveMemory copyWith({
    EveMemoryType? type,
    String? content,
    double? importance,
    double? confidence,
    int? reinforcementCount,
    DateTime? updatedAt,
    DateTime? lastUsedAt,
    String? source,
    bool? pinned,
    bool? archived,
    List<double>? embedding,
    String? embeddingProvider,
    String? embeddingModel,
  }) {
    return EveMemory(
      id: id,
      type: type ?? this.type,
      content: content ?? this.content,
      importance: importance ?? this.importance,
      confidence: confidence ?? this.confidence,
      reinforcementCount: reinforcementCount ?? this.reinforcementCount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      source: source ?? this.source,
      pinned: pinned ?? this.pinned,
      archived: archived ?? this.archived,
      embedding: embedding ?? this.embedding,
      embeddingProvider: embeddingProvider ?? this.embeddingProvider,
      embeddingModel: embeddingModel ?? this.embeddingModel,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'content': content,
        'importance': importance,
        'confidence': confidence,
        'reinforcementCount': reinforcementCount,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'lastUsedAt': lastUsedAt.toIso8601String(),
        'source': source,
        'pinned': pinned,
        'archived': archived,
        'embedding': embedding,
        'embeddingProvider': embeddingProvider,
        'embeddingModel': embeddingModel,
      };

  factory EveMemory.fromJson(Map<String, dynamic> json) {
    return EveMemory(
      id: json['id'] as String,
      type: EveMemoryType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => EveMemoryType.semantic,
      ),
      content: json['content'] as String,
      importance: (json['importance'] as num?)?.toDouble() ?? .5,
      confidence: (json['confidence'] as num?)?.toDouble() ?? .7,
      reinforcementCount: (json['reinforcementCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastUsedAt: DateTime.parse(json['lastUsedAt'] as String),
      source: json['source'] as String? ?? 'conversation',
      pinned: json['pinned'] as bool? ?? false,
      archived: json['archived'] as bool? ?? false,
      embedding: (json['embedding'] as List? ?? const []).map((e) => (e as num).toDouble()).toList(),
      embeddingProvider: json['embeddingProvider'] as String? ?? 'local',
      embeddingModel: json['embeddingModel'] as String? ?? 'local-hash-v1',
    );
  }

  /// Memory lifecycle score: importance + confidence + reinforcement + recency.
  double lifecycleScore(DateTime now) {
    final ageDays = math.max(0, now.difference(lastUsedAt).inHours / 24);
    final recency = math.exp(-ageDays / 45);
    final reinforcement = math.min(1, reinforcementCount / 5);
    return (importance * .42) +
        (confidence * .28) +
        (reinforcement * .15) +
        (recency * .15) +
        (pinned ? .2 : 0);
  }
}
