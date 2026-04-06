import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/widgets/animated_clouds_background.dart';
import '../../core/widgets/floating_mascot.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _page = 0;
  late AnimationController _slideCtrl;

  static const _slides = [
    _Slide(
      emoji: '🧠',
      tag: 'Self Awareness',
      title: 'Understand your emotions',
      subtitle:
          'Reflect on your day, log your mood, and discover what your mind truly needs.',
      accent: Color(0xFF5C9EAD),
    ),
    _Slide(
      emoji: '💬',
      tag: 'Real Support',
      title: 'Real people,\nReal conversations',
      subtitle:
          'Every message is read and responded to by certified mental health professionals.',
      accent: Color(0xFF7A6BAD),
    ),
    _Slide(
      emoji: '🌱',
      tag: 'Daily Growth',
      title: 'Your guide\nto wellness',
      subtitle:
          'Access guided activities, daily tips, and personalized content — all in one place.',
      accent: Color(0xFF5C9E7A),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450))
      ..forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _slides.length - 1) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedCloudsBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            PageView.builder(
              controller: _pageCtrl,
              itemCount: _slides.length,
              onPageChanged: (i) {
                setState(() => _page = i);
                _slideCtrl.forward(from: 0);
              },
              itemBuilder: (_, i) => _SlidePage(
                slide: _slides[i],
                size: size,
                anim: _slideCtrl,
              ),
            ),

            // Skip
            Positioned(
              top: size.height * 0.062,
              right: 24,
              child: SafeArea(
                child: TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/welcome'),
                  child: Text(
                    'Skip',
                    style: GoogleFonts.nunito(
                      color: const Color(0xFF7A6055),
                      fontSize: size.width * 0.038,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Bottom bar
            Positioned(
              bottom: size.height * 0.055,
              left: 28,
              right: 28,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dots
                  Row(
                    children: List.generate(_slides.length, (i) {
                      final active = _page == i;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 7),
                        width: active ? 26 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active
                              ? _slides[_page].accent
                              : const Color(0xFFD4C5BC),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  // Next button
                  GestureDetector(
                    onTap: _next,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.065,
                        vertical: size.height * 0.016,
                      ),
                      decoration: BoxDecoration(
                        color: _slides[_page].accent,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: _slides[_page].accent.withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Text(
                        _page == _slides.length - 1
                            ? 'Get Started'
                            : 'Next  →',
                        style: GoogleFonts.nunito(
                          fontSize: size.width * 0.038,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slide {
  final String emoji;
  final String tag;
  final String title;
  final String subtitle;
  final Color accent;
  const _Slide(
      {required this.emoji,
      required this.tag,
      required this.title,
      required this.subtitle,
      required this.accent});
}

class _SlidePage extends StatelessWidget {
  final _Slide slide;
  final Size size;
  final AnimationController anim;
  const _SlidePage(
      {required this.slide, required this.size, required this.anim});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Mascot + emoji badge
          SizedBox(
            height: size.height * 0.52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow behind mascot
                Container(
                  width: size.width * 0.55,
                  height: size.width * 0.55,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        slide.accent.withValues(alpha: 0.18),
                        slide.accent.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
                // Mascot
                Positioned(
                  top: size.height * 0.04,
                  child: FloatingMascot(size: size.width * 0.30),
                ),
                // Emoji badge
                Positioned(
                  bottom: size.height * 0.04,
                  child: FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.4),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                          parent: anim, curve: Curves.easeOutCubic)),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.055,
                          vertical: size.height * 0.016,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: slide.accent.withValues(alpha: 0.22),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(slide.emoji,
                                style: TextStyle(
                                    fontSize: size.width * 0.09)),
                            SizedBox(width: size.width * 0.028),
                            Text(
                              slide.tag,
                              style: GoogleFonts.nunito(
                                fontSize: size.width * 0.038,
                                fontWeight: FontWeight.w800,
                                color: slide.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Text section
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
              child: FadeTransition(
                opacity: anim,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        slide.title,
                        style: GoogleFonts.nunito(
                          fontSize: size.width * 0.072,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF2C1810),
                          height: 1.18,
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.014),
                    Text(
                      slide.subtitle,
                      style: GoogleFonts.nunito(
                        fontSize: size.width * 0.038,
                        color: const Color(0xFF7A6055),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: size.height * 0.13),
        ],
      ),
    );
  }
}
