---
name: tunnel-monitor-organization
description: >-
  Validate and maintain Tunnel Monitor monorepo folder structure (Private/Public/Universal),
  SemVer release folders, and path placement. Use when reorganizing files, adding releases,
  onboarding contributors, or checking structure compliance.
---

# Tunnel Monitor Organization

## When to use

- Reorganizing or adding files in Tunnel Monitor
- Creating GUI or core releases
- Onboarding contributors to the monorepo layout
- Validating structure before a PR or release

## Workflow

1. Read [`.cursor/rules/tunnel-monitor-folder-structure.mdc`](../../rules/tunnel-monitor-folder-structure.mdc).
2. Run validation from repo root:

```bash
bash Universal/scripts/validate-folder-structure.sh
```

3. For CI-strict mode:

```bash
TM_STRUCTURE_STRICT=1 bash Universal/scripts/validate-folder-structure.sh
```

4. If misplaced items are found, use `git mv` to canonical paths (see [reference.md](reference.md)). Never duplicate GUI source — Public copies via sync script only.

5. For a new GUI release (Private or Public):

- Bump `{Category}/VERSION`
- Add release block to `{Category}/datasets/bundle-manifest.json` with next `NN-vX.Y.Z` folder
- Update root `CHANGELOG.md` (Code / Data / Build-CI)
- Build to `{Category}/build/dist/`, archive to `{Category}/builds/releases/NN-vX.Y.Z/`
- Tag monorepo `vX.Y.Z` when shipping Public artifacts

## Quick placement guide

| Content | Category |
|---------|----------|
| Mac Studio install, payload, Swift GUI source | Private |
| Sanitized deploy bundles, public docs, tray-app | Public |
| monitor-engine, adapters, vendor-core scripts | Universal |

## Output

Report validation result, any misplaced paths, and proposed `git mv` commands. Do not leave files at legacy root paths.
