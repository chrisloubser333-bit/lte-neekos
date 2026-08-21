import 'package:flutter/material.dart';
import '../models/eve_conversation_state.dart';
import '../theme/app_theme.dart';

class EveConversationStatus extends StatelessWidget {
  final EveConversationState state;
  final String? message;

  const EveConversationStatus({
    super.key,
    required this.state,
    this.message,
  });

  String get _label {
    switch (state) {
      case EveConversationState.listening:
        return 'Listening…';
      case EveConversationState.processing:
        return 'Eve is thinking…';
      case EveConversationState.speaking:
        return 'Eve is speaking';
      case EveConversationState.error:
        return message ?? 'Something went wrong';
      case EveConversationState.idle:
        return 'Ready to talk';
    }
  }

  IconData get _icon {
    switch (state) {
      case EveConversationState.listening:
        return Icons.graphic_eq_rounded;
      case EveConversationState.processing:
        return Icons.auto_awesome_rounded;
      case EveConversationState.speaking:
        return Icons.graphic_eq_rounded;
      case EveConversationState.error:
        return Icons.warning_amber_rounded;
      case EveConversationState.idle:
        return Icons.graphic_eq_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = state != EveConversationState.idle;
    final error = state == EveConversationState.error;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFF18172F).withOpacity(.86),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: (error ? Colors.redAccent : AppTheme.primary)
              .withOpacity(active ? .48 : .28),
        ),
        boxShadow: active
            ? AppTheme.glow(
                error ? Colors.redAccent : AppTheme.primary,
                blur: 18,
                spread: 1,
                opacity: .18,
              )
            : const [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon,
              size: 19,
              color: error
                  ? Colors.redAccent
                  : (active ? AppTheme.accent : AppTheme.primary)),
          const SizedBox(width: 9),
          Text(
            _label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (state == EveConversationState.idle) ...[
            const SizedBox(width: 9),
            Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: AppTheme.success,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
