import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/mood.dart';
import '../../core/services/mood_provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/widgets/floating_mascot.dart';
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
        final isDarkBg = _isDarkMood(moodProvider.currentMood);

        return Scaffold(
          backgroundColor: config.backgroundColor,
          body: Stack(
            children: [
              // Animated mood background
              const MoodBackground(),
              SafeArea(
                child: Column(
                  children: [
                    _AppBar(moodProvider: moodProvider, isDarkBg: isDarkBg),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            _GreetingSection(
                                greeting: _greeting(), isDarkBg: isDarkBg),
                            const SizedBox(height: 8),
                            _QuoteCard(quote: _quote, isDarkBg: isDarkBg),
                            const SizedBox(height: 20),
                            _MascotSection(
                                config: config, isDarkBg: isDarkBg),
                            const SizedBox(height: 16),
                            // Mood lock banner (shown when mood is active)
                            if (moodProvider.currentMood != MoodType.none)
                              MoodLockBanner(provider: moodProvider),
                            const SizedBox(height: 16),
                            // Mood selector
                            MoodSelector(
                                provider: moodProvider, isDarkBg: isDarkBg),
                            const SizedBox(height: 28),
                            _ActionButtons(
                                config: config, isDarkBg: isDarkBg),
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
          bottomNavigationBar: _BottomNav(isDarkBg: isDarkBg),
        );
      },
    );
  }

  /// Moods with dark backgrounds where text needs to be white
  static bool _isDarkMood(MoodType mood) {
    return mood == MoodType.angry ||
        mood == MoodType.sad ||
        mood == MoodType.confused ||
        mood == MoodType.anxious;
  }
}

// ---------------------------------------------------------------------------
// Animated gradient heading
// ---------------------------------------------------------------------------
class _AnimatedLogo extends StatefulWidget {
  final bool isDarkBg;
  const _AnimatedLogo({required this.isDarkBg});

  @override
  State<_AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<_AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final shimmer = _controller.value;
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(shimmer * 2 - 1, 0),
              end: Alignment(shimmer * 2, 0),
              colors: widget.isDarkBg
                  ? const [
                      Color(0xFFE0F0FF),
                      Color(0xFFFFFFFF),
                      Color(0xFFB8E0FF),
                    ]
                  : const [
                      Color(0xFF5C3D2E),
                      Color(0xFF9B6B4E),
                      Color(0xFF5C3D2E),
                    ],
            ).createShader(bounds);
          },
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Mind',
                  style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: ' A ',
                  style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: 'Lot',
                  style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AppBar extends StatelessWidget {
  final MoodProvider moodProvider;
  final bool isDarkBg;
  const _AppBar({required this.moodProvider, required this.isDarkBg});

  @override
  Widget build(BuildContext context) {
    final iconColor = isDarkBg ? Colors.white : const Color(0xFF5C3D2E);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.menu, color: iconColor),
            onPressed: () {},
          ),
          _AnimatedLogo(isDarkBg: isDarkBg),
          Row(
            children: [
              if (moodProvider.currentMood != MoodType.none)
                IconButton(
                  icon: Icon(
                    moodProvider.isMuted
                        ? Icons.volume_off_rounded
                        : Icons.volume_up_rounded,
                    color: iconColor,
                  ),
                  onPressed: () => moodProvider.toggleMute(),
                ),
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: iconColor),
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
  final bool isDarkBg;
  const _GreetingSection({required this.greeting, required this.isDarkBg});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<String>(
          future: AuthService().getUserAlias(),
          builder: (context, snapshot) {
            final name = snapshot.data ?? 'Friend';
            return Text(
              'Hi $name,',
              style: GoogleFonts.nunito(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: isDarkBg ? Colors.white : const Color(0xFF2C1810),
                shadows: isDarkBg
                    ? [const Shadow(color: Colors.black54, blurRadius: 8)]
                    : null,
              ),
            );
          },
        ),
        Text(
          greeting,
          style: GoogleFonts.nunito(
            fontSize: 16,
            color: isDarkBg
                ? Colors.white70
                : const Color(0xFF7A6055),
            shadows: isDarkBg
                ? [const Shadow(color: Colors.black54, blurRadius: 6)]
                : null,
          ),
        ),
      ],
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final String quote;
  final bool isDarkBg;
  const _QuoteCard({required this.quote, required this.isDarkBg});

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
          color: isDarkBg ? Colors.white : const Color(0xFF5C3D2E),
          height: 1.5,
          shadows: isDarkBg
              ? [const Shadow(color: Colors.black54, blurRadius: 6)]
              : null,
        ),
      ),
    );
  }
}

class _MascotSection extends StatelessWidget {
  final MoodConfig config;
  final bool isDarkBg;
  const _MascotSection({required this.config, required this.isDarkBg});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Animated floating mascot that changes emoji based on mood
        Stack(
          alignment: Alignment.center,
          children: [
            if (config.type == MoodType.none)
              const FloatingMascot(size: 140)
            else
              // Show mood emoji inside a floating animated container
              _MoodMascot(config: config),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Tell us how you are feeling?',
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDarkBg ? Colors.white : const Color(0xFF5C3D2E),
            shadows: isDarkBg
                ? [const Shadow(color: Colors.black54, blurRadius: 6)]
                : null,
          ),
        ),
      ],
    );
  }
}

/// Mood-responsive animated mascot that bounces with the selected mood emoji
class _MoodMascot extends StatefulWidget {
  final MoodConfig config;
  const _MoodMascot({required this.config});

  @override
  State<_MoodMascot> createState() => _MoodMascotState();
}

class _MoodMascotState extends State<_MoodMascot>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_bounceController, _pulseController]),
      builder: (_, child) {
        final bounce = _bounceController.value;
        final pulse = 1.0 + _pulseController.value * 0.06;
        return Transform.translate(
          offset: Offset(0, -10 * bounce),
          child: Transform.scale(
            scale: pulse,
            child: child,
          ),
        );
      },
      child: Container(
        width: 140,
        height: 130,
        decoration: BoxDecoration(
          color: widget.config.primaryColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(70),
          border: Border.all(
            color: widget.config.primaryColor.withValues(alpha: 0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.config.primaryColor.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Text(
            widget.config.emoji,
            style: const TextStyle(fontSize: 64),
          ),
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final MoodConfig config;
  final bool isDarkBg;
  const _ActionButtons({required this.config, required this.isDarkBg});

  @override
  Widget build(BuildContext context) {
    final outlineColor = isDarkBg ? Colors.white : const Color(0xFF5C3D2E);

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.phone_outlined, color: outlineColor),
            label: Text('Call',
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: outlineColor)),
            style: OutlinedButton.styleFrom(
              foregroundColor: outlineColor,
              side: BorderSide(color: outlineColor, width: 1.5),
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
              backgroundColor:
                  isDarkBg ? Colors.white : const Color(0xFF5C3D2E),
              foregroundColor:
                  isDarkBg ? const Color(0xFF5C3D2E) : Colors.white,
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
  final bool isDarkBg;
  const _BottomNav({required this.isDarkBg});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkBg
            ? const Color(0xFF1A1A2E).withValues(alpha: 0.9)
            : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor:
            isDarkBg ? Colors.white : const Color(0xFF5C3D2E),
        unselectedItemColor:
            isDarkBg ? Colors.white54 : const Color(0xFFB0A090),
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
