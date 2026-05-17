import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/song.dart';

// ── Notifier ─────────────────────────────────────────────────────────────────
// State is List<Song> — the list of favorited songs.

class FavoritesNotifier extends Notifier<List<Song>> {
  @override
  List<Song> build() => [];

  bool isFavorite(String songId) => state.any((s) => s.id == songId);

  void toggle(Song song) {
    debugPrint('[FAV] toggle called for song id=${song.id} title=${song.title}');
    if (isFavorite(song.id)) {
      state = state.where((s) => s.id != song.id).toList();
    } else {
      state = [...state, song];
    }
    debugPrint('[FAV] _favorites now has ${state.length} songs: ${state.map((s) => s.id).toList()}');
    _persistToCloud();
  }

  void clear() => state = [];

  void _persistToCloud() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    debugPrint('[FAV] persistToCloud: currentUser uid = $uid');
    if (uid == null) return;
    debugPrint('[FAV] persistToCloud: writing ${state.length} songs to Firestore');
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(
          {'favoriteSongs': state.map((s) => s.toMap()).toList()},
          SetOptions(merge: true),
        )
        .then((_) => debugPrint('[FAV] persistToCloud: Firestore write complete'))
        .catchError((Object e) => debugPrint('[FAV] persistToCloud ERROR: $e'));
  }

  Future<void> syncFromCloud() async {
    debugPrint('[FAV] syncFromCloud START, currentUser = ${FirebaseAuth.instance.currentUser?.uid}');
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

      debugPrint('[FAV] syncFromCloud: user doc exists=${userDoc.exists}, favoriteSongs field = ${userDoc.data()?['favoriteSongs']}');

      if (!userDoc.exists) return;
      final data = userDoc.data();
      if (data == null || data['favoriteSongs'] == null) return;

      final raw = data['favoriteSongs'];
      if (raw is! List || raw.isEmpty) return;

      final ids = raw
          .whereType<Map>()
          .map((m) => m['id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
      debugPrint('[FAV] parsed ${ids.length} favorite IDs: $ids');

      final cloudFavorites = raw
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

      state = cloudFavorites;
      debugPrint('[FAV] syncFromCloud DONE, _favorites now has ${state.length} songs');
    } catch (e, stack) {
      debugPrint('[FAV] syncFromCloud ERROR: $e');
      debugPrint('[FAV] stack: $stack');
    }
  }
}

// ── Provider ─────────────────────────────────────────────────────────────────

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, List<Song>>(FavoritesNotifier.new);
