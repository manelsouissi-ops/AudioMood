class Song {
  final String id;
  final String title;
  final String artist;
  final String? coverUrl;
  final String? audioUrl;
  final Duration duration;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    this.coverUrl,
    this.audioUrl,
    required this.duration,
  });

  String get durationLabel {
    final m = duration.inMinutes;
    final s = duration.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
