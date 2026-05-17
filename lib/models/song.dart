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

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'artist': artist,
        'coverUrl': coverUrl,
        'audioUrl': audioUrl,
        'durationSeconds': duration.inSeconds,
      };

  factory Song.fromMap(Map<String, dynamic> map) => Song(
        id: map['id'] as String? ?? '',
        title: map['title'] as String? ?? '',
        artist: map['artist'] as String? ?? '',
        coverUrl: map['coverUrl'] as String?,
        audioUrl: map['audioUrl'] as String?,
        duration:
            Duration(seconds: (map['durationSeconds'] as num?)?.toInt() ?? 0),
      );
}
