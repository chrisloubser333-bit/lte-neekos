import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/eve_memory.dart';
import '../providers/memory_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final memories = context.watch<MemoryProvider>().memories;
    final settings = context.watch<SettingsProvider>();
    final isAf = settings.language == 'af';
    final filtered = _filter == 'all'
        ? memories
        : memories.where((m) => m.type.name == _filter).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(isAf ? 'Eve se geheue' : 'Eve’s Memory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppTheme.primary),
            onPressed: () => _showAddMemory(isAf),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _introCard(isAf, memories.length),
          const SizedBox(height: 22),
          _sectionTitle(isAf ? 'Geheuetipes' : 'Memory types'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('all', isAf ? 'Alles' : 'All'),
                _filterChip('semantic', isAf ? 'Feite' : 'Facts'),
                _filterChip('preference', isAf ? 'Voorkeure' : 'Preferences'),
                _filterChip('episodic', isAf ? 'Ervarings' : 'Experiences'),
                _filterChip('relationship', isAf ? 'Verhouding' : 'Relationship'),
                _filterChip('skill', isAf ? 'Vaardighede' : 'Skills'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            _emptyState(isAf)
          else
            ...filtered.map((m) => _memoryTile(m, isAf)),
          const SizedBox(height: 28),
          _sectionTitle(isAf ? 'Privaatheid & beheer' : 'Privacy & control'),
          _privacyCard(isAf),
        ],
      ),
    );
  }

  Widget _introCard(bool isAf, int count) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.secondary.withOpacity(.20),
            AppTheme.surface.withOpacity(.88),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.primary.withOpacity(.32)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary.withOpacity(.16),
              boxShadow: AppTheme.glow(AppTheme.primary, blur: 22, opacity: .18),
            ),
            child: const Icon(Icons.psychology_rounded,
                color: AppTheme.primary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAf ? 'Eve onthou wat belangrik is' : 'Eve remembers what matters',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  isAf
                      ? '$count langtermynherinneringe · plaaslik gestoor'
                      : '$count long-term memories · stored locally',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(bool isAf) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 55),
      child: Column(
        children: [
          Icon(Icons.auto_awesome_rounded,
              size: 54, color: AppTheme.primary.withOpacity(.5)),
          const SizedBox(height: 14),
          Text(
            isAf ? 'Nog geen langtermynherinneringe' : 'No long-term memories yet',
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
          ),
          const SizedBox(height: 7),
          Text(
            isAf
                ? 'Sê “Eve, onthou dat …” om iets doelbewus te stoor.'
                : 'Say “Eve, remember that …” to save something intentionally.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _privacyCard(bool isAf) {
    return _glassCard(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.lock_outline_rounded,
                color: AppTheme.success),
            title: Text(isAf ? 'Plaaslik eerste' : 'Local-first',
                style: const TextStyle(color: AppTheme.textPrimary)),
            subtitle: Text(
              isAf ? 'Herinneringe bly op hierdie toestel.' : 'Memories stay on this device.',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ),
          const Divider(height: 1, color: AppTheme.border),
          ListTile(
            leading: const Icon(Icons.delete_sweep_rounded,
                color: AppTheme.textSecondary),
            title: Text(isAf ? 'Vee alle herinneringe uit' : 'Delete all memories',
                style: const TextStyle(color: Color(0xFFFF6B6B))),
            onTap: () => _confirmDeleteAll(isAf),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(title,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600)),
      );

  Widget _glassCard({required Widget child, Color? borderColor}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(.72),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: borderColor ?? AppTheme.border.withOpacity(.55)),
      ),
      child: child,
    );
  }

  Widget _filterChip(String value, String label) {
    final selected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _filter = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary.withOpacity(.17) : AppTheme.surface.withOpacity(.55),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppTheme.primary.withOpacity(.7) : AppTheme.border.withOpacity(.5),
            ),
          ),
          child: Text(label,
              style: TextStyle(
                  color: selected ? AppTheme.primary : AppTheme.textSecondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13)),
        ),
      ),
    );
  }

  Widget _memoryTile(EveMemory memory, bool isAf) {
    final color = _typeColor(memory.type);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _glassCard(
        borderColor: color.withOpacity(.30),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(.14),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(_typeIcon(memory.type), color: color, size: 21),
          ),
          title: Text(memory.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, height: 1.3)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Row(
              children: [
                Text(_label(memory.type, isAf),
                    style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Text('${(memory.confidence * 100).round()}% confidence',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10.5)),
                if (memory.pinned) ...[
                  const SizedBox(width: 7),
                  const Icon(Icons.push_pin_rounded, size: 13, color: AppTheme.primary),
                ],
              ],
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.more_horiz_rounded, color: AppTheme.textSecondary),
            onPressed: () => _showMemoryActions(memory, isAf),
          ),
        ),
      ),
    );
  }

  Color _typeColor(EveMemoryType type) {
    switch (type) {
      case EveMemoryType.semantic: return const Color(0xFF6BCBFF);
      case EveMemoryType.preference: return AppTheme.primary;
      case EveMemoryType.episodic: return AppTheme.success;
      case EveMemoryType.relationship: return AppTheme.accent;
      case EveMemoryType.skill: return const Color(0xFFFFC857);
    }
  }

  IconData _typeIcon(EveMemoryType type) {
    switch (type) {
      case EveMemoryType.semantic: return Icons.lightbulb_outline_rounded;
      case EveMemoryType.preference: return Icons.favorite_outline_rounded;
      case EveMemoryType.episodic: return Icons.event_note_rounded;
      case EveMemoryType.relationship: return Icons.people_outline_rounded;
      case EveMemoryType.skill: return Icons.school_outlined;
    }
  }

  String _label(EveMemoryType type, bool isAf) {
    if (!isAf) return type.name.toUpperCase();
    switch (type) {
      case EveMemoryType.semantic: return 'FEIT';
      case EveMemoryType.preference: return 'VOORKEUR';
      case EveMemoryType.episodic: return 'ERVARING';
      case EveMemoryType.relationship: return 'VERHOUDING';
      case EveMemoryType.skill: return 'VAARDIGHEID';
    }
  }

  void _showMemoryActions(EveMemory memory, bool isAf) {
    final provider = context.read<MemoryProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Text(memory.content,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15)),
            ),
            ListTile(
              leading: Icon(memory.pinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
                  color: AppTheme.primary),
              title: Text(memory.pinned ? 'Unpin' : 'Pin',
                  style: const TextStyle(color: AppTheme.textPrimary)),
              onTap: () { Navigator.pop(ctx); provider.pin(memory.id); },
            ),
            ListTile(
              leading: const Icon(Icons.thumb_up_alt_outlined, color: AppTheme.success),
              title: const Text('Reinforce', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () { Navigator.pop(ctx); provider.reinforce(memory.id); },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF6B6B)),
              title: Text(isAf ? 'Vergeet' : 'Forget', style: const TextStyle(color: Color(0xFFFF6B6B))),
              onTap: () { Navigator.pop(ctx); provider.delete(memory.id); },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showAddMemory(bool isAf) {
    final controller = TextEditingController();
    EveMemoryType type = EveMemoryType.semantic;
    bool pinned = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(16, 18, 16, MediaQuery.of(ctx).viewInsets.bottom + 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(isAf ? 'Voeg geheue by' : 'Add memory',
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: isAf ? 'Wat moet Eve onthou?' : 'What should Eve remember?',
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: EveMemoryType.values.map((t) => ChoiceChip(
                  label: Text(t.name),
                  selected: type == t,
                  onSelected: (_) => setSheetState(() => type = t),
                )).toList(),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: pinned,
                onChanged: (v) => setSheetState(() => pinned = v),
                title: const Text('Pin this memory', style: TextStyle(color: AppTheme.textPrimary)),
                subtitle: const Text('Pinned memories do not decay automatically.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
              ),
              FilledButton.icon(
                onPressed: () async {
                  if (controller.text.trim().isEmpty) return;
                  await context.read<MemoryProvider>().addMemory(controller.text.trim(), type: type, pinned: pinned);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                icon: const Icon(Icons.save_rounded),
                label: Text(isAf ? 'Stoor' : 'Save memory'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteAll(bool isAf) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(isAf ? 'Vee alle geheue uit?' : 'Delete all memories?', style: const TextStyle(color: AppTheme.textPrimary)),
        content: Text(isAf ? 'Dit kan nie ongedaan gemaak word nie.' : 'This cannot be undone.', style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF6B6B)),
            onPressed: () async {
              await context.read<MemoryProvider>().clearAll();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete all'),
          ),
        ],
      ),
    );
  }
}
