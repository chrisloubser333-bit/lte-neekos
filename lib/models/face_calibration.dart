import 'dart:ui';

/// Normalized facial geometry for the selected avatar image.
/// Coordinates are in the displayed image's 0..1 coordinate space.
class FaceCalibration {
  final Offset mouthCenter;
  final double mouthWidth;
  final double mouthHeight;
  final Offset leftEyeCenter;
  final Offset rightEyeCenter;
  final double eyeWidth;
  final double eyeHeight;
  final Rect faceBounds;
  final double imageAspectRatio;

  const FaceCalibration({
    required this.mouthCenter,
    required this.mouthWidth,
    required this.mouthHeight,
    required this.leftEyeCenter,
    required this.rightEyeCenter,
    required this.eyeWidth,
    required this.eyeHeight,
    required this.faceBounds,
    required this.imageAspectRatio,
  });
}
