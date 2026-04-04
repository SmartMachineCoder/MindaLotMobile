import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A shared animated background for all starting pages.
/// Displays smooth, continuously passing clouds with parallax layers
/// to create a lively, Mascot-themed atmosphere.
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
        // Sky gradient base
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFC5E8E8), // Soft teal top
                Color(0xFFDFF2F2), // Light teal
                Color(0xFFEDF7F7), // Very light bottom
              ],
            ),
          ),
        ),

        // Animated passing clouds
        AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return CustomPaint(
              size: Size.infinite,
              painter: _RichCloudsPainter(progress: _controller.value),
            );
          },
        ),

        // The foreground content (must have transparent Scaffold)
        widget.child,
      ],
    );
  }
}

class _RichCloudsPainter extends CustomPainter {
  final double progress;

  _RichCloudsPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // --- Back layer: large distant clouds, slow, low opacity ---
    _drawCloudRow(
      canvas, size,
      speed: 0.3,
      yPositions: [0.08, 0.22, 0.38, 0.55, 0.72, 0.88],
      cloudSizes: [220, 280, 200, 260, 240, 190],
      opacity: 0.25,
      heightRatio: 0.45,
      seeds: [0, 17, 34, 51, 68, 85],
    );

    // --- Mid layer: medium clouds, medium speed ---
    _drawCloudRow(
      canvas, size,
      speed: 0.6,
      yPositions: [0.12, 0.32, 0.52, 0.75, 0.92],
      cloudSizes: [160, 200, 180, 150, 170],
      opacity: 0.4,
      heightRatio: 0.5,
      seeds: [10, 30, 50, 70, 90],
    );

    // --- Front layer: small clouds, faster, more opaque ---
    _drawCloudRow(
      canvas, size,
      speed: 1.0,
      yPositions: [0.15, 0.45, 0.65, 0.85],
      cloudSizes: [120, 140, 110, 130],
      opacity: 0.55,
      heightRatio: 0.55,
      seeds: [5, 25, 55, 75],
    );
  }

  void _drawCloudRow(
    Canvas canvas,
    Size size, {
    required double speed,
    required List<double> yPositions,
    required List<double> cloudSizes,
    required double opacity,
    required double heightRatio,
    required List<int> seeds,
  }) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha:opacity)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < yPositions.length; i++) {
      final w = cloudSizes[i];
      final h = w * heightRatio;
      final totalTravel = size.width + w * 2;

      // Each cloud starts at a different offset based on seed
      final seedOffset = (seeds[i] / 100.0) * totalTravel;
      final xPos = -w + ((progress * speed * totalTravel + seedOffset) % totalTravel);
      final yPos = size.height * yPositions[i];

      // Gentle vertical bobbing
      final bobOffset = math.sin(progress * math.pi * 4 + seeds[i]) * 4;

      _drawSingleCloud(canvas, paint, Offset(xPos, yPos + bobOffset), w, h);
    }
  }

  void _drawSingleCloud(Canvas canvas, Paint paint, Offset center, double w, double h) {
    final path = Path();

    // Main body (rounded rectangle)
    final bodyRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + h * 0.1),
      width: w,
      height: h * 0.55,
    );
    path.addRRect(RRect.fromRectAndRadius(bodyRect, Radius.circular(h * 0.3)));

    // Top bumps (3 overlapping circles for organic cloud shape)
    path.addOval(Rect.fromCenter(
      center: Offset(center.dx - w * 0.2, center.dy - h * 0.15),
      width: h * 0.65,
      height: h * 0.65,
    ));
    path.addOval(Rect.fromCenter(
      center: Offset(center.dx + w * 0.05, center.dy - h * 0.25),
      width: h * 0.8,
      height: h * 0.8,
    ));
    path.addOval(Rect.fromCenter(
      center: Offset(center.dx + w * 0.25, center.dy - h * 0.1),
      width: h * 0.55,
      height: h * 0.55,
    ));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _RichCloudsPainter old) =>
      old.progress != progress;
}
