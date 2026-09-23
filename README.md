# Better Todo

Better Todo is a private, offline Android app for scheduled tasks, ordinary and protected lists, and a daily "Proud of me" check-in. It is built with Flutter and stores data on the device in SQLite. It has no account, server, analytics, advertising, or cloud sync.

## Features

- A permanent Schedule list with a two-week agenda, monthly calendar, optional task times, and task ordering within each day.
- Regular lists with optional sections, drag ordering, and one pinned list at a time. Protected information lists share an unlock session that closes when the app is backgrounded.
- Tasks with a title, optional description, subtasks, and a locally managed assignee. Deleting a person reassigns their tasks to `Me`.
- A daily "Proud of me" answer (happy, neutral, or sad) shown on the calendar.
- A dark Android interface and plain-text list export.

See [behavior rules](docs/behavior.md) for precise user-visible rules and limitations.

## Privacy and data

Lists, tasks, subtasks, people, the password setting, and check-ins live in the local `better_todo.db` database. Protected lists are an in-app privacy barrier; their password and contents are **not encrypted**. Use device protection and backups for important data. Confirmed deletions are permanent. See the [database guide](docs/database.md).

## Requirements

- Flutter with a Dart SDK compatible with `pubspec.yaml` (currently Dart 3.12.2 or newer within the declared major version)
- Android SDK and a connected Android device or emulator
- Node.js 22 or newer and npm only for the documentation website

## Develop and run

```bash
flutter pub get
flutter analyze
flutter run
```

For an Android 11+ phone over Wi-Fi, enable **Developer options > Wireless debugging** and keep the phone and computer on the same network. On the first connection, choose **Pair device with pairing code**:

```bash
adb pair <phone-ip>:<pairing-port>
adb connect <phone-ip>:<connection-port>
flutter run
```

The pairing and connection ports are different. Later sessions normally need only `adb connect` and `flutter run`. While Flutter runs, press `r` for hot reload, `R` for hot restart, and `q` to stop.

## Build an APK

```bash
adb shell getprop ro.product.cpu.abi
flutter build apk --release --split-per-abi
```

Pick the APK matching the phone architecture from `build/app/outputs/flutter-apk/`. A build without `--split-per-abi` produces a larger universal APK. The Android release build currently uses debug signing; inspect signing before wider distribution.

## Project layout

| Path                         | Responsibility                               |
| ---------------------------- | -------------------------------------------- |
| `lib/app/`                   | Root Flutter app and shared controller       |
| `lib/data/`                  | Models, SQLite lifecycle, repository queries |
| `lib/features/`              | Home, regular lists, schedule screens        |
| `lib/theme/`, `lib/widgets/` | Shared presentation                          |
| `android/`                   | Android host and build configuration         |
| `docs/`                      | Guides and VitePress website                 |

Read [ARCHITECTURE.md](ARCHITECTURE.md) for component boundaries, [development](docs/development.md) for contribution checks, [AGENTS.md](AGENTS.md) for agent guidance, and [docs/README.md](docs/README.md) to run the documentation site.
