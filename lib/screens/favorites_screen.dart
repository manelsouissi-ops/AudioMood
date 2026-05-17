import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/favorites_provider.dart';
import '../providers/player_provider.dart';
import '../models/song.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Favorites'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: favorites.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border,
                      size: 80, color: AppColors.textMuted),
                  SizedBox(height: 16),
                  Text('No favorites yet',
                      style: TextStyle(color: Colors.white, fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Tap the heart on any song to add it here',
                      style: TextStyle(color: AppColors.textMuted),
                      textAlign: TextAlign.center),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: favorites.length,
              itemBuilder: (context, i) {
                final song = favorites[i];
                return _FavoriteTile(
                  song: song,
                  queue: favorites.skip(i + 1).toList(),
                );
              },
            ),
    );
  }
}

class _FavoriteTile extends ConsumerWidget {
  final Song song;
  final List<Song> queue;
  const _FavoriteTile({required this.song, required this.queue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 52, height: 52,
          child: song.coverUrl != null && song.coverUrl!.isNotEmpty
              ? Image.network(
                  song.coverUrl!, fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) => progress == null
                      ? child
                      : const ColoredBox(color: AppColors.surface,
                          child: Center(child: SizedBox(width: 18, height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.primary)))),
                  errorBuilder: (_, e, st) => const ColoredBox(
                      color: AppColors.surface,
                      child: Icon(Icons.music_note, color: Colors.white)))
              : const ColoredBox(color: AppColors.surface,
                  child: Icon(Icons.music_note, color: Colors.white)),
        ),
      ),
      title: Text(song.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(song.artist,
          style: const TextStyle(color: AppColors.textMuted),
          maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: IconButton(
        icon: const Icon(Icons.favorite, color: AppColors.accent),
        onPressed: () => ref.read(favoritesProvider.notifier).toggle(song),
      ),
      onTap: () {
        ref.read(playerProvider.notifier).play(song, queue: queue);
        Navigator.pushNamed(context, '/player');
      },
    );
  }
}
