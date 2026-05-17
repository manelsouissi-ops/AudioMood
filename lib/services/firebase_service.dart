import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mood.dart';
import '../models/playlist.dart';

// Atelier 9 pattern: FirebaseFirestore.instance, collection(), .get(), snapshot.docs.map()
class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetches playlists from Firestore WITHOUT loading songs subcollection.
  /// Songs are loaded lazily from Deezer using playlist.searchQuery.
  Future<List<Playlist>> fetchPlaylists() async {
    final snap = await _db.collection('playlists').get();
    final playlists = <Playlist>[];
    for (final doc in snap.docs) {
      final data = doc.data();

      MoodType? mood;
      try {
        final moodStr = data['mood'] as String?;
        if (moodStr != null) {
          mood = MoodType.values.firstWhere((m) => m.name == moodStr);
        }
      } catch (_) {
        mood = null;
      }

      final name = data['name'] as String? ?? '';
      final searchQuery = (data['searchQuery'] as String?)?.isNotEmpty == true
          ? data['searchQuery'] as String
          : null;

      playlists.add(Playlist(
        id: doc.id,
        name: name,
        mood: mood,
        coverUrl: (data['coverUrl'] as String?)?.isNotEmpty == true
            ? data['coverUrl'] as String
            : null,
        songs: const [], // populated lazily via DeezerService
        searchQuery: searchQuery,
      ));
    }
    return playlists;
  }

  Future<void> saveFavorites(String userId, List<String> songIds) async {
    await _db.collection('users').doc(userId).set(
      {'favoriteSongIds': songIds},
      SetOptions(merge: true),
    );
  }

  Future<List<String>> loadFavoriteSongIds(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return [];
    final data = doc.data();
    if (data == null) return [];
    final raw = data['favoriteSongIds'];
    if (raw == null) return [];
    return List<String>.from(raw as List);
  }
}
