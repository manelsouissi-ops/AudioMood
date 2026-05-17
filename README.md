# AudioMood

A Flutter app that detects your mood and plays the perfect music to match it.

## Features

- **Mood Detection** — Camera-based mood analysis that picks a playlist tailored to how you feel
- **Music Player** — Full playback screen with progress bar, skip, shuffle, and repeat controls
- **Smart Playlists** — Playlists curated per mood (Happy, Sad, Relaxed, Energetic, Calm, Angry)
- **Favorites** — Save songs you love with a single tap
- **Auth Flow** — Sign up and log in with email and password

## Tech Stack

- **Flutter** 3.41.x / Dart 3.11.x
- **Provider** 6.x — state management (ChangeNotifier pattern)
- **Material 3** dark theme with purple/magenta accent

## Project Structure

```
lib/
├── data/
│   └── mock_data.dart          # Static songs and playlists
├── models/
│   ├── app_user.dart
│   ├── mood.dart               # MoodType enum + MoodResult
│   ├── song.dart
│   └── playlist.dart
├── providers/
│   ├── auth_provider.dart
│   ├── mood_provider.dart
│   ├── player_provider.dart
│   └── favorites_provider.dart
├── screens/
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── home_screen.dart
│   ├── player_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   └── placeholders/
│       ├── search_placeholder.dart
│       ├── profile_placeholder.dart
│       └── settings_placeholder.dart
├── theme/
│   └── app_theme.dart
├── widgets/
│   ├── main_scaffold.dart      # Bottom nav + drawer wrapper
│   └── app_drawer.dart
└── main.dart
```

## Getting Started

### Prerequisites

- Flutter SDK ≥ 3.0.0
- Android Studio / VS Code with Flutter extension
- Android emulator or physical device

### Run the app

```bash
flutter pub get
flutter run
```

## Roadmap

| Phase | Status | Description |
|-------|--------|-------------|
| 1 | ✅ Done | Navigation, screens, drawer, bottom nav |
| 2 | ✅ Done | Provider state management |
| 3 | 🔜 | SharedPreferences — persist login state |
| 4 | 🔜 | Firebase Auth + Firestore |
| 5 | 🔜 | Camera-based mood detection (ML) |
| 6 | 🔜 | Real audio playback |
| 7 | 🔜 | Search screen |
