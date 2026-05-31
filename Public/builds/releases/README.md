# Versioned release artifacts

Each **shipped SemVer** gets one numbered folder under `builds/releases/`. Folder names match
`datasets/bundle-manifest.json` (`01-v1.0.0`, `02-v1.1.0`, …).

## Layout

```
builds/releases/02-v1.1.0/
  bundle-manifest.json    # per-artifact dataRevision + contentSha256
  CHECKSUMS.sha256        # checksums for downloadable files
  Tunnel Monitor.app/
  Tunnel-Monitor-1.1.0.pkg   # when build-pkg.sh was run for this version
```

## Build & archive

```bash
cd Public
VERSION=1.1.0 bash build/build-app.sh
VERSION=1.1.0 bash build/build-pkg.sh

# Or archive an existing .app / .pkg without rebuilding:
bash build/archive-release.sh --version 1.0.0 \
  --app "build/dist/Tunnel Monitor.app"
```

Staging output for the next build remains in `build/dist/`. The archive step copies into
`builds/releases/<folder>/` so `dist/` can be overwritten without losing prior versions.

## Policy

- One SemVer string per unique embedded payload ([SemVer 2.0.0](https://semver.org/)).
- Bump **PATCH** (minimum) when bundled JSON, icons, or `Assets.car` change materially.
- Track **`dataRevision`** in `bundle-manifest.json`; do not reuse a version label for a different bundle.
- Never overwrite an existing release folder.
