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
flutter run -d web-server --web-port=5480 --web-hostname=localhost --no-web-resources-cdn
```

Open http://localhost:5480

## App flow (mobile)

1. **Onboarding** — what Termul is (agents live on a host you SSH into)
2. **Home** — empty state if no SSH yet; otherwise list of hosts
3. **Add SSH** — form: label, IP/host, port, username, password → save & connect
4. **Terminal** — live session with tabs (`+` to add), output pane, chat/prompt bar

SSH connect is **simulated** in this UI preview so you can walk the flow on web. Wire a real PTY/SSH client next for production.

Gallery of TUI components remains under **COMPONENTS** on the home header.

## What's included

- **Themes:** `oci` (default — Refero Outsource Consultants: bone + indigo), `mocha`, `phosphor`, `tokyo-night`
- **Fonts (bundled substitutes):** Space Grotesk ≈ PP Neue Montreal, JetBrains Mono ≈ GT America Mono
- **Components:** `TuiText`, `TuiButton`, `TuiInput`, `TuiBadge`, `TuiStatusDot`, `TuiBox`, `TuiSidebar`, `TuiTabs`, `TuiPane`
- **Screens:** component gallery + Herdr-style shell demo

Style reference: [Outsource Consultants on Refero](https://styles.refero.design/style/16be276a-d8ce-484e-8f7a-cbbb09f717f7)


## License

MIT
