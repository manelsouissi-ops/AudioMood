import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../widgets/main_scaffold.dart';
import '../models/mood.dart';
import '../models/song.dart';
import '../providers/player_provider.dart';
import '../services/deezer_service.dart';
import '../services/search_history_service.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchCtrl = TextEditingController();
  final _historyService = SearchHistoryService();
  List<String> _recentSearches = [];
  List<Song> _results = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  String? _error;

  static String _queryForMood(MoodType mood) => switch (mood) {
        MoodType.happy => 'happy',
        MoodType.sad => 'sad songs',
        MoodType.angry => 'rock',
        MoodType.relaxed => 'relax',
        MoodType.energetic => 'workout',
        MoodType.calm => 'calm',
      };

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final recent = await _historyService.loadRecentSearches();
    if (mounted) setState(() => _recentSearches = recent);
  }

  Future<void> _performSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    setState(() {
      _isSearching = true;
      _hasSearched = true;
      _error = null;
      _results = [];
    });
    try {
      final songs = await DeezerService().searchTracks(q);
      if (!mounted) return;
      setState(() { _results = songs; _isSearching = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isSearching = false;
      });
    }
    await _historyService.addRecentSearch(q);
    if (!mounted) return;
    await _loadHistory();
  }

  void _searchByMood(MoodType mood) {
    _searchCtrl.text = mood.label;
    _performSearch(_queryForMood(mood));
  }

  Future<void> _removeRecent(String term) async {
    await _historyService.removeRecentSearch(term);
    if (!mounted) return;
    _loadHistory();
  }

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() {
      _hasSearched = false; _results = []; _error = null; _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: 1,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Search',
                        style: TextStyle(color: Colors.white, fontSize: 28,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchCtrl,
                      style: const TextStyle(color: Colors.black87, fontSize: 16),
                      textInputAction: TextInputAction.search,
                      onSubmitted: _performSearch,
                      decoration: InputDecoration(
                        hintText: 'Songs, artists, playlists...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: _clearSearch)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _searchCtrl,
                builder: (_, value, child) => const SizedBox.shrink(),
              ),
            ),
            if (_isSearching)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(
                    color: AppColors.primary)),
              )
            else if (_hasSearched)
              _buildResultsSliver()
            else
              _buildBrowseSliver(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSliver() {
    if (_error != null) {
      return SliverFillRemaining(
        child: Center(child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error!, textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted)),
        )),
      );
    }
    if (_results.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No results found',
            style: TextStyle(color: AppColors.textMuted, fontSize: 16))),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, i) => _SongResultTile(
          song: _results[i], queue: _results.skip(i + 1).toList()),
        childCount: _results.length,
      ),
    );
  }

  Widget _buildBrowseSliver() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_recentSearches.isNotEmpty) ...[
              const Text('Recent Searches',
                  style: TextStyle(color: Colors.white, fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._recentSearches.map((term) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.access_time,
                        color: AppColors.textMuted),
                    title: Text(term,
                        style: const TextStyle(color: Colors.white)),
                    trailing: IconButton(
                      icon: const Icon(Icons.close,
                          color: AppColors.textMuted, size: 18),
                      onPressed: () => _removeRecent(term),
                    ),
                    onTap: () => _performSearch(term),
                  )),
              const SizedBox(height: 24),
            ],
            const Text('Browse by Mood',
                style: TextStyle(color: Colors.white, fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: MoodType.values.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 12,
                mainAxisSpacing: 12, childAspectRatio: 1.6,
              ),
              itemBuilder: (context, i) {
                final mood = MoodType.values[i];
                return GestureDetector(
                  onTap: () => _searchByMood(mood),
                  child: Container(
                    decoration: BoxDecoration(
                      color: mood.color.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: mood.color.withValues(alpha: 0.5), width: 1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(mood.emoji,
                            style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 6),
                        Text(mood.label,
                            style: const TextStyle(color: Colors.white,
                                fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SongResultTile extends ConsumerWidget {
  final Song song;
  final List<Song> queue;
  const _SongResultTile({required this.song, required this.queue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 52, height: 52,
          child: song.coverUrl != null && song.coverUrl!.isNotEmpty
              ? Image.network(song.coverUrl!, fit: BoxFit.cover,
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
      trailing: Text(song.durationLabel,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
      onTap: () {
        ref.read(playerProvider.notifier).play(song, queue: queue);
        Navigator.pushNamed(context, '/player');
      },
    );
  }
}
