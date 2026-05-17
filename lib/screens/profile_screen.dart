import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../widgets/main_scaffold.dart';
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/mood_provider.dart';
import '../providers/player_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final favsCount = ref.watch(favoritesProvider).length;
    final moodCount = ref.watch(moodProvider).history.length;
    final recentCount = ref.watch(playerProvider).recentlyPlayed.length;

    return MainScaffold(
      currentIndex: 3,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _avatar(auth),
              const SizedBox(height: 16),
              Text(auth.displayName,
                  style: const TextStyle(color: Colors.white, fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(auth.email.isNotEmpty ? auth.email : 'guest@audiomood.app',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile editing coming soon')),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white38),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                ),
                child: const Text('Edit Profile'),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _stat(favsCount.toString(), 'Favorites'),
                  _stat(moodCount.toString(), 'Moods'),
                  _stat(recentCount.toString(), 'Recent'),
                ],
              ),
              const SizedBox(height: 28),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _menuTile(context,
                        icon: Icons.favorite, iconColor: AppColors.accent,
                        label: 'My Favorites',
                        onTap: () => Navigator.pushNamed(context, '/favorites')),
                    _divider(),
                    _menuTile(context,
                        icon: Icons.history, iconColor: AppColors.primary,
                        label: 'Listening History',
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Listening history coming soon')),
                        )),
                    _divider(),
                    _menuTile(context,
                        icon: Icons.settings, iconColor: Colors.grey,
                        label: 'App Settings',
                        onTap: () => Navigator.pushReplacementNamed(
                            context, '/settings')),
                    _divider(),
                    _menuTile(context,
                        icon: Icons.notifications, iconColor: Colors.orange,
                        label: 'Notifications',
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Coming soon')),
                        )),
                    _divider(),
                    _menuTile(context,
                        icon: Icons.camera_alt, iconColor: AppColors.primary,
                        label: 'Camera Permissions',
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Coming soon')),
                        )),
                    _divider(),
                    _menuTile(context,
                        icon: Icons.logout, iconColor: Colors.red,
                        label: 'Log Out',
                        onTap: () async {
                          // logout() invalidates favorites/mood/player internally
                          await ref.read(authProvider.notifier).logout();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/onboarding', (r) => false);
                          }
                        }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatar(AuthState auth) {
    final url = auth.user?.avatarUrl;
    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        radius: 50, backgroundColor: AppColors.surface,
        child: ClipOval(
          child: Image.network(url, width: 100, height: 100, fit: BoxFit.cover,
              errorBuilder: (_, e, st) => const Icon(Icons.person,
                  size: 50, color: AppColors.primary)),
        ),
      );
    }
    return const CircleAvatar(
      radius: 50, backgroundColor: AppColors.primary,
      child: Icon(Icons.person, size: 50, color: Colors.white),
    );
  }

  Widget _stat(String value, String label) {
    return Column(children: [
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 24,
          fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
    ]);
  }

  Widget _menuTile(BuildContext context, {
    required IconData icon, required Color iconColor,
    required String label, required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(label, style: const TextStyle(color: AppColors.textOnLight,
          fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.black38),
      onTap: onTap,
    );
  }

  Widget _divider() =>
      const Divider(height: 1, indent: 56, color: Colors.black12);
}
