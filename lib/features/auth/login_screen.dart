import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nikController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;
  bool _obscurePassword = true;
  String? _errorMessage;
  bool _loading = false;

  @override
  void dispose() {
    _nikController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_nikController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Email/NIK dan Password wajib diisi.');
      return;
    }

    setState(() {
      _errorMessage = null;
      _loading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _nikController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      final isAdmin = await AuthService.isAdmin();
      Navigator.pushReplacementNamed(context, isAdmin ? '/admin' : '/home');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = switch (e.code) {
          'user-not-found' || 'invalid-credential' => 'Email atau Password salah.',
          'wrong-password' => 'Password salah.',
          'too-many-requests' => 'Terlalu banyak percobaan. Coba lagi nanti.',
          _ => 'Login gagal: ${e.message}',
        };
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _errorMessage = 'Terjadi kesalahan. Coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo & Brand
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.brandBlue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.home_outlined, size: 40, color: AppColors.brandBlue),
              ),
              const SizedBox(height: 12),
              const Text('Wargaku', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.dark)),
              const SizedBox(height: 4),
              Text('ADMINISTRASI & KEAMANAN RT',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2, color: AppColors.slateGray)),
              const Spacer(),
              // Fields
              _buildField('Email / Username', '👤', _nikController, false),
              const SizedBox(height: 16),
              _buildField('Password', '🔒', _passwordController, true),
              const SizedBox(height: 12),
              // Remember + Forgot
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    SizedBox(
                      width: 20, height: 20,
                      child: Checkbox(value: _rememberMe, onChanged: (v) => setState(() => _rememberMe = v!)),
                    ),
                    const SizedBox(width: 6),
                    const Text('Ingat Saya', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  ]),
                  const Text('Lupa Password?', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.brandBlue)),
                ],
              ),
              const SizedBox(height: 16),
              // Error banner
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('⚠️ $_errorMessage', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.red.shade700)),
                ),
              const SizedBox(height: 16),
              // Login button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Masuk Ke Aplikasi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1)),
                ),
              ),
              const Spacer(),
              // Footer
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 11, color: AppColors.slateGray),
                    children: [
                      TextSpan(text: 'Belum punya akun? '),
                      TextSpan(text: 'Hubungi Pengurus RT', style: TextStyle(color: AppColors.brandBlue, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, String icon, TextEditingController ctrl, bool isPassword) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.dark)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          obscureText: isPassword && _obscurePassword,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixIcon: Padding(padding: const EdgeInsets.all(12), child: Text(icon, style: const TextStyle(fontSize: 16))),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 18),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 2)),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }
}
