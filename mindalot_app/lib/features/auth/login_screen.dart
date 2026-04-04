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

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _acceptedTerms = false;
  String? _error;

  // Triple-tap counter on logo for counsellor hidden login
  int _logoTapCount = 0;
  DateTime? _lastLogoTap;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogoTap() {
    final now = DateTime.now();
    if (_lastLogoTap != null &&
        now.difference(_lastLogoTap!) < const Duration(seconds: 2)) {
      _logoTapCount++;
    } else {
      _logoTapCount = 1;
    }
    _lastLogoTap = now;
    if (_logoTapCount >= 3) {
      _logoTapCount = 0;
      Navigator.pushNamed(context, '/counsellor-login');
    }
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter your username and password.');
      return;
    }
    if (!_acceptedTerms) {
      setState(() => _error = 'Please accept the Terms & Conditions.');
      return;
    }

    setState(() => _error = null);

    // POC: save alias from username and go to home
    // Production: validate against backend API
    await AuthService().setUserAlias(username);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCloudsBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 24),
                child: Column(
                  children: [
                    // Floating mascot above logo
                    const FloatingMascot(size: 110),
                    const SizedBox(height: 12),
                    // Triple-tap logo — hidden counsellor entry
                    GestureDetector(
                      onTap: _onLogoTap,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'mind',
                              style: GoogleFonts.nunito(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF5C3D2E),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            TextSpan(
                              text: 'alot',
                              style: GoogleFonts.nunito(
                                fontSize: 24,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF7A6055),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    Text(
                      'Login to Your Account',
                      style: GoogleFonts.nunito(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2C1810),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Username
                    TextField(
                      controller: _usernameController,
                      autocorrect: false,
                      decoration: InputDecoration(
                        hintText: 'Username',
                        hintStyle: GoogleFonts.nunito(
                            color: const Color(0xFFB0A090)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                              color: Color(0xFFD4C5BC)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                              color: Color(0xFFD4C5BC)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                              color: Color(0xFF5C3D2E), width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                      ),
                      style: GoogleFonts.nunito(fontSize: 15),
                    ),
                    const SizedBox(height: 14),

                    // Password
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: GoogleFonts.nunito(
                            color: const Color(0xFFB0A090)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: const Color(0xFF7A6055),
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                      ),
                      style: GoogleFonts.nunito(fontSize: 15),
                      onSubmitted: (_) => _login(),
                    ),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Forgot password',
                          style: GoogleFonts.nunito(
                              color: const Color(0xFF7A6055), fontSize: 13),
                        ),
                      ),
                    ),

                    // Terms
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _acceptedTerms,
                          onChanged: (v) =>
                              setState(() => _acceptedTerms = v ?? false),
                          activeColor: const Color(0xFF5C3D2E),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              'By clicking this you are accepting the Terms & Conditions of Mind a Lot',
                              style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  color: const Color(0xFF7A6055)),
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(_error!,
                          style: GoogleFonts.nunito(
                              color: Colors.red.shade600, fontSize: 13)),
                    ],

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _acceptedTerms
                            ? const Color(0xFF5C3D2E)
                            : Colors.grey.shade300,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text(
                        'Login',
                        style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _acceptedTerms
                                ? Colors.white
                                : Colors.grey.shade500),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, '/register'),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.nunito(
                              fontSize: 14, color: const Color(0xFF7A6055)),
                          children: [
                            const TextSpan(text: "Don't have an account? "),
                            TextSpan(
                              text: 'Register',
                              style: GoogleFonts.nunito(
                                  color: const Color(0xFF5C3D2E),
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
