import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _keyNotifications = 'audiomood:notifications_enabled';
  static const String _keyAutoPlayNext = 'audiomood:auto_play_next';
  static const String _keyAudioQuality = 'audiomood:audio_quality';

  bool _notificationsEnabled = true;
  bool _autoPlayNext = true;
  String _audioQuality = 'Normal';

  bool get notificationsEnabled => _notificationsEnabled;
  bool get autoPlayNext => _autoPlayNext;
  String get audioQuality => _audioQuality;

  // Atelier 8 pattern: SharedPreferences load on startup
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool(_keyNotifications) ?? true;
    _autoPlayNext = prefs.getBool(_keyAutoPlayNext) ?? true;
    _audioQuality = prefs.getString(_keyAudioQuality) ?? 'Normal';
    notifyListeners(); // Atelier 7 pattern
  }

  Future<void> setNotifications(bool value) async {
    _notificationsEnabled = value;
    notifyListeners(); // Atelier 7 pattern
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, value);
  }

  Future<void> setAutoPlayNext(bool value) async {
    _autoPlayNext = value;
    notifyListeners(); // Atelier 7 pattern
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoPlayNext, value);
  }

  Future<void> setAudioQuality(String value) async {
    _audioQuality = value;
    notifyListeners(); // Atelier 7 pattern
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAudioQuality, value);
  }
}
