# AudioMood

AudioMood is a Flutter app that combines mood-based music discovery, authentication, and playback flows in a single mobile experience. The app boots through Firebase, uses Provider for state management, and organizes the UI around splash, onboarding, auth, home, search, favorites, profile, settings, mood scan, and player screens.

## What’s Included

- Firebase initialization with generated platform options
- Email/password authentication flow
- Mood detection flow with camera-based screens
- Music playback UI with a dedicated player screen
- Favorites, search, profile, and settings screens
- App-wide state management with `MultiProvider`
- Material design theme and reusable widgets

## Tech Stack

- Flutter 3.41.x / Dart 3.11.x
- Provider for app state
- Firebase Core, Auth, and Firestore
- Google Sign-In
- Image Picker for camera/media input
- Audioplayers for playback UI integration
- SharedPreferences for local persistence
- HTTP for remote API calls

## App Flow

The app starts in [lib/main.dart](lib/main.dart), initializes Firebase, and registers these providers at the root:

- `AuthProvider`
- `MoodProvider`
- `PlayerProvider`
- `FavoritesProvider`
- `SettingsProvider`

From there, routing takes the user through:

- Splash
- Onboarding
- Login / Sign Up / Forgot Password
- Home
- Camera Scan
- Mood Result
- Player
- Search
- Favorites
- Profile
- Settings

## Project Structure

```text
lib/
├── firebase_options.dart
├── main.dart
├── providers/
├── screens/
│   ├── auth/
│   └── mood/
├── services/
├── theme/
└── widgets/
```

Key files:

- [lib/main.dart](lib/main.dart) - app bootstrap, Firebase init, and route table
- [lib/services/mood_service.dart](lib/services/mood_service.dart) - mood-related logic
- [lib/services/firebase_service.dart](lib/services/firebase_service.dart) - Firebase helpers
- [lib/screens/home_screen.dart](lib/screens/home_screen.dart) - main user entry screen
- [lib/screens/player_screen.dart](lib/screens/player_screen.dart) - audio playback UI
- [lib/providers/auth_provider.dart](lib/providers/auth_provider.dart) - auth state

## Setup

### Prerequisites

- Flutter SDK installed and on your PATH
- A connected device, emulator, or simulator
- Firebase project configured for Android / iOS / web as needed

### Install Dependencies

```bash
flutter pub get
```

### Run the App

```bash
flutter run
```

## Firebase Notes

This project includes Firebase configuration files and generated options. If you create a new Firebase project or change platforms, regenerate the config so that [lib/firebase_options.dart](lib/firebase_options.dart) and the native platform files stay in sync.

## Configuration

If you change API endpoints or storage behavior, check the service files in [lib/services/](lib/services/) and the keys/constants used by the providers.

## Development Notes

- Keep app state changes inside the provider layer when possible.
- Add new screens through route registration in [lib/main.dart](lib/main.dart).
- Update the README whenever you add a major feature or change the launch flow.

## Status

The current codebase includes the main app shell, auth flow, mood flow, playback screen, search, favorites, profile, and settings. This README now reflects the whole project rather than only the initial scaffold.
