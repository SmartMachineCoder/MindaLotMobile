import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:video_player/video_player.dart';
import '../../../core/models/mood.dart';
import '../../../core/services/mood_provider.dart';

/// Full-screen animated background that changes with mood.
///
/// Strategy for angry (ocean) mode:
///   1. Procedural ocean animation shows INSTANTLY on tap (zero delay).
///   2. Two real sea videos pre-load in the background on home screen mount.
///   3. When a video is ready, it crossfades in over the procedural animation.
///   On mobile (Android/iOS) this crossfade takes ~1s. On Windows desktop it
///   may take longer, but the procedural animation covers the wait.
class MoodBackground extends StatefulWidget {
  const MoodBackground({super.key});

  @override
  State<MoodBackground> createState() => _MoodBackgroundState();
}

class _MoodBackgroundState extends State<MoodBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  MoodType _currentMood = MoodType.none;
  MoodType _previousMood = MoodType.none;
  late AnimationController _transitionController;
  late Animation<double> _transitionAnim;

  // Two sea video players — pre-loaded at mount, crossfaded when ready
  VideoPlayerController? _seaVideo1;
  VideoPlayerController? _seaVideo2;
  bool _isVideo1Ready = false;
  bool _isVideo2Ready = false;
  int _activeVideoIndex = 0; // Alternate between the two

  // Crossfade from procedural → video
  late AnimationController _videoCrossfadeController;
  late Animation<double> _videoCrossfadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _transitionAnim = CurvedAnimation(
        parent: _transitionController, curve: Curves.easeInOut);

    _videoCrossfadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _videoCrossfadeAnim = CurvedAnimation(
        parent: _videoCrossfadeController, curve: Curves.easeIn);

    // Start pre-loading both sea videos immediately
    _preloadVideos();
  }

  void _preloadVideos() {
    _seaVideo1 = VideoPlayerController.asset(
      'assets/video/13278969_1080_1920_30fps.mp4',
    )..initialize().then((_) {
        _seaVideo1!.setLooping(true);
        _seaVideo1!.setVolume(0.0);
        if (mounted) {
          setState(() => _isVideo1Ready = true);
          // If already in angry mode, start playing + crossfade
          if (_currentMood == MoodType.angry) {
            _startVideo();
          }
        }
      }).catchError((e) {
        debugPrint('Sea video 1 load error: $e');
      });

    _seaVideo2 = VideoPlayerController.asset(
      'assets/video/6550972-hd_1080_1920_25fps.mp4',
    )..initialize().then((_) {
        _seaVideo2!.setLooping(true);
        _seaVideo2!.setVolume(0.0);
        if (mounted) {
          setState(() => _isVideo2Ready = true);
          if (_currentMood == MoodType.angry && !_isVideo1Ready) {
            _startVideo();
          }
        }
      }).catchError((e) {
        debugPrint('Sea video 2 load error: $e');
      });
  }

  void _startVideo() {
    // Pick whichever video is ready; alternate on re-entry
    VideoPlayerController? chosen;
    if (_activeVideoIndex == 0 && _isVideo1Ready) {
      chosen = _seaVideo1;
    } else if (_isVideo2Ready) {
      chosen = _seaVideo2;
      _activeVideoIndex = 1;
    } else if (_isVideo1Ready) {
      chosen = _seaVideo1;
      _activeVideoIndex = 0;
    }

    if (chosen != null && !chosen.value.isPlaying) {
      chosen.play();
      // Crossfade from procedural → video
      _videoCrossfadeController.forward(from: 0);
    }

    // Alternate for next time
    _activeVideoIndex = (_activeVideoIndex + 1) % 2;
  }

  void _stopVideos() {
    _videoCrossfadeController.value = 0;
    _seaVideo1?.pause();
    _seaVideo2?.pause();
  }

  @override
  void dispose() {
    _controller.dispose();
    _transitionController.dispose();
    _videoCrossfadeController.dispose();
    _seaVideo1?.dispose();
    _seaVideo2?.dispose();
    super.dispose();
  }

  /// Get the currently active (playing or ready) video controller
  VideoPlayerController? get _activeVideo {
    // Return whichever is currently playing
    if (_seaVideo1 != null &&
        _isVideo1Ready &&
        _seaVideo1!.value.isPlaying) {
      return _seaVideo1;
    }
    if (_seaVideo2 != null &&
        _isVideo2Ready &&
        _seaVideo2!.value.isPlaying) {
      return _seaVideo2;
    }
    return null;
  }

  Widget _buildVideoLayer(VideoPlayerController vc, double opacity) {
    return Opacity(
      opacity: opacity,
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: vc.value.size.width,
            height: vc.value.size.height,
            child: VideoPlayer(vc),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundLayer(MoodType mood, double opacity) {
    if (mood == MoodType.angry) {
      final video = _activeVideo;
      if (video != null) {
        // Show procedural ocean underneath, video on top crossfading in
        return Opacity(
          opacity: opacity,
          child: AnimatedBuilder(
            animation: _videoCrossfadeAnim,
            builder: (_, __) {
              return Stack(
                children: [
                  // Procedural ocean (fades out as video fades in)
                  Opacity(
                    opacity: 1.0 - _videoCrossfadeAnim.value,
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _MoodPainter(
                          mood: mood, progress: _controller.value),
                    ),
                  ),
                  // Real video (fades in)
                  _buildVideoLayer(video, _videoCrossfadeAnim.value),
                ],
              );
            },
          ),
        );
      }
    }

    // All other moods or angry without video ready yet → procedural
    return Opacity(
      opacity: opacity,
      child: CustomPaint(
        size: Size.infinite,
        painter: _MoodPainter(mood: mood, progress: _controller.value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodProvider>(
      builder: (context, provider, _) {
        if (provider.currentMood != _currentMood) {
          _previousMood = _currentMood;
          _currentMood = provider.currentMood;

          if (_currentMood == MoodType.angry) {
            _startVideo();
          } else {
            _stopVideos();
          }

          _transitionController.forward(from: 0);
        }

        final size = MediaQuery.of(context).size;

        return AnimatedBuilder(
          animation: Listenable.merge(
              [_controller, _transitionAnim, _videoCrossfadeAnim]),
          builder: (_, __) {
            return Container(
              width: size.width,
              height: size.height,
              color: Colors.white,
              child: Stack(
                children: [
                  if (_transitionAnim.value < 1.0)
                    _buildBackgroundLayer(_previousMood, 1.0),
                  _buildBackgroundLayer(
                      _currentMood, _transitionAnim.value),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Procedural painters — instant, 60fps, zero loading
// ═══════════════════════════════════════════════════════════════════════════

class _MoodPainter extends CustomPainter {
  final MoodType mood;
  final double progress;

  _MoodPainter({required this.mood, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    switch (mood) {
      case MoodType.angry:
        _paintCinematicOcean(canvas, size);
        break;
      case MoodType.anxious:
        _paintForestCanopy(canvas, size);
        break;
      case MoodType.happy:
        _paintSoftSunrise(canvas, size);
        break;
      case MoodType.sad:
        _paintCozyRain(canvas, size);
        break;
      case MoodType.confused:
        _paintStarryCosmos(canvas, size);
        break;
      default:
        _paintDefault(canvas, size);
        break;
    }
  }

  // ── ANGRY: Cinematic ocean ──────────────────────────────────────────────
  void _paintCinematicOcean(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sky
    final skyRect = Rect.fromLTWH(0, 0, w, h * 0.50);
    canvas.drawRect(
      skyRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF070D15),
            const Color(0xFF0C1929),
            Color.lerp(const Color(0xFF0E2A43), const Color(0xFF153553),
                (math.sin(progress * math.pi * 2) + 1) / 2)!,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(skyRect),
    );

    // Storm clouds
    final cloudPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
    for (int i = 0; i < 5; i++) {
      final cx = w * ((i * 0.25 + progress * 0.08) % 1.4 - 0.2);
      final cy = h * (0.06 + i * 0.06);
      cloudPaint.color = Color.fromRGBO(
          40 + i * 10, 50 + i * 8, 70 + i * 12, 0.25 + i * 0.04);
      canvas.drawCircle(Offset(cx, cy), 80.0 + i * 30, cloudPaint);
    }

    // Lightning
    final flash = math.sin(progress * math.pi * 12);
    if (flash > 0.92) {
      canvas.drawCircle(
        Offset(w * (0.2 + math.sin(progress * 7) * 0.3), h * 0.15),
        200,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.15 + (flash - 0.92) * 2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80),
      );
    }

    // Horizon glow
    final horizonY = h * 0.48;
    canvas.drawRect(
      Rect.fromLTWH(0, horizonY - 15, w, 30),
      Paint()
        ..color = const Color(0xFF2A5070).withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
    );

    // Ocean base
    canvas.drawRect(
      Rect.fromLTWH(0, horizonY, w, h - horizonY),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A2840), Color(0xFF061828), Color(0xFF030D18)],
        ).createShader(Rect.fromLTWH(0, horizonY, w, h - horizonY)),
    );

    // 7-layer rolling waves
    for (int layer = 0; layer < 7; layer++) {
      final wavePath = Path();
      final baseY = horizonY + layer * (h - horizonY) * 0.13;
      final amplitude = 8.0 + layer * 5.0;
      final speed = progress * math.pi * (3.0 + (7 - layer) * 0.6);
      final f1 = 2.0 + layer * 0.5;
      final f2 = 4.5 + layer * 0.3;

      wavePath.moveTo(0, h);
      wavePath.lineTo(0, baseY);
      for (double x = 0; x <= w; x += 3) {
        final t = x / w;
        wavePath.lineTo(
          x,
          baseY +
              amplitude * math.sin(t * math.pi * f1 + speed) +
              amplitude * 0.4 * math.cos(t * math.pi * f2 - speed * 1.3) +
              amplitude * 0.2 * math.sin(t * math.pi * 7 + speed * 0.5 + layer),
        );
      }
      wavePath.lineTo(w, h);
      wavePath.close();

      final depth = layer / 6.0;
      canvas.drawPath(
        wavePath,
        Paint()
          ..color = Color.lerp(
              const Color(0xFF1A5070), const Color(0xFF040E16), depth)!,
      );
      if (layer < 5) {
        canvas.drawPath(
          wavePath,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.25 - depth * 0.15)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5 - depth * 1.5
            ..strokeCap = StrokeCap.round,
        );
      }
    }

    // Spray particles
    final sprayPaint = Paint();
    for (int i = 0; i < 80; i++) {
      final seed = i * 7.31;
      final phase = progress * math.pi * 4 + seed;
      final cx = w * ((seed * 0.13) % 1.0);
      final cy = horizonY + (i % 5) * (h - horizonY) * 0.12;
      final peak = math.sin(cx / w * math.pi * 3 + phase);
      if (peak > 0.5) {
        final sy = cy + 10 * math.sin(cx / w * math.pi * 3 + phase) -
            (peak - 0.5) * 30 * (1 + math.sin(seed));
        sprayPaint.color =
            Colors.white.withValues(alpha: ((peak - 0.5) * 0.6).clamp(0.0, 0.5));
        canvas.drawCircle(Offset(cx, sy), 1.0 + (i % 3) * 0.5, sprayPaint);
      }
    }

    // Shimmer reflections
    final reflectPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    for (int i = 0; i < 20; i++) {
      final rx = w * ((i * 0.17 + progress * 0.15) % 1.0);
      final ry = horizonY + 20 + (i * 13.7 % (h * 0.4));
      final sh = (math.sin(progress * math.pi * 8 + i * 2) + 1) / 2;
      reflectPaint.color = Color.fromRGBO(180, 210, 240, 0.05 + sh * 0.08);
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(rx, ry), width: 30 + sh * 20, height: 4),
        reflectPaint,
      );
    }
  }

  // ── ANXIOUS: Forest canopy ─────────────────────────────────────────────
  void _paintForestCanopy(Canvas canvas, Size size) {
    final bgRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(
      bgRect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0.0, -0.5),
          radius: 1.5,
          colors: [Color(0xFF2A4D32), Color(0xFF0D1C12)],
        ).createShader(bgRect),
    );

    final rayPaint = Paint()
      ..color = const Color(0xFFA7D7B5).withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    for (int i = 0; i < 4; i++) {
      final startX = size.width * (0.2 * i) - 100;
      final sway = math.sin(progress * math.pi * 4 + i) * 30;
      final path = Path()
        ..moveTo(startX, -50)
        ..lineTo(startX + 120, -50)
        ..lineTo(size.width + sway + (i * 50), size.height + 100)
        ..lineTo(size.width - 250 + sway + (i * 50), size.height + 100)
        ..close();
      canvas.drawPath(path, rayPaint);
    }

    final treePaint = Paint()..color = const Color(0xFF0A140E);
    for (int i = 0; i < 6; i++) {
      final x = size.width * (i * 0.2);
      final th = size.height * (0.6 + (i % 3) * 0.15);
      canvas.drawPath(
        Path()
          ..moveTo(x, size.height)
          ..lineTo(x + 10, th + 50)
          ..lineTo(x - 20, th + 80)
          ..lineTo(x + 15, th + 20)
          ..lineTo(x, th)
          ..lineTo(x + 20, th + 30)
          ..lineTo(x + 50, th + 70)
          ..lineTo(x + 30, th + 60)
          ..lineTo(x + 40, size.height)
          ..close(),
        treePaint,
      );
    }

    final dustPaint = Paint()
      ..color = const Color(0xFFC8E6C9).withValues(alpha: 0.6);
    for (int i = 0; i < 50; i++) {
      final x = size.width * ((i * 0.13 + progress * 0.2) % 1.0);
      final y = size.height * (1.0 - ((i * 0.27 + progress * 0.1) % 1.0));
      final sway = math.sin(progress * math.pi * 10 + i) * 10.0;
      canvas.drawCircle(Offset(x + sway, y), 1.0 + (i % 2), dustPaint);
    }
  }

  // ── HAPPY: Soft sunrise ────────────────────────────────────────────────
  void _paintSoftSunrise(Canvas canvas, Size size) {
    final bgRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(
      bgRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF87CEEB), Color(0xFFFFDAB9)],
        ).createShader(bgRect),
    );

    final sunY = size.height * 0.55;
    final pulse = math.sin(progress * math.pi * 4);
    final sunR = 60.0 + pulse * 5.0;
    canvas.drawCircle(
      Offset(size.width * 0.5, sunY),
      sunR * 1.5,
      Paint()
        ..color = const Color(0xFFFFF1E0).withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40),
    );
    canvas.drawCircle(Offset(size.width * 0.5, sunY), sunR,
        Paint()..color = const Color(0xFFFFF9EE));

    canvas.drawPath(
      Path()
        ..moveTo(0, size.height)
        ..lineTo(0, size.height * 0.8)
        ..quadraticBezierTo(
            size.width * 0.5, size.height * 0.65, size.width, size.height * 0.85)
        ..lineTo(size.width, size.height)
        ..close(),
      Paint()..color = const Color(0xFF98FB98).withValues(alpha: 0.5),
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width, size.height)
        ..lineTo(size.width, size.height * 0.75)
        ..quadraticBezierTo(
            size.width * 0.5, size.height * 0.9, 0, size.height * 0.9)
        ..lineTo(0, size.height)
        ..close(),
      Paint()..color = const Color(0xFF90EE90).withValues(alpha: 0.8),
    );

    final bokeh = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    for (int i = 0; i < 15; i++) {
      final x = size.width * ((i * 0.23) % 1.0);
      final y = size.height * ((1.0 - (i * 0.15 + progress * 0.2)) % 1.0);
      final sway = math.sin(progress * math.pi * 4 + i) * 15;
      canvas.drawCircle(Offset(x + sway, y), 4.0 + (i % 4) * 3.0, bokeh);
    }
  }

  // ── SAD: Cinematic rain ────────────────────────────────────────────────
  void _paintCozyRain(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A2634), Color(0xFF091016)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.8),
      150,
      Paint()
        ..color = const Color(0xFFE67E22).withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100),
    );

    final rainF = Paint()
      ..color = const Color(0xFF8899A6).withValues(alpha: 0.6)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final rainB = Paint()
      ..color = const Color(0xFF4B5B6B).withValues(alpha: 0.3)
      ..strokeWidth = 1.0;
    for (int i = 0; i < 200; i++) {
      final isFront = i % 4 == 0;
      final spd = isFront ? 3.0 : 1.5;
      final len = isFront ? 40.0 : 20.0;
      final x = size.width * ((i * 0.03 + progress * 0.2 * spd) % 1.0);
      final y = size.height * ((i * 0.07 + progress * spd) % 1.0);
      canvas.drawLine(
          Offset(x, y), Offset(x - len * 0.25, y + len), isFront ? rainF : rainB);
    }
  }

  // ── CONFUSED: Starry cosmos ────────────────────────────────────────────
  void _paintStarryCosmos(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = const Color(0xFF02000A));

    final center = Offset(size.width * 0.5, size.height * 0.5);
    canvas.drawCircle(
      center +
          Offset(math.cos(progress * math.pi * 2) * 80,
              math.sin(progress * math.pi * 2) * 80),
      size.width * 0.7,
      Paint()
        ..color = const Color(0xFF6B21A8).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120),
    );
    canvas.drawCircle(
      center +
          Offset(math.sin(progress * math.pi * 2 + math.pi) * 60,
              math.cos(progress * math.pi * 2 + math.pi) * 60),
      size.width * 0.6,
      Paint()
        ..color = const Color(0xFF0369A1).withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100),
    );

    final sp = Paint();
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(progress * math.pi * 2 * 0.2);
    for (int i = 0; i < 200; i++) {
      final a = i * 0.8;
      final r = (i * 8.0) % size.height;
      final tw = (math.sin(progress * math.pi * 20 + i) + 1.0) / 2.0;
      sp.color = Colors.white.withValues(alpha: 0.2 + 0.8 * tw);
      canvas.drawCircle(
          Offset(math.cos(a) * r, math.sin(a) * r), 0.5 + (i % 3) * 0.8, sp);
    }
    canvas.restore();
  }

  // ── DEFAULT: Calm teal ─────────────────────────────────────────────────
  void _paintDefault(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F4F4), Color(0xFFBFE0E0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    final shape = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(
      Offset(size.width * 0.5 + math.cos(progress * math.pi * 2) * 50,
          size.height * 0.3 + math.sin(progress * math.pi * 2) * 50),
      100,
      shape,
    );
    canvas.drawCircle(
      Offset(size.width * 0.2 + math.cos(progress * math.pi * 2 + 2) * 30,
          size.height * 0.7 + math.sin(progress * math.pi * 2 + 2) * 30),
      150,
      shape,
    );
  }

  @override
  bool shouldRepaint(covariant _MoodPainter old) =>
      old.progress != progress || old.mood != mood;
}
