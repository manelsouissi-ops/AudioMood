import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/song.dart';

class FavoritesProvider with ChangeNotifier {
  final List<Song> _favorites = [];

  List<Song> get favorites => List.unmodifiable(_favorites);
  int get count => _favorites.length;

  bool isFavorite(String songId) => _favorites.any((s) => s.id == songId);

  // NOTE: There is NO load() method and NO SharedPreferences in this class.
  // Favorites are only persisted to Firestore and synced via syncFromCloud().

  void toggle(Song song) {
    debugPrint('[FAV] toggle called for song id=${song.id} title=${song.title}');
    if (isFavorite(song.id)) {
      _favorites.removeWhere((s) => s.id == song.id);
    } else {
      _favorites.add(song);
    }
    debugPrint(
        '[FAV] _favorites now has ${_favorites.length} songs: ${_favorites.map((s) => s.id).toList()}');
    notifyListeners(); // Atelier 7 pattern
    _persistToCloud();
  }

  void clear() {
    _favorites.clear();
    notifyListeners(); // Atelier 7 pattern
  }

  /// Fire-and-forget: persist full Song objects to Firestore so they can be
  /// restored without a collectionGroup query (Deezer songs are not in Firestore).
  void _persistToCloud() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    debugPrint('[FAV] persistToCloud: currentUser uid = $uid');
    if (uid == null) return;
    debugPrint(
        '[FAV] persistToCloud: writing ${_favorites.length} songs to Firestore');
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(
          {'favoriteSongs': _favorites.map((s) => s.toMap()).toList()},
          SetOptions(merge: true),
        )
        .then((_) => debugPrint('[FAV] persistToCloud: Firestore write complete'))
        .catchError((Object e) =>
            debugPrint('[FAV] persistToCloud ERROR: $e'));
  }

  /// Called from splash after sign-in is confirmed, and after every login.
  /// Reads full Song maps from Firestore — no collectionGroup query needed.
  Future<void> syncFromCloud() async {
    debugPrint(
        '[FAV] syncFromCloud START, currentUser = ${FirebaseAuth.instance.currentUser?.uid}');
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('[FAV] syncFromCloud: no currentUser, aborting');
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      debugPrint(
          '[FAV] syncFromCloud: user doc exists=${userDoc.exists}, favoriteSongs field = ${userDoc.data()?['favoriteSongs']}');

      if (!userDoc.exists) return;
      final data = userDoc.data();
      if (data == null || data['favoriteSongs'] == null) return;

      final raw = data['favoriteSongs'];
      if (raw is! List || raw.isEmpty) return;

      final List<String> ids = raw
          .whereType<Map>()
          .map((m) => m['id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
      debugPrint('[FAV] parsed ${ids.length} favorite IDs: $ids');

      // Rebuild Song objects directly from stored maps — no Firestore query needed
      final List<Song> cloudFavorites = raw
          .whereType<Map>()
          .map((m) {
            try {
              return Song.fromMap(Map<String, dynamic>.from(m));
            } catch (_) {
              return null;
            }
          })
          .whereType<Song>()
          .toList();

      _favorites
        ..clear()
        ..addAll(cloudFavorites);

      notifyListeners(); // Atelier 7 pattern
      debugPrint(
          '[FAV] syncFromCloud DONE, _favorites now has ${_favorites.length} songs');
    } catch (e, stack) {
      debugPrint('[FAV] syncFromCloud ERROR: $e');
      debugPrint('[FAV] stack: $stack');
    }
  }
}
