# uvpn releases

## Current

| Version | Tag | Notes |
|---------|-----|-------|
| 0.1.0 | `uvpn-v0.1.0` | Initial Universal product — Python engine, 4 adapters, CLI/TUI/GTK/Swift |

Download from [GitHub Releases](https://github.com/roto31/Tunnel-Monitor---Universal/releases).

## Install from source

```bash
git clone https://github.com/roto31/Tunnel-Monitor---Universal.git
cd Tunnel-Monitor---Universal
git checkout uvpn-v0.1.0   # when tagged
python3 -m venv .venv && source .venv/bin/activate
pip install -e ".[dev]"
uvpn init-config
```

## Legacy bash macOS releases

Pre-uvpn `.pkg` and `.app.zip` builds: [legacy/RELEASES.md](legacy/RELEASES.md).
