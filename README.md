# Oma20-20-20

A small Omarchy top-bar reminder for the 20-20-20 eye-care rule: every 20
minutes, look at something 20 feet away for 20 seconds.

The plugin is off by default. Click the eye icon with the left mouse button to
open its menu and use the switch. Right-click the icon to toggle reminders
without opening the menu. When a reminder arrives, it hides automatically after
20 seconds by default; turn off **Auto-hide** to keep it visible until you press
Escape. **Remember settings** keeps the reminder and auto-hide choices after a
shell restart or reboot and is off by default.

## Installation

Install from the Omarchy plugin marketplace with:

```bash
omarchy plugin add https://github.com/eithe/oma20-20-20.git --enable
```

The plugin is identified as `io.github.eithe.oma20-20-20` and is placed in the
center section of the bar by default. The timer starts only after reminders are
enabled; the first reminder appears 20 minutes later.

To install a local checkout for development (rerun after source changes):

```bash
./install.sh
```

To remove the local installation:

```bash
./uninstall.sh
```

## Development

The plugin has no external runtime dependencies. Its entry point is
`BarWidget.qml`; the reminder overlay lives in `tools/vision-break/`.

The repository uses the MIT license.
