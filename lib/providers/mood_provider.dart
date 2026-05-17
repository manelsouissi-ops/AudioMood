import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mood.dart';

// ── State ────────────────────────────────────────────────────────────────────

class MoodState {
  final MoodResult? current;
  final List<MoodResult> history;

  const MoodState({this.current, this.history = const []});

  bool get hasDetectedMood => current != null;
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class MoodNotifier extends Notifier<MoodState> {
  @override
  MoodState build() => const MoodState();

  void setMood(MoodType mood, double confidence) {
    final result = MoodResult(
      mood: mood,
      confidence: confidence,
      detectedAt: DateTime.now(),
    );
    state = MoodState(
      current: result,
      history: [result, ...state.history],
    );
  }

  void clear() => state = MoodState(history: state.history);
}

// ── Provider ─────────────────────────────────────────────────────────────────

final moodProvider = NotifierProvider<MoodNotifier, MoodState>(MoodNotifier.new);
