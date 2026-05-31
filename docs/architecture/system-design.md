# Universal VPN Monitor — architecture

Product codename: **uvpn**. Python backend; shell CLI/TUI; native GUIs on Linux (GTK4) and macOS (Swift).

---

## 1. Layered architecture

```mermaid
flowchart TB
    subgraph Interfaces["Interfaces (equivalent capabilities)"]
        CLI[uvpn CLI Python]
        TUI[uvpn-tui Bash menu]
        LGUI[Linux GTK4 GUI]
        MGUI[macOS Swift GUI]
    end

    subgraph Core["Python monitoring core"]
        ENG[MonitorEngine]
        PROB[Universal probes ICMP DNS]
        DIAG[Diagnosis plus runbooks]
        STATE[state.json store]
        REG[Adapter registry]
    end

    subgraph Adapters["VPN adapters plugins"]
        OV[OpenVPN]
        WG[WireGuard]
        IP[IPsec IKEv2]
        CISCO[Cisco AnyConnect]
        GEN[Generic reachability]
    end

    subgraph PAL["Platform abstraction layer"]
        API[MonitorAPI]
    end

    CLI --> API
    TUI --> API
    LGUI --> API
    API --> ENG
    MGUI --> STATE
    ENG --> PROB
    ENG --> DIAG
    ENG --> REG
    REG --> OV
    REG --> WG
    REG --> IP
    REG --> CISCO
    REG --> GEN
    ENG --> STATE
    LGUI --> STATE
```

**Rule:** GUIs never implement probes. macOS GUI reads the same `~/.config/uvpn/state.json` written by `MonitorEngine` (or invokes `uvpn check` via helper).

---

## 2. Check cycle data flow

```mermaid
sequenceDiagram
    participant IF as Interface
    participant ENG as MonitorEngine
    participant AD as VpnAdapter
    participant PR as Universal probes
    participant ST as state.json

    IF->>ENG: run_check
    ENG->>AD: probe config
    AD-->>ENG: AdapterStatus
    ENG->>PR: ping remote LAN WAN dig DDNS
    PR-->>ENG: ProbeResults
    ENG->>ENG: compute_diagnosis
    ENG->>ST: atomic write snapshot
    ENG-->>IF: CheckSnapshot
```

---

## 3. Adapter plugin pattern

```mermaid
classDiagram
    class VpnAdapter {
        <<abstract>>
        +adapter_id str
        +vpn_type str
        +probe(config) AdapterStatus
        +capabilities() dict
    }
    class OpenVpnAdapter
    class WireGuardAdapter
    class IpsecAdapter
    class CiscoAnyConnectAdapter
    class GenericReachabilityAdapter
    VpnAdapter <|-- OpenVpnAdapter
    VpnAdapter <|-- WireGuardAdapter
    VpnAdapter <|-- IpsecAdapter
    VpnAdapter <|-- CiscoAnyConnectAdapter
    VpnAdapter <|-- GenericReachabilityAdapter
```

Register in `uvpn/adapters/registry.py`:

```python
ADAPTERS["my_vendor"] = MyVendorAdapter
```

Each adapter returns `AdapterStatus` without raising — the engine always completes a cycle.

---

## 4. Universal vs protocol-specific metrics

| Layer | Always runs | Purpose |
|-------|-------------|---------|
| **Universal probes** | Yes | End-to-end P2P health independent of vendor |
| **Adapter probe** | Per `vpn_type` | Daemon/session state (OpenVPN mgmt, `wg show`, etc.) |
| **Diagnosis** | Yes | Combines both layers |

