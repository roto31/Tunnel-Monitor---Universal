# Universal VPN Monitor Wiki

**Connected on screen is not the same as reachable for work.**

---

## The afternoon everyone remembers

Picture a Tuesday that should have been ordinary.

**Maya** — contract PM on a **MacBook**, **GlobalProtect** green, client demo in twenty minutes. The project share spins forever. Reboot, reconnect, still nothing. Later: tunnel “up” but split-tunnel routes never included the share. The UI did not lie; it did not tell the whole story.

**Jordan** — grad student on **Ubuntu**, **Pulse/Ivanti** “connected,” lab share unreachable for days. Fix: **Trusted Server** missing on a rebuilt image.

**Alex** — freelancer, **FortiClient** + **Pulse** on one **Mac**, tired of debugging their own clients. *(On **iPhone**, client VPN is common; **uvpn does not run on iOS today**—monitor from macOS/Linux or [Status Portal](Status-Portal) on the host.)*

**Sam** — twelve-person company, one “network person.” Slack: “VPN’s broken.” Stale **DDNS** after a remote DHCP change. Ten-minute fix, evening gone. Sam *is* the NOC.

They did not fail at technology. They failed at **visibility**: *client fine* vs *work reachable*.

**uvpn** runs on **Linux and macOS**, compares VPN client state to probes you care about, and names the mismatch (`VPN_NEGOTIATION_FAILED`, `DDNS_DRIFT`, …) before you fix the wrong layer. It is **not** a VPN client.

| Situation | Fact |
|-----------|------|
| Split tunnel + green UI | Common; uvpn can flag negotiation/routing |
| Pulse Linux policy gaps | Documented in [Pulse / Ivanti](Pulse-Ivanti) |
| DDNS drift | Checked by uvpn |
| uvpn on iOS | Not shipped |
| Replaces IT / vendor support | No — narrows diagnosis only |

**Writers:** [Brand and voice](Brand-and-Voice) · **Repo landing:** [README](https://github.com/roto31/Tunnel-Monitor---Universal#the-afternoon-everyone-remembers)

**Current release:** **1.1.0** — optional NIST-aligned **status portal** (`uvpn-statusd`). **1.0.0** was first production gate. Adapters: **OpenVPN**, **WireGuard**, **IPsec/IKEv2**, **Cisco AnyConnect**, **Fortinet**, **GlobalProtect**, **Pulse/Ivanti**, **generic**.

One Python engine — **CLI**, **TUI**, **Linux GTK GUI**, **macOS Swift GUI**, optional **HTTPS status portal** (private overlay).

---

## Start here

1. [Getting Started](Getting-Started)
2. [Brand and voice](Brand-and-Voice)
3. [Architecture](Architecture)
4. [VPN platform research (cited)](VPN-Research)
5. [VPN platform diagrams](VPN-Platform-Diagrams)
6. [Troubleshooting](Troubleshooting)
7. [Security](Security) · [Status portal](Status-Portal)

## Interfaces

| Interface | Wiki page |
|-----------|-----------|
| CLI | [CLI](CLI) |
| Universal terminal | [Universal Terminal TUI](Universal-Terminal-TUI) |
| Linux GUI | [Linux GUI](Linux-GUI) |
| macOS GUI | [macOS GUI](macOS-GUI) |
| Operator UX | [GUI Operator Features](GUI-Operator-Features) |
| Status portal (optional) | [Status Portal](Status-Portal) — `uvpn-statusd`, NIST hardening |

## VPN setup guides

- [OpenVPN](OpenVPN)
- [WireGuard](WireGuard)
- [IPsec IKEv2](IPsec-IKEv2)
- [Cisco AnyConnect](Cisco-AnyConnect)
- [Fortinet FortiClient](Fortinet-FortiClient)
- [Palo Alto GlobalProtect](Palo-Alto-GlobalProtect)
- [Pulse / Ivanti](Pulse-Ivanti)

## Platform install

- [Linux install](Linux-Install)
- [macOS install](macOS-Install)
- [Scheduling (systemd / LaunchAgent)](Scheduling)
- [Status portal](Status-Portal) — LAN/Tailscale read-only API
- [Security (NIST)](Security) — architecture, threat model, verification

## Releases

- [Releases](Releases)

---

## Legacy bash monitor

The archived UniFi/site-specific stack lives under [Legacy Overview](Legacy-Overview). **Do not use for new Universal deployments.**
