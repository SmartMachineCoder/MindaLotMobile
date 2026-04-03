import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/services/counsellor_provider.dart';

class CounsellorLoginScreen extends StatefulWidget {
  const CounsellorLoginScreen({super.key});

  @override
  State<CounsellorLoginScreen> createState() => _CounsellorLoginScreenState();
}

class _CounsellorLoginScreenState extends State<CounsellorLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter your credentials.');
      return;
    }

    setState(() => _error = null);
    final provider = context.read<CounsellorProvider>();
    final success = await provider.login(email, password);

    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, '/counsellor-dashboard');
    } else {
      // Silent fail — no hint about whether page exists
      setState(() => _error = 'Invalid credentials. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Deliberately plain — no branding to hint this is a special page
      backgroundColor: const Color(0xFFF5F0EB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Minimal header — no "counsellor" mention visible on screen
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5C3D2E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.lock_outline_rounded,
                      color: Colors.white, size: 36),
                ),
                const SizedBox(height: 28),
                Text(
                  'Sign In',
                  style: GoogleFonts.nunito(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2C1810),
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined,
                        color: Color(0xFF7A6055)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: GoogleFonts.nunito(fontSize: 15),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: Color(0xFF7A6055)),
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
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: GoogleFonts.nunito(fontSize: 15),
                  onSubmitted: (_) => _login(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: GoogleFonts.nunito(
                        color: Colors.red.shade600, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 24),
                Consumer<CounsellorProvider>(
                  builder: (_, provider, __) => ElevatedButton(
                    onPressed: provider.isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5C3D2E),
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: provider.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text('Sign In',
                            style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('← Back',
                      style: GoogleFonts.nunito(
                          color: const Color(0xFF7A6055), fontSize: 14)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
