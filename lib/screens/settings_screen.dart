import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/main_scaffold.dart';
import '../providers/settings_provider.dart';
import '../providers/player_provider.dart';
import '../services/search_history_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Atelier 7 pattern: context.watch for live value reads
    final settings = context.watch<SettingsProvider>();

    return MainScaffold(
      currentIndex: 4,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // ── Section 1: Playback ──────────────────────────────────
              _sectionLabel('Playback'),
              _card([
                SwitchListTile(
                  title: const Text('Auto-play next song',
                      style: TextStyle(color: AppColors.textOnLight,
                          fontWeight: FontWeight.w500)),
                  subtitle: const Text('Continue to next song automatically',
                      style: TextStyle(color: Colors.black45, fontSize: 12)),
                  value: settings.autoPlayNext,
                  activeThumbColor: AppColors.primary,
                  // Atelier 7 pattern: context.read for one-shot method call
                  onChanged: (val) {
                    context.read<SettingsProvider>().setAutoPlayNext(val);
                    context.read<PlayerProvider>().setAutoPlayNext(val);
                  },
                ),
              ]),
              const SizedBox(height: 20),

              // ── Section 2: Notifications ─────────────────────────────
              _sectionLabel('Notifications'),
              _card([
                SwitchListTile(
                  title: const Text('Enable notifications',
                      style: TextStyle(color: AppColors.textOnLight,
                          fontWeight: FontWeight.w500)),
                  subtitle: const Text('Get updates about new music',
                      style: TextStyle(color: Colors.black45, fontSize: 12)),
                  value: settings.notificationsEnabled,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) =>
                      context.read<SettingsProvider>().setNotifications(val),
                ),
              ]),
              const SizedBox(height: 20),

              // ── Section 3: Data & Privacy ────────────────────────────
              _sectionLabel('Data & Privacy'),
              _card([
                ListTile(
                  leading:
                      const Icon(Icons.history, color: AppColors.primary),
                  title: const Text('Clear search history',
                      style: TextStyle(color: AppColors.textOnLight,
                          fontWeight: FontWeight.w500)),
                  subtitle: const Text('Remove all recent searches',
                      style: TextStyle(color: Colors.black45, fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right,
                      color: Colors.black38),
                  onTap: () => _confirmClearSearchHistory(context),
                ),
                const Divider(height: 1, indent: 56, color: Colors.black12),
                ListTile(
                  leading: const Icon(Icons.playlist_remove,
                      color: AppColors.primary),
                  title: const Text('Clear recently played',
                      style: TextStyle(color: AppColors.textOnLight,
                          fontWeight: FontWeight.w500)),
                  subtitle: const Text('Remove listening history',
                      style: TextStyle(color: Colors.black45, fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right,
                      color: Colors.black38),
                  onTap: () => _confirmClearRecentlyPlayed(context),
                ),
              ]),
              const SizedBox(height: 20),

              // ── Section 4: About ─────────────────────────────────────
              _sectionLabel('About'),
              _card([
                const ListTile(
                  leading: Icon(Icons.music_note, color: AppColors.primary),
                  title: Text('AudioMood',
                      style: TextStyle(color: AppColors.textOnLight,
                          fontWeight: FontWeight.w500)),
                  subtitle: Text('Feel your music',
                      style: TextStyle(color: Colors.black45, fontSize: 12)),
                ),
                const Divider(height: 1, indent: 56, color: Colors.black12),
                const ListTile(
                  leading: Icon(Icons.info_outline,
                      color: AppColors.textMuted),
                  title: Text('App version',
                      style: TextStyle(color: AppColors.textOnLight,
                          fontWeight: FontWeight.w500)),
                  subtitle: Text('1.0.0',
                      style: TextStyle(color: Colors.black45, fontSize: 12)),
                ),
              ]),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(text.toUpperCase(),
            style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1)),
      );

  Widget _card(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(children: children),
      );

  Future<void> _confirmClearSearchHistory(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear search history?'),
        content:
            const Text('All recent searches will be removed.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Clear',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await SearchHistoryService().clearRecentSearches();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Search history cleared')),
    );
  }

  Future<void> _confirmClearRecentlyPlayed(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear recently played?'),
        content: const Text('Your listening history will be removed.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Clear',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    // Atelier 7 pattern: context.read for one-shot method call
    context.read<PlayerProvider>().clearRecentlyPlayed();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recently played cleared')),
    );
  }
}
