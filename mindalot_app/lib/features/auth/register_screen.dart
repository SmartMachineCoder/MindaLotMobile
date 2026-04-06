import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/auth_service.dart';
import '../../core/widgets/animated_clouds_background.dart';
import '../../core/widgets/floating_mascot.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _aliasCtrl = TextEditingController();
  String? _error;
  late AnimationController _fadeIn;

  @override
  void initState() {
    super.initState();
    _fadeIn = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();
  }

  @override
  void dispose() {
    _aliasCtrl.dispose();
    _fadeIn.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final alias = _aliasCtrl.text.trim();
    if (alias.isEmpty) {
      setState(() => _error = 'Please choose a display name.');
      return;
    }
    setState(() => _error = null);
    await AuthService().setUserAlias(alias);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
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
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.065,
                vertical: size.height * 0.02,
              ),
              child: Column(
                children: [
                  // Back
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFFD4C5BC)),
                        ),
                        child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Color(0xFF5C3D2E),
                            size: 16),
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.020),

                  // Mascot
                  FloatingMascot(size: size.width * 0.30),

                  SizedBox(height: size.height * 0.012),

                  // Privacy badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.04,
                      vertical: size.height * 0.009,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FFF4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFF5C9E7A)
                              .withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔒',
                            style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 6),
                        Text(
                          'Your identity stays 100% private',
                          style: GoogleFonts.nunito(
                            fontSize: size.width * 0.032,
                            color: const Color(0xFF3A7A55),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.026),

                  // Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(size.width * 0.060),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 24,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Choose your alias ✨',
                            style: GoogleFonts.nunito(
                              fontSize: size.width * 0.062,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF2C1810),
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.005),
                        Text(
                          'This is how your counsellor will know you',
                          style: GoogleFonts.nunito(
                            fontSize: size.width * 0.034,
                            color: const Color(0xFF9A8070),
                          ),
                        ),

                        SizedBox(height: size.height * 0.018),

                        // Quick-pick suggestions
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            '🌙 BlueMoon',
                            '⭐ StarGazer',
                            '🌊 DeepWave',
                            '🦋 Solace',
                          ].map((s) {
                            return GestureDetector(
                              onTap: () {
                                _aliasCtrl.text = s
                                    .replaceAll(
                                        RegExp(r'[^\w\s]'), '')
                                    .trim();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.032,
                                  vertical: size.height * 0.008,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F0ED),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                  border: Border.all(
                                      color: const Color(0xFFD4C5BC)),
                                ),
                                child: Text(
                                  s,
                                  style: GoogleFonts.nunito(
                                    fontSize: size.width * 0.033,
                                    color: const Color(0xFF5C3D2E),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        SizedBox(height: size.height * 0.016),

                        TextField(
                          controller: _aliasCtrl,
                          onSubmitted: (_) => _register(),
                          style: GoogleFonts.nunito(
                            fontSize: size.width * 0.038,
                            color: const Color(0xFF2C1810),
                          ),
                          decoration: InputDecoration(
                            hintText: 'e.g. StarGazer, BlueMoon...',
                            hintStyle: GoogleFonts.nunito(
                              color: const Color(0xFFB0A090),
                              fontSize: size.width * 0.038,
                            ),
                            prefixIcon: const Icon(
                                Icons.person_outline_rounded,
                                color: Color(0xFF7A6055),
                                size: 20),
                            filled: true,
                            fillColor: const Color(0xFFF5F0ED),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                  color: Color(0xFF5C3D2E), width: 1.5),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: size.height * 0.018),
                          ),
                        ),
                        SizedBox(height: size.height * 0.007),
                        Text(
                          'We never use your real name.',
                          style: GoogleFonts.nunito(
                            fontSize: size.width * 0.030,
                            color: const Color(0xFFB0A090),
                          ),
                        ),

                        if (_error != null) ...[
                          SizedBox(height: size.height * 0.014),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline_rounded,
                                    color: Colors.red.shade400,
                                    size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: GoogleFonts.nunito(
                                      color: Colors.red.shade600,
                                      fontSize: size.width * 0.032,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        SizedBox(height: size.height * 0.024),

                        GestureDetector(
                          onTap: _register,
                          child: Container(
                            width: double.infinity,
                            height: size.height * 0.065,
                            decoration: BoxDecoration(
                              color: const Color(0xFF5C3D2E),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF5C3D2E)
                                      .withValues(alpha: 0.30),
                                  blurRadius: 16,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Start My Journey 🚀',
                                style: GoogleFonts.nunito(
                                  fontSize: size.width * 0.042,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.025),

                  GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(
                        context, '/login'),
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.nunito(
                          fontSize: size.width * 0.036,
                          color: const Color(0xFF7A6055),
                        ),
                        children: [
                          const TextSpan(
                              text: 'Already have an account?  '),
                          TextSpan(
                            text: 'Sign In',
                            style: GoogleFonts.nunito(
                              color: const Color(0xFF5C3D2E),
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
