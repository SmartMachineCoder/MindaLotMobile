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

class _RegisterScreenState extends State<RegisterScreen> {
  final _aliasController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _aliasController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final alias = _aliasController.text.trim();

    if (alias.isEmpty) {
      setState(() => _error = 'Please choose a display name.');
      return;
    }

    setState(() => _error = null);

    // Save alias — we never store the real name
    await AuthService().setUserAlias(alias);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCloudsBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF5C3D2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Tell Us Your Name',
            style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2C1810))),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Animated cloud mascot
              Center(
                child: Column(
                  children: [
                    const FloatingMascot(size: 120),
                    const SizedBox(height: 8),
                    Text(
                      'Your identity stays private.\nWe only know your alias.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: const Color(0xFF7A6055),
                          height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              const _Label('Display Name (Alias)'),
              const SizedBox(height: 6),
              TextField(
                controller: _aliasController,
                decoration: _inputDecoration(
                  hint: 'e.g. StarGazer, BlueMoon...',
                  icon: Icons.person_outline_rounded,
                ),
                style: GoogleFonts.nunito(fontSize: 15),
                onSubmitted: (_) => _register(),
              ),
              const SizedBox(height: 4),
              Text(
                'This is how your counsellor will refer to you. Not your real name.',
                style: GoogleFonts.nunito(
                    fontSize: 12, color: const Color(0xFF7A6055)),
              ),
              const SizedBox(height: 18),

              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!,
                    style: GoogleFonts.nunito(
                        color: Colors.red.shade600, fontSize: 13)),
              ],

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C3D2E),
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: Text('Get Started',
                    style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.nunito(
                          fontSize: 14, color: const Color(0xFF7A6055)),
                      children: [
                        const TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Sign In',
                          style: GoogleFonts.nunito(
                              color: const Color(0xFF5C3D2E),
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.nunito(color: const Color(0xFFB0A090)),
      prefixIcon: Icon(icon, color: const Color(0xFF7A6055)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF5C3D2E)),
    );
  }
}
