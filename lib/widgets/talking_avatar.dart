import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'deformable_avatar.dart';
import 'face_rig.dart';
import '../models/face_calibration.dart';
import '../services/face_calibration_service.dart';

class TalkingAvatar extends StatefulWidget {
  final String? imagePath;
  final bool isSpeaking;
  final double size;
  final String name;
  final String viseme;

  const TalkingAvatar({
    super.key,
    required this.imagePath,
    required this.isSpeaking,
    this.size = 210,
    this.name = 'EVE',
    this.viseme = 'rest',
  });

  @override
  State<TalkingAvatar> createState() => _TalkingAvatarState();
}

class _TalkingAvatarState extends State<TalkingAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _blinkTimer;
  bool _blink = false;
  FaceCalibration? _calibration;
  String? _calibratedPath;
  final FaceCalibrationService _faceService = FaceCalibrationService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _scheduleBlink();
    _calibrate();
  }

  void _scheduleBlink() {
    _blinkTimer?.cancel();
    _blinkTimer = Timer(
      Duration(milliseconds: 2600 + (DateTime.now().millisecond % 2600)),
      () async {
        if (!mounted) return;
        setState(() => _blink = true);
        await Future<void>.delayed(const Duration(milliseconds: 110));
        if (!mounted) return;
        setState(() => _blink = false);
        _scheduleBlink();
      },
    );
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _controller.dispose();
    _faceService.dispose();
    super.dispose();
  }


  Future<void> _calibrate() async {
    final path = widget.imagePath;
    if (path == null || path == _calibratedPath) return;
    _calibratedPath = path;
    final result = await _faceService.calibrate(path);
    if (!mounted || widget.imagePath != path) return;
    setState(() => _calibration = result);
  }

  @override
  void didUpdateWidget(covariant TalkingAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      _calibration = null;
      _calibratedPath = null;
      _calibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final phase = _controller.value * 6.28318;
        final speakingMotion = widget.isSpeaking
            ? 1.0 + (0.006 * (1 + _sin(phase)))
            : 1.0;
        final sway = widget.isSpeaking ? 0.006 * _sin(phase * .65) : 0.0;

        return Transform.translate(
          offset: Offset(widget.size * sway, 0),
          child: Transform.scale(
            scale: speakingMotion,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: widget.size + 24,
                  height: widget.size + 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.glow(
                      widget.isSpeaking ? AppTheme.accent : AppTheme.primary,
                      blur: widget.isSpeaking ? 30 : 18,
                      spread: widget.isSpeaking ? 3 : 1,
                    ),
                  ),
                ),
                ClipOval(
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    color: AppTheme.surfaceLight,
                    child: widget.imagePath != null &&
                            File(widget.imagePath!).existsSync()
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(
                                File(widget.imagePath!),
                                fit: BoxFit.cover,
                              ),
                              if (_calibration != null)
                                DeformableAvatar(
                                  imagePath: widget.imagePath!,
                                  size: widget.size,
                                  calibration: _calibration,
                                  viseme: widget.viseme,
                                  speaking: widget.isSpeaking,
                                  blink: _blink,
                                ),
                            ],
                          )
                        : const Icon(
                            Icons.face_3_rounded,
                            size: 96,
                            color: AppTheme.primary,
                          ),
                  ),
                ),
                // Fallback facial rig remains available when the photo cannot
                // be decoded by the textured mesh renderer.
                if (widget.imagePath != null && _calibration == null)
                  FaceRig(
                    viseme: widget.viseme,
                    speaking: widget.isSpeaking,
                    blink: _blink,
                    size: widget.size,
                    calibration: _calibration,
                  ),
                if (widget.isSpeaking)
                  Positioned(
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.background.withOpacity(.88),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.primary.withOpacity(.55),
                        ),
                      ),
                      child: Text(
                        widget.viseme == 'rest'
                            ? '${widget.name} is speaking'
                            : widget.viseme,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _sin(double value) {
    // Small, dependency-free approximation suitable for subtle motion.
    return math.sin(value);
  }
}

