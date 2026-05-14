import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/main_scaffold.dart';
import '../providers/auth_provider.dart';
import '../providers/mood_provider.dart';
import '../providers/player_provider.dart';
import '../models/mood.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import '../data/mock_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _simulateMoodDetection(BuildContext context) {
    // Atelier 7 pattern: context.read for one-shot method call
    final moodProvider = context.read<MoodProvider>();
    final current = moodProvider.current;
    final values = MoodType.values;
    final nextIndex = current == null
        ? 0
        : (values.indexOf(current.mood) + 1) % values.length;
    final picked = values[nextIndex];
    moodProvider.setMood(picked, 0.85);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mood detected: ${picked.emoji} ${picked.label}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playlists = MockData.playlists;
    final recent = MockData.recentlyPlayed;

    return MainScaffold(
      currentIndex: 0,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context),
              const SizedBox(height: 16),
              _moodCard(context),
              const SizedBox(height: 24),
              const Text(
                'Recommended for You',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: playlists.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, i) => _playlistCard(context, playlists[i]),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Recently Played',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...recent.map((s) => _songTile(context, s)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    // Atelier 7 pattern: context.watch rebuilds the header when auth state changes
    final auth = context.watch<AuthProvider>();
    return Row(
      children: [
        Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Good morning 👋',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              Text(
                auth.displayName,
                style: const TextStyle(
                    color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {}),
        const CircleAvatar(radius: 18, backgroundColor: Colors.grey),
      ],
    );
  }

  Widget _moodCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How are you feeling today?',
            style: TextStyle(
                color: AppColors.textOnLight, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // Atelier 7 pattern: Consumer<MoodProvider> for granular sub-tree rebuild
          Consumer<MoodProvider>(
            builder: (context, mood, _) {
              if (mood.hasDetectedMood) {
                final result = mood.current!;
                return Container(
                  height: 130,
                  decoration: BoxDecoration(
                    color: result.mood.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(result.mood.emoji,
                            style: const TextStyle(fontSize: 50)),
                        const SizedBox(height: 8),
                        Text(
                          '${result.mood.label} • ${result.confidencePercent}',
                          style: const TextStyle(
                              color: AppColors.textOnLight,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Container(
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                    child: Icon(Icons.camera_alt_outlined, size: 50, color: Colors.grey)),
              );
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, foregroundColor: Colors.white),
              onPressed: () => _simulateMoodDetection(context),
              child: const Text('Detect My Mood'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _playlistCard(BuildContext context, Playlist p) {
    final moodColor = p.mood?.color ?? Colors.grey;
    final badgeLabel =
        p.mood != null ? '${p.mood!.emoji} ${p.mood!.label}' : null;

    return GestureDetector(
      onTap: () {
        if (p.songs.isEmpty) return;
        // Atelier 7 pattern: context.read for one-shot method call
        context.read<PlayerProvider>().play(
              p.songs.first,
              queue: p.songs.skip(1).toList(),
            );
        Navigator.pushNamed(context, '/player');
      },
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 110,
              decoration: BoxDecoration(
                color: moodColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Center(
                  child: Icon(Icons.music_note, size: 40, color: Colors.white)),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  if (badgeLabel != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(badgeLabel,
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _songTile(BuildContext context, Song s) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8)),
        child: const Icon(Icons.music_note, color: Colors.white),
      ),
      title: Text(s.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      subtitle: Text(s.artist, style: const TextStyle(color: AppColors.textMuted)),
      trailing: Text(s.durationLabel, style: const TextStyle(color: AppColors.textMuted)),
      onTap: () {
        // Atelier 7 pattern: context.read for one-shot method call
        context.read<PlayerProvider>().play(s);
        Navigator.pushNamed(context, '/player');
      },
    );
  }
}
