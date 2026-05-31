# Phase 0 — Convergence notes

**Merge base:** Mac [`Public/mac/payload/opt/tunnel-monitor/monitor.sh`](../Public/mac/payload/opt/tunnel-monitor/monitor.sh) for state-machine behavior (OUR_INTERNET_DOWN counter freeze, dedup suppress on DISAGREEMENT/GATEWAY_UNREACHABLE). Linux [`Public/linux/payload/opt/tunnel-monitor/monitor.sh`](../Public/linux/payload/opt/tunnel-monitor/monitor.sh) for generic naming (`ROUTER_*` → canonical `GATEWAY_*`).

**Production deploy path:** [`Public/mac/install.sh`](../Public/mac/install.sh) installs from `Public/mac/payload/` → `/opt/tunnel-monitor/`. The root `opt/` tree is a legacy mirror; canonical source is `Public/mac/`.

## Diagnosis parity (unified in core)

| Input | Mac v1 | Linux v1 | Core v2 |
|-------|--------|----------|---------|
| Gateway SSH fails | `UDR7_UNREACHABLE` | `ROUTER_UNREACHABLE` | `GATEWAY_UNREACHABLE` |
| Gateway `0:UP`, tunnel down | `DISAGREEMENT` | `DISAGREEMENT` | `DISAGREEMENT` |
| Dedup skip when gateway `N:DOWN` | Yes, except UNREACHABLE/DISAGREEMENT | Yes (no DISAGREEMENT exception) | Mac behavior (exception for UNREACHABLE/DISAGREEMENT) |

DISAGREEMENT condition: gateway state line equals `0:UP` (equivalent to `ROUTER_ALERT_STATE==UP && ROUTER_COUNT==0`).

## Intentional platform differences (adapters)

- **macOS:** banner via `notify.sh` + osascript; BSD ping timeout in ms.
- **Linux:** notify stub; GNU ping `-W` in seconds; logs to stdout and file.
- **UniFi gateway:** line state file; ipsec diagnostics hook; no LAN JSON.
