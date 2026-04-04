import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animated cloud mascot with constant floating/bobbing motion.
/// The mascot gently drifts up-down and sways side-to-side, with blinking eyes
/// and a subtle breathing scale effect — always alive, never static.
class FloatingMascot extends StatefulWidget {
  final double size;
  final bool showFace;

  const FloatingMascot({
    super.key,
    this.size = 140,
    this.showFace = true,
  });

  @override
  State<FloatingMascot> createState() => _FloatingMascotState();
}

class _FloatingMascotState extends State<FloatingMascot>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _blinkController;
  late AnimationController _breatheController;

  @override
  void initState() {
    super.initState();

    // Gentle up-down + sway loop (6 seconds)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // Blink every ~3.5 seconds
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _startBlinkLoop();

    // Subtle breathing scale (5 seconds)
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  void _startBlinkLoop() async {
    while (mounted) {
      await Future.delayed(Duration(milliseconds: 2800 + (math.Random().nextInt(1500))));
      if (!mounted) return;
      await _blinkController.forward();
      if (!mounted) return;
      await _blinkController.reverse();
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _blinkController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatController, _breatheController]),
      builder: (_, child) {
        final floatProgress = _floatController.value * 2 * math.pi;
        final dy = math.sin(floatProgress) * 12; // bob up/down 12px
        final dx = math.cos(floatProgress * 0.7) * 6; // sway 6px
        final tilt = math.sin(floatProgress * 0.5) * 0.03; // subtle tilt
        final breatheScale = 1.0 + _breatheController.value * 0.05; // 5% scale

        return Transform.translate(
          offset: Offset(dx, dy),
          child: Transform.rotate(
            angle: tilt,
            child: Transform.scale(
              scale: breatheScale,
              child: child,
            ),
          ),
        );
      },
      child: _MascotBody(
        size: widget.size,
        showFace: widget.showFace,
        blinkController: _blinkController,
      ),
    );
  }
}

class _MascotBody extends StatelessWidget {
  final double size;
  final bool showFace;
  final AnimationController blinkController;

  const _MascotBody({
    required this.size,
    required this.showFace,
    required this.blinkController,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.85,
      child: CustomPaint(
        painter: _CloudMascotPainter(),
        child: showFace
            ? Center(
                child: Padding(
                  padding: EdgeInsets.only(top: size * 0.05),
                  child: AnimatedBuilder(
                    animation: blinkController,
                    builder: (_, __) {
                      final blinkValue = blinkController.value;
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Left eye
                          _Eye(size: size * 0.09, blinkValue: blinkValue),
                          SizedBox(width: size * 0.12),
                          // Right eye
                          _Eye(size: size * 0.09, blinkValue: blinkValue),
                        ],
                      );
                    },
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

class _Eye extends StatelessWidget {
  final double size;
  final double blinkValue;

  const _Eye({required this.size, required this.blinkValue});

  @override
  Widget build(BuildContext context) {
    final eyeHeight = size * (1.0 - blinkValue * 0.9);
    return Container(
      width: size,
      height: eyeHeight,
      decoration: BoxDecoration(
        color: const Color(0xFF3D2010),
        borderRadius: BorderRadius.circular(size / 2),
      ),
    );
  }
}

class _CloudMascotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = const Color(0xFFB8DDE0).withValues(alpha:0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    final cx = size.width / 2;
    final cy = size.height / 2;
    final baseW = size.width * 0.45;
    final baseH = size.height * 0.3;

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + baseH * 0.8), width: baseW * 1.8, height: baseH * 0.5),
      shadowPaint,
    );

    // Main cloud body - rounded rectangle base
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + baseH * 0.15), width: baseW * 2, height: baseH * 1.4),
      Radius.circular(baseH * 0.7),
    );
    canvas.drawRRect(bodyRect, paint);

    // Top bumps (three rounded humps to look cloud-like)
    // Center bump (biggest)
    canvas.drawCircle(Offset(cx, cy - baseH * 0.45), baseW * 0.55, paint);
    // Left bump
    canvas.drawCircle(Offset(cx - baseW * 0.55, cy - baseH * 0.1), baseW * 0.42, paint);
    // Right bump
    canvas.drawCircle(Offset(cx + baseW * 0.5, cy - baseH * 0.15), baseW * 0.38, paint);

    // Subtle rosy cheeks
    final cheekPaint = Paint()
      ..color = const Color(0xFFFFB7B7).withValues(alpha:0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(Offset(cx - baseW * 0.5, cy + baseH * 0.15), size.width * 0.06, cheekPaint);
    canvas.drawCircle(Offset(cx + baseW * 0.5, cy + baseH * 0.15), size.width * 0.06, cheekPaint);

    // Small smile
    final smilePaint = Paint()
      ..color = const Color(0xFF3D2010).withValues(alpha:0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final smilePath = Path();
    smilePath.moveTo(cx - size.width * 0.06, cy + baseH * 0.25);
    smilePath.quadraticBezierTo(cx, cy + baseH * 0.42, cx + size.width * 0.06, cy + baseH * 0.25);
    canvas.drawPath(smilePath, smilePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
