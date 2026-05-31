# Showcase List Test

A simple Flutter posts app built as a clean architecture starter project. The app fetches posts from JSONPlaceholder, caches remote responses with Dio, stores parsed data locally with Hive CE for offline support, and uses BLoC/Cubit for presentation state.

## Features

- Posts list from `https://jsonplaceholder.typicode.com/posts`
- Layered clean architecture: `data`, `domain`, and `presentation`
- Dio remote client with Hive-backed Dio response cache
- Hive CE local storage for parsed posts and theme preference
- Offline fallback using locally cached posts
- Pull-to-refresh support
- Light, dark, and system theme mode from the Settings page
- Unit and widget tests for models, repositories, BLoC/Cubit, and UI states

## Project Structure

```text
lib/
  app/                  App widget, routes, and dependency bootstrap
  core/                 Shared constants, Dio setup, errors, storage helpers
  features/
    posts/
      data/             Remote/local data sources, models, repository impl
      domain/           Entities, repository contracts, use cases
      presentation/     BLoC, pages, and widgets
    settings/           Theme persistence, ThemeCubit, settings page
    widgets/            Shared presentation widgets
  main.dart             Flutter entry point
```

## Requirements

- Flutter SDK with Dart `^3.9.2`
- Android Studio or Android SDK for Android builds
- Xcode and CocoaPods for iOS builds on macOS

Check your local setup with:

```sh
flutter doctor
```

## Install Dependencies

```sh
flutter pub get
```

## Run The App

List available devices:

```sh
flutter devices
```

Run the production flavor on the selected/default device:

```sh
flutter run --flavor production --dart-define=APP_FLAVOR=production
```

Run the tenant flavor on the selected/default device:

```sh
flutter run --flavor tenant --dart-define=APP_FLAVOR=tenant
```

Run a flavor on a specific device:

```sh
flutter run -d <device-id> --flavor tenant --dart-define=APP_FLAVOR=tenant
```

VS Code users can choose one of the configured launch targets from Run and Debug:

- `Production`
- `Tenant`
- `Production Profile`
- `Tenant Profile`
- `Production Release`
- `Tenant Release`

## Flavors

The app currently supports two flavors:

| Flavor | Android application ID | iOS bundle ID | App name |
| --- | --- | --- | --- |
| `production` | `com.example.showcase_list_test` | `com.example.showcaseListTest` | `Showcase List Test` |
| `tenant` | `com.example.showcase_list_test.tenant` | `com.example.showcaseListTest.tenant` | `Showcase List Test Tenant` |

Both flavors currently use the same JSONPlaceholder API. Runtime Flutter configuration is selected with `APP_FLAVOR`.

Production:

```sh
flutter run --flavor production --dart-define=APP_FLAVOR=production
```

Tenant:

```sh
flutter run --flavor tenant --dart-define=APP_FLAVOR=tenant
```

## Quality Checks

Analyze the project:

```sh
flutter analyze
```

Run all tests:

```sh
flutter test
```

## Build Android

Build a production release APK:

```sh
flutter build apk --flavor production --release --dart-define=APP_FLAVOR=production
```

Build a tenant release APK:

```sh
flutter build apk --flavor tenant --release --dart-define=APP_FLAVOR=tenant
```

APK outputs are usually created under:

```text
build/app/outputs/flutter-apk/
```

Build a production Android App Bundle for Play Store distribution:

```sh
flutter build appbundle --flavor production --release --dart-define=APP_FLAVOR=production
```

Build a tenant Android App Bundle for Play Store distribution:

```sh
flutter build appbundle --flavor tenant --release --dart-define=APP_FLAVOR=tenant
```

AAB outputs are usually created under:

```text
build/app/outputs/bundle/
```

Before publishing, update the Android `applicationId` and configure a real release signing key in `android/app/build.gradle.kts`.

## Build iOS

Install iOS pods if needed:

```sh
cd ios
pod install
cd ..
```

Build a production iOS release app:

```sh
flutter build ios --flavor production --release --dart-define=APP_FLAVOR=production
```

Build a tenant iOS release app:

```sh
flutter build ios --flavor tenant --release --dart-define=APP_FLAVOR=tenant
```

Build an unsigned production iOS release app for local/archive workflows:

```sh
flutter build ios --flavor production --release --no-codesign --dart-define=APP_FLAVOR=production
```

Build an unsigned tenant iOS release app for local/archive workflows:

```sh
flutter build ios --flavor tenant --release --no-codesign --dart-define=APP_FLAVOR=tenant
```

For App Store/TestFlight distribution, open the iOS workspace in Xcode and configure signing, bundle identifier, team, capabilities, and archive/export settings:

```sh
open ios/Runner.xcworkspace
```

## Notes

- `dio_cache_interceptor_hive_store` is used to match the Dio + Hive cache requirement. Pub currently marks that package as discontinued in favor of newer cache-store packages, so consider migrating if starting a production app.
- The current Android release config still uses debug signing from the Flutter template. Replace it before distributing a release build.
