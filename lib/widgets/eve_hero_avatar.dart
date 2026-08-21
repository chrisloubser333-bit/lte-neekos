import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/eve_conversation_state.dart';
import '../theme/app_theme.dart';
import 'talking_avatar.dart';

class EveHeroAvatar extends StatefulWidget {
  final String? customImagePath;
  final bool isSpeaking;
  final EveConversationState state;
  final String viseme;

  const EveHeroAvatar({
    super.key,
    required this.customImagePath,
    required this.isSpeaking,
    required this.state,
    required this.viseme,
  });

  @override
  State<EveHeroAvatar> createState() => _EveHeroAvatarState();
}

class _EveHeroAvatarState extends State<EveHeroAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _active =>
      widget.state == EveConversationState.listening ||
      widget.state == EveConversationState.processing ||
      widget.state == EveConversationState.speaking;

  @override
  Widget build(BuildContext context) {
    if (widget.customImagePath != null &&
        File(widget.customImagePath!).existsSync()) {
      return SizedBox(
        height: 370,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _halo(),
            TalkingAvatar(
              imagePath: widget.customImagePath,
              isSpeaking: widget.isSpeaking,
              viseme: widget.viseme,
              size: 260,
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 370,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final pulse = _active
              ? .5 + .5 * math.sin(_controller.value * math.pi * 2)
              : 0.15;
          return Stack(
            alignment: Alignment.center,
            children: [
              _halo(intensity: pulse),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _WavePainter(
                      progress: _controller.value,
                      active: _active,
                    ),
                  ),
                ),
              ),
              Transform.scale(
                scale: 1 + (_active ? .008 * pulse : 0),
                child: Container(
                  width: 292,
                  height: 292,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.secondary.withOpacity(.34 + .18 * pulse),
                        blurRadius: 42 + 20 * pulse,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/eve_neutral.png',
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _halo({double intensity = .35}) {
    return Container(
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.primary.withOpacity(.28 + .28 * intensity),
          width: 1.3,
        ),
        gradient: RadialGradient(
          colors: [
            AppTheme.secondary.withOpacity(.22 + .16 * intensity),
            AppTheme.accent.withOpacity(.06),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double progress;
  final bool active;

  const _WavePainter({required this.progress, required this.active});

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height * .55;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = AppTheme.primary.withOpacity(active ? .72 : .28);

    final path = Path();
    const count = 48;
    for (var i = 0; i < count; i++) {
      final x = size.width * (i / (count - 1));
      final normalized = (i - count / 2) / (count / 2);
      final envelope = math.exp(-(normalized * normalized) * 2.8);
      final amp = (active ? 42 : 17) * envelope;
      final y = centerY +
          math.sin(progress * math.pi * 2 * 2.0 + i * .55) * amp;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.active != active;
}
