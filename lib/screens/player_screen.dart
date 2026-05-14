import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/main_scaffold.dart';
import '../providers/player_provider.dart';
import '../providers/favorites_provider.dart';
import '../models/song.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: 2,
      appBar: AppBar(
        title: const Text('Now Playing', style: TextStyle(fontSize: 16)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
        ],
      ),
      // Atelier 7 pattern: Consumer<PlayerProvider> wraps the entire body
      body: Consumer<PlayerProvider>(
        builder: (context, player, _) {
          if (!player.hasSong) {
            return _emptyState();
          }
          return _playerBody(context, player);
        },
      ),
    );
  }

  Widget _emptyState() {
    return const SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_off, size: 80, color: AppColors.textMuted),
            SizedBox(height: 16),
            Text('No song playing',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Pick a song from Home to start',
                style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _playerBody(BuildContext context, PlayerProvider player) {
    final Song song = player.currentSong!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Album art
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.album, size: 80, color: Colors.white),
                    SizedBox(height: 8),
                    Text('Album Art', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(song.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                      Text(song.artist,
                          style: const TextStyle(color: AppColors.textMuted)),
                    ],
                  ),
                ),
                // Atelier 7 pattern: Consumer<FavoritesProvider> for granular rebuild
                Consumer<FavoritesProvider>(
                  builder: (context, fav, _) => IconButton(
                    icon: Icon(
                      fav.isFavorite(song.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: fav.isFavorite(song.id)
                          ? AppColors.accent
                          : Colors.white,
                    ),
                    // Atelier 7 pattern: context.read for one-shot method call
                    onPressed: () => context.read<FavoritesProvider>().toggle(song),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Slider(
              value: player.progress,
              onChanged: (v) {
                final newPos = Duration(
                  milliseconds: (song.duration.inMilliseconds * v).round(),
                );
                // Atelier 7 pattern: context.read for one-shot method call
                context.read<PlayerProvider>().seek(newPos);
              },
              activeColor: AppColors.primary,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_fmt(player.position),
                    style: const TextStyle(color: AppColors.textMuted)),
                Text(song.durationLabel,
                    style: const TextStyle(color: AppColors.textMuted)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                    icon: const Icon(Icons.shuffle, color: Colors.white),
                    onPressed: () {}),
                IconButton(
                    icon: const Icon(Icons.skip_previous, size: 40, color: Colors.white),
                    onPressed: () {}),
                Container(
                  width: 70,
                  height: 70,
                  decoration:
                      const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: IconButton(
                    icon: Icon(
                      player.isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 40,
                      color: Colors.black,
                    ),
                    // Atelier 7 pattern: context.read for one-shot method call
                    onPressed: () => context.read<PlayerProvider>().togglePlayPause(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, size: 40, color: Colors.white),
                  // Atelier 7 pattern: context.read for one-shot method call
                  onPressed: () => context.read<PlayerProvider>().next(),
                ),
                IconButton(
                    icon: const Icon(Icons.repeat, color: Colors.white),
                    onPressed: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
