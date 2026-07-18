# Better Todo

An Android task and list application built with Flutter.

## Run on an Android phone

The phone and computer must be connected to the same local network. Wireless
debugging requires Android 11 or newer.

### First connection

1. On the phone, enable **Developer options** by tapping **Build number** seven
   times under **Settings > About phone**.
2. Open **Developer options > Wireless debugging** and enable it.
3. Select **Pair device with pairing code**.
4. In WSL, pair using the address and pairing port displayed by the phone:

```bash
adb pair <phone-ip>:<pairing-port>
```

5. Return to the main Wireless debugging screen and connect using its separate
   connection port:

```bash
adb connect <phone-ip>:<connection-port>
```

Check that Flutter detects the phone:

```bash
adb devices
flutter devices
```

If `adb pair` reports `unknown host service`, ensure the current Android SDK
version of ADB is selected:

```bash
export PATH="$HOME/Android/Sdk/platform-tools:$PATH"
hash -r
```

### Start development

Install dependencies and launch the app:

```bash
flutter pub get
flutter run
```

If multiple devices are available:

```bash
flutter run -d <device-id>
```

While Flutter is running:

- Save a Dart file or press `r` for hot reload.
- Press `R` for hot restart.
- Press `q` to stop.

For later sessions, pairing is normally unnecessary. Re-enable Wireless
debugging, use its current connection address, and run:

```bash
adb connect <phone-ip>:<connection-port>
flutter run
```

## Test and build

Run all local checks and build debug and release APKs:

```bash
./scripts/test_and_build.sh
```

To also run the integration test on the connected phone:

```bash
./scripts/test_and_build.sh --device <device-id>
```

Find the device ID with `flutter devices`.

Generated APKs:

```text
build/app/outputs/flutter-apk/app-debug.apk
build/app/outputs/flutter-apk/app-release.apk
```

Install the release APK manually with:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```
