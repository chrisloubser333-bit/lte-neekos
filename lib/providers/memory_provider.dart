import 'package:flutter/foundation.dart';
import '../models/eve_memory.dart';
import '../services/memory_manager.dart';

class MemoryProvider extends ChangeNotifier {
  final MemoryManager manager;

  MemoryProvider(this.manager) {
    manager.addListener(_forward);
  }

  List<EveMemory> get memories => manager.memories;
  int get count => manager.count;

  Future<EveMemory?> addMemory(String text, {
    EveMemoryType type = EveMemoryType.semantic,
    double importance = .7,
    bool pinned = false,
  }) => manager.remember(text, type: type, importance: importance, pinned: pinned);

  Future<void> delete(String id) => manager.forget(id);
  Future<void> archive(String id) => manager.archive(id);
  Future<void> pin(String id) => manager.togglePinned(id);
  Future<void> reinforce(String id, {bool confirmed = true}) =>
      manager.reinforce(id, confirmed: confirmed);
  Future<void> clearAll() => manager.clearAll();

  void _forward() => notifyListeners();

  @override
  void dispose() {
    manager.removeListener(_forward);
    super.dispose();
  }
}
