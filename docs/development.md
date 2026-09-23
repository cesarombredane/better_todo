# Development workflow

Start with the [project README](../README.md) for toolchain setup and APK builds. Read [architecture](../ARCHITECTURE.md) before moving responsibilities between components.

## Commands

Run from the repository root:

```bash
flutter pub get
flutter analyze
flutter run
```

Run `flutter pub get` after a dependency change or on a fresh checkout. There is currently no `test/` suite. Use focused manual checks on a device or emulator for behavior changes, and distinguish those checks from static analysis. Format changed Dart files with `dart format <paths>`.

For documentation website changes, use the [website guide](README.md) and run `npm run build` from `docs/`. Review navigation and local search in preview when a browser is available.

## Change checklist

1. Inspect the relevant screen, controller, repository, and existing documentation.
2. Make the smallest coherent change without editing generated files or unrelated work.
3. Update [behavior](behavior.md) for user-visible changes, [database](database.md) for persistence changes, and [architecture](../ARCHITECTURE.md) for responsibility changes.
4. Run `flutter analyze` and relevant manual checks. For database changes, test fresh creation and upgrades using disposable data.
5. Review the diff and report what passed, what was not checked, and any remaining risk.

## Useful app checks

- Schedule a task, change its day or time, reorder tasks within a day, and inspect both agenda and calendar.
- Create regular and protected lists; add, reorder, and remove sections and tasks. Background the app and confirm protected lists relock.
- Edit subtasks and assignees, delete a non-owner person, then confirm their tasks belong to `Me`.
- Record and change today's check-in, restart, and confirm its calendar marker.
- Confirm destructive actions and list export with representative data.

Preserve real user data. Do not clear the app database or uninstall the app to make a migration pass. Android build output and local SDK paths remain untracked.
