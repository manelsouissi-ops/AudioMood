import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mood_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/favorites_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _resetAllProviders() {
    ref.read(moodProvider.notifier).clear();
    ref.read(playerProvider.notifier).stop();
    ref.read(favoritesProvider.notifier).clear();
  }

  Future<void> _handleLogin() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both fields')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).login(email, pass);
      await ref.read(favoritesProvider.notifier).syncFromCloud();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final msg = switch (e.code) {
        'user-not-found' => 'No account found with this email',
        'wrong-password' || 'invalid-credential' => 'Wrong email or password',
        'invalid-email' => 'Invalid email format',
        'user-disabled' => 'This account has been disabled',
        'too-many-requests' => 'Too many attempts. Try again later',
        _ => e.message ?? 'Login failed',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Login failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _loading = true);
    _resetAllProviders();
    try {
      await ref.read(authProvider.notifier).loginWithGoogle();
      await ref.read(favoritesProvider.notifier).syncFromCloud();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Google sign-in failed')),
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      if (msg.contains('canceled') || msg.contains('cancelled') ||
          msg.contains('sign_in_canceled')) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _loading ? null : () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.bar_chart_rounded,
                      color: Colors.white, size: 50),
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text('Welcome Back',
                    style: TextStyle(color: Colors.white, fontSize: 26,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text('Sign in to continue',
                    style: TextStyle(color: AppColors.textMuted)),
              ),
              const SizedBox(height: 32),
              const Text('Email', style: TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 6),
              TextField(
                controller: _emailCtrl, enabled: !_loading,
                style: const TextStyle(color: Colors.black87, fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Enter your email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Password', style: TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 6),
              TextField(
                controller: _passCtrl, obscureText: _obscure, enabled: !_loading,
                style: const TextStyle(color: Colors.black87, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _loading
                      ? null
                      : () => Navigator.pushNamed(context, '/forgot-password'),
                  child: const Text('Forgot password?',
                      style: TextStyle(color: AppColors.accent)),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _handleLogin,
                  child: _loading
                      ? const SizedBox(height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Log In'),
                ),
              ),
              const SizedBox(height: 16),
              Row(children: [
                const Expanded(child: Divider(color: AppColors.textMuted)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or continue with',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ),
                const Expanded(child: Divider(color: AppColors.textMuted)),
              ]),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _loading ? null : _handleGoogleLogin,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white, foregroundColor: Colors.black87,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Text('G',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  label: const Text('Continue with Google',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ",
                        style: TextStyle(color: AppColors.textMuted)),
                    GestureDetector(
                      onTap: _loading ? null
                          : () => Navigator.pushReplacementNamed(context, '/signup'),
                      child: const Text('Sign up',
                          style: TextStyle(color: Colors.white,
                              decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
