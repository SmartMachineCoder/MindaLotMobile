import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/mood.dart';
import '../../../core/services/mood_provider.dart';

/// Full-screen animated background that changes with mood.
/// Uses gradient + particle-like painters for each mood.
/// In production, replace with Lottie animation loaded from Firebase Storage.
class MoodBackground extends StatefulWidget {
  const MoodBackground({super.key});

  @override
  State<MoodBackground> createState() => _MoodBackgroundState();
}

class _MoodBackgroundState extends State<MoodBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  MoodType _lastMood = MoodType.none;
  MoodType _currentMood = MoodType.none;
  late AnimationController _transitionController;
  late Animation<double> _transitionAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _transitionAnim = CurvedAnimation(
        parent: _transitionController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodProvider>(
      builder: (context, provider, _) {
        if (provider.currentMood != _currentMood) {
          _lastMood = _currentMood;
          _currentMood = provider.currentMood;
          _transitionController.forward(from: 0);
        }

        final config = MoodData.get(_currentMood);
        final size = MediaQuery.of(context).size;

        return AnimatedBuilder(
          animation: Listenable.merge([_controller, _transitionAnim]),
          builder: (_, __) {
            return Stack(
              children: [
                // Base background gradient
                Container(
                  width: size.width,
                  height: size.height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        config.primaryColor.withOpacity(0.25),
                        config.backgroundColor,
                      ],
                    ),
                  ),
                ),
                // Mood-specific animated layer
                CustomPaint(
                  size: size,
                  painter: _MoodPainter(
                    mood: _currentMood,
                    progress: _controller.value,
                    opacity: _transitionAnim.value,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _MoodPainter extends CustomPainter {
  final MoodType mood;
  final double progress;
  final double opacity;

  _MoodPainter(
      {required this.mood, required this.progress, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    switch (mood) {
      case MoodType.angry:
        _paintOcean(canvas, size);
        break;
      case MoodType.anxious:
        _paintForest(canvas, size);
        break;
      case MoodType.happy:
        _paintSunrise(canvas, size);
        break;
      case MoodType.sad:
        _paintRain(canvas, size);
        break;
      case MoodType.confused:
        _paintStars(canvas, size);
        break;
      default:
        break;
    }
  }

  void _paintOcean(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2E6E8E).withOpacity(0.15 * opacity)
      ..style = PaintingStyle.fill;

    // Draw wave layers
    for (int i = 0; i < 3; i++) {
      final path = Path();
      final waveOffset = progress * size.width + i * 80.0;
      final waveHeight = size.height * (0.75 + i * 0.08);
      final amplitude = 20.0 - i * 4.0;

      path.moveTo(0, waveHeight);
      for (double x = 0; x <= size.width; x += 1) {
        final y = waveHeight +
            amplitude *
                _sin((x + waveOffset) / size.width * 2 * 3.14159);
        path.lineTo(x, y);
      }
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  void _paintForest(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF7DBF8E).withOpacity(0.12 * opacity)
      ..style = PaintingStyle.fill;

    // Draw tree silhouettes
    for (int i = 0; i < 5; i++) {
      final x = size.width * (0.1 + i * 0.2);
      final h = size.height * (0.35 + (i % 2) * 0.1);
      final path = Path();
      path.moveTo(x, size.height * 0.95);
      path.lineTo(x - 30, h + 60);
      path.lineTo(x - 20, h + 60);
      path.lineTo(x - 40, h);
      path.lineTo(x, h - 60);
      path.lineTo(x + 40, h);
      path.lineTo(x + 20, h + 60);
      path.lineTo(x + 30, h + 60);
      path.close();
      canvas.drawPath(path, paint);
    }

    // Sun rays
    final sunPaint = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.08 * opacity)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.15), 30, sunPaint);
  }

  void _paintSunrise(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF5C842).withOpacity(0.15 * opacity)
      ..style = PaintingStyle.fill;

    // Sun
    final sunY = size.height * (0.3 - progress * 0.05);
    canvas.drawCircle(Offset(size.width * 0.5, sunY), 50, paint);

    // Rays
    final rayPaint = Paint()
      ..color = const Color(0xFFF5C842).withOpacity(0.08 * opacity)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 8; i++) {
      final angle = i * 3.14159 / 4 + progress;
      canvas.drawLine(
        Offset(size.width * 0.5 + 55 * _cos(angle.toDouble()),
            sunY + 55 * _sin(angle.toDouble())),
        Offset(size.width * 0.5 + 90 * _cos(angle.toDouble()),
            sunY + 90 * _sin(angle.toDouble())),
        rayPaint,
      );
    }
  }

  void _paintRain(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4845A).withOpacity(0.08 * opacity)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Rain drops
    for (int i = 0; i < 20; i++) {
      final x = size.width * ((i * 0.05 + progress * 0.3) % 1.0);
      final y = size.height * ((i * 0.07 + progress * 0.5) % 1.0);
      canvas.drawLine(
          Offset(x, y), Offset(x - 4, y + 12), paint);
    }
  }

  void _paintStars(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF9B7FD4).withOpacity(0.2 * opacity)
      ..style = PaintingStyle.fill;

    // Stars
    for (int i = 0; i < 30; i++) {
      final x = size.width * ((i * 0.033 + 0.01) % 1.0);
      final y = size.height * ((i * 0.041 + 0.01) % 0.6);
      final r = 1.5 + (i % 3) * 1.0 +
          _sin(progress * 6.28 + i) * 0.5;
      canvas.drawCircle(Offset(x, y), r.abs(), paint);
    }
  }

  double _sin(double x) {
    // Simple sine approximation
    return (x - x * x * x / 6 + x * x * x * x * x / 120).clamp(-1.0, 1.0);
  }

  double _cos(double x) => _sin(x + 1.5708);

  @override
  bool shouldRepaint(covariant _MoodPainter old) =>
      old.progress != progress || old.mood != mood || old.opacity != opacity;
}
