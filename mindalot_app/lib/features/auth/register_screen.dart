import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _aliasController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptedTerms = false;
  String? _error;

  @override
  void dispose() {
    _aliasController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final alias = _aliasController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (alias.isEmpty) {
      setState(() => _error = 'Please choose a display name.');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    if (!_acceptedTerms) {
      setState(() => _error = 'Please accept the Terms & Conditions.');
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
    return Scaffold(
      backgroundColor: const Color(0xFFE8F4F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF5C3D2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Create Account',
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
              // Cloud mascot
              Center(
                child: Column(
                  children: [
                    const Text('☁️', style: TextStyle(fontSize: 64)),
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

              _Label('Display Name (Alias)'),
              const SizedBox(height: 6),
              TextField(
                controller: _aliasController,
                decoration: _inputDecoration(
                  hint: 'e.g. StarGazer, BlueMoon...',
                  icon: Icons.person_outline_rounded,
                ),
                style: GoogleFonts.nunito(fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                'This is how your counsellor will refer to you. Not your real name.',
                style: GoogleFonts.nunito(
                    fontSize: 12, color: const Color(0xFF7A6055)),
              ),
              const SizedBox(height: 18),

              _Label('Password'),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: _inputDecoration(
                  hint: 'At least 6 characters',
                  icon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF7A6055),
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                style: GoogleFonts.nunito(fontSize: 15),
              ),
              const SizedBox(height: 14),

              _Label('Confirm Password'),
              const SizedBox(height: 6),
              TextField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                decoration: _inputDecoration(
                  hint: 'Re-enter password',
                  icon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF7A6055),
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                style: GoogleFonts.nunito(fontSize: 15),
                onSubmitted: (_) => _register(),
              ),
              const SizedBox(height: 20),

              // Terms checkbox
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
                            fontSize: 13, color: const Color(0xFF7A6055)),
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
