# Agent working guide

These instructions apply throughout this repository. Read the root [README](README.md), [architecture](ARCHITECTURE.md), and relevant `docs/` pages before changing implementation. Check the source too: documentation may lag behind code.

## Working practices

- Preserve unrelated working-tree changes. Do not edit generated Flutter, Gradle, npm, or VitePress output.
- Keep the app offline and Android-focused unless the requested feature changes that scope. Do not add accounts, telemetry, remote storage, or sync incidentally.
- Keep SQLite creation and migrations in `AppDatabase`, reads and writes in `TodoRepository`, shared state and operations in `AppController`, and interface behavior in feature widgets. Explain intentional boundary changes in `ARCHITECTURE.md`.
- Preserve user data. Add versioned migrations for schema changes and validate both fresh creation and upgrade on disposable data. Never clear the user's app data as a migration workaround.
- Format changed Dart files and run `flutter analyze`. Use focused device checks when changing visible behavior. Report checks actually run and any blocker.

## Documentation ownership

| File                  | Update when                                                      |
| --------------------- | ---------------------------------------------------------------- |
| `README.md`           | Features, requirements, setup, or APK instructions change        |
| `ARCHITECTURE.md`     | Component boundaries, state flow, or platform integration change |
| `docs/behavior.md`    | User-visible rules or limitations change                         |
| `docs/database.md`    | Schema, migration, or data effects change                        |
| `docs/development.md` | Development and verification steps change                        |
| `docs/README.md`      | Documentation website setup or routes change                     |
| `AGENTS.md`           | This working guidance changes                                    |

Root Markdown files are authoritative. VitePress includes them rather than maintaining content copies. For website edits, run `npm run build` from `docs/`, and check navigation and search in local preview when a browser is available. Leave Git staging and commits to the repository owner.
