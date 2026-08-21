import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/models/eve_memory.dart';
import '../lib/services/memory_manager.dart';
import '../lib/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('explicit remember creates a pinned memory', () async {
    final storage = StorageService();
    await storage.init();
    final manager = MemoryManager(storage);

    await Future<void>.delayed(const Duration(milliseconds: 20));
    final stored = await manager.extractAndStore('Eve, remember that I prefer voice conversations.');

    expect(stored, hasLength(1));
    expect(stored.first.pinned, isTrue);
    expect(stored.first.type, EveMemoryType.preference);
  });

  test('relevant memories can be retrieved without exact wording', () async {
    final storage = StorageService();
    await storage.init();
    final manager = MemoryManager(storage);

    await manager.remember(
      'User prefers voice conversations',
      type: EveMemoryType.preference,
      importance: .9,
    );

    final results = await manager.retrieveRelevant('I would rather talk than type');
    expect(results, isNotEmpty);
  });

  test('forget command removes a matching memory', () async {
    final storage = StorageService();
    await storage.init();
    final manager = MemoryManager(storage);

    await manager.remember('User prefers Eve voice', type: EveMemoryType.preference);
    final response = await manager.handleMemoryCommand('Eve, forget Eve voice');

    expect(response, contains('forgot'));
    expect(manager.memories, isEmpty);
  });
}
