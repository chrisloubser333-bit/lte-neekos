import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../models/face_calibration.dart';

/// Real-time photo deformation layer for a personalized Eve avatar.
///
/// This is intentionally renderer-agnostic: it uses Flutter's textured
/// vertices so the user's original photo remains the identity layer while
/// small, local mesh deformations animate the mouth and eyes. A future Rive
/// asset can replace this renderer without changing the face calibration or
/// viseme contracts.
class DeformableAvatar extends StatefulWidget {
  final String imagePath;
  final double size;
  final FaceCalibration? calibration;
  final String viseme;
  final bool speaking;
  final bool blink;

  const DeformableAvatar({
    super.key,
    required this.imagePath,
    required this.size,
    required this.calibration,
    required this.viseme,
    required this.speaking,
    required this.blink,
  });

  @override
  State<DeformableAvatar> createState() => _DeformableAvatarState();
}

class _DeformableAvatarState extends State<DeformableAvatar> {
  ui.Image? _image;
  String? _loadedPath;
  int _loadToken = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant DeformableAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      _load();
    }
  }

  Future<void> _load() async {
    final token = ++_loadToken;
    final bytes = await _readBytes(widget.imagePath);
    if (bytes == null) return;
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    codec.dispose();
    if (!mounted || token != _loadToken) {
      frame.image.dispose();
      return;
    }
    final old = _image;
    setState(() {
      _image = frame.image;
      _loadedPath = widget.imagePath;
    });
    old?.dispose();
  }

  Future<Uint8List?> _readBytes(String path) async {
    try {
      return await File(path).readAsBytes();
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _loadToken++;
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    if (image == null || _loadedPath != widget.imagePath) {
      return const SizedBox.shrink();
    }
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _DeformableFacePainter(
          image: image,
          calibration: widget.calibration,
          viseme: widget.viseme,
          speaking: widget.speaking,
          blink: widget.blink,
        ),
      ),
    );
  }
}

class _DeformableFacePainter extends CustomPainter {
  final ui.Image image;
  final FaceCalibration? calibration;
  final String viseme;
  final bool speaking;
  final bool blink;

