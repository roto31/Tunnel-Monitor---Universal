# Universal VPN Monitor (uvpn)

**Connected on screen is not the same as reachable for work.**

---

## The afternoon everyone remembers

Picture a Tuesday that should have been ordinary.

**Maya** is a contract project manager on a **MacBook** at home. **GlobalProtect** is green in the menu bar; a client demo is in twenty minutes. She opens the project share and gets spinning beachballs—not a password prompt, not a polite error, just nothing. She reboots, reconnects VPN, still nothing. Forty-five minutes later she learns the tunnel was “up” while only a slice of routes were pushed—a **split-tunnel** policy IT changed last month. Maya did nothing wrong. The UI did not lie; it did not tell the whole story.

Same week, different building: **Jordan** is a graduate student on **Ubuntu**, using the university **Pulse/Ivanti** client to reach a lab file share for thesis data. The client says connected. `ping` to the lab subnet does not answer. Three days on a ticket. The fix is a **Trusted Server** entry missing on a rebuilt laptop image—not mysterious gremlins.

**Alex** freelances across two clients—**FortiClient** for one, **Pulse** for another, on the same **Mac**. Alex is not confused about credentials; Alex is tired of being the help desk for their own livelihood. Every new client means another icon, another policy, another “it works on my machine” call.

On **iPhone**, Alex sometimes checks email over a client VPN profile—but **uvpn does not run on iOS today** (see [product facts](#real-situations-vs-product-facts) below). The monitor lives on the Mac or Linux host that actually carries the tunnel.

**Sam** is the only person who is also “the network person” at a twelve-person company. Slack pings while shipping a feature: “VPN’s broken again.” Sam SSHs, checks logs, pings, checks DDNS—the remote office router got a new DHCP lease and the **DDNS** record is stale. Ten minutes to fix, an evening lost. Sam’s company cannot afford a NOC; Sam *is* the NOC.

None of these people failed at technology. They failed at **visibility**: the gap between *the VPN client thinks it is fine* and *the work you need to do is actually reachable*.

**Universal VPN Monitor** lives in that gap. It runs on **Linux and macOS**—your laptop, a small office server, a studio Linux box—and on a schedule you choose asks:

1. What does the **VPN control plane** say? (FortiClient, GlobalProtect, Pulse, Cisco Secure Client, OpenVPN, WireGuard, strongSwan—when installed.)
2. Can we still **reach** the host or network that matters?

When those answers disagree, uvpn names the mismatch—`VPN_NEGOTIATION_FAILED`, `DDNS_DRIFT`, `REMOTE_INTERNET_DOWN`, and others—so the next step is obvious instead of theatrical.

**Promise:** know which kind of broken you have before you burn an hour fixing the wrong layer.

One Python **MonitorEngine** + **MonitorAPI** powers four interfaces: **CLI**, **universal terminal**, **Linux GUI** (GTK4 + tkinter fallback), **macOS Swift GUI** (Liquid Glass on macOS 26). uvpn is **not** a VPN client—it watches one you already use.

---

## Real situations vs product facts

The scenes above are **realistic composites**—plausible Tuesdays, not one incident report. Technical claims below are what uvpn is built for.

| Situation | Status |
|-----------|--------|
| Split tunnel: “connected” UI while some subnets are unreachable | **Common** — often surfaces as `VPN_NEGOTIATION_FAILED` |
| Pulse on Linux: policy / Trusted Server gaps after image rebuild | **Documented** — [Pulse guide](docs/vpn-solutions/pulse-ivanti.md) |
| Remote site WAN changes; DDNS no longer matches config | **Checked** — `DDNS_DRIFT` |
| uvpn on iOS or inside the iOS VPN stack | **Not shipped** — monitor from macOS/Linux on the same path |
| uvpn opens firewall tickets or replaces vendor support | **No** — it narrows diagnosis; you still fix the site |

Full voice guide for contributors: [docs/brand/narrative-and-voice.md](docs/brand/narrative-and-voice.md)

> **Version note:** `0.2.0` was a development pre-release. **1.0.0** is the first production release — enterprise adapters (Fortinet, GlobalProtect, Pulse) are fixture-validated against vendor documentation, and scheduling unit files ship under `src/deploy/`.

## Quick start

```bash
git clone https://github.com/roto31/Tunnel-Monitor---Universal.git
cd Tunnel-Monitor---Universal
python3 -m venv .venv && source .venv/bin/activate
pip install -e ".[dev]"
uvpn init-config
uvpn preflight && uvpn check
uvpn statistics && uvpn diagnostics
bash scripts/uvpn-tui
```

## Repository structure

```
src/
  uvpn/           Core engine, adapters, MonitorAPI
  cli/            Shell CLI (uvpn)
  terminal-app/   Universal terminal menu (uvpn-tui)
  gui-linux/      GTK4 + tkinter fallback
  gui-macos/      Swift menu bar app
  deploy/         systemd timer + LaunchAgent installers
docs/
  architecture/   System design, Mermaid diagrams, cited research
  platform-linux/ platform-macos/
  vpn-solutions/  Per-VPN guides with source citations
legacy/           Archived bash monitor (not Universal product)
```

## Supported VPN adapters

| vpn_type | Status | Guide |
|----------|--------|-------|
| `generic` | Production | Any routed P2P VPN |
| `openvpn` | Production | [docs/vpn-solutions/openvpn.md](docs/vpn-solutions/openvpn.md) |
| `wireguard` | Production | [docs/vpn-solutions/wireguard.md](docs/vpn-solutions/wireguard.md) |
| `ipsec` / `ikev2` | Production | [docs/vpn-solutions/ipsec-ikev2.md](docs/vpn-solutions/ipsec-ikev2.md) |
| `cisco_anyconnect` | Production | [docs/vpn-solutions/cisco-anyconnect.md](docs/vpn-solutions/cisco-anyconnect.md) |
| `fortinet` | Production (fixture-validated) | [docs/vpn-solutions/fortinet-forticlient.md](docs/vpn-solutions/fortinet-forticlient.md) |
| `globalprotect` | Production (fixture-validated) | [docs/vpn-solutions/palo-alto-globalprotect.md](docs/vpn-solutions/palo-alto-globalprotect.md) |
| `pulse` | Production (CLI + fixtures) | [docs/vpn-solutions/pulse-ivanti.md](docs/vpn-solutions/pulse-ivanti.md) |

## Optional status portal (private network)

Read-only **uvpn-statusd** (FastAPI) for phone/browser status on LAN or Tailscale — `pip install -e ".[portal]"`. Not enabled by default.

- **Install:** [docs/deploy/status-portal.md](docs/deploy/status-portal.md)
- **NIST architecture** (CSF 2.0, SP 800-53 Moderate, SP 800-52 TLS): [docs/security/nist-portal-architecture.md](docs/security/nist-portal-architecture.md)
- **Threat model & audit:** [docs/security/threat-model.md](docs/security/threat-model.md), [docs/security/verification.md](docs/security/verification.md)

## Documentation

- [Architecture](docs/architecture/system-design.md) — all Mermaid diagrams
- [Platform API](docs/architecture/platform-abstraction.md)
- [Scheduling](docs/deploy/scheduling.md) — systemd + LaunchAgent
- [Status portal](docs/deploy/status-portal.md) — optional `uvpn-statusd` (private overlay)
- [Security](docs/security/README.md) — NIST-aligned portal hardening · [Security policy](SECURITY.md)
- [Adapter version matrix](docs/architecture/adapter-version-matrix.md)
- [Plugin guide](docs/architecture/plugin-adapters.md)
- [VPN research (cited)](docs/architecture/research-vpn-platforms.md)
- [Wiki](https://github.com/roto31/Tunnel-Monitor---Universal/wiki)

## CLI capabilities

| Command | Capability |
|---------|------------|
| `check` | Full monitoring cycle |
| `status` | Connection status |
| `statistics` | Probe + adapter metrics |
| `logs` | Recent VPN log lines |
| `diagnostics` | Diagnosis + runbook JSON |
| `explain` | Human-readable runbook |
| `preflight` | Dependency and config checks |
| `adapters` | List registered VPN adapters |

Legacy bash stack: [legacy/README.md](legacy/README.md)
