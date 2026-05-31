# Private release artifacts

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

## Policy

- One SemVer string per unique embedded payload ([SemVer 2.0.0](https://semver.org/)).
- Bump **PATCH** (minimum) when bundled JSON, icons, or `Assets.car` change materially.
- Track **`dataRevision`** in `bundle-manifest.json`; do not reuse a version label for a different bundle.
- Never overwrite an existing release folder; create the next sequence number instead.
