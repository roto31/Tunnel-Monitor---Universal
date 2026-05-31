# Tunnel Monitor — Xcode project (app + widget)

Optional XcodeGen project that builds **Tunnel Monitor.app** with an embedded **WidgetKit** extension.

## Liquid Glass UI (macOS 26)

`LiquidGlassDesign.swift` applies `glassEffect`, `GlassEffectContainer`, and `.glass` button styles on **macOS 26+**, with material fallbacks on macOS 14–25. Respect **Reduce Transparency** in System Settings when testing.

## App icon (Liquid Glass, macOS 26)

Layered SVGs and a 1024 master live in `../TunnelMonitor/Resources/AppIcon/`. Open them in **Icon Composer**, save `AppIcon.icon` beside `AppIcon.icns`, and set the target **App Icon** to `AppIcon`. See `AppIcon/README.md`.

## Prerequisites

- macOS 14+
- Xcode + `xcodegen` (`brew install xcodegen`)

## Build

```bash
cd app/TunnelMonitorXcode
xcodegen generate
cd ../..
VERSION=1.1.0 bash build/build-app.sh
```

When XcodeGen is available, `build-app.sh` uses `xcodebuild` and embeds the widget. Otherwise it falls back to SwiftPM (menu bar + dashboard only, no widget).

## App Group

Both targets use `group.com.tunnel.monitor`. The main app writes `Library/tunnel-status.json` on each poll; the widget reads it.

Add the desktop widget from the macOS widget gallery after installing the app.
