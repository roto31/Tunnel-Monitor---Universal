# macOS CLI usage

Same commands as Linux — see [platform-linux/cli-usage.md](../platform-linux/cli-usage.md).

```bash
pip install -e ".[dev]"
sudo ln -sf "$(pwd)/scripts/uvpn" /usr/local/bin/uvpn
uvpn check
uvpn statistics
bash scripts/uvpn-tui
```

Config: `~/.config/uvpn/config.json`

Optional **uvpn-statusd** for mobile status over private overlay: [../deploy/status-portal.md](../deploy/status-portal.md), [../security/host-hardening-macos.md](../security/host-hardening-macos.md).
