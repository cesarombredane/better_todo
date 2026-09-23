# Documentation website

This folder is a separate VitePress project for Better Todo. Node is needed only for the website; Flutter and Android use their own toolchain.

## Install and run

Use Node.js 22 or newer and npm. From the repository root:

```bash
cd docs
npm ci
npm run dev
```

Open the local URL printed by VitePress, normally `http://127.0.0.1:5173`. Use `npm ci` for repeatable installation from the lockfile and `npm install` when intentionally changing dependencies.

## Build and preview

```bash
npm run build
npm run preview
```

The static output is `.vitepress/dist/`. Preview normally serves on `http://127.0.0.1:4173`; use the printed address if a port changes. The site is configured for serving at `/`. Publishing under a subpath requires a matching VitePress `base` setting. No deployment workflow is configured.

## Content ownership

| Source                             | Website route   |
| ---------------------------------- | --------------- |
| [Root README](../README.md)        | `/`             |
| [Architecture](../ARCHITECTURE.md) | `/architecture` |
| [Agent guide](../AGENTS.md)        | `/agents`       |
| [Development](development.md)      | `/development`  |
| [Database](database.md)            | `/database`     |
| [Behavior](behavior.md)            | `/behavior`     |
| This file                          | `/website`      |

The small `index.md`, `architecture.md`, and `agents.md` pages include root Markdown as the source of truth. Add guides as `docs/<name>.md` and add them to `.vitepress/config.mjs`. Source links use relative paths; the site translates documentation links to routes and code links to the GitHub repository. Local search is bundled with the site, and Mermaid blocks render diagrams.

VitePress cache, build output, and `node_modules/` are ignored. After editing the website, run `npm run build` and check navigation, search, and diagrams in preview. Run `flutter analyze` from the root as the app check.
