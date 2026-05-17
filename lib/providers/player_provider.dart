import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../models/song.dart';

class PlayerProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Song? _currentSong;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  List<Song> _queue = [];
  final List<Song> _recentlyPlayed = [];
  final List<Song> _playedHistory = [];
  bool _autoPlayNext = true;

  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  bool get hasSong => _currentSong != null;
  List<Song> get recentlyPlayed => List.unmodifiable(_recentlyPlayed);

  void setAutoPlayNext(bool value) {
    _autoPlayNext = value;
    notifyListeners(); // Atelier 7 pattern
  }

  double get progress {
    if (_currentSong == null || _currentSong!.duration.inMilliseconds == 0) {
      return 0.0;
    }
    return (_position.inMilliseconds / _currentSong!.duration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  PlayerProvider() {
    _audioPlayer.onPositionChanged.listen((pos) {
      _position = pos;
      notifyListeners();
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      if (_autoPlayNext) next(); // auto-advance respects the setting
    });
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });
  }

  /// Play a song. Pushes the outgoing song to history so previous() can go back.
  /// Pass pushToHistory: false when navigating backwards (previous()) to avoid
  /// re-adding a history song back into history.
  Future<void> play(Song song,
      {List<Song>? queue, bool pushToHistory = true}) async {
    if (pushToHistory && _currentSong != null &&
        _currentSong!.id != song.id) {
      _playedHistory.add(_currentSong!);
    }

    _currentSong = song;
    _position = Duration.zero;
    if (queue != null) _queue = List.of(queue);

    // Track recently played — move to front, cap at 10
    _recentlyPlayed.removeWhere((s) => s.id == song.id);
    _recentlyPlayed.insert(0, song);
    if (_recentlyPlayed.length > 10) _recentlyPlayed.removeLast();

    if (song.audioUrl != null && song.audioUrl!.isNotEmpty) {
      await _audioPlayer.play(UrlSource(song.audioUrl!));
      _isPlaying = true;
    } else {
      _isPlaying = false;
    }
    notifyListeners(); // Atelier 7 pattern
  }

  Future<void> togglePlayPause() async {
    if (_currentSong == null) return;
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
    // _isPlaying updated by onPlayerStateChanged listener
  }

  Future<void> seek(Duration to) async {
    await _audioPlayer.seek(to);
    _position = to;
    notifyListeners(); // Atelier 7 pattern
  }

  Future<void> next() async {
    if (_queue.isEmpty) return;
    final nextSong = _queue.removeAt(0);
    await play(nextSong, queue: _queue);
  }

  /// Go back to the previous song. If history is empty, restarts current song.
  Future<void> previous() async {
    if (_playedHistory.isEmpty) {
      await seek(Duration.zero);
      return;
    }
    final prevSong = _playedHistory.removeLast();
    if (_currentSong != null) {
      _queue.insert(0, _currentSong!);
    }
    await play(prevSong, pushToHistory: false);
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentSong = null;
    _isPlaying = false;
    _position = Duration.zero;
    _queue = [];
    notifyListeners(); // Atelier 7 pattern
  }

  void clearRecentlyPlayed() {
    _recentlyPlayed.clear();
    notifyListeners(); // Atelier 7 pattern
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
