# Termul

Flutter **TUI** (terminal UI) component kit — web-first preview, ready for Android & iOS.

Inspired by agent multiplexers like [herdr.dev](https://herdr.dev): sidebar spaces, agent status glyphs, panes, prompts, and monospace chrome.

## Repos

| Repo | Purpose |
|------|---------|
| [`TUI-Termul/termul`](https://github.com/TUI-Termul/termul) | Flutter source + live gallery |
| [`TUI-Termul/docs`](https://github.com/TUI-Termul/docs) | Design system & component docs |

## Quick start (web)

```bash
flutter pub get
flutter run -d chrome
```

Or serve a release build:

```bash
flutter build web
# open build/web/index.html via any static server
```

## What's included

- **Themes:** `mocha`, `phosphor`, `tokyo-night`
- **Components:** `TuiText`, `TuiButton`, `TuiInput`, `TuiBadge`, `TuiStatusDot`, `TuiBox`, `TuiSidebar`, `TuiTabs`, `TuiPane`
- **Screens:** component gallery + Herdr-style shell demo

## License

MIT
