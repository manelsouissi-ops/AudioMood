import 'package:flutter/foundation.dart';
import '../models/mood.dart';

class MoodProvider with ChangeNotifier {
  MoodResult? _current;
  final List<MoodResult> _history = [];

  MoodResult? get current => _current;
  List<MoodResult> get history => List.unmodifiable(_history);
  bool get hasDetectedMood => _current != null;

  void setMood(MoodType mood, double confidence) {
    _current = MoodResult(
      mood: mood,
      confidence: confidence,
      detectedAt: DateTime.now(),
    );
    _history.insert(0, _current!);
    notifyListeners(); // Atelier 7 pattern
  }

  void clear() {
    _current = null;
    notifyListeners(); // Atelier 7 pattern
  }
}
