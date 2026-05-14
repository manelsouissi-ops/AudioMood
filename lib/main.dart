import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/player_screen.dart';
import 'screens/placeholders/search_placeholder.dart';
import 'screens/placeholders/profile_placeholder.dart';
import 'screens/placeholders/settings_placeholder.dart';
import 'providers/auth_provider.dart';
import 'providers/mood_provider.dart';
import 'providers/player_provider.dart';
import 'providers/favorites_provider.dart';

void main() {
  // Atelier 7 pattern: MultiProvider at the root so every widget can access state
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: const AudioMoodApp(),
    ),
  );
}

class AudioMoodApp extends StatelessWidget {
  const AudioMoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AudioMood',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: '/splash',
      routes: {
        '/splash': (c) => const SplashScreen(),
        '/onboarding': (c) => const OnboardingScreen(),
        '/login': (c) => const LoginScreen(),
        '/signup': (c) => const SignupScreen(),
        '/home': (c) => const HomeScreen(),
        '/player': (c) => const PlayerScreen(),
        '/search': (c) => const SearchPlaceholder(),
        '/profile': (c) => const ProfilePlaceholder(),
        '/settings': (c) => const SettingsPlaceholder(),
      },
    );
  }
}
