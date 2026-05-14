import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Atelier 7 pattern: Consumer<AuthProvider> for granular sub-tree rebuild
          Consumer<AuthProvider>(
            builder: (context, auth, _) => UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              accountName: Text(
                auth.displayName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                auth.email.isNotEmpty ? auth.email : 'guest@audiomood.app',
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: AppColors.primary),
              ),
            ),
          ),
          _drawerTile(context, Icons.home, 'Home', '/home'),
          _drawerTile(context, Icons.search, 'Search', '/search'),
          _drawerTile(context, Icons.play_circle_filled, 'Player', '/player'),
          _drawerTile(context, Icons.person, 'Profile', '/profile'),
          const Divider(color: Colors.white24),
          _drawerTile(context, Icons.settings, 'Settings', '/settings'),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: const Text('Log Out', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Atelier 7 pattern: context.read for one-shot method call
              context.read<AuthProvider>().logout();
              Navigator.pushNamedAndRemoveUntil(context, '/onboarding', (r) => false);
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerTile(BuildContext context, IconData icon, String label, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, route);
      },
    );
  }
}
