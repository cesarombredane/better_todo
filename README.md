# Better Todo

A private Android todo, list, and scheduling application built with Flutter.
All data is stored locally in SQLite.

## Features

- Scheduled lists with a two-week agenda and monthly calendar
- Dated tasks with optional times, completion, editing, deletion, and ordering
- Dragging scheduled tasks to another day
- Regular todo lists with reorderable sections and todos
- One pinned list for quick access
- Simple password-locked lists with automatic relocking
- Dark-only interface and offline storage

## Run on an Android phone

Enable **Developer options > Wireless debugging** on an Android 11 or newer
phone. The phone and computer must be on the same local network.

For the first connection, select **Pair device with pairing code** and run:

```bash
adb pair <phone-ip>:<pairing-port>
```

Connect using the separate address shown on the main Wireless debugging screen:

```bash
adb connect <phone-ip>:<connection-port>
flutter run
```

Open the side menu to create and manage lists. Scheduled lists provide agenda
and calendar views; regular lists provide optional sections.

While Flutter is running, save a Dart file or press `r` for hot reload. Press
`R` for hot restart and `q` to stop.

For later sessions, pairing is normally unnecessary. Run `adb connect` with
the phone's current connection address, followed by `flutter run`.

## Build the APK

Check the phone's processor architecture:

```bash
adb shell getprop ro.product.cpu.abi
```

Build smaller APKs containing only one processor architecture each:

```bash
flutter build apk --release --split-per-abi
```

The APKs are created at:

```text
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
build/app/outputs/flutter-apk/app-x86_64-release.apk
```

Most modern Android phones report `arm64-v8a`; install the APK with the matching
name. Building without `--split-per-abi` creates a larger universal APK.
