import 'package:flutter/material.dart';
import '../../core/widgets/animated_clouds_background.dart';
import '../../core/widgets/floating_mascot.dart';

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
        });
        _breathController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _breathText = 'Breathe in';
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
      child: AnimatedCloudsBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _scaleAnim,
                builder: (_, __) => Transform.scale(
                  scale: _scaleAnim.value,
                  child: const FloatingMascot(size: 180),
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
      ),
    );
  }
}

