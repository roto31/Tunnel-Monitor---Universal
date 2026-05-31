# Messaging snippets (copy-paste)

Aligned with [narrative-and-voice.md](narrative-and-voice.md). Adjust names and platforms; keep facts accurate.

## One-liner

**uvpn** checks whether your VPN is actually working—not just whether the client icon says you are connected.

## Elevator (30 seconds)

Most VPN trouble is invisible until something urgent breaks. uvpn runs quiet checks from your Mac or Linux machine, compares what the VPN client claims with whether your remote network really answers, and tells you what kind of problem you have before you burn an hour in the wrong fix.

## Tagline options (pick one per surface)

- Know before the ticket.
- Connected on screen. Reachable in practice.
- The VPN check you run before the panic search.

## Diagnosis one-liners (for UI / `uvpn explain` intros)

| Code | Snippet |
|------|---------|
| `HEALTHY` | Path looks good. The client and your probe target agree. |
| `OUR_INTERNET_DOWN` | Fix local internet first—uvpn paused counting VPN failures while you are offline. |
| `VPN_DAEMON_DOWN` | The VPN client is not in a connected state. Open the client or pick the right adapter guide. |
| `VPN_NEGOTIATION_FAILED` | The client says you are on the VPN, but the host you care about does not answer—often split tunnel or routing. |
| `DDNS_DRIFT` | The hostname you watch no longer points at the WAN IP you expected. |
| `REMOTE_INTERNET_DOWN` | The remote site’s public side does not answer—likely their ISP, not your laptop. |
| `TUNNEL_DOWN` | WAN looks reachable but the LAN probe failed—dig into the VPN path. |
| `UNSUPPORTED` | uvpn cannot read this VPN stack yet—check install, binary path, or use `generic`. |
| `UNKNOWN` | Not enough signal—run `uvpn preflight` and confirm config. |

## Section openers (docs)

**Troubleshooting:** Start with what you are trying to reach, not with reinstalling the client.

**Install:** Five minutes now beats forty minutes after the next outage.

**Platform guide:** This page is the reworded map of what your vendor manual already says—plus how uvpn listens to it.

## What we do not say

- “Magic,” “seamless,” “enterprise-grade synergy”
- Guaranteed uptime or SLA claims uvpn does not enforce
- That uvpn runs on iOS or Windows (unless and until shipped)
