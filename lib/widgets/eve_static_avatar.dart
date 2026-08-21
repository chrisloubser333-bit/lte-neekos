import 'package:flutter/material.dart';

import '../models/eve_conversation_state.dart';

class EveStaticAvatar extends StatelessWidget {
  final String imageAsset;
  final EveConversationState state;

  const EveStaticAvatar({
    super.key,
    this.imageAsset = 'assets/eve_neutral.png',
    this.state = EveConversationState.idle,
  });

  bool get _active =>
      state == EveConversationState.listening ||
      state == EveConversationState.processing ||
      state == EveConversationState.speaking;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: _active ? 1 : 0),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
      builder: (context, intensity, child) {
        return AnimatedScale(
          scale: state == EveConversationState.listening
              ? 1.0 + (0.012 * intensity)
              : 1.0,
          duration: const Duration(milliseconds: 260),
          child: Container(
            padding: EdgeInsets.all(8 * intensity),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(
                    .10 + (.30 * intensity),
                  ),
                  blurRadius: 20 + (22 * intensity),
                  spreadRadius: 1 + (5 * intensity),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        );
      },
    );
  }
}
