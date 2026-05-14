import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_drawer.dart';

/// A reusable Scaffold wrapper that adds:
///   - the side drawer (Atelier 6)
///   - the bottom navigation bar (Home / Search / Player / Profile / Settings)
///
/// Wrap the body of any authenticated screen with this and pass `currentIndex`
/// so the right tab is highlighted.
class MainScaffold extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final PreferredSizeWidget? appBar;

  const MainScaffold({
    super.key,
    required this.body,
    required this.currentIndex,
    this.appBar,
  });

  static const _routes = ['/home', '/search', '/player', '/profile', '/settings'];

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;
    Navigator.pushReplacementNamed(context, _routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      drawer: const AppDrawer(),
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        currentIndex: currentIndex,
        onTap: (i) => _onTap(context, i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.play_circle_filled), label: 'Player'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
