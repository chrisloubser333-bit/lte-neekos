import 'dart:math' as math;
import "../models/eve_conversation_state.dart";
import "../providers/settings_provider.dart";
import "dart:async";
import "dart:math" as math_lib;
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../providers/chat_provider.dart";
import '../theme/app_theme.dart';
import '../widgets/eve_conversation_status.dart';
import '../widgets/eve_hero_avatar.dart';
import '../widgets/message_bubble.dart';
import 'settings_screen.dart';
import 'memory_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  int _tab = 0;
  Timer? _transcriptTimer;

  @override
  void dispose() {
    _transcriptTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  EveConversationState _state(ChatProvider chat) {
    if (chat.error != null) return EveConversationState.error;
    if (chat.isListening) return EveConversationState.listening;
    if (chat.isLoading) return EveConversationState.processing;
    if (chat.isSpeaking) return EveConversationState.speaking;
    return EveConversationState.idle;
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    final chat = context.read<ChatProvider>();
    await chat.sendText(text);
    _scrollToBottom();
  }

  Future<void> _toggleMic(ChatProvider chat) async {
    if (chat.isListening) {
      await chat.stopUserSpeech();
      final transcript = chat.transcript.trim();
      if (transcript.isNotEmpty) {
        _controller.value = TextEditingValue(
          text: transcript,
          selection: TextSelection.collapsed(offset: transcript.length),
        );
      }
      return;
    }

    await chat.startUserSpeech();
    _transcriptTimer?.cancel();
    _transcriptTimer = Timer.periodic(const Duration(milliseconds: 120), (_) {
      if (!mounted) return;
      final transcript = context.read<ChatProvider>().transcript;
      if (transcript.isNotEmpty && transcript != _controller.text) {
        _controller.value = TextEditingValue(
          text: transcript,
          selection: TextSelection.collapsed(offset: transcript.length),
        );
        setState(() {});
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final settings = context.watch<SettingsProvider>();
    final state = _state(chat);

    if (chat.messages.isNotEmpty) _scrollToBottom();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          const _BackgroundGlow(),
          SafeArea(
            child: Column(
              children: [
                _Header(
                  language: settings.language,
                  onSettings: _openSettings,
                  onMenu: _openSettings,
                ),
                Expanded(
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(18, 3, 18, 0),
                          child: Column(
                            children: [
                              _LiveBadge(),
                              const SizedBox(height: 2),
                              EveHeroAvatar(
                                customImagePath: settings.avatarPath,
                                isSpeaking: chat.isSpeaking,
                                state: state,
                                viseme: chat.currentViseme,
                              ),
                              Transform.translate(
                                offset: const Offset(0, -20),
                                child: EveConversationStatus(
                                  state: state,
                                  message: chat.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (!chat.hasApiKey)
                        SliverToBoxAdapter(child: _ApiKeyNotice(onTap: _openSettings)),
                      if (chat.messages.isNotEmpty)
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          sliver: SliverList.builder(
                            itemCount: chat.messages.length,
                            itemBuilder: (_, i) => MessageBubble(
                              message: chat.messages[i],
                              isSpeaking: chat.isSpeaking &&
                                  i == chat.messages.length - 1,
                            ),
                          ),
                        )
                      else
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 8),
                        ),
                    ],
                  ),
                ),
                _Composer(
                  controller: _controller,
                  chat: chat,
                  settings: settings,
                  onMic: () => _toggleMic(chat),
                  onSend: _send,
                  state: state,
                ),
                _BottomNav(
                  selected: _tab,
                  onChanged: (index) {
                    setState(() => _tab = index);
                    if (index == 3) {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MemoryScreen()));
                    }
                    if (index == 1 || index == 2) _openSettings();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -170,
            left: -90,
            child: Container(
              width: 430,
              height: 430,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.secondary.withOpacity(.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 300,
            right: -160,
            child: Container(
              width: 420,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.accent.withOpacity(.09),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String language;
  final VoidCallback onSettings;
  final VoidCallback onMenu;

  const _Header({
    required this.language,
    required this.onSettings,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 10, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onMenu,
            icon: const Icon(Icons.menu_rounded, size: 27),
          ),
          Expanded(
            child: Center(
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
                  children: [
                    TextSpan(text: 'Listen with '),
                    TextSpan(
                      text: 'Eve',
                      style: TextStyle(
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onSettings,
            icon: const Icon(Icons.settings_outlined, size: 25),
          ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: const BoxDecoration(
            color: AppTheme.success,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.success,
                blurRadius: 8,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'LIVE',
          style: TextStyle(
            color: AppTheme.success,
            fontWeight: FontWeight.w600,
            letterSpacing: .7,
          ),
        ),
      ],
    );
  }
}

class _ApiKeyNotice extends StatelessWidget {
  final VoidCallback onTap;
  const _ApiKeyNotice({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surface.withOpacity(.86),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.primary.withOpacity(.18)),
        ),
        child: Row(
          children: [
            const Icon(Icons.key_rounded, size: 18, color: AppTheme.primary),
            const SizedBox(width: 9),
            const Expanded(
              child: Text(
                'Add your xAI API key to start chatting.',
                style: TextStyle(fontSize: 12.5),
              ),
            ),
            TextButton(onPressed: onTap, child: const Text('Settings')),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final ChatProvider chat;
  final SettingsProvider settings;
  final VoidCallback onMic;
  final VoidCallback onSend;
  final EveConversationState state;

  const _Composer({
    required this.controller,
    required this.chat,
    required this.settings,
    required this.onMic,
    required this.onSend,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final listening = state == EveConversationState.listening;
    final disabled = chat.isLoading;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D20).withOpacity(.96),
        border: Border(
          top: BorderSide(color: AppTheme.border.withOpacity(.28)),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: !disabled,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  decoration: InputDecoration(
                    hintText: listening
                        ? (settings.language == 'af'
                            ? 'Luister… praat met Eve'
                            : 'Listening… speak to Eve')
                        : (settings.language == 'af'
                            ? 'Boodskap aan Eve…'
                            : 'Message Eve…'),
                    prefixIcon: Icon(
                      listening
                          ? Icons.graphic_eq_rounded
                          : Icons.chat_bubble_outline_rounded,
                      color: listening ? AppTheme.accent : AppTheme.textSecondary,
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.secondary.withOpacity(.95),
                          boxShadow: AppTheme.glow(
                            AppTheme.secondary,
                            blur: 15,
                            spread: 1,
                            opacity: .22,
                          ),
                        ),
                        child: IconButton(
                          onPressed: disabled ? null : onSend,
                          icon: const Icon(Icons.arrow_upward_rounded),
                          iconSize: 21,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ComposerAction(
                icon: Icons.keyboard_rounded,
                label: 'Keyboard',
                onTap: () {},
              ),
              _MicControl(
                listening: listening,
                speaking: chat.isSpeaking,
                onTap: onMic,
              ),
              _ComposerAction(
                icon: Icons.graphic_eq_rounded,
                label: listening ? 'Voice active' : 'Voice',
                onTap: onMic,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ComposerAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ComposerAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            children: [
              Container(
                width: 58,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.surface.withOpacity(.75),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppTheme.border.withOpacity(.35)),
                ),
                child: Icon(icon, size: 21, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MicControl extends StatefulWidget {
  final bool listening;
  final bool speaking;
  final VoidCallback onTap;

  const _MicControl({
    required this.listening,
    required this.speaking,
    required this.onTap,
  });

  @override
  State<_MicControl> createState() => _MicControlState();
}

class _MicControlState extends State<_MicControl>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.listening || widget.speaking;
    return SizedBox(
      width: 118,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          final pulse = .5 + .5 * math_lib.sin(_controller.value * math_lib.pi * 2);
          return Column(
            children: [
              Transform.scale(
                scale: active ? 1 + .045 * pulse : 1,
                child: GestureDetector(
                  onTap: widget.onTap,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFE86CFF), Color(0xFF7646FF)],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(.24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accent.withOpacity(
                            active ? .48 : .34,
                          ),
                          blurRadius: active ? 28 : 20,
                          spreadRadius: active ? 5 : 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.listening
                          ? Icons.stop_rounded
                          : (widget.speaking
                              ? Icons.volume_up_rounded
                              : Icons.mic_rounded),
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                widget.listening
                    ? 'Listening'
                    : (widget.speaking ? 'Speaking' : 'Tap to speak'),
                style: TextStyle(
                  fontSize: 12,
                  color: active ? AppTheme.primary : AppTheme.textSecondary,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _BottomNav({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.chat_bubble_rounded, 'Chat'),
      (Icons.auto_awesome_rounded, 'Models'),
      (Icons.graphic_eq_rounded, 'Voices'),
      (Icons.psychology_outlined, 'Memory'),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      decoration: BoxDecoration(
        color: const Color(0xFF060711).withOpacity(.98),
        border: Border(
          top: BorderSide(color: AppTheme.border.withOpacity(.22)),
        ),
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final active = selected == index;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(index),
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      items[index].$1,
                      size: 22,
                      color: active ? AppTheme.primary : AppTheme.textSecondary,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      items[index].$2,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: active
                            ? AppTheme.primary
                            : AppTheme.textSecondary,
                        fontWeight:
                            active ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// Minimal local sine helper for animation.
class math {
  static double sin(double x) {
    x %= 6.283185307179586;
    double term = x;
    double sum = x;
    for (int n = 1; n < 7; n++) {
      term *= -x * x / ((2 * n) * (2 * n + 1));
      sum += term;
    }
    return sum;
  }
}
