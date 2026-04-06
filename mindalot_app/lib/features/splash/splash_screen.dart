import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/widgets/animated_clouds_background.dart';
import '../../core/widgets/floating_mascot.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathCtrl;
  late AnimationController _fadeCtrl;
  late AnimationController _ringCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  String _breathText = 'Breathe in...';

  @override
  void initState() {
    super.initState();

    _breathCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4));
    _scaleAnim = Tween<double>(begin: 0.76, end: 1.0).animate(
        CurvedAnimation(parent: _breathCtrl, curve: Curves.easeInOut));
    _breathCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        setState(() => _breathText = 'Breathe out...');
        _breathCtrl.reverse();
      } else if (s == AnimationStatus.dismissed) {
        setState(() => _breathText = 'Breathe in...');
        _breathCtrl.forward();
      }
    });
    _breathCtrl.forward();

    _ringCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat();

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim =
        Tween<double>(begin: 1.0, end: 0.0).animate(_fadeCtrl);

    Future.delayed(const Duration(seconds: 4), () async {
      if (!mounted) return;
      await _fadeCtrl.forward();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/onboarding');
    });
  }

  @override
  void dispose() {
    _breathCtrl.dispose();
    _fadeCtrl.dispose();
    _ringCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final mascotSize = size.width * 0.42;

    return FadeTransition(
      opacity: _fadeAnim,
      child: AnimatedCloudsBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Rings + mascot
                AnimatedBuilder(
                  animation: Listenable.merge([_scaleAnim, _ringCtrl]),
                  builder: (_, __) => Stack(
                    alignment: Alignment.center,
                    children: [
                      _Ring(progress: _ringCtrl.value, delay: 0.0,
                          scale: _scaleAnim.value,
                          color: const Color(0xFF5C9EAD)),
                      _Ring(progress: _ringCtrl.value, delay: 0.33,
                          scale: _scaleAnim.value,
                          color: const Color(0xFF8BBFC9)),
                      _Ring(progress: _ringCtrl.value, delay: 0.66,
                          scale: _scaleAnim.value,
                          color: const Color(0xFFB2D8E0)),
                      Transform.scale(
                        scale: _scaleAnim.value,
                        child: FloatingMascot(size: mascotSize),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: size.height * 0.05),

                // Brand
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: 'Mind ',
                        style: GoogleFonts.nunito(
                          fontSize: size.width * 0.10,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF2C1810),
                        ),
                      ),
                      TextSpan(
                        text: 'A Lot',
                        style: GoogleFonts.nunito(
                          fontSize: size.width * 0.10,
                          fontWeight: FontWeight.w300,
                          color: const Color(0xFF5C3D2E),
                        ),
                      ),
                    ]),
                  ),
                ),

                SizedBox(height: size.height * 0.018),

                // Breath label
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
                  child: Text(
                    _breathText,
                    key: ValueKey(_breathText),
                    style: GoogleFonts.nunito(
                      fontSize: size.width * 0.048,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF7A6055),
                      letterSpacing: 0.8,
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

class _Ring extends StatelessWidget {
  final double progress;
  final double delay;
  final double scale;
  final Color color;
  const _Ring(
      {required this.progress,
      required this.delay,
      required this.scale,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final p = ((progress + delay) % 1.0);
    final s = scale * (1.0 + p * 0.5);
    final o = (1.0 - p) * 0.20;
    return Transform.scale(
      scale: s,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: o), width: 1.5),
        ),
      ),
    );
  }
}
