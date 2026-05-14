import 'mood.dart';
import 'song.dart';

class Playlist {
  final String id;
  final String name;
  final MoodType? mood;
  final String? coverUrl;
  final List<Song> songs;

  const Playlist({
    required this.id,
    required this.name,
    this.mood,
    this.coverUrl,
    required this.songs,
  });

  Duration get totalDuration =>
      songs.fold(Duration.zero, (sum, s) => sum + s.duration);

  String get totalDurationLabel {
    final total = totalDuration;
    final h = total.inHours;
    final m = total.inMinutes % 60;
    if (h > 0) return '${h}h ${m}min';
    return '${m}min';
  }
}
