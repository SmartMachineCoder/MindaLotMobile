import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/mood.dart';
import '../../core/services/mood_provider.dart';
import 'widgets/mood_background.dart';
import 'widgets/mood_selector.dart';
import 'widgets/mood_lock_banner.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  static const String _quote =
      '"Your focus decides your outcome."';

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodProvider>(
      builder: (context, moodProvider, _) {
        final config = moodProvider.currentConfig;
        return Scaffold(
          backgroundColor: config.backgroundColor,
          body: Stack(
            children: [
              // Animated mood background
              const MoodBackground(),
              SafeArea(
                child: Column(
                  children: [
                    _AppBar(moodProvider: moodProvider),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            _GreetingSection(greeting: _greeting()),
                            const SizedBox(height: 8),
                            _QuoteCard(quote: _quote),
                            const SizedBox(height: 20),
                            _MascotSection(config: config),
                            const SizedBox(height: 16),
                            // Mood lock banner (shown when mood is active)
                            if (moodProvider.currentMood != MoodType.none)
                              MoodLockBanner(provider: moodProvider),
                            const SizedBox(height: 16),
                            // Mood selector
                            MoodSelector(provider: moodProvider),
                            const SizedBox(height: 28),
                            _ActionButtons(config: config),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: _BottomNav(),
        );
      },
    );
  }
}

class _AppBar extends StatelessWidget {
  final MoodProvider moodProvider;
  const _AppBar({required this.moodProvider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF5C3D2E)),
            onPressed: () {},
          ),
          // mind alot logo text
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'mind',
                  style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF5C3D2E),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                TextSpan(
                  text: '\nalot',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF7A6055),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              // Mute button when mood is active
              if (moodProvider.currentMood != MoodType.none)
                IconButton(
                  icon: Icon(
                    moodProvider.isMuted
                        ? Icons.volume_off_rounded
                        : Icons.volume_up_rounded,
                    color: const Color(0xFF5C3D2E),
                  ),
                  onPressed: () => moodProvider.toggleMute(),
                ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Color(0xFF5C3D2E)),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GreetingSection extends StatelessWidget {
  final String greeting;
  const _GreetingSection({required this.greeting});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Hi Friend,',
          style: GoogleFonts.nunito(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2C1810),
          ),
        ),
        Text(
          greeting,
          style: GoogleFonts.nunito(
            fontSize: 16,
            color: const Color(0xFF7A6055),
          ),
        ),
      ],
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final String quote;
  const _QuoteCard({required this.quote});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        quote,
        textAlign: TextAlign.center,
        style: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontStyle: FontStyle.italic,
          color: const Color(0xFF5C3D2E),
          height: 1.5,
        ),
      ),
    );
  }
}

class _MascotSection extends StatelessWidget {
  final MoodConfig config;
  const _MascotSection({required this.config});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Mascot with mood-responsive emoji
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          width: 150,
          height: 140,
          decoration: BoxDecoration(
            color: config.primaryColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(80),
          ),
          child: Center(
            child: Text(
              config.type == MoodType.none ? '🧘' : config.emoji,
              style: const TextStyle(fontSize: 72),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tell us how you are feeling?',
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF5C3D2E),
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final MoodConfig config;
  const _ActionButtons({required this.config});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.phone_outlined),
            label: Text('Call',
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700, fontSize: 16)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF5C3D2E),
              side: const BorderSide(color: Color(0xFF5C3D2E), width: 1.5),
              minimumSize: const Size(0, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/chat'),
            icon: const Icon(Icons.chat_bubble_outline),
            label: Text('Chat',
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700, fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5C3D2E),
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFF5C3D2E),
        unselectedItemColor: const Color(0xFFB0A090),
        selectedLabelStyle:
            GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 12),
        unselectedLabelStyle:
            GoogleFonts.nunito(fontWeight: FontWeight.w400, fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline_rounded),
            label: 'Knowledge Hub',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
