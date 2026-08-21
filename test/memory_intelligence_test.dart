import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/models/eve_memory.dart';
import '../lib/services/memory_intelligence_service.dart';
import '../lib/services/memory_manager.dart';
import '../lib/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async => SharedPreferences.setMockInitialValues({}));

  test('parses structured AI memory decisions', () {
    final decisions = MemoryIntelligenceService.parseDecisions('''
```json
{"decisions":[{"operation":"create","type":"preference","content":"User prefers voice conversations","importance":0.9,"confidence":0.95,"target_hint":"voice"}]}
```
''');
    expect(decisions, hasLength(1));
    expect(decisions.first.operation, 'create');
    expect(decisions.first.type, EveMemoryType.preference);
    expect(decisions.first.importance, closeTo(.9, .001));
  });

  test('applies AI create and reinforce decisions', () async {
    final storage = StorageService();
    await storage.init();
    final manager = MemoryManager(storage);
    await manager.remember(
      'User prefers voice conversations',
      type: EveMemoryType.preference,
      importance: .8,
      confidence: .7,
    );

    await manager.applyAiDecisions([
      const MemoryDecision(
        operation: 'reinforce',
        type: EveMemoryType.preference,
        content: 'User prefers voice conversations',
        importance: .8,
        confidence: .9,
        targetHint: 'voice conversations',
      ),
      const MemoryDecision(
        operation: 'create',
        type: EveMemoryType.skill,
        content: 'User is building a Flutter application',
        importance: .75,
        confidence: .88,
        targetHint: 'Flutter',
      ),
    ]);

    expect(manager.memories, hasLength(2));
    final voice = manager.memories.firstWhere((m) => m.type == EveMemoryType.preference);
    expect(voice.reinforcementCount, greaterThanOrEqualTo(1));
  });

  test('ignore decision does not create memory', () async {
    final storage = StorageService();
    await storage.init();
    final manager = MemoryManager(storage);

    await manager.applyAiDecisions([
      const MemoryDecision(
        operation: 'ignore',
        type: EveMemoryType.semantic,
        content: '',
        importance: .1,
        confidence: .9,
        targetHint: '',
      ),
    ]);

    expect(manager.memories, isEmpty);
  });
}
