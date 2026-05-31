# Releasing Tunnel Monitor — Universal (macOS)

## Version sources

| File | Purpose |
|------|---------|
| [`bundle-manifest.json`](bundle-manifest.json) | Cross-category index: `artifactVersion` + `coreVersion` |
| [`Public/VERSION`](Public/VERSION) | Public GUI artifact SemVer |
| [`Private/VERSION`](Private/VERSION) | Private GUI artifact SemVer |
| [`Public/datasets/bundle-manifest.json`](Public/datasets/bundle-manifest.json) | Public release folder index + `dataRevision` |
| [`Private/datasets/bundle-manifest.json`](Private/datasets/bundle-manifest.json) | Private release folder index |
| [`Universal/vendor/core/VERSION`](Universal/vendor/core/VERSION) | Core engine version |

**Rule:** One SemVer per downloadable artifact. Any material change to embedded
`wizard-fields.json`, icons, or `Assets.car` requires at least a **PATCH** bump
and a new `dataRevision` entry.

## PR / release checklist

- [ ] Files placed under correct category folder (`Private/`, `Public/`, `Universal/`)
- [ ] No production secrets or real topology in `Public/`
- [ ] New release uses next `NN-vX.Y.Z` folder (never overwrite)
- [ ] `dataRevision` updated if bundled data changed
- [ ] [`CHANGELOG.md`](CHANGELOG.md) entry with Code / Data / Build-CI category
- [ ] `bash Universal/scripts/validate-folder-structure.sh` passes (CI uses `TM_STRUCTURE_STRICT=1`)

## Maintainer workflow

### 1. Bump version

1. Set `artifactVersion` in root `bundle-manifest.json`.
2. Update `Public/VERSION` and/or `Private/VERSION`.
3. Add a release block to `Public/datasets/bundle-manifest.json` (`folder`: `NN-vX.Y.Z`).
4. Update [`CHANGELOG.md`](CHANGELOG.md).

### 2. Build on macOS

```bash
cd Public
VERSION=X.Y.Z TM_SKIP_LIQUID_GLASS=1 bash build/build-pkg.sh
```

Outputs:

- `Public/build/dist/Tunnel Monitor.app`
- `Public/build/dist/Tunnel-Monitor-X.Y.Z.pkg`
- `Public/builds/releases/NN-vX.Y.Z/` (when archive step succeeds)

Unsigned builds adhoc-sign the `.app` (required for `/Applications` launch).
Set `DEVELOPER_ID_*` and Apple notary env vars for signed/notarized releases.

### 3. Tag and push

```bash
git tag -a vX.Y.Z -m "Release vX.Y.Z"
git push origin main
git push origin vX.Y.Z
```

### 4. GitHub Actions (automated)

Workflow [`.github/workflows/release.yml`](.github/workflows/release.yml) runs on `v*` tags:

- Builds from `Public/build/`
- Uploads `.pkg`, `.app.zip`, and `CHECKSUMS.sha256`
- Creates a GitHub Release with generated notes

Manual dispatch: **Actions → Release macOS app → Run workflow** (optional version input).

### 5. Required secrets (signed releases only)

| Secret | Purpose |
|--------|---------|
| `MACOS_CERT_P12_BASE64` | Developer ID cert |
| `MACOS_CERT_P12_PASSWORD` | Cert export password |
| `DEVELOPER_ID_APPLICATION` | Codesign `.app` |
| `DEVELOPER_ID_INSTALLER` | Sign `.pkg` |
| `APPLE_ID`, `APPLE_TEAM_ID`, `APPLE_APP_SPECIFIC_PASSWORD` | Notarization |

Unsigned CI builds work without secrets (adhoc-signed `.app`, unsigned `.pkg`).

## Operator install

See [`RELEASES.md`](RELEASES.md).
