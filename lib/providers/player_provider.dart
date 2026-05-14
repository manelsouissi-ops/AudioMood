import 'package:flutter/foundation.dart';
import '../models/song.dart';

class PlayerProvider with ChangeNotifier {
  Song? _currentSong;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  List<Song> _queue = [];

  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  bool get hasSong => _currentSong != null;

  double get progress {
    if (_currentSong == null || _currentSong!.duration.inMilliseconds == 0) {
      return 0.0;
    }
    return (_position.inMilliseconds / _currentSong!.duration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  void play(Song song, {List<Song>? queue}) {
    _currentSong = song;
    _isPlaying = true;
    _position = Duration.zero;
    if (queue != null) _queue = List.of(queue);
    notifyListeners(); // Atelier 7 pattern
  }

  void togglePlayPause() {
    if (_currentSong == null) return;
    _isPlaying = !_isPlaying;
    notifyListeners(); // Atelier 7 pattern
  }

  void seek(Duration to) {
    _position = to;
    notifyListeners(); // Atelier 7 pattern
  }

  void next() {
    if (_queue.isEmpty) return;
    final nextSong = _queue.removeAt(0);
    play(nextSong, queue: _queue);
  }

  void stop() {
    _currentSong = null;
    _isPlaying = false;
    _position = Duration.zero;
    _queue = [];
    notifyListeners(); // Atelier 7 pattern
  }
}
