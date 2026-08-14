import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';

/// Simple in-memory placeholder until full memory provider is built
class _MemoryItem {
  final String id;
  final String content;
  final String type; // health, preference, goal, fact, other
  final int importance;
  final DateTime createdAt;

  _MemoryItem({
    required this.id,
    required this.content,
    required this.type,
    required this.importance,
    required this.createdAt,
  });
}

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  String _filter = 'all';

  // Placeholder data – will be replaced by real MemoryProvider later
  final List<_MemoryItem> _memories = [
    _MemoryItem(
      id: '1',
      content: 'Asthma symptoms improve when avoiding cold air at night',
      type: 'health',
      importance: 5,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    _MemoryItem(
      id: '2',
      content: 'Prefers Eve as the main voice',
      type: 'preference',
      importance: 4,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    _MemoryItem(
      id: '3',
      content: 'Wants to practise more Afrikaans conversation',
      type: 'goal',
      importance: 3,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  Color _typeColor(String type) {
    switch (type) {
      case 'health':
        return AppTheme.success;
      case 'preference':
        return AppTheme.primary;
      case 'goal':
        return AppTheme.secondary;
      default:
        return AppTheme.accent;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'health':
        return Icons.favorite_rounded;
      case 'preference':
        return Icons.tune_rounded;
      case 'goal':
        return Icons.flag_rounded;
      default:
        return Icons.memory_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isAf = settings.language == 'af';

    final filtered = _filter == 'all'
        ? _memories
        : _memories.where((m) => m.type == _filter).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(isAf ? 'Geheue' : 'Memory'),
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
          // Core Profile card
          _sectionTitle(isAf ? 'Kernprofiel' : 'Core Profile'),
          _glassCard(
            borderColor: AppTheme.secondary.withOpacity(0.4),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_rounded,
                          color: AppTheme.secondary, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        isAf ? 'Oor jou' : 'About you',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _profileLine(isAf
                      ? 'Verkies Afrikaans & Engels'
                      : 'Prefers Afrikaans & English'),
                  _profileLine(isAf
                      ? 'Gebruik Eve as hoofstem'
                      : 'Uses Eve as main voice'),
                  _profileLine(isAf
                      ? 'Belangstellings: gesondheid & leer'
                      : 'Interests: health & learning'),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(isAf ? 'Wysig' : 'Edit'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Filter chips
          _sectionTitle(isAf ? 'Herinneringe' : 'Memories'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('all', isAf ? 'Alles' : 'All'),
                _filterChip('health', isAf ? 'Gesondheid' : 'Health'),
                _filterChip('preference', isAf ? 'Voorkeure' : 'Preferences'),
                _filterChip('goal', isAf ? 'Doelwitte' : 'Goals'),
                _filterChip('fact', isAf ? 'Feite' : 'Facts'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Memory list
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(Icons.psychology_outlined,
                      size: 56, color: AppTheme.textSecondary.withOpacity(0.5)),
                  const SizedBox(height: 12),
                  Text(
                    isAf
                        ? 'Nog geen herinneringe in hierdie kategorie nie'
                        : 'No memories in this category yet',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            )
          else
            ...filtered.map((m) => _memoryTile(m, isAf)),

          const SizedBox(height: 28),

          // Privacy / danger
          _sectionTitle(isAf ? 'Privaatheid' : 'Privacy'),
          _glassCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_sweep_rounded,
                      color: AppTheme.textSecondary),
                  title: Text(
                    isAf ? 'Vee korttermyngeheue uit' : 'Clear short-term memory',
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isAf
                            ? 'Korttermyngeheue uitgevee'
                            : 'Short-term memory cleared'),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, color: AppTheme.border),
                ListTile(
                  leading: const Icon(Icons.delete_forever_rounded,
                      color: Color(0xFFFF6B6B)),
                  title: Text(
                    isAf ? 'Vee alle herinneringe uit' : 'Delete all memories',
                    style: const TextStyle(color: Color(0xFFFF6B6B)),
                  ),
                  onTap: () => _confirmDeleteAll(isAf),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _glassCard({required Widget child, Color? borderColor}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor ?? AppTheme.border.withOpacity(0.6),
        ),
      ),
      child: child,
    );
  }

  Widget _profileLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: AppTheme.secondary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ),
        ],
      ),
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
            color: selected
                ? AppTheme.primary.withOpacity(0.18)
                : AppTheme.surface.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? AppTheme.primary.withOpacity(0.7)
                  : AppTheme.border.withOpacity(0.5),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppTheme.primary : AppTheme.textSecondary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _memoryTile(_MemoryItem m, bool isAf) {
    final color = _typeColor(m.type);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _glassCard(
        borderColor: color.withOpacity(0.35),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_typeIcon(m.type), color: color, size: 20),
          ),
          title: Text(
            m.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              height: 1.3,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${m.type.toUpperCase()} · ${_timeAgo(m.createdAt, isAf)}',
              style: TextStyle(
                color: color.withOpacity(0.9),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.more_horiz_rounded,
                color: AppTheme.textSecondary),
            onPressed: () => _showMemoryActions(m, isAf),
          ),
          onTap: () => _showMemoryActions(m, isAf),
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt, bool isAf) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 1) {
      return isAf ? '${diff.inDays} dae gelede' : '${diff.inDays} days ago';
    }
    if (diff.inDays == 1) return isAf ? '1 dag gelede' : '1 day ago';
    if (diff.inHours >= 1) {
      return isAf ? '${diff.inHours} ure gelede' : '${diff.inHours} hours ago';
    }
    return isAf ? 'Pas nou' : 'Just now';
  }

  void _showMemoryActions(_MemoryItem m, bool isAf) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  m.content,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.edit_rounded,
                      color: AppTheme.primary),
                  title: Text(isAf ? 'Wysig' : 'Edit',
                      style: const TextStyle(color: AppTheme.textPrimary)),
                  onTap: () {
                    Navigator.pop(ctx);
                    // Edit flow placeholder
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_rounded,
                      color: Color(0xFFFF6B6B)),
                  title: Text(isAf ? 'Vee uit' : 'Delete',
                      style: const TextStyle(color: Color(0xFFFF6B6B))),
                  onTap: () {
                    setState(() {
                      _memories.removeWhere((e) => e.id == m.id);
                    });
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddMemory(bool isAf) {
    final controller = TextEditingController();
    String selectedType = 'fact';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isAf ? 'Voeg herinnering by' : 'Add memory',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 3,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: isAf
                      ? 'Wat moet Eve onthou?'
                      : 'What should Eve remember?',
                  hintStyle: const TextStyle(color: AppTheme.textSecondary),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  for (final t in ['fact', 'preference', 'health', 'goal'])
                    ChoiceChip(
                      label: Text(t),
                      selected: selectedType == t,
                      onSelected: (_) {
                        selectedType = t;
                        (ctx as Element).markNeedsBuild();
                      },
                      selectedColor: AppTheme.primary.withOpacity(0.25),
                      labelStyle: TextStyle(
                        color: selectedType == t
                            ? AppTheme.primary
                            : AppTheme.textSecondary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  if (controller.text.trim().isEmpty) return;
                  setState(() {
                    _memories.insert(
                      0,
                      _MemoryItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        content: controller.text.trim(),
                        type: selectedType,
                        importance: 3,
                        createdAt: DateTime.now(),
                      ),
                    );
                  });
                  Navigator.pop(ctx);
                },
                child: Text(isAf ? 'Stoor' : 'Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteAll(bool isAf) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          isAf ? 'Vee alles uit?' : 'Delete everything?',
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          isAf
              ? 'Alle herinneringe sal permanent verwyder word.'
              : 'All memories will be permanently removed.',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isAf ? 'Kanselleer' : 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B)),
            onPressed: () {
              setState(() => _memories.clear());
              Navigator.pop(ctx);
            },
            child: Text(isAf ? 'Vee uit' : 'Delete'),
          ),
        ],
      ),
    );
  }
}
