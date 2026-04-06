import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/widgets/animated_clouds_background.dart';
import '../../core/widgets/floating_mascot.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  int _tapCount = 0;
  DateTime? _lastTap;
  late AnimationController _fadeIn;

  @override
  void initState() {
    super.initState();
    _fadeIn = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();
  }

  @override
  void dispose() {
    _fadeIn.dispose();
    super.dispose();
  }

  void _onLogoTap() {
    final now = DateTime.now();
    if (_lastTap != null &&
        now.difference(_lastTap!) < const Duration(seconds: 2)) {
      _tapCount++;
    } else {
      _tapCount = 1;
    }
    _lastTap = now;
    if (_tapCount >= 3) {
      _tapCount = 0;
      Navigator.pushNamed(context, '/counsellor-login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedCloudsBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeIn,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Mascot — triple-tap for counsellor hidden login
                  GestureDetector(
                    onTap: _onLogoTap,
                    child: FloatingMascot(size: size.width * 0.44),
                  ),

                  SizedBox(height: size.height * 0.030),

                  // Brand name
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(children: [
                        TextSpan(
                          text: 'Mind',
                          style: GoogleFonts.nunito(
                            fontSize: size.width * 0.115,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF2C1810),
                          ),
                        ),
                        TextSpan(
                          text: ' A ',
                          style: GoogleFonts.nunito(
                            fontSize: size.width * 0.115,
                            fontWeight: FontWeight.w300,
                            color: const Color(0xFF7A6055),
                          ),
                        ),
                        TextSpan(
                          text: 'Lot',
                          style: GoogleFonts.nunito(
                            fontSize: size.width * 0.115,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF5C3D2E),
                          ),
                        ),
                      ]),
                    ),
                  ),

                  SizedBox(height: size.height * 0.010),

                  Text(
                    'Your personal mental wellness companion',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: size.width * 0.038,
                      color: const Color(0xFF9A8070),
                      height: 1.5,
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Tagline pill
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.045,
                      vertical: size.height * 0.011,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                          color: const Color(0xFFD4C5BC), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('✨',
                            style: TextStyle(fontSize: 14)),
                        SizedBox(width: size.width * 0.022),
                        Flexible(
                          child: Text(
                            'Just breathe — I\'ll find you the right help',
                            style: GoogleFonts.nunito(
                              fontSize: size.width * 0.034,
                              color: const Color(0xFF7A6055),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.032),

                  // Primary CTA
                  _Button(
                    onTap: () =>
                        Navigator.pushNamed(context, '/register'),
                    label: "I'm new here",
                    filled: true,
                    size: size,
                  ),

                  SizedBox(height: size.height * 0.016),

                  // Secondary CTA
                  _Button(
                    onTap: () =>
                        Navigator.pushNamed(context, '/login'),
                    label: 'I already have an account',
                    filled: false,
                    size: size,
                  ),

                  SizedBox(height: size.height * 0.04),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final bool filled;
  final Size size;
  const _Button(
      {required this.onTap,
      required this.label,
      required this.filled,
      required this.size});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: size.height * 0.068,
        decoration: BoxDecoration(
          color: filled
              ? const Color(0xFF5C3D2E)
              : Colors.white.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(30),
          border: filled
              ? null
              : Border.all(
                  color: const Color(0xFF5C3D2E).withValues(alpha: 0.4),
                  width: 1.5),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: const Color(0xFF5C3D2E).withValues(alpha: 0.28),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  )
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: size.width * 0.042,
              fontWeight: FontWeight.w700,
              color: filled
                  ? Colors.white
                  : const Color(0xFF5C3D2E),
            ),
          ),
        ),
      ),
    );
  }
}
