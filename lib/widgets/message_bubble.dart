import 'package:flutter/material.dart';
import '../models/message.dart';
import '../theme/app_theme.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isSpeaking;

  const MessageBubble({
    super.key,
    required this.message,
    this.isSpeaking = false,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final accent = isUser ? AppTheme.secondary : AppTheme.primary;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.fromLTRB(15, 13, 15, 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * .82,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isUser
                ? [
                    AppTheme.secondary.withOpacity(.28),
                    AppTheme.secondary.withOpacity(.13),
                  ]
                : [
                    const Color(0xFF24203E).withOpacity(.92),
                    const Color(0xFF17162D).withOpacity(.92),
                  ],
          ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(21),
            topRight: const Radius.circular(21),
            bottomLeft: Radius.circular(isUser ? 21 : 7),
            bottomRight: Radius.circular(isUser ? 7 : 21),
          ),
          border: Border.all(color: accent.withOpacity(.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isUser)
                  const Text(
                    'Eve',
                    style: TextStyle(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                if (!isUser) const SizedBox(width: 8),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    color: AppTheme.textSecondary.withOpacity(.82),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SelectableText(
              message.content,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15.5,
                height: 1.38,
              ),
            ),
            if (!isUser) ...[
              const SizedBox(height: 10),
              _VoiceReplyStrip(active: isSpeaking),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _VoiceReplyStrip extends StatefulWidget {
  final bool active;
  const _VoiceReplyStrip({required this.active});

  @override
  State<_VoiceReplyStrip> createState() => _VoiceReplyStripState();
}

class _VoiceReplyStripState extends State<_VoiceReplyStrip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.18),
        borderRadius: BorderRadius.circular(21),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.secondary.withOpacity(.7)),
            ),
            child: Icon(
              widget.active ? Icons.volume_up_rounded : Icons.play_arrow_rounded,
              size: 17,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(22, (i) {
                    final wave = .35 +
                        .65 *
                            ((1 +
                                    math.sin(_controller.value *
                                            math.pi *
                                            2 +
                                        i * .72)) /
                                2);
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: 2,
                            height: widget.active ? 7 + 16 * wave : 8 + (i % 3) * 4,
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withOpacity(.72),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Text(
            widget.active ? '•••' : 'Voice',
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// Local math import without exposing it from the main widget file.
class math {
  static double sin(num value) => _sin(value.toDouble());
  static double _sin(double x) {
    // Taylor approximation is sufficient for tiny UI animation.
    x = x % (6.283185307179586);
    double term = x, sum = x;
    for (int n = 1; n < 7; n++) {
      term *= -x * x / ((2 * n) * (2 * n + 1));
      sum += term;
    }
    return sum;
  }
}
