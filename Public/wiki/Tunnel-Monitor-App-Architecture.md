# Tunnel Monitor.app — architecture & diagrams

[← Hub](Tunnel-Monitor-App)

Mac LAN-client stack: **Tunnel Monitor.app** + `/opt/tunnel-monitor/`. For gateway monitors and WAN Guard, see [[Architecture]].

---

## System components

```mermaid
flowchart TB
  subgraph daemon [LaunchDaemon every 5 min]
    monitorSh[monitor.sh]
    stateJson[(state.json)]
    sendEmail[send-email.sh]
    notifySh[notify.sh]
    sshDedup[ssh-router-state.sh]
    monitorSh --> stateJson
    monitorSh --> sendEmail
    monitorSh --> notifySh
    monitorSh --> sshDedup
  end

  subgraph gui [Tunnel Monitor.app read-only UI]
    menuBar[MenuBarExtra popover]
    dashboard[Dashboard window]
    setupWin[Configuration window]
    monitorState[MonitorState polls state.json]
    actions[Actions CLI and osascript]
    menuBar --> monitorState
    dashboard --> monitorState
    setupWin --> configEnv["config.env"]
    menuBar --> actions
  end

  subgraph remote [Remote site]
    remoteGW[REMOTE_LAN_IP over tunnel]
  end

  subgraph hub [Local UniFi gateway optional]
    udr7State["gateway dedup state"]
  end

  SMTP[SMTP provider]
  monitorSh -->|ping| remoteGW
  sshDedup -->|SSH cat| udr7State
  sendEmail --> SMTP
  monitorState --> stateJson
  actions -->|kickstart| monitorSh
```

---

## Data flow (one check cycle)

```mermaid
sequenceDiagram
  participant LD as launchd
  participant M as monitor.sh
  participant S as state.json
  participant E as send-email.sh
  participant N as notify.sh
  participant App as Tunnel Monitor.app

  LD->>M: every 300s
  M->>M: ping REMOTE_LAN_IP REMOTE_WAN_IP 1.1.1.1
  M->>M: dig REMOTE_DDNS compare REMOTE_WAN_IP
  M->>M: SSH read gateway dedup state
  M->>M: compute_diagnosis
  M->>S: atomic write .tmp then mv
  alt failures >= FAILURE_THRESHOLD and alert_state was UP
    M->>E: alert email unless dedup suppresses
    M->>N: banner Tunnel DOWN
  end
  loop every 5 to 30s
    App->>S: read JSON
    App->>App: StatusPresentation traffic light
  end
```

---

## Alert decision flow

```mermaid
flowchart TD
  start[Check cycle] --> ourNet{Our internet OK?}
  ourNet -->|no| ourDown[OUR_INTERNET_DOWN no email]
  ourNet -->|yes| tunnel{tunnel ping OK?}
  tunnel -->|yes| healthy[HEALTHY recovery if was DOWN]
  tunnel -->|no| udr7reach{Gateway SSH reachable?}
  udr7reach -->|no| udr7unreach[UDR7_UNREACHABLE Mac alerts]
  udr7reach -->|yes| disagree{Gateway says 0:UP?}
  disagree -->|yes| disagreement[DISAGREEMENT Mac alerts]
  disagree -->|no| dns{DDNS matches REMOTE_WAN_IP?}
  dns -->|no| drift[DDNS_DRIFT]
  dns -->|yes| wan{Remote WAN ping OK?}
  wan -->|no| remoteDown[REMOTE_INTERNET_DOWN]
  wan -->|yes| tunnelDown[TUNNEL_DOWN]
  tunnelDown --> threshold{failure_count >= FAILURE_THRESHOLD?}
  drift --> threshold
  remoteDown --> threshold
  disagreement --> threshold
  udr7unreach --> threshold
  threshold -->|yes new DOWN| dedup{Gateway already DOWN alert?}
  dedup -->|yes| bannerOnly[Banner only suppress email]
  dedup -->|no| emailBanner[Email and banner]
```

---

## Configuration save (GUI)

```mermaid
sequenceDiagram
  participant U as User
  participant W as Configuration window
  participant C as ConfigEnvWriter
  participant O as osascript admin
  participant F as config.env

  U->>W: Save
  W->>C: render KEY=value lines
  W->>W: write temp file mode 0600
  W->>O: install to /opt/tunnel-monitor/config.env
  O->>F: root:wheel 0600
  W->>U: dismiss on success
```

---

## Opening Setup from menu bar

```mermaid
sequenceDiagram
  participant U as User
  participant P as Menu popover
  participant Shell as AppShellController
  participant Opener as AppWindowOpener on menu label
  participant W as Configuration window

  U->>P: Setup
  P->>Shell: requestSetupWizard
  Shell->>Opener: openSetupWizardRequest true
  Opener->>W: openWindow id setup
  Opener->>Shell: clearSetupWizardRequest
```

`AppWindowOpener` sits on the **menu bar label** so Setup works before any dashboard exists.

---

## `state.json` (GUI fields)

| Field | Meaning |
|-------|---------|
| `alert_state` | `UP` / `DOWN` |
| `diagnosis` | `HEALTHY`, `TUNNEL_DOWN`, `DDNS_DRIFT`, … |
| `failure_count` | Consecutive bad cycles |
| `down_since` | ISO down streak start |
| `checks.*` | Per-check ok / latency |
| `udr7_dedup` or `router_dedup` | SSH dedup block |

---

## Traffic light mapping

| Color | Meaning |
|-------|---------|
| Green | HEALTHY, failure count 0 |
| Yellow | Issues, alert still UP |
| Red | `alert_state` DOWN |

Settings poll interval (5/15/30 s) only affects how often the **app** re-reads JSON — not the daemon.

---

## Legacy UX changes

| Before | Now |
|--------|-----|
| SwiftBar only | App + optional SwiftBar |
| Sheet in popover | **Configuration** window |
| Popover `StatusView` | `MenuBarPopoverView` |

Build signing: [[Build-and-Release]] only.
