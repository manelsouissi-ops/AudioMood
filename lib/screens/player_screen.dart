import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../widgets/main_scaffold.dart';
import '../providers/player_provider.dart';
import '../providers/favorites_provider.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
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
      body: player.hasSong
          ? _playerBody(context, ref, player)
          : _emptyState(),
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
                style: TextStyle(color: Colors.white, fontSize: 20,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Pick a song from Home to start',
                style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _playerBody(BuildContext context, WidgetRef ref, PlayerState player) {
    final song = player.currentSong!;
    final favorites = ref.watch(favoritesProvider);
    final isFav = favorites.any((s) => s.id == song.id);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 240, height: 240,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: song.coverUrl != null && song.coverUrl!.isNotEmpty
                  ? Image.network(
                      song.coverUrl!, fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : const Center(child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white)),
                      errorBuilder: (_, e, st) => const Center(
                          child: Icon(Icons.album, size: 80, color: Colors.white)),
                    )
                  : const Center(
                      child: Icon(Icons.album, size: 80, color: Colors.white)),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(song.title,
                          style: const TextStyle(color: Colors.white,
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      Text(song.artist,
                          style: const TextStyle(color: AppColors.textMuted)),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? AppColors.accent : Colors.white,
                  ),
                  onPressed: () =>
                      ref.read(favoritesProvider.notifier).toggle(song),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Slider(
              value: player.progress,
              onChanged: (v) {
                final newPos = Duration(
                    milliseconds: (song.duration.inMilliseconds * v).round());
                ref.read(playerProvider.notifier).seek(newPos);
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
                IconButton(icon: const Icon(Icons.shuffle, color: Colors.white),
                    onPressed: () {}),
                IconButton(
                    icon: const Icon(Icons.skip_previous,
                        size: 40, color: Colors.white),
                    onPressed: () => ref.read(playerProvider.notifier).previous()),
                Container(
                  width: 70, height: 70,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: IconButton(
                    icon: Icon(
                      player.isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 40, color: Colors.black,
                    ),
                    onPressed: () =>
                        ref.read(playerProvider.notifier).togglePlayPause(),
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.skip_next,
                        size: 40, color: Colors.white),
                    onPressed: () => ref.read(playerProvider.notifier).next()),
                IconButton(icon: const Icon(Icons.repeat, color: Colors.white),
                    onPressed: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
