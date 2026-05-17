import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/settings_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    debugPrint('[SPLASH] calling auth.initialize()');
    // ref is always safe in ConsumerState — no capture needed before async gaps
    await Future.wait([
      ref.read(authProvider.notifier).initialize(),
      ref.read(settingsProvider.notifier).load(),
    ]);
    final isLoggedIn = ref.read(authProvider).isLoggedIn;
    debugPrint('[SPLASH] auth done, isLoggedIn = $isLoggedIn');

    debugPrint('[SPLASH] calling favorites.syncFromCloud() (isLoggedIn=$isLoggedIn)');
    await Future.wait([
      Future.delayed(const Duration(seconds: 1)),
      if (isLoggedIn) ref.read(favoritesProvider.notifier).syncFromCloud(),
    ]);

    if (!mounted) return;
    final dest = isLoggedIn ? '/home' : '/onboarding';
    debugPrint('[SPLASH] all bootstrap done, navigating to $dest');
    Navigator.pushReplacementNamed(context, dest);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(Icons.bar_chart_rounded,
                  color: Colors.white, size: 90),
            ),
            const SizedBox(height: 24),
            const Text(
              'AUDIOMOOD',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Feel your music',
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
