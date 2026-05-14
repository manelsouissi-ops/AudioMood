import 'package:flutter/foundation.dart';
import '../models/song.dart';

class FavoritesProvider with ChangeNotifier {
  final List<Song> _favorites = [];

  List<Song> get favorites => List.unmodifiable(_favorites);
  int get count => _favorites.length;

  bool isFavorite(String songId) => _favorites.any((s) => s.id == songId);

  void toggle(Song song) {
    if (isFavorite(song.id)) {
      _favorites.removeWhere((s) => s.id == song.id);
    } else {
      _favorites.add(song);
    }
    notifyListeners(); // Atelier 7 pattern
  }

  void clear() {
    _favorites.clear();
    notifyListeners(); // Atelier 7 pattern
  }
}
