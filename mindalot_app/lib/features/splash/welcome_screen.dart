import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/widgets/animated_clouds_background.dart';
import '../../core/widgets/floating_mascot.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // Triple-tap counter for hidden counsellor login
  int _tapCount = 0;
  DateTime? _lastTap;

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
    return AnimatedCloudsBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Triple-tap cloud mascot with floating animation
              GestureDetector(
                onTap: _onLogoTap,
                child: const FloatingMascot(size: 180),
              ),
              const SizedBox(height: 28),
              Text(
                'Just Breathe in and out',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2C1810),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'I will help you find a perfect therapist',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: const Color(0xFF7A6055),
                ),
              ),
              const SizedBox(height: 52),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C3D2E),
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(
                  "I'm new here",
                  style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/home'),
                child: Text(
                  'I already have my credentials',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    color: const Color(0xFF5C3D2E),
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600,
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