  _DeformableFacePainter({
    required this.image,
    required this.calibration,
    required this.viseme,
    required this.speaking,
    required this.blink,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final calibration = this.calibration;
    if (calibration == null) {
      _paintCover(canvas, size, const Offset(0, 0), 1.0);
      return;
    }

    const grid = 24;
    final positions = <Offset>[];
    final textures = <Offset>[];
    final indices = <int>[];

    final imageAspect = image.width / image.height;
    final scale = math.max(size.width / image.width, size.height / image.height);
    final renderedW = image.width * scale;
    final renderedH = image.height * scale;
    final dx = (size.width - renderedW) / 2;
    final dy = (size.height - renderedH) / 2;

    for (var y = 0; y <= grid; y++) {
      for (var x = 0; x <= grid; x++) {
        final u = x / grid;
        final v = y / grid;
        var p = Offset(dx + u * renderedW, dy + v * renderedH);
        p = _deform(
          p,
          size,
          calibration,
          renderedW,
          renderedH,
        );
        positions.add(p);
        textures.add(Offset(u * image.width, v * image.height));
      }
    }

    for (var y = 0; y < grid; y++) {
      for (var x = 0; x < grid; x++) {
        final a = y * (grid + 1) + x;
        final b = a + 1;
        final c = a + (grid + 1);
        final d = c + 1;
        indices.addAll([a, b, c, b, d, c]);
      }
    }

    final vertices = ui.Vertices.raw(
      ui.VertexMode.triangles,
      positions,
      textureCoordinates: textures,
      indices: Uint16List.fromList(indices),
    );
    final paint = Paint()
      ..shader = ui.ImageShader(
        image,
        TileMode.clamp,
        TileMode.clamp,
        _identityMatrix(),
      );
    canvas.drawVertices(vertices, BlendMode.srcOver, paint);
  }

  Offset _deform(
    Offset p,
    Size size,
    FaceCalibration c,
    double renderedW,
    double renderedH,
  ) {
    final mouth = Offset(
      (size.width - renderedW) / 2 + c.mouthCenter.dx * renderedW,
      (size.height - renderedH) / 2 + c.mouthCenter.dy * renderedH,
    );
    final leftEye = Offset(
      (size.width - renderedW) / 2 + c.leftEyeCenter.dx * renderedW,
      (size.height - renderedH) / 2 + c.leftEyeCenter.dy * renderedH,
    );
    final rightEye = Offset(
      (size.width - renderedW) / 2 + c.rightEyeCenter.dx * renderedW,
      (size.height - renderedH) / 2 + c.rightEyeCenter.dy * renderedH,
    );

    final mouthRadius = (c.mouthWidth * renderedW * .85).clamp(24.0, size.width * .38);
    final mouthInfluence = _falloff(p, mouth, mouthRadius);
    final eyeRadius = (c.eyeWidth * renderedW * 2.2).clamp(18.0, size.width * .22);

    final mouthOpen = _mouthOpenFactor(viseme);
    var result = p;

    if (mouthInfluence > 0) {
      // Stretch vertically around the mouth center and slightly widen for
      // rounded/wide visemes. The movement is intentionally small so a photo
      // remains natural rather than looking like a rubber mask.
      final vertical = mouthOpen * size.height * .045 * mouthInfluence;
      final horizontal = _mouthWidthFactor(viseme) * size.width * .018 * mouthInfluence;
      result = Offset(
        result.dx + (result.dx - mouth.dx) * horizontal / math.max(1, mouthRadius),
        result.dy + (result.dy - mouth.dy) * vertical / math.max(1, mouthRadius),
      );
    }

    if (blink) {
      result = _compressAround(result, leftEye, eyeRadius, .10);
      result = _compressAround(result, rightEye, eyeRadius, .10);
    }

    return result;
  }

  Offset _compressAround(Offset p, Offset center, double radius, double amount) {
    final d = p - center;
    final dist = d.distance;
    if (dist >= radius) return p;
    final influence = 1 - (dist / radius);
    return center + Offset(d.dx, d.dy * (1 - amount * influence));
  }

  double _falloff(Offset p, Offset center, double radius) {
    final dist = (p - center).distance;
    return math.max(0, 1 - dist / radius);
  }

  double _mouthOpenFactor(String value) {
    switch (value) {
      case 'open': return 1.0;
      case 'round': return .9;
      case 'wide': return .72;
      case 'pucker': return .58;
      case 'teeth': return .45;
      case 'closed': return .08;
      case 'smile': return .25;
      case 'neutral': return speaking ? .20 : .05;
      default: return speaking ? .12 : 0;
    }
  }

  double _mouthWidthFactor(String value) {
    switch (value) {
      case 'wide':
      case 'smile': return 1.0;
      case 'round':
      case 'pucker': return -.45;
      default: return 0;
    }
  }

  void _paintCover(Canvas canvas, Size size, Offset _, double __) {
    final scale = math.max(size.width / image.width, size.height / image.height);
    final w = image.width * scale;
    final h = image.height * scale;
    final rect = Rect.fromLTWH((size.width - w) / 2, (size.height - h) / 2, w, h);
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      rect,
      Paint(),
    );
  }

  Float64List _identityMatrix() {
    final m = Float64List(16);
    m[0] = 1;
    m[5] = 1;
    m[10] = 1;
    m[15] = 1;
    return m;
  }

  @override
  bool shouldRepaint(covariant _DeformableFacePainter oldDelegate) =>
      oldDelegate.image != image ||
      oldDelegate.calibration != calibration ||
      oldDelegate.viseme != viseme ||
      oldDelegate.speaking != speaking ||
      oldDelegate.blink != blink;
}

// Implemented in a separate file on mobile in a real app; kept here as a
// compile-time hook for this project. See mobile_file_reader.dart.
Future<Uint8List> _readIo(String path) async {
  throw UnsupportedError('Filesystem avatar loading requires the mobile IO adapter.');
}