This matches operational reality: [RFC 4271 BGP-style reachability](https://www.rfc-editor.org/rfc/rfc4271) thinking applies — **data plane** (ping) and **control plane** (VPN daemon) can diverge.

---

## 5. System requirements

### Linux (server or desktop)

| Requirement | Version |
|-------------|---------|
| Python | 3.11+ |
| ping, dig | iputils, bind-utils |
| Optional GUI | GTK 4, PyGObject 3.42+ (Ubuntu 22.04+, Fedora 38+, Debian 12+) |
| WireGuard adapter | `wireguard-tools` |
| IPsec adapter | `strongswan-swanctl` or `strongswan-starter` |
| OpenVPN adapter | OpenVPN with `--management` enabled |
| Cisco adapter | Cisco Secure Client installed |

### macOS (desktop client)

| Requirement | Version |
|-------------|---------|
| Python | 3.11+ (system or Homebrew) |
| macOS | 14+ (GUI); 26+ for Liquid Glass styling |
| Cisco adapter | Secure Client / AnyConnect binary |

---

## 6. Repository layout

```
src/
  uvpn/                 Python package (core, adapters, api, cli module)
  cli/uvpn              Shell CLI wrapper
  terminal-app/uvpn-tui Universal terminal application
  gui-linux/            GTK4 + tkinter fallback
  gui-macos/            Swift menu bar app
docs/
  architecture/         System design, research, PAL, plugins
  platform-linux/       Linux install, CLI, TUI, GUI
  platform-macos/       macOS install, CLI, TUI, GUI
  vpn-solutions/        Per-VPN configuration guides
legacy/                 Archived bash monitor
wiki/                   GitHub wiki source pointer
```

See also [platform-abstraction.md](platform-abstraction.md) and [plugin-adapters.md](plugin-adapters.md).

---

## 8. Interface architecture

All four interfaces expose **status, statistics, logs, diagnostics**:

```mermaid
flowchart LR
    subgraph Clients
        CLI[CLI uvpn]
        TUI[Terminal uvpn-tui]
        LG[Linux GUI]
        MG[macOS GUI]
    end
    API[MonitorAPI]
    ENG[MonitorEngine]
    ST[state.json]

    CLI --> API
    TUI --> API
    LG --> API
    MG --> ST
    API --> ENG
    ENG --> ST
    ST --> MG
    ST --> LG
```

| Capability | CLI | TUI | Linux GUI | macOS GUI |
|------------|-----|-----|-----------|-----------|
| Connection status | `status` | menu 2 | Status tab | menu bar title |
| Statistics | `statistics` | menu 3 | Statistics tab | Statistics disclosure |
| Logs | `logs` | menu 4 | Logs tab | Logs disclosure |
| Diagnostics | `diagnostics` | menu 5 | Diagnostics tab | Steps disclosure |
| Run check | `check` | menu 1 | Run check btn | Run check btn |

---

## 9. Platform-specific data flow

### Linux

```mermaid
sequenceDiagram
    participant Op as Operator
    participant TUI as uvpn-tui bash
    participant CLI as uvpn CLI
    participant API as MonitorAPI
    participant ENG as MonitorEngine
    participant AD as Adapter
    participant ST as state.json

    Op->>TUI: menu select check
    TUI->>CLI: uvpn check
    CLI->>API: run_check
    API->>ENG: run_check
    ENG->>AD: probe plus stats logs
    ENG->>ST: atomic write
    Op->>TUI: menu statistics
    TUI->>CLI: uvpn statistics
    CLI->>API: get_statistics
    API->>ST: read
```

GTK path: `launch_gui.py` → `MonitorAPI.full_view()` directly (no duplicate probes).

### macOS

```mermaid
sequenceDiagram
    participant GUI as Swift MenuBarExtra
    participant CLI as uvpn check
    participant ENG as MonitorEngine
    participant ST as state.json

    CLI->>ENG: run_check
    ENG->>ST: write statistics logs diagnostics
    GUI->>ST: poll every 15s
    GUI->>CLI: optional Run check button
```

Liquid Glass styling: `glassEffect` on macOS 26+ with material fallback on macOS 14–25.

---

## 10. VPN monitoring signal flow

```mermaid
flowchart TB
    VPN[VPN tunnel data plane]
    AD[Protocol adapter CLI or socket]
    UP[Universal probes ping dig]
    ENG[MonitorEngine]
    DIAG[Diagnosis engine]
    ST[state.json]
    IF[CLI TUI GUI]

    VPN --> AD
    VPN --> UP
    AD --> ENG
    UP --> ENG
    ENG --> DIAG
    DIAG --> ST
    ST --> IF
```

---

## 11. Extensibility roadmap

| Phase | Deliverable |
|-------|-------------|
| v0.1 | Core engine, 4 adapters, CLI/TUI, GTK scaffold, Swift reader |
| v0.2 | MonitorAPI, statistics/logs, Forti/GP/Pulse heuristics, tkinter fallback, Liquid Glass |
| v0.3 | Harden enterprise adapters per validated CLI versions |
| v1.0 | Signed packages, systemd/launchd scheduling |

Each new adapter requires **cited** vendor CLI/API documentation in `docs/research/`.
