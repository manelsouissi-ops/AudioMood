import '../models/mood.dart';
import '../models/playlist.dart';
import '../models/song.dart';

class MockData {
  static final List<Song> _songs = [
    const Song(
      id: 's0',
      title: 'Good as Hell',
      artist: 'Lizzo',
      duration: Duration(minutes: 3, seconds: 45),
    ),
    const Song(
      id: 's1',
      title: 'Levitating',
      artist: 'Dua Lipa',
      duration: Duration(minutes: 3, seconds: 24),
    ),
    const Song(
      id: 's2',
      title: 'Blinding Lights',
      artist: 'The Weeknd',
      duration: Duration(minutes: 3, seconds: 20),
    ),
    const Song(
      id: 's3',
      title: 'Someone Like You',
      artist: 'Adele',
      duration: Duration(minutes: 4, seconds: 45),
    ),
    const Song(
      id: 's4',
      title: 'Weightless',
      artist: 'Marconi Union',
      duration: Duration(minutes: 8, seconds: 8),
    ),
    const Song(
      id: 's5',
      title: 'Eye of the Tiger',
      artist: 'Survivor',
      duration: Duration(minutes: 4, seconds: 5),
    ),
  ];

  static final List<Playlist> _playlists = [
    Playlist(
      id: 'p0',
      name: 'Happy Vibes',
      mood: MoodType.happy,
      songs: [_songs[0], _songs[1], _songs[2]],
    ),
    Playlist(
      id: 'p1',
      name: 'Chill Out',
      mood: MoodType.sad,
      songs: [_songs[3], _songs[4]],
    ),
    Playlist(
      id: 'p2',
      name: 'Sunset Lounge',
      mood: MoodType.relaxed,
      songs: [_songs[1], _songs[4]],
    ),
    Playlist(
      id: 'p3',
      name: 'Pump It Up',
      mood: MoodType.energetic,
      songs: [_songs[5], _songs[2]],
    ),
  ];

  static List<Song> get allSongs => List.unmodifiable(_songs);
  static List<Playlist> get playlists => List.unmodifiable(_playlists);
  static List<Song> get recentlyPlayed => _songs.take(2).toList();

  static Playlist? playlistForMood(MoodType mood) {
    try {
      return _playlists.firstWhere((p) => p.mood == mood);
    } catch (_) {
      return null;
    }
  }
}
