import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/settings_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Store provider refs before any async gap (BuildContext safety)
    // Atelier 7 pattern: context.read for one-shot async call
    final auth = context.read<AuthProvider>();
    final favs = context.read<FavoritesProvider>();
    final settings = context.read<SettingsProvider>();

    // 1. Resolve auth state + load persisted settings in parallel
    debugPrint('[SPLASH] calling auth.initialize()');
    await Future.wait([
      auth.initialize(),
      settings.load(),
    ]);
    debugPrint('[SPLASH] auth done, isLoggedIn = ${auth.isLoggedIn}');

    // NOTE: There is no favorites.load() — no SharedPreferences layer exists.
    // Favorites are synced exclusively from Firestore via syncFromCloud().

    // 2. Sync favorites from cloud (only if signed in), then minimum splash delay
    debugPrint('[SPLASH] calling favorites.syncFromCloud() (isLoggedIn=${auth.isLoggedIn})');
    await Future.wait([
      Future.delayed(const Duration(seconds: 1)),
      if (auth.isLoggedIn) favs.syncFromCloud(),
    ]);

    if (!mounted) return;

    // 3. Navigate based on auth state
    final dest = auth.isLoggedIn ? '/home' : '/onboarding';
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
