import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/main_scaffold.dart';
import '../providers/auth_provider.dart';
import '../providers/mood_provider.dart';
import '../providers/player_provider.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import '../services/firebase_service.dart';
import '../services/deezer_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final Future<List<Playlist>> _playlistsFuture;
  String? _loadingPlaylistId;

  @override
  void initState() {
    super.initState();
    _playlistsFuture = FirebaseService().fetchPlaylists();
  }

  @override
  Widget build(BuildContext context) {
    final recent = ref.watch(playerProvider).recentlyPlayed;

    return MainScaffold(
      currentIndex: 0,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 16),
              _moodCard(context),
              const SizedBox(height: 24),
              const Text('Recommended for You',
                  style: TextStyle(color: Colors.white, fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              FutureBuilder<List<Playlist>>(
                future: _playlistsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(height: 180,
                        child: Center(child: CircularProgressIndicator(
                            color: AppColors.primary)));
                  }
                  if (snapshot.hasError) {
                    return SizedBox(height: 180,
                        child: Center(child: Text('Error: ${snapshot.error}',
                            style: const TextStyle(color: AppColors.textMuted))));
                  }
                  final playlists = snapshot.data ?? [];
                  if (playlists.isEmpty) {
                    return const SizedBox(height: 180,
                        child: Center(child: Text(
                          'No playlists yet — add some in Firestore',
                          style: TextStyle(color: AppColors.textMuted))));
                  }
                  return SizedBox(
                    height: 180,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: playlists.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (_, i) => _playlistCard(context, playlists[i]),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text('Recently Played',
                  style: TextStyle(color: Colors.white, fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (recent.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('No songs played yet',
                      style: TextStyle(color: AppColors.textMuted)),
                )
              else
                ...recent.map((s) => _songTile(context, s)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    final auth = ref.watch(authProvider);
    return Row(
      children: [
        Builder(builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        )),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Good morning 👋',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              Text(auth.displayName,
                  style: const TextStyle(color: Colors.white, fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        IconButton(icon: const Icon(Icons.notifications_outlined,
            color: Colors.white), onPressed: () {}),
        const CircleAvatar(radius: 18, backgroundColor: Colors.grey),
      ],
    );
  }

  Widget _moodCard(BuildContext context) {
    final mood = ref.watch(moodProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card, borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('How are you feeling today?',
              style: TextStyle(color: AppColors.textOnLight, fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (mood.hasDetectedMood)
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/mood-result'),
              child: Container(
                height: 130,
                decoration: BoxDecoration(
                  color: mood.current!.mood.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(mood.current!.mood.emoji,
                          style: const TextStyle(fontSize: 50)),
                      const SizedBox(height: 8),
                      Text('${mood.current!.mood.label} • ${mood.current!.confidencePercent}',
                          style: const TextStyle(color: AppColors.textOnLight,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            )
          else
            Container(
              height: 130,
              decoration: BoxDecoration(
                color: Colors.grey[300], borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Icon(Icons.camera_alt_outlined,
                  size: 50, color: Colors.grey)),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, foregroundColor: Colors.white),
              onPressed: () => Navigator.pushNamed(context, '/camera-scan'),
              child: const Text('Detect My Mood'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _playPlaylist(Playlist p) async {
    setState(() => _loadingPlaylistId = p.id);
    try {
      final query = p.searchQuery?.isNotEmpty == true ? p.searchQuery! : p.name;
      final songs = await DeezerService().searchTracks(query);
      if (songs.isEmpty) throw Exception('No songs found for "${p.name}"');
      if (!mounted) return;
      await ref.read(playerProvider.notifier).play(
            songs.first,
            queue: songs.skip(1).toList(),
          );
      if (!mounted) return;
      Navigator.pushNamed(context, '/player');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loadingPlaylistId = null);
    }
  }

  Widget _playlistCard(BuildContext context, Playlist p) {
    final moodColor = p.mood?.color ?? Colors.grey;
    final badgeLabel = p.mood != null ? '${p.mood!.emoji} ${p.mood!.label}' : null;
    final isLoading = _loadingPlaylistId == p.id;
    return GestureDetector(
      onTap: isLoading ? null : () => _playPlaylist(p),
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 110,
              decoration: BoxDecoration(
                color: moodColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Center(
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.music_note, size: 40, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      style: const TextStyle(color: Colors.white,
                          fontWeight: FontWeight.w600),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (badgeLabel != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(badgeLabel,
                          style: const TextStyle(color: Colors.white,
                              fontSize: 11),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
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
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 50, height: 50,
          child: s.coverUrl != null && s.coverUrl!.isNotEmpty
              ? Image.network(s.coverUrl!, fit: BoxFit.cover,
                  errorBuilder: (_, e, st) => const ColoredBox(
                    color: Colors.grey,
                    child: Icon(Icons.music_note, color: Colors.white),
                  ))
              : const ColoredBox(color: Colors.grey,
                  child: Icon(Icons.music_note, color: Colors.white)),
        ),
      ),
      title: Text(s.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      subtitle: Text(s.artist,
          style: const TextStyle(color: AppColors.textMuted)),
      trailing: Text(s.durationLabel,
          style: const TextStyle(color: AppColors.textMuted)),
      onTap: () {
        ref.read(playerProvider.notifier).play(s);
        Navigator.pushNamed(context, '/player');
      },
    );
  }
}
