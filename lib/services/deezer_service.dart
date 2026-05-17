import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/song.dart';

// Atelier 10 pattern: GET to REST API, parse JSON response
class DeezerService {
  static const String _baseUrl = 'https://api.deezer.com/search/track';

  Future<List<Song>> searchTracks(String query, {int limit = 25}) async {
    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'q': query,
        'limit': limit.toString(),
      });

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Deezer search failed (${response.statusCode})');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map || decoded['data'] is! List) {
        throw Exception('Unexpected response from Deezer');
      }

      final tracks = decoded['data'] as List<dynamic>;
      final songs = <Song>[];

      for (final track in tracks) {
        if (track is! Map) continue;

        // Defensive field reads — never blind-cast
        final id = track['id'];
        final title = track['title'] as String? ?? '';
        final durationRaw = track['duration'];
        final preview = track['preview'] as String?;

        // Skip tracks with no playable preview
        if (preview == null || preview.isEmpty) continue;
        if (id == null || title.isEmpty) continue;

        final artistName =
            (track['artist'] is Map ? track['artist']['name'] : null)
                    as String? ??
                'Unknown';
        final coverUrl =
            (track['album'] is Map ? track['album']['cover_medium'] : null)
                as String?;
        final durationSec =
            durationRaw != null ? (durationRaw as num).toInt() : 0;

        songs.add(Song(
          id: id.toString(),
          title: title,
          artist: artistName,
          coverUrl: coverUrl,
          audioUrl: preview,
          duration: Duration(seconds: durationSec),
        ));
      }

      return songs;
    } on SocketException {
      throw Exception('Network error — check your connection');
    } on Exception {
      rethrow;
    }
  }
}
