import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/auth_service.dart';
import '../../core/widgets/animated_clouds_background.dart';
import '../../core/widgets/floating_mascot.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _terms = false;
  String? _error;
  late AnimationController _fadeIn;

  int _logoTaps = 0;
  DateTime? _lastLogoTap;

  @override
  void initState() {
    super.initState();
    _fadeIn = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _fadeIn.dispose();
    super.dispose();
  }

  void _onLogoTap() {
    final now = DateTime.now();
    if (_lastLogoTap != null &&
        now.difference(_lastLogoTap!) < const Duration(seconds: 2)) {
      _logoTaps++;
    } else {
      _logoTaps = 1;
    }
    _lastLogoTap = now;
    if (_logoTaps >= 3) {
      _logoTaps = 0;
      Navigator.pushNamed(context, '/counsellor-login');
    }
  }

  Future<void> _login() async {
    final u = _userCtrl.text.trim();
    final p = _passCtrl.text;
    if (u.isEmpty || p.isEmpty) {
      setState(() => _error = 'Please enter your username and password.');
      return;
    }
    if (!_terms) {
      setState(() => _error = 'Please accept the Terms & Conditions.');
      return;
    }
    setState(() => _error = null);
    await AuthService().setUserAlias(u);
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
                  SizedBox(height: size.height * 0.015),

                  // Mascot + brand
                  GestureDetector(
                    onTap: _onLogoTap,
                    child: FloatingMascot(size: size.width * 0.26),
                  ),
                  SizedBox(height: size.height * 0.010),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: 'mind',
                          style: GoogleFonts.nunito(
                            fontSize: size.width * 0.085,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            color: const Color(0xFF5C3D2E),
                          ),
                        ),
                        TextSpan(
                          text: 'alot',
                          style: GoogleFonts.nunito(
                            fontSize: size.width * 0.060,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF7A6055),
                          ),
                        ),
                      ]),
                    ),
                  ),

                  SizedBox(height: size.height * 0.030),

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
                            'Welcome back 👋',
                            style: GoogleFonts.nunito(
                              fontSize: size.width * 0.062,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF2C1810),
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.005),
                        Text(
                          'Sign in to continue your journey',
                          style: GoogleFonts.nunito(
                            fontSize: size.width * 0.036,
                            color: const Color(0xFF9A8070),
                          ),
                        ),

                        SizedBox(height: size.height * 0.025),

                        _Field(
                          ctrl: _userCtrl,
                          hint: 'Username',
                          icon: Icons.person_outline_rounded,
                          size: size,
                        ),
                        SizedBox(height: size.height * 0.016),
                        _Field(
                          ctrl: _passCtrl,
                          hint: 'Password',
                          icon: Icons.lock_outline_rounded,
                          obscure: _obscure,
                          size: size,
                          onToggle: () =>
                              setState(() => _obscure = !_obscure),
                          onSubmit: (_) => _login(),
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              'Forgot password?',
                              style: GoogleFonts.nunito(
                                fontSize: size.width * 0.034,
                                color: const Color(0xFF5C3D2E),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        // Terms
                        GestureDetector(
                          onTap: () =>
                              setState(() => _terms = !_terms),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 200),
                                width: 20,
                                height: 20,
                                margin: const EdgeInsets.only(top: 2),
                                decoration: BoxDecoration(
                                  color: _terms
                                      ? const Color(0xFF5C3D2E)
                                      : Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(6),
                                  border: Border.all(
                                    color: _terms
                                        ? const Color(0xFF5C3D2E)
                                        : const Color(0xFFD4C5BC),
                                    width: 1.5,
                                  ),
                                ),
                                child: _terms
                                    ? const Icon(Icons.check_rounded,
                                        color: Colors.white, size: 13)
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'By continuing you accept the Terms & Conditions of MindALot',
                                  style: GoogleFonts.nunito(
                                    fontSize: size.width * 0.032,
                                    color: const Color(0xFF7A6055),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
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

                        // Login button
                        GestureDetector(
                          onTap: _login,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: double.infinity,
                            height: size.height * 0.065,
                            decoration: BoxDecoration(
                              color: _terms
                                  ? const Color(0xFF5C3D2E)
                                  : const Color(0xFFD4C5BC),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: _terms
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF5C3D2E)
                                            .withValues(alpha: 0.30),
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
                                'Sign In',
                                style: GoogleFonts.nunito(
                                  fontSize: size.width * 0.042,
                                  fontWeight: FontWeight.w800,
                                  color: _terms
                                      ? Colors.white
                                      : const Color(0xFF9A8A7E),
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
                    onTap: () =>
                        Navigator.pushNamed(context, '/register'),
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.nunito(
                          fontSize: size.width * 0.036,
                          color: const Color(0xFF7A6055),
                        ),
                        children: [
                          const TextSpan(
                              text: "Don't have an account?  "),
                          TextSpan(
                            text: 'Register',
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

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Size size;
  final VoidCallback? onToggle;
  final ValueChanged<String>? onSubmit;

  const _Field({
    required this.ctrl,
    required this.hint,
    required this.icon,
    required this.size,
    this.obscure = false,
    this.onToggle,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      onSubmitted: onSubmit,
      style: GoogleFonts.nunito(
          fontSize: size.width * 0.038, color: const Color(0xFF2C1810)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.nunito(
            color: const Color(0xFFB0A090),
            fontSize: size.width * 0.038),
        prefixIcon: Icon(icon, color: const Color(0xFF7A6055), size: 20),
        suffixIcon: onToggle != null
            ? IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF7A6055),
                  size: 20,
                ),
                onPressed: onToggle,
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF5F0ED),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF5C3D2E), width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(
            horizontal: 18, vertical: size.height * 0.018),
      ),
    );
  }
}
