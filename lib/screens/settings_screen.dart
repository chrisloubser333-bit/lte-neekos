import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/ai_model_option.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';
import 'memory_screen.dart';
import 'voice_recorder_screen.dart';
import 'avatar_studio_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Map<AiProviderId, TextEditingController> _keyControllers = {for (final p in AiProviderId.values) p: TextEditingController()};
  bool _obscureKey = true;

  @override
  void dispose() {
    for (final c in _keyControllers.values) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final chat = context.watch<ChatProvider>();
    final isAf = settings.language == 'af';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(isAf ? 'Instellings' : 'Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _sectionTitle(isAf ? 'KI-verskaffersleutels' : 'AI provider keys'),
          Text(
            isAf
                ? 'Eve se geheue is gedeel oor alle gekose modelle. Sleutels word plaaslik in veilige berging bewaar.'
                : 'Eve’s memory is shared across all selected models. Keys are stored locally in secure storage.',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 8),
          ...AiProviderId.values.map((provider) {
            final configured = settings.isProviderConfigured(provider);
            final label = switch (provider) {
              AiProviderId.xai => 'xAI / Grok',
              AiProviderId.openai => 'OpenAI / GPT',
              AiProviderId.anthropic => 'Anthropic / Claude',
              AiProviderId.google => 'Google / Gemini',
            };
            final controller = _keyControllers[provider]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _glassCard(
                child: TextField(
                  controller: controller,
                  obscureText: true,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: '$label API key',
                    hintText: configured ? '••••••••••••••••' : 'Paste key',
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.save_rounded, color: AppTheme.primary),
                      onPressed: () async {
                        final key = controller.text.trim();
                        if (key.isNotEmpty) {
                          await chat.setProviderApiKey(provider, key);
                          controller.clear();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(isAf ? 'Sleutel gestoor' : '$label key saved')),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 6),
          Text(
            isAf
                ? 'Vir produksie behoort API-oproepe deur jou backend te gaan; moenie mobiele sleutels publiek versprei nie.'
                : 'For production, route API calls through your backend; do not distribute unrestricted mobile keys publicly.',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 28),

          // Language
          _sectionTitle(isAf ? 'Taal' : 'Language'),
          _glassCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  _langChip('en', 'English', settings.language == 'en', () {
                    settings.setLanguage('en');
                  }),
                  const SizedBox(width: 10),
                  _langChip('af', 'Afrikaans', settings.language == 'af', () {
                    settings.setLanguage('af');
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // AI model selection
          _sectionTitle(isAf ? 'KI-model' : 'AI model'),
          ...settings.models.map((model) {
            final selected = model.id == settings.modelId;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _glassCard(
                borderColor: selected ? AppTheme.primary.withOpacity(0.6) : null,
                glow: selected,
                child: ListTile(
                  leading: Icon(Icons.auto_awesome_rounded,
                      color: selected ? AppTheme.primary : AppTheme.textSecondary),
                  title: Text(model.name,
                      style: const TextStyle(color: AppTheme.textPrimary)),
                  subtitle: Text(model.description,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  trailing: selected
                      ? const Icon(Icons.check_circle_rounded, color: AppTheme.primary)
                      : null,
                  onTap: () => settings.setModelId(model.id),
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // Avatar
          _sectionTitle(isAf ? 'Avatar' : 'Avatar'),
          _glassCard(
            child: ListTile(
              leading: const Icon(Icons.face_retouching_natural_rounded,
                  color: AppTheme.secondary),
              title: Text(
                isAf ? 'Pas Eve se avatar aan' : 'Customize Eve’s avatar',
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
              subtitle: Text(
                settings.avatarPath == null
                    ? (isAf ? 'Gebruik standaard Eve' : 'Using default Eve')
                    : (isAf ? 'Persoonlike foto gekies' : 'Personal photo selected'),
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              trailing: const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.textSecondary),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AvatarStudioScreen()),
                );
              },
            ),
          ),

          const SizedBox(height: 28),

          // Voice selection
          _sectionTitle(isAf ? 'Stem' : 'Voice'),
          ...settings.allVoices.map((voice) {
            final selected = voice.id == settings.voiceId;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _glassCard(
                borderColor: selected
                    ? AppTheme.primary.withOpacity(0.6)
                    : null,
                glow: selected,
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  leading: Icon(
                    voice.isCustom
                        ? Icons.record_voice_over_rounded
                        : Icons.person_rounded,
                    color: selected ? AppTheme.primary : AppTheme.textSecondary,
                  ),
                  title: Text(
                    voice.name,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    voice.description,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13),
                  ),
                  trailing: selected
                      ? const Icon(Icons.check_circle_rounded,
                          color: AppTheme.primary)
                      : null,
                  onTap: () => settings.setVoiceId(voice.id),
                ),
              ),
            );
          }),

          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const VoiceRecorderScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add_rounded),
            label: Text(isAf ? 'Leer \'n nuwe stem' : 'Teach a new voice'),
          ),

          const SizedBox(height: 28),

          // Memory
          _sectionTitle(isAf ? 'Geheue' : 'Memory'),
          _glassCard(
            child: ListTile(
              leading: const Icon(Icons.psychology_rounded,
                  color: AppTheme.secondary),
              title: Text(
                isAf ? 'Bestuur geheue' : 'Manage memory',
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
              subtitle: Text(
                isAf
                    ? 'Sien en beheer wat Eve onthou'
                    : 'View and control what Eve remembers',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13),
              ),
              trailing: const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.textSecondary),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MemoryScreen()),
                );
              },
            ),
          ),

          const SizedBox(height: 28),

          // Appearance
          _sectionTitle(isAf ? 'Voorkoms' : 'Appearance'),
          _glassCard(
            child: SwitchListTile(
              title: Text(
                isAf ? 'Donker futuristiese tema' : 'Dark futuristic theme',
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
              subtitle: Text(
                isAf ? 'Altyd aktief in hierdie weergawe' : 'Always on in this version',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13),
              ),
              value: true,
              onChanged: null, // locked to futuristic dark for now
            ),
          ),

          const SizedBox(height: 28),

          // Danger zone
          _sectionTitle(isAf ? 'Gevaar sone' : 'Danger zone'),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFF6B6B),
              side: const BorderSide(color: Color(0xFFFF6B6B)),
            ),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppTheme.surface,
                  title: Text(
                    isAf ? 'Vee kletsgeskiedenis uit?' : 'Clear chat history?',
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                  content: Text(
                    isAf
                        ? 'Dit kan nie ongedaan gemaak word nie.'
                        : 'This cannot be undone.',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(isAf ? 'Kanselleer' : 'Cancel'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B6B)),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(isAf ? 'Vee uit' : 'Clear'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await chat.clearHistory();
              }
            },
            icon: const Icon(Icons.delete_outline_rounded),
            label: Text(isAf
                ? 'Vee kletsgeskiedenis uit'
                : 'Clear chat history'),
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

  Widget _glassCard({
    required Widget child,
    Color? borderColor,
    bool glow = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor ?? AppTheme.border.withOpacity(0.6),
        ),
        boxShadow: glow ? AppTheme.glow(AppTheme.primary, blur: 12) : null,
      ),
      child: child,
    );
  }

  Widget _langChip(
      String code, String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.primary.withOpacity(0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppTheme.primary.withOpacity(0.7)
                  : AppTheme.border.withOpacity(0.5),
            ),
            boxShadow: selected
                ? AppTheme.glow(AppTheme.primary, blur: 8, spread: 0)
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? AppTheme.primary : AppTheme.textSecondary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
