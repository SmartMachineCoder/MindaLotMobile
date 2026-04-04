import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/widgets/animated_clouds_background.dart';
import '../../core/widgets/floating_mascot.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _slides = const [
    _Slide(
      emoji: '📣',
      title: 'Understand your emotions',
      subtitle:
          'Reflect on your day, log your mood, and discover what your mind needs.',
    ),
    _Slide(
      emoji: '💙',
      title: 'Real people,\nReal conversations',
      subtitle:
          'Every message you send is read and responded to by certified professionals.',
    ),
    _Slide(
      emoji: '📖',
      title: 'Inner Compass:\nYour Guide to Wellness',
      subtitle:
          'Access helpful blogs, daily tips, and guided activities — all in one place.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _slides.length - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCloudsBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => _slides[i],
          ),
          // Skip button
          Positioned(
            top: 52,
            right: 24,
            child: TextButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/welcome'),
              child: Text('Skip',
                  style: GoogleFonts.nunito(
                      color: const Color(0xFF7A6055), fontSize: 16)),
            ),
          ),
          // Dots + Next
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(
                    _slides.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 6),
                      width: _page == i ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _page == i
                            ? const Color(0xFF5C3D2E)
                            : const Color(0xFFD4C5BC),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C3D2E),
                    minimumSize: const Size(120, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    _page == _slides.length - 1 ? 'Get Started' : 'Next',
                    style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
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

class _Slide extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;

  const _Slide({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.transparent,
                borderRadius:
                    BorderRadius.only(bottomRight: Radius.circular(80)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const FloatingMascot(size: 100),
                    const SizedBox(height: 16),
                    Text(emoji, style: const TextStyle(fontSize: 80)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.nunito(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2C1810)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    subtitle,
                    style: GoogleFonts.nunito(
                        fontSize: 16,
                        color: const Color(0xFF7A6055),
                        height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
