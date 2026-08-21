import 'dart:math' as math;
import "dart:math" as math_lib;
import "package:flutter/material.dart";
import '../models/message.dart';

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
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.grey[800],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.content,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
