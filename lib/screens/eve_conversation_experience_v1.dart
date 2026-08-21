import 'package:flutter/material.dart';

import '../models/eve_conversation_state.dart';
import '../widgets/eve_conversation_status.dart';
import '../widgets/eve_static_avatar.dart';

/// Reference screen for the Eve Conversation Experience v1.
/// Wire `state`, `messages`, and callbacks to the existing ChatProvider.
class EveConversationExperienceV1 extends StatelessWidget {
  final EveConversationState state;
  final List<String> userMessages;
  final TextEditingController controller;
  final VoidCallback onMic;
  final VoidCallback onSend;

  const EveConversationExperienceV1({
    super.key,
    required this.state,
    required this.userMessages,
    required this.controller,
    required this.onMic,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Listen with Eve',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Expanded(
                flex: 5,
                child: Center(
                  child: EveStaticAvatar(state: state),
                ),
              ),
              EveConversationStatus(state: state),
              const SizedBox(height: 12),
              Expanded(
                flex: 4,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  itemCount: userMessages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, index) => Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 330),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(userMessages[index]),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => onSend(),
                      decoration: InputDecoration(
                        hintText: state == EveConversationState.listening
                            ? 'Listening…'
                            : 'Message Eve…',
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: IconButton(
                          tooltip: state == EveConversationState.listening
                              ? 'Stop listening'
                              : 'Speak to Eve',
                          onPressed: onMic,
                          icon: Icon(
                            state == EveConversationState.listening
                                ? Icons.stop_rounded
                                : Icons.mic_rounded,
                          ),
                        ),
                        suffixIcon: IconButton(
                          tooltip: 'Send',
                          onPressed: onSend,
                          icon: const Icon(Icons.arrow_upward_rounded),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
