import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../widgets/main_scaffold.dart';
import '../providers/settings_provider.dart';
import '../providers/player_provider.dart';
import '../services/search_history_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MainScaffold(
      currentIndex: 4,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Settings',
                  style: TextStyle(color: Colors.white, fontSize: 28,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
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
                  onChanged: (val) {
                    ref.read(settingsProvider.notifier).setAutoPlayNext(val);
                    ref.read(playerProvider.notifier).setAutoPlayNext(val);
                  },
                ),
              ]),
              const SizedBox(height: 20),
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
                      ref.read(settingsProvider.notifier).setNotifications(val),
                ),
              ]),
              const SizedBox(height: 20),
              _sectionLabel('Data & Privacy'),
              _card([
                ListTile(
                  leading: const Icon(Icons.history, color: AppColors.primary),
                  title: const Text('Clear search history',
                      style: TextStyle(color: AppColors.textOnLight,
                          fontWeight: FontWeight.w500)),
                  subtitle: const Text('Remove all recent searches',
                      style: TextStyle(color: Colors.black45, fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.black38),
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
                  trailing: const Icon(Icons.chevron_right, color: Colors.black38),
                  onTap: () => _confirmClearRecentlyPlayed(context, ref),
                ),
              ]),
              const SizedBox(height: 20),
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
                  leading: Icon(Icons.info_outline, color: AppColors.textMuted),
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
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11,
                fontWeight: FontWeight.w600, letterSpacing: 1)),
      );

  Widget _card(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14),
        ),
        child: Column(children: children),
      );

  Future<void> _confirmClearSearchHistory(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear search history?'),
        content: const Text('All recent searches will be removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Clear', style: TextStyle(color: Colors.red))),
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

  Future<void> _confirmClearRecentlyPlayed(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear recently played?'),
        content: const Text('Your listening history will be removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Clear', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    ref.read(playerProvider.notifier).clearRecentlyPlayed();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recently played cleared')),
    );
  }
}
