import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/face_calibration.dart';

/// Personalized 2D face rig. The user's photo remains the identity layer;
/// detected facial geometry determines where animated features are placed.
class FaceRig extends StatelessWidget {
  final String viseme;
  final bool speaking;
  final double size;
  final FaceCalibration? calibration;
  final bool blink;

  const FaceRig({
    super.key,
    required this.viseme,
    required this.speaking,
    required this.size,
    required this.calibration,
    this.blink = false,
  });

  @override
  Widget build(BuildContext context) {
    if (calibration == null) return const SizedBox.shrink();
    return IgnorePointer(
      child: CustomPaint(
        size: Size.square(size),
        painter: _FaceRigPainter(
          viseme: viseme,
          speaking: speaking,
          calibration: calibration!,
          blink: blink,
        ),
      ),
    );
  }
}

class _FaceRigPainter extends CustomPainter {
  final String viseme;
  final bool speaking;
  final FaceCalibration calibration;
  final bool blink;

  const _FaceRigPainter({
    required this.viseme,
    required this.speaking,
    required this.calibration,
    required this.blink,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final mouth = _coverPoint(calibration.mouthCenter, size);

    final coverScale = _coverScale(size);
    final mouthW = (size.width * calibration.mouthWidth * coverScale).clamp(18.0, size.width * .38);
    final baseH = (size.height * calibration.mouthHeight * coverScale).clamp(3.0, size.height * .08);
    final open = _openAmount(viseme, baseH);

    // Soft shadow blends the rig into the user's photograph.
    final shadow = Paint()
      ..color = Colors.black.withOpacity(.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    canvas.drawOval(
      Rect.fromCenter(center: mouth, width: mouthW * 1.12, height: (open + baseH) * 1.25),
      shadow,
    );

    final outer = Path()
      ..moveTo(mouth.dx - mouthW / 2, mouth.dy)
      ..cubicTo(
        mouth.dx - mouthW * .28,
        mouth.dy - baseH,
        mouth.dx + mouthW * .28,
        mouth.dy - baseH,
        mouth.dx + mouthW / 2,
        mouth.dy,
      )
      ..cubicTo(
        mouth.dx + mouthW * .30,
        mouth.dy + open,
        mouth.dx - mouthW * .30,
        mouth.dy + open,
        mouth.dx - mouthW / 2,
        mouth.dy,
      )
      ..close();

    final mouthPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(mouth.dx, mouth.dy - 2),
        Offset(mouth.dx, mouth.dy + open + 4),
        [Colors.black.withOpacity(.92), Colors.black.withOpacity(.58)],
      );
    canvas.drawPath(outer, mouthPaint);

    if (viseme == 'teeth' || viseme == 'wide') {
      final teeth = Paint()..color = Colors.white.withOpacity(.86);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(mouth.dx, mouth.dy - 1), width: mouthW * .55, height: (open * .35 + 3).clamp(2.0, 7.0)),
          const Radius.circular(3),
        ),
        teeth,
      );
    }

    if (open > 5) {
      final tongue = Paint()..color = const Color(0xFFB85C68).withOpacity(.72);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(mouth.dx, mouth.dy + open * .42), width: mouthW * .40, height: open * .34 + 2),
        tongue,
      );
    }

    _paintEyes(canvas, size);
  }

  void _paintEyes(Canvas canvas, Size size) {
    final left = _coverPoint(calibration.leftEyeCenter, size);
    final right = _coverPoint(calibration.rightEyeCenter, size);
    final coverScale = _coverScale(size);
    final eyeW = (size.width * calibration.eyeWidth * coverScale).clamp(10.0, size.width * .16);
    final eyeH = (size.height * calibration.eyeHeight * coverScale).clamp(3.0, size.height * .055);

    if (!blink) return;
    final lid = Paint()
      ..color = Colors.black.withOpacity(.20)
      ..strokeWidth = (size.width * .007).clamp(1.0, 2.2)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (final eye in [left, right]) {
      canvas.drawArc(Rect.fromCenter(center: eye, width: eyeW, height: eyeH), .08, 3.0, false, lid);
    }
  }

  double _coverScale(Size size) {
    // The portrait is rendered with BoxFit.cover into a square viewport.
    final imageW = calibration.imageAspectRatio;
    final imageH = 1.0;
    return (size.width / imageW).compareTo(size.height / imageH) > 0
        ? size.width / imageW
        : size.height / imageH;
  }

  Offset _coverPoint(Offset normalized, Size size) {
    final imageAspect = calibration.imageAspectRatio;
    final scale = _coverScale(size);
    final renderedW = imageAspect * scale;
    final renderedH = scale;
    final dx = (size.width - renderedW) / 2;
    final dy = (size.height - renderedH) / 2;
    return Offset(
      dx + normalized.dx * renderedW,
      dy + normalized.dy * renderedH,
    );
  }

  double _openAmount(String value, double baseH) {
    final h = baseH.clamp(3.0, 12.0);
    switch (value) {
      case 'open': return h * 2.5;
      case 'wide': return h * 1.7;
      case 'round': return h * 2.3;
      case 'pucker': return h * 1.5;
      case 'closed': return h * .35;
      case 'teeth': return h * 1.25;
      case 'smile': return h * .75;
      default: return speaking ? h : h * .45;
    }
  }

  @override
  bool shouldRepaint(covariant _FaceRigPainter oldDelegate) =>
      oldDelegate.viseme != viseme ||
      oldDelegate.speaking != speaking ||
      oldDelegate.blink != blink ||
      oldDelegate.calibration != calibration;
}
