import 'package:flutter/material.dart';
import 'dart:math' as math;

// Max rendered size — prevents overflow on desktop/tablet previews
const double _kMaxMascotSize = 180.0;

/// Fluffy white cloud mascot with blinking eyes, rosy cheeks,
/// gentle float/sway and subtle breathing scale — always alive.
class FloatingMascot extends StatefulWidget {
  final double size;
  final bool showFace;
  const FloatingMascot({super.key, this.size = 140, this.showFace = true});

  @override
  State<FloatingMascot> createState() => _FloatingMascotState();
}

class _FloatingMascotState extends State<FloatingMascot>
    with TickerProviderStateMixin {
  late AnimationController _floatCtrl;
  late AnimationController _blinkCtrl;
  late AnimationController _breathCtrl;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 6))
      ..repeat();
    _blinkCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 180));
    _breathCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 5))
      ..repeat(reverse: true);
    _startBlink();
  }

  void _startBlink() async {
    while (mounted) {
      await Future.delayed(
          Duration(milliseconds: 2600 + math.Random().nextInt(1800)));
      if (!mounted) return;
      await _blinkCtrl.forward();
      if (!mounted) return;
      await _blinkCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _blinkCtrl.dispose();
    _breathCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatCtrl, _breathCtrl]),
      builder: (_, child) {
        final t = _floatCtrl.value * math.pi * 2;
        final dy = math.sin(t) * 11;
        final dx = math.cos(t * 0.7) * 5;
        final tilt = math.sin(t * 0.5) * 0.03;
        final breathe = 1.0 + _breathCtrl.value * 0.04;
        return Transform.translate(
          offset: Offset(dx, dy),
          child: Transform.rotate(
            angle: tilt,
            child: Transform.scale(scale: breathe, child: child),
          ),
        );
      },
      child: _MascotBody(
        size: math.min(widget.size, _kMaxMascotSize),
        showFace: widget.showFace,
        blinkCtrl: _blinkCtrl,
      ),
    );
  }
}

class _MascotBody extends StatelessWidget {
  final double size;
  final bool showFace;
  final AnimationController blinkCtrl;
  const _MascotBody(
      {required this.size,
      required this.showFace,
      required this.blinkCtrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.86,
      child: CustomPaint(
        painter: _CloudPainter(),
        child: showFace
            ? Center(
                child: Padding(
                  padding: EdgeInsets.only(top: size * 0.04),
                  child: AnimatedBuilder(
                    animation: blinkCtrl,
                    builder: (_, __) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _Eye(size: size * 0.095, blink: blinkCtrl.value),
                        SizedBox(width: size * 0.13),
                        _Eye(size: size * 0.095, blink: blinkCtrl.value),
                      ],
                    ),
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
  final double blink;
  const _Eye({required this.size, required this.blink});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * (1.0 - blink * 0.9),
      decoration: BoxDecoration(
        color: const Color(0xFF3D2010),
        borderRadius: BorderRadius.circular(size),
      ),
    );
  }
}

class _CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final bw = size.width * 0.46;
    final bh = size.height * 0.30;

    // Drop shadow
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, cy + bh * 0.85),
          width: bw * 1.8,
          height: bh * 0.45),
      Paint()
        ..color = const Color(0xFF90CAD6).withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    final fill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, cy + bh * 0.16),
            width: bw * 2,
            height: bh * 1.4),
        Radius.circular(bh * 0.72),
      ),
      fill,
    );
    // Centre bump (largest)
    canvas.drawCircle(Offset(cx, cy - bh * 0.44), bw * 0.56, fill);
    // Left bump
    canvas.drawCircle(Offset(cx - bw * 0.56, cy - bh * 0.10), bw * 0.43, fill);
    // Right bump
    canvas.drawCircle(Offset(cx + bw * 0.51, cy - bh * 0.15), bw * 0.39, fill);

    // Rosy cheeks
    final cheek = Paint()
      ..color = const Color(0xFFFFB7B7).withValues(alpha: 0.38)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(
        Offset(cx - bw * 0.52, cy + bh * 0.16), size.width * 0.065, cheek);
    canvas.drawCircle(
        Offset(cx + bw * 0.52, cy + bh * 0.16), size.width * 0.065, cheek);

    // Smile
    final smile = Path()
      ..moveTo(cx - size.width * 0.065, cy + bh * 0.26)
      ..quadraticBezierTo(cx, cy + bh * 0.44, cx + size.width * 0.065,
          cy + bh * 0.26);
    canvas.drawPath(
      smile,
      Paint()
        ..color = const Color(0xFF3D2010).withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
