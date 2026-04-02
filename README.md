# Meeting Cost Clock

Meeting Cost Clock is a Flutter app for iOS, Android, and web that turns a meeting into a live cost meter.

## What it does

- Calculates meeting burn rate from attendee count and average annual salary
- Converts annual salary into hourly, per-minute, and per-second cost
- Animates the live total like a rolling odometer or gas-pump display
- Lets you push the timer ahead if the meeting started before the clock did

## Run locally

```bash
flutter pub get
flutter run
```

To open the iOS project in Xcode, use:

```bash
open ios/Runner.xcworkspace
```

## Web deployment on Vercel

This repo includes a `vercel.json` config plus helper scripts under `scripts/` so Vercel can:

1. install a pinned Flutter SDK
2. enable Flutter web
3. build the app to `build/web`
4. serve the Flutter web output as a static site

For local validation before deployment:

```bash
flutter build web --release
```

## Tests

```bash
flutter analyze
flutter test
```
