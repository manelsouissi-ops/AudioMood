# AudioMood

AudioMood is a Flutter mini-project that combines mood detection, music search, authentication, persistence, and playback in one app. The codebase now uses Riverpod at the root, Firebase for backend services, Deezer for music search, and a simple chart to visualize recent detected moods.

## Criterion Mapping

### 1. Architecture and Code Quality

- Riverpod is used consistently through `ProviderScope` and `NotifierProvider` state classes.
- The project now exposes a clearer `core/features/models/widgets` layer under `lib/core/` for shared structure.
- Reusable widgets are factored out for the app shell, drawer, and mood chart.
- Empty-list and network failure cases are handled defensively so the app does not crash on missing data.

### 2. UI and UX

- The app uses a dark Material theme with consistent colors and spacing.
- Loading states are present in playlist and authentication flows.
- Snackbars are shown for empty results and user-facing errors.
- The mood result page now includes a small chart to make the experience more informative.

### 3. Data and API Integration

- Firebase Core initializes the app.
- Firebase Auth handles sign up, login, Google sign-in, and password reset.
- Firestore stores user and playlist data.
- Deezer is used as the music API backend for track search.
- SharedPreferences is used for local settings persistence.
- Mood history is visualized locally from the Riverpod state.

### 4. Demo, Mastery, and Documentation

- The app has a complete route flow from splash to home, mood detection, search, favorites, profile, and settings.
- The README documents the architecture, dependencies, flow, and evaluation criteria.
- The code changes now make it easier to explain the backend, state management, and persistence choices during a live demo.

## What’s Included

- Firebase initialization with generated platform options
- Email/password and Google authentication flow
- Mood detection flow with camera-based screens
- Mood result screen with playlist launch and chart visualization
- Music playback UI with a dedicated player screen
- Favorites, search, profile, and settings screens
- App-wide state management with Riverpod
- Material design theme and reusable widgets

## Tech Stack

- Flutter 3.41.x / Dart 3.11.x
- Riverpod for app state
- Firebase Core, Auth, and Firestore
- Google Sign-In
- Image Picker for camera/media input
- Audioplayers for playback UI integration
- SharedPreferences for local persistence
- HTTP for remote API calls

## Project Structure

```text
lib/
├── core/
│   ├── features/
│   │   └── mood/
│   │       └── presentation/widgets/
│   ├── models/
│   ├── theme/
│   └── widgets/
├── models/
├── providers/
├── screens/
├── services/
└── main.dart
```

Key files:

- [lib/main.dart](lib/main.dart) - app bootstrap, Firebase init, and route table
- [lib/core/theme/app_theme.dart](lib/core/theme/app_theme.dart) - shared theme and colors
- [lib/core/widgets/main_scaffold.dart](lib/core/widgets/main_scaffold.dart) - reusable authenticated shell
- [lib/core/features/mood/presentation/widgets/mood_history_chart.dart](lib/core/features/mood/presentation/widgets/mood_history_chart.dart) - mood visualization
- [lib/providers/auth_provider.dart](lib/providers/auth_provider.dart) - auth state
- [lib/providers/mood_provider.dart](lib/providers/mood_provider.dart) - mood state
- [lib/services/firebase_service.dart](lib/services/firebase_service.dart) - Firestore helper
- [lib/services/deezer_service.dart](lib/services/deezer_service.dart) - music API client

## Run

```bash
flutter pub get
flutter run
```

## Notes for Evaluation

- The app satisfies the required authentication space with simple forms plus Google sign-in.
- The backend/frontend communication requirement is covered by Firebase and Deezer API calls.
- Persistence is justified by using Firestore online and SharedPreferences locally.
- The chart is intentionally simple so it can be demonstrated clearly in a mini-project review.
