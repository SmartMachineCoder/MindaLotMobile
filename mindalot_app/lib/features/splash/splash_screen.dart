import 'package:flutter/material.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  String _breathText = 'Breathe in';
  bool _isBreathingIn = true;

  @override
  void initState() {
    super.initState();

    // Breathing animation — 4s in, 4s out
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _scaleAnim = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    _breathController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _breathText = 'Breathe out';
          _isBreathingIn = false;
        });
        _breathController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _breathText = 'Breathe in';
          _isBreathingIn = true;
        });
        _breathController.forward();
      }
    });

    _breathController.forward();

    // Fade out and navigate after 4s
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(_fadeController);

    Future.delayed(const Duration(seconds: 4), () async {
      if (!mounted) return;
      await _fadeController.forward();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/onboarding');
    });
  }

  @override
  void dispose() {
    _breathController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Scaffold(
        backgroundColor: const Color(0xFFE8F4F4),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _scaleAnim,
                builder: (_, __) => Transform.scale(
                  scale: _scaleAnim.value,
                  child: const _BreathingBlob(),
                ),
              ),
              const SizedBox(height: 32),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                child: Text(
                  _breathText,
                  key: ValueKey(_breathText),
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF5C3D2E),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BreathingBlob extends StatelessWidget {
  const _BreathingBlob();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 220,
      child: CustomPaint(
        painter: _BlobPainter(),
        child: Center(
          child: Text(
            '🙂',
            style: TextStyle(fontSize: 52),
          ),
        ),
      ),
    );
  }
}

class _BlobPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF5BBFBF)
      ..style = PaintingStyle.fill;

    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy) * 0.85;

    // Draw a smooth blob shape
    path.moveTo(cx + r * math.cos(0), cy + r * math.sin(0));
    for (int i = 1; i <= 360; i++) {
      final angle = i * math.pi / 180;
      final wave = 1.0 + 0.12 * math.sin(3 * angle) + 0.08 * math.cos(5 * angle);
      final x = cx + r * wave * math.cos(angle);
      final y = cy + r * wave * math.sin(angle);
      path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
