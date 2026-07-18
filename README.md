# Better Todo

An Android-first task and list application built with Flutter. The current home
page displays `TEST`.

## Launch the app

Install the project dependencies:

```bash
flutter pub get
```

List available Android devices:

```bash
flutter devices
```

Launch the app on a connected phone or Android emulator:

```bash
flutter run
```

If several devices are available, select one explicitly:

```bash
flutter run -d <device-id>
```

While the app is running, save a Dart file in VS Code to hot reload it. In the
terminal, press `r` for hot reload, `R` for hot restart, and `q` to stop.

## Build the APK

Create an optimized release APK:

```bash
flutter build apk --release
```

The resulting file is:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Install it on a connected Android device:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

To create a development APK instead:

```bash
flutter build apk --debug
```

The development APK is written to:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## Check the project

Before building, run:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

The GitHub Actions workflow performs these checks, runs the Android integration
test, builds the release APK, and uploads it as the `better-todo-apk` artifact.
