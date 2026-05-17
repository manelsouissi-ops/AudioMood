import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/mood/camera_scan_screen.dart';
import 'screens/mood/mood_result_screen.dart';
import 'screens/home_screen.dart';
import 'screens/player_screen.dart';
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    // ProviderScope replaces MultiProvider — all providers are global constants
    const ProviderScope(child: AudioMoodApp()),
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
        '/forgot-password': (c) => const ForgotPasswordScreen(),
        '/camera-scan': (c) => const CameraScanScreen(),
        '/mood-result': (c) => const MoodResultScreen(),
        '/home': (c) => const HomeScreen(),
        '/player': (c) => const PlayerScreen(),
        '/search': (c) => const SearchScreen(),
        '/favorites': (c) => const FavoritesScreen(),
        '/profile': (c) => const ProfileScreen(),
        '/settings': (c) => const SettingsScreen(),
      },
    );
  }
}
