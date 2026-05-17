import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── State ────────────────────────────────────────────────────────────────────

class SettingsState {
  final bool notificationsEnabled;
  final bool autoPlayNext;
  final String audioQuality;

  const SettingsState({
    this.notificationsEnabled = true,
    this.autoPlayNext = true,
    this.audioQuality = 'Normal',
  });

  SettingsState copyWith({
    bool? notificationsEnabled,
    bool? autoPlayNext,
    String? audioQuality,
  }) =>
      SettingsState(
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        autoPlayNext: autoPlayNext ?? this.autoPlayNext,
        audioQuality: audioQuality ?? this.audioQuality,
      );
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class SettingsNotifier extends Notifier<SettingsState> {
  static const String _keyNotifications = 'audiomood:notifications_enabled';
  static const String _keyAutoPlayNext = 'audiomood:auto_play_next';
  static const String _keyAudioQuality = 'audiomood:audio_quality';

  @override
  SettingsState build() => const SettingsState(); // default values until load()

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      notificationsEnabled: prefs.getBool(_keyNotifications) ?? true,
      autoPlayNext: prefs.getBool(_keyAutoPlayNext) ?? true,
      audioQuality: prefs.getString(_keyAudioQuality) ?? 'Normal',
    );
  }

  Future<void> setNotifications(bool value) async {
    state = state.copyWith(notificationsEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, value);
  }

  Future<void> setAutoPlayNext(bool value) async {
    state = state.copyWith(autoPlayNext: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoPlayNext, value);
  }

  Future<void> setAudioQuality(String value) async {
    state = state.copyWith(audioQuality: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAudioQuality, value);
  }
}

// ── Provider ─────────────────────────────────────────────────────────────────

final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
