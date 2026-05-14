import 'package:flutter/material.dart';

enum MoodType {
  happy,
  sad,
  angry,
  relaxed,
  energetic,
  calm;

  String get label => switch (this) {
        MoodType.happy => 'Happy',
        MoodType.sad => 'Sad',
        MoodType.angry => 'Angry',
        MoodType.relaxed => 'Relaxed',
        MoodType.energetic => 'Energetic',
        MoodType.calm => 'Calm',
      };

  String get emoji => switch (this) {
        MoodType.happy => '😊',
        MoodType.sad => '😢',
        MoodType.angry => '😠',
        MoodType.relaxed => '😌',
        MoodType.energetic => '⚡',
        MoodType.calm => '🧘',
      };

  Color get color => switch (this) {
        MoodType.happy => const Color(0xFFFFB300),
        MoodType.sad => const Color(0xFF42A5F5),
        MoodType.angry => const Color(0xFFE53935),
        MoodType.relaxed => const Color(0xFF66BB6A),
        MoodType.energetic => const Color(0xFFFF7043),
        MoodType.calm => const Color(0xFFAB47BC),
      };
}

class MoodResult {
  final MoodType mood;
  final double confidence;
  final DateTime detectedAt;

  const MoodResult({
    required this.mood,
    required this.confidence,
    required this.detectedAt,
  });

  String get confidencePercent => '${(confidence * 100).round()}%';
}
