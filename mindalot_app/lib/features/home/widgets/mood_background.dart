import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:video_player/video_player.dart';
import '../../../core/models/mood.dart';
import '../../../core/services/mood_provider.dart';

/// Full-screen mood background.
///
/// Moods with a video (angry, anxious):
///   • Video is pre-loaded silently on home screen mount.
///   • On mood select → video plays INSTANTLY (no crossfade delay).
///   • Volume is on so ocean/nature sounds play.
///
/// All other moods: procedural painted background.
class MoodBackground extends StatefulWidget {
  const MoodBackground({super.key});

  @override
  State<MoodBackground> createState() => _MoodBackgroundState();
}

class _MoodBackgroundState extends State<MoodBackground>
    with TickerProviderStateMixin {
  late AnimationController _proceduralCtrl; // drives painted animations
  MoodType _currentMood = MoodType.none;
  MoodType _previousMood = MoodType.none;
  late AnimationController _transitionCtrl;
  late Animation<double> _transitionAnim;

  // One video controller per mood that has a video
  final Map<MoodType, VideoPlayerController> _videos = {};
  final Map<MoodType, bool> _videoReady = {};

  static const Map<MoodType, String> _videoAssets = {
    MoodType.angry: 'assets/video/6550972-hd_1080_1920_25fps.mp4',
    MoodType.anxious: 'assets/video/13278969_1080_1920_30fps.mp4',
  };

  bool _moodChangeScheduled = false;

  @override
  void initState() {
    super.initState();

    _proceduralCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _transitionCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _transitionAnim = CurvedAnimation(
        parent: _transitionCtrl, curve: Curves.easeInOut);

    _preloadAll();
  }

  /// Pre-load all mood videos in parallel at startup so they're ready instantly.
  void _preloadAll() {
    for (final entry in _videoAssets.entries) {
      final mood = entry.key;
      final path = entry.value;
      final ctrl = VideoPlayerController.asset(path)
        ..setLooping(true)
        ..setVolume(0.0); // muted until that mood is actually selected
      _videos[mood] = ctrl;
      _videoReady[mood] = false;
      ctrl.initialize().then((_) {
        if (!mounted) return;
        setState(() => _videoReady[mood] = true);
        // If user already selected this mood before video loaded, start now
        if (_currentMood == mood) _activateVideo(mood);
      }).catchError((e) {
        debugPrint('Video init error [$mood]: $e');
      });
    }
  }

  void _activateVideo(MoodType mood) {
    final ctrl = _videos[mood];
    if (ctrl == null || !(_videoReady[mood] ?? false)) return;
    ctrl.setVolume(0.7); // turn on sound
    ctrl.play();
  }

  void _deactivateVideo(MoodType mood) {
    final ctrl = _videos[mood];
    if (ctrl == null) return;
    ctrl.setVolume(0.0);
    ctrl.pause();
    ctrl.seekTo(Duration.zero);
  }

  void _onMoodChanged(MoodType newMood) {
    if (!mounted) return;

    // Stop previous mood's video if it had one
    if (_videoAssets.containsKey(_previousMood)) {
      _deactivateVideo(_previousMood);
    }

    setState(() {
      _previousMood = _currentMood;
      _currentMood = newMood;
    });

    // Start new mood's video immediately
    if (_videoAssets.containsKey(newMood)) {
      _activateVideo(newMood);
    }

    _transitionCtrl.forward(from: 0);
  }

  @override
  void dispose() {
    _proceduralCtrl.dispose();
    _transitionCtrl.dispose();
    for (final ctrl in _videos.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  /// Renders the video as a cover-fit full-screen layer.
  Widget _videoLayer(MoodType mood) {
    final ctrl = _videos[mood];
    if (ctrl == null || !(_videoReady[mood] ?? false)) {
      return const SizedBox.shrink();
    }
    final size = ctrl.value.size;
    if (size.width == 0 || size.height == 0) return const SizedBox.shrink();

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: VideoPlayer(ctrl),
        ),
      ),
    );
  }

  Widget _buildLayer(MoodType mood, double opacity) {
    final hasVideo = _videoAssets.containsKey(mood);

    Widget content;
    if (hasVideo) {
      if (_videoReady[mood] ?? false) {
        // Video ready — show it directly, no procedural underneath
        content = _videoLayer(mood);
      } else {
        // Video still loading — show simple colour fill (no procedural to avoid
        // the "fake ocean" the user hates)
        content = Container(
          color: mood == MoodType.angry
              ? const Color(0xFF071828)
              : const Color(0xFF0D1C12),
        );
      }
    } else {
      content = AnimatedBuilder(
        animation: _proceduralCtrl,
        builder: (_, __) => CustomPaint(
          size: Size.infinite,
          painter: _MoodPainter(mood: mood, progress: _proceduralCtrl.value),
        ),
      );
    }

    return Opacity(opacity: opacity, child: content);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodProvider>(
      builder: (context, provider, _) {
        if (provider.currentMood != _currentMood && !_moodChangeScheduled) {
          _moodChangeScheduled = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _moodChangeScheduled = false;
            _onMoodChanged(provider.currentMood);
          });
        }

        final size = MediaQuery.of(context).size;

        return AnimatedBuilder(
          animation: _transitionAnim,
          builder: (_, __) {
            return Container(
              width: size.width,
              height: size.height,
              color: Colors.white,
              child: Stack(
                children: [
                  if (_transitionAnim.value < 1.0)
                    Positioned.fill(
                        child: _buildLayer(_previousMood, 1.0)),
                  Positioned.fill(
                    child: _buildLayer(_currentMood, _transitionAnim.value),
                  ),
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
// Procedural painters for non-video moods
// ═══════════════════════════════════════════════════════════════════════════

class _MoodPainter extends CustomPainter {
  final MoodType mood;
  final double progress;
  _MoodPainter({required this.mood, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    switch (mood) {
      case MoodType.happy:
        _paintSunrise(canvas, size);
        break;
      case MoodType.sad:
        _paintRain(canvas, size);
        break;
      case MoodType.confused:
        _paintCosmos(canvas, size);
        break;
      default:
        _paintDefault(canvas, size);
        break;
    }
  }

  void _paintSunrise(Canvas canvas, Size size) {
    final bg = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(bg,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF87CEEB), Color(0xFFFFDAB9)],
          ).createShader(bg));
    final sunY = size.height * 0.55;
    final pulse = math.sin(progress * math.pi * 4);
    final r = 60.0 + pulse * 5.0;
    canvas.drawCircle(Offset(size.width * 0.5, sunY), r * 1.5,
        Paint()
          ..color = const Color(0xFFFFF1E0).withValues(alpha: 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40));
    canvas.drawCircle(Offset(size.width * 0.5, sunY), r,
        Paint()..color = const Color(0xFFFFF9EE));
  }

  void _paintRain(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A2634), Color(0xFF091016)],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)));
    final rf = Paint()
      ..color = const Color(0xFF8899A6).withValues(alpha: 0.6)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 200; i++) {
      final spd = i % 4 == 0 ? 3.0 : 1.5;
      final len = i % 4 == 0 ? 40.0 : 20.0;
      final x = size.width * ((i * 0.03 + progress * 0.2 * spd) % 1.0);
      final y = size.height * ((i * 0.07 + progress * spd) % 1.0);
      canvas.drawLine(Offset(x, y), Offset(x - len * 0.25, y + len),
          i % 4 == 0 ? rf : (rf..color = const Color(0xFF4B5B6B).withValues(alpha: 0.3)));
    }
  }

  void _paintCosmos(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = const Color(0xFF02000A));
    final center = Offset(size.width * 0.5, size.height * 0.5);
    canvas.drawCircle(
      center + Offset(math.cos(progress * math.pi * 2) * 80,
          math.sin(progress * math.pi * 2) * 80),
      size.width * 0.7,
      Paint()
        ..color = const Color(0xFF6B21A8).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120),
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

  void _paintDefault(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8F4F4), Color(0xFFBFE0E0)],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)));
    final shape = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(
      Offset(size.width * 0.5 + math.cos(progress * math.pi * 2) * 50,
          size.height * 0.3 + math.sin(progress * math.pi * 2) * 50),
      100, shape);
    canvas.drawCircle(
      Offset(size.width * 0.2 + math.cos(progress * math.pi * 2 + 2) * 30,
          size.height * 0.7 + math.sin(progress * math.pi * 2 + 2) * 30),
      150, shape);
  }

  @override
  bool shouldRepaint(covariant _MoodPainter old) =>
      old.progress != progress || old.mood != mood;
}
