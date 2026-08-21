import 'dart:io';
import 'dart:math' as math;
import 'dart:math' show Point;
import 'dart:ui';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../models/face_calibration.dart';

/// Detects a single, preferably frontal face in a user-selected avatar photo.
/// Detection happens once when the avatar changes; animation never invokes ML.
class FaceCalibrationService {
  final FaceDetector _detector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableContours: true,
      enableClassification: true,
      minFaceSize: 0.18,
    ),
  );

  Future<FaceCalibration?> calibrate(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) return null;

    final bytes = await file.readAsBytes();
    final codec = await instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final width = frame.image.width.toDouble();
    final height = frame.image.height.toDouble();
    frame.image.dispose();
    codec.dispose();

    final faces = await _detector.processImage(InputImage.fromFilePath(imagePath));
    if (faces.isEmpty) return null;

    faces.sort((a, b) => b.boundingBox.width.compareTo(a.boundingBox.width));
    final face = faces.first;

    final mouthPoints = <Point<int>>[];
    for (final type in [
      FaceContourType.upperLipTop,
      FaceContourType.upperLipBottom,
      FaceContourType.lowerLipTop,
      FaceContourType.lowerLipBottom,
    ]) {
      mouthPoints.addAll(face.contours[type]?.points ?? const []);
    }

    final leftEye = face.contours[FaceContourType.leftEye]?.points ?? const <Point<int>>[];
    final rightEye = face.contours[FaceContourType.rightEye]?.points ?? const <Point<int>>[];

    if (mouthPoints.length < 4 || leftEye.length < 4 || rightEye.length < 4) {
      return null;
    }

    final mouth = _bounds(mouthPoints);
    final left = _bounds(leftEye);
    final right = _bounds(rightEye);

    return FaceCalibration(
      mouthCenter: Offset(
        _clamp01(mouth.center.dx / width),
        _clamp01(mouth.center.dy / height),
      ),
      mouthWidth: _clamp01(mouth.width / width),
      mouthHeight: _clamp01(mouth.height / height),
      leftEyeCenter: Offset(
        _clamp01(left.center.dx / width),
        _clamp01(left.center.dy / height),
      ),
      rightEyeCenter: Offset(
        _clamp01(right.center.dx / width),
        _clamp01(right.center.dy / height),
      ),
      eyeWidth: _clamp01(math.max(left.width, right.width) / width),
      eyeHeight: _clamp01(math.max(left.height, right.height) / height),
      imageAspectRatio: width / height,
      faceBounds: Rect.fromLTRB(
        _clamp01(face.boundingBox.left / width),
        _clamp01(face.boundingBox.top / height),
        _clamp01(face.boundingBox.right / width),
        _clamp01(face.boundingBox.bottom / height),
      ),
    );
  }

  Rect _bounds(List<Point<int>> points) {
    var minX = points.first.x.toDouble();
    var maxX = minX;
    var minY = points.first.y.toDouble();
    var maxY = minY;
    for (final p in points.skip(1)) {
      minX = math.min(minX, p.x.toDouble());
      maxX = math.max(maxX, p.x.toDouble());
      minY = math.min(minY, p.y.toDouble());
      maxY = math.max(maxY, p.y.toDouble());
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  double _clamp01(double value) => value.clamp(0.0, 1.0).toDouble();

  Future<void> dispose() => _detector.close();
}
