import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/song.dart';

// ── State ────────────────────────────────────────────────────────────────────

class PlayerState {
  final Song? currentSong;
  final bool isPlaying;
  final Duration position;
  final List<Song> recentlyPlayed;

  const PlayerState({
    this.currentSong,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.recentlyPlayed = const [],
  });

  bool get hasSong => currentSong != null;

  double get progress {
    if (currentSong == null || currentSong!.duration.inMilliseconds == 0) {
      return 0.0;
    }
    return (position.inMilliseconds / currentSong!.duration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  // Uses a sentinel to allow explicitly nulling currentSong
  PlayerState copyWith({
    Object? currentSong = _sentinel,
    bool? isPlaying,
    Duration? position,
    List<Song>? recentlyPlayed,
  }) =>
      PlayerState(
        currentSong: currentSong == _sentinel
            ? this.currentSong
            : currentSong as Song?,
        isPlaying: isPlaying ?? this.isPlaying,
        position: position ?? this.position,
        recentlyPlayed: recentlyPlayed ?? this.recentlyPlayed,
      );
}

const _sentinel = Object();

// ── Notifier ─────────────────────────────────────────────────────────────────

class PlayerNotifier extends Notifier<PlayerState> {
  final ap.AudioPlayer _audioPlayer = ap.AudioPlayer();
  List<Song> _queue = [];
  final List<Song> _playedHistory = [];
  bool _autoPlayNext = true;

  @override
  PlayerState build() {
    _audioPlayer.onPositionChanged.listen((pos) {
      state = state.copyWith(position: pos);
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      if (_autoPlayNext) next();
    });
    _audioPlayer.onPlayerStateChanged.listen((audioState) {
      state = state.copyWith(isPlaying: audioState == ap.PlayerState.playing);
    });
    ref.onDispose(() => _audioPlayer.dispose());
    return const PlayerState();
  }

  void setAutoPlayNext(bool value) => _autoPlayNext = value;

  Future<void> play(Song song,
      {List<Song>? queue, bool pushToHistory = true}) async {
    if (pushToHistory &&
        state.currentSong != null &&
        state.currentSong!.id != song.id) {
      _playedHistory.add(state.currentSong!);
    }
    if (queue != null) _queue = List.of(queue);

    final recent = List<Song>.from(state.recentlyPlayed)
      ..removeWhere((s) => s.id == song.id);
    recent.insert(0, song);
    if (recent.length > 10) recent.removeLast();

    if (song.audioUrl != null && song.audioUrl!.isNotEmpty) {
      await _audioPlayer.play(ap.UrlSource(song.audioUrl!));
      state = state.copyWith(
        currentSong: song,
        isPlaying: true,
        position: Duration.zero,
        recentlyPlayed: recent,
      );
    } else {
      state = state.copyWith(
        currentSong: song,
        isPlaying: false,
        position: Duration.zero,
        recentlyPlayed: recent,
      );
    }
  }

  Future<void> togglePlayPause() async {
    if (!state.hasSong) return;
    if (state.isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  Future<void> seek(Duration to) async {
    await _audioPlayer.seek(to);
    state = state.copyWith(position: to);
  }

  Future<void> next() async {
    if (_queue.isEmpty) return;
    final nextSong = _queue.removeAt(0);
    await play(nextSong, queue: _queue);
  }

  Future<void> previous() async {
    if (_playedHistory.isEmpty) {
      await seek(Duration.zero);
      return;
    }
    final prevSong = _playedHistory.removeLast();
    if (state.currentSong != null) {
      _queue.insert(0, state.currentSong!);
    }
    await play(prevSong, pushToHistory: false);
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _queue = [];
    state = const PlayerState();
  }

  void clearRecentlyPlayed() {
    state = state.copyWith(recentlyPlayed: []);
  }
}

// ── Provider ─────────────────────────────────────────────────────────────────

final playerProvider =
    NotifierProvider<PlayerNotifier, PlayerState>(PlayerNotifier.new);
