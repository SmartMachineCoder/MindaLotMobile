import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animated passing-clouds background — soft sky gradient with parallax cloud layers.
class AnimatedCloudsBackground extends StatefulWidget {
  final Widget child;
  const AnimatedCloudsBackground({super.key, required this.child});

  @override
  State<AnimatedCloudsBackground> createState() =>
      _AnimatedCloudsBackgroundState();
}

class _AnimatedCloudsBackgroundState extends State<AnimatedCloudsBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Pure white background
        Container(color: Colors.white),
        // Animated clouds
        AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => CustomPaint(
            size: Size.infinite,
            painter: _CloudsPainter(progress: _controller.value),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _CloudsPainter extends CustomPainter {
  final double progress;
  _CloudsPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Back layer — large, slow, faint
    _drawLayer(canvas, size,
        speed: 0.25,
        yRatios: [0.06, 0.20, 0.38, 0.56, 0.74, 0.90],
        widths: [260, 310, 230, 280, 250, 200],
        opacity: 0.30,
        seeds: [0, 18, 36, 54, 72, 90]);

    // Mid layer
    _drawLayer(canvas, size,
        speed: 0.55,
        yRatios: [0.10, 0.30, 0.52, 0.72, 0.92],
        widths: [180, 220, 195, 165, 185],
        opacity: 0.55,
        seeds: [8, 28, 48, 68, 88]);

    // Front layer — small, faster, opaque
    _drawLayer(canvas, size,
        speed: 1.0,
        yRatios: [0.14, 0.42, 0.64, 0.84],
        widths: [130, 150, 120, 140],
        opacity: 0.80,
        seeds: [5, 25, 55, 75]);
  }

  void _drawLayer(
    Canvas canvas,
    Size size, {
    required double speed,
    required List<double> yRatios,
    required List<double> widths,
    required double opacity,
    required List<int> seeds,
  }) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < yRatios.length; i++) {
      final w = widths[i];
      final h = w * 0.48;
      final travel = size.width + w * 2;
      final seedOff = (seeds[i] / 100.0) * travel;
      final x = -w + ((progress * speed * travel + seedOff) % travel);
      final y = size.height * yRatios[i];
      final bob = math.sin(progress * math.pi * 4 + seeds[i]) * 4;
      _cloud(canvas, paint, Offset(x, y + bob), w, h);
    }
  }

  void _cloud(Canvas canvas, Paint paint, Offset c, double w, double h) {
    final path = Path();
    final bodyRect = Rect.fromCenter(
        center: Offset(c.dx, c.dy + h * 0.12), width: w, height: h * 0.55);
    path.addRRect(
        RRect.fromRectAndRadius(bodyRect, Radius.circular(h * 0.3)));
    path.addOval(Rect.fromCenter(
        center: Offset(c.dx - w * 0.18, c.dy - h * 0.14),
        width: h * 0.68, height: h * 0.68));
    path.addOval(Rect.fromCenter(
        center: Offset(c.dx + w * 0.06, c.dy - h * 0.24),
        width: h * 0.82, height: h * 0.82));
    path.addOval(Rect.fromCenter(
        center: Offset(c.dx + w * 0.26, c.dy - h * 0.10),
        width: h * 0.58, height: h * 0.58));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CloudsPainter old) =>
      old.progress != progress;
}
