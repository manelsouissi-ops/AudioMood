import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mood_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/favorites_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _obscure2 = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _resetAllProviders() {
    ref.read(moodProvider.notifier).clear();
    ref.read(playerProvider.notifier).stop();
    ref.read(favoritesProvider.notifier).clear();
  }

  Future<void> _handleSignup() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;
    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    if (pass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).signup(name, email, pass);
      await ref.read(favoritesProvider.notifier).syncFromCloud();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final msg = switch (e.code) {
        'email-already-in-use' => 'An account already exists with this email',
        'invalid-email' => 'Invalid email format',
        'weak-password' => 'Password is too weak (at least 6 characters)',
        'operation-not-allowed' => 'Email/password signup is not enabled',
        _ => e.message ?? 'Signup failed',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Signup failed: $e')));
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
        title: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary, borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.bar_chart_rounded, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Create Account',
                  style: TextStyle(color: Colors.white, fontSize: 26,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('Join AudioMood and let the music find you',
                  style: TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 24),
              const Text('Full Name', style: TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 6),
              TextField(
                controller: _nameCtrl, enabled: !_loading,
                style: const TextStyle(color: Colors.black87, fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Enter your full name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 14),
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
              const SizedBox(height: 14),
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
              const SizedBox(height: 14),
              const Text('Confirm Password', style: TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 6),
              TextField(
                controller: _confirmCtrl, obscureText: _obscure2, enabled: !_loading,
                style: const TextStyle(color: Colors.black87, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Confirm your password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure2 = !_obscure2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _handleSignup,
                  child: _loading
                      ? const SizedBox(height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Sign Up'),
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
                    const Text('Already have an account? ',
                        style: TextStyle(color: AppColors.textMuted)),
                    GestureDetector(
                      onTap: _loading ? null
                          : () => Navigator.pushReplacementNamed(context, '/login'),
                      child: const Text('Log in',
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
