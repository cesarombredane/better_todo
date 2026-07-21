# Better Todo

A private, offline Android application for scheduling tasks, organizing lists,
and recording a small daily mental-health check-in. It is built with Flutter
and distributed as an APK.

The application is intended for personal use. It has no account, server,
analytics, advertisements, or cloud synchronization. All application data is
stored locally on the phone in SQLite.

## Current status

The initial application is feature-complete and ready for daily use. Future
work will focus on fixes and improvements discovered while using it.

## Features

### Schedule

- One permanent `Schedule` list, pinned by default
- Two-week agenda and monthly calendar views
- Dated tasks with an optional time
- Reorderable tasks within a day
- Calendar marker for the current day
- Task validation with confirmation and permanent deletion

### Todos and information lists

- Regular lists for todos without a date
- Optional reorderable sections within a list
- Reorderable lists, sections, and todos
- One list can be pinned at a time
- Password-protected information lists without completion checkboxes
- One global unlock session for every protected list
- Automatic relocking when the application goes into the background

### Task details

- Required title of up to 50 characters
- Optional longer description
- Unlimited subtasks that can be edited, removed, and marked as done
- Subtasks displayed and directly checkable from the main list
- Optional scheduled time
- Assignment to `Me` or another locally managed person
- People can be created and deleted from the navigation drawer
- Deleting a person reassigns their tasks to `Me`

### Proud of me

- One daily check-in available from the app bar
- Green happy, yellow neutral, and red sad answers
- The current day's answer can be changed
- Past answers are displayed on the monthly calendar

### Interface

- Android-only application
- Dark mode only
- Centralized dark-grey, light-grey, and pastel-yellow color palette
- Custom yellow launcher icon
- Touch-friendly controls and confirmation dialogs for destructive actions

## Data and privacy

The application works completely offline. Lists, tasks, subtasks, people,
password settings, and daily check-ins are stored in the local
`better_todo.db` SQLite database.

Locked lists provide a simple privacy barrier inside the application. The
password and locked-list contents are not cryptographically encrypted and
should not be used for highly sensitive information.

Task validation and confirmed deletions are permanent. Because there is no
cloud synchronization, the application database should be backed up separately
if the data becomes important.

## Technology

- Flutter and Dart for the application and interface
- Material widgets for Android UI behavior
- `sqflite` for the local SQLite database
- Gradle for the Android build and APK packaging

Only the dependencies currently used by the application are included.

## Architecture

The project uses a small layered structure:

```text
lib/
├── main.dart                       Application entry point
├── app/
│   ├── better_todo_app.dart       Root Material application
│   └── app_controller.dart        UI state and application operations
├── data/
│   ├── local/app_database.dart    SQLite schema and migrations
│   ├── models/todo_models.dart    Application data models
│   └── repositories/
│       └── todo_repository.dart   Database reads and writes
├── features/
│   ├── home/                      Main screen and navigation drawer
│   ├── regular/                   Regular and protected lists
│   └── schedule/                  Agenda and calendar views
├── theme/                         Shared colors and Flutter theme
└── widgets/                       Shared dialogs and display widgets
```

The interface calls `AppController`, which keeps the current UI state and
coordinates operations. `TodoRepository` contains SQLite queries, while
`AppDatabase` owns database creation and versioned migrations. Widgets do not
execute SQL directly.

The `android/` directory contains the native Android wrapper, Gradle build
configuration, launcher icon, splash styling, and the minimal Flutter activity
used to package and launch the Dart application.

## Local database

The main tables are:

- `todo_lists` for scheduled, regular, locked, and pinned lists
- `list_sections` for grouping regular todos
- `scheduled_todos` and `regular_todos` for the two task types
- `todo_subtasks` for subtasks belonging to either task type
- `persons` for task assignment, including the protected `Me` entry
- `daily_pride` for one mental-health check-in per day
- `app_settings` for the local password setting

Database migrations run automatically when a newer application version opens
an existing database.

## Development checks

Install declared Dart dependencies after changing `pubspec.yaml`:

```bash
flutter pub get
```

Check the source code before building:

```bash
flutter analyze
```

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
