# Tunnel Monitor monorepo

| Category | Path | Description |
|----------|------|-------------|
| **Private** | [`Private/`](Private/) | Mac Studio production edition; canonical GUI source; gitignored operator docs |
| **Public** | [`Public/`](Public/) | Sanitized distributable bundles and public docs |
| **Universal** | [`Universal/`](Universal/) | Shared engine, adapters, core scripts |

Maintainer guides: [`RELEASING.md`](RELEASING.md) · [`CHANGELOG.md`](CHANGELOG.md) · [`RELEASES.md`](RELEASES.md)

Validate layout: `bash Universal/scripts/validate-folder-structure.sh`

---

# Gam-and-Bee Tunnel Monitor — Mac Studio edition

**Private operator docs:** [`Private/docs/README.md`](Private/docs/README.md) (topology, incident history, decision trees).

A macOS-native LaunchDaemon + SwiftBar plugin + CLI that watches the
Banana ↔ Gam-and-Bee site-to-site IPsec VPN from a **LAN-client perspective**
(your Mac Studio). It is the second vantage point alongside the existing UDR7
monitor — same alert behavior, deduped so you don't get two emails for the
same outage, plus a banner notification and a menu bar dot.

---

## 1. What it does

- Pings the remote LAN gateway through the tunnel every 5 minutes.
- Pings the remote public IP and 1.1.1.1 to disambiguate failures.
- Checks DDNS resolution against the expected static A record.
- After 3 consecutive failures (~15 min), sends an iCloud SMTP email **and** a
  native macOS banner notification.
- Sends a recovery email + banner when the tunnel comes back up.
- Reads the UDR7 monitor's state file over SSH so when the UDR7 has already
  alerted, the Mac stays quiet on email but still updates the menu bar.
- A SwiftBar plugin reads the daemon's state file once every 30s and renders
  the menu bar status (green/yellow/red) plus a dropdown of last-checked
  values and clickable actions.

It is deliberately **complementary** to the UDR7 monitor, not a replacement.

---

## 2. Architecture

```
┌──────────────────────┐                  ┌────────────────────────┐
│  Mac Studio          │                  │  UDR7 (Banana)         │
│  /opt/tunnel-monitor │                  │  /data/tunnel-monitor  │
│                      │                  │                        │
│  monitor.sh ─┬─ ping  192.168.0.1 ────┐ │  monitor.sh (timer)    │
│              ├─ ping  75.73.219.205   │ │  state: "0:UP" ...     │
│              ├─ ping  1.1.1.1         │ │                        │
│              ├─ dig   gamandbeeu...   │ │                        │
│              └─ ssh ──────────────────┼─►  cat .../state         │
│                                       │ │     "N:UP" / "N:DOWN"  │
│  state.json (alert state, dedup data) │ │                        │
│       ▲                               │ │                        │
│       │ jq                            │ │                        │
│  SwiftBar plugin (30s)                │ │                        │
│       │                               │ │                        │
│  notify.sh ─► launchctl asuser ──► macOS Notification Center     │
│  send-email.sh ─► curl smtp://smtp.mail.me.com:587               │
└──────────────────────┘                  └────────────────────────┘
```

**Dedup contract:**

| Mac sees | UDR7 says         | What Mac does                                |
|----------|-------------------|----------------------------------------------|
| UP       | n/a               | reset failure count, no alert                |
| DOWN     | unreachable       | alert with `UDR7 UNREACHABLE` subject note   |
| DOWN     | `0:UP`            | alert with `DISAGREEMENT (UDR7 says UP)`     |
| DOWN     | `N:UP` (N>0)      | normal alert (both monitors converging)      |
| DOWN     | `N:DOWN`          | suppress email (banner still fires)          |
| recovery | n/a               | recovery email + banner                      |

---

## 3. Install

Two supported install paths. Pick **either**.

### 3a. Recommended: signed `.pkg` from GitHub Releases

1. Download the latest `Tunnel-Monitor-<version>.pkg` from the
   [Releases page](../../releases).
2. Double-click the pkg, follow the GUI installer (admin password required).
3. Open `/Applications/Tunnel Monitor.app` once — it lives in the menu bar.
   On **first launch** a **Configuration** window collects the same values
   normally placed in `config.env` (SMTP, topology, gateway SSH); saving
   requires your admin password. Use **Configure later** if you already edited
   the file with `sudo vi`. Reopen any time from **Setup…** in the menu.
   Operator guide: [`Public/docs/tunnel-monitor/`](Public/docs/tunnel-monitor/) (or private `Private/docs/repo/docs/tunnel-monitor/`).
4. From the menu bar popover:
   - **Edit Config** → set `SMTP_PASSWORD`.
   - **Copy SSH Auth Cmd** → paste in Terminal once to authorize the Mac on
     the UDR7. Then **SSH Test** should pass.
   - **Test Email** / **Test Notify** → smoke test alert paths.
   - **Force Check** → trigger a health check immediately.

The pkg installs:

| Path | Purpose |
|---|---|
| `/Applications/Tunnel Monitor.app` | Menu bar app (SwiftUI) |
| `/opt/tunnel-monitor/` | scripts, CLI, config, state, logs |
| `/Library/LaunchDaemons/com.ruter.tunnel-monitor.plist` | 5-min health-check daemon |
| `/usr/local/bin/tunnel-check` | operator CLI symlink |
| `~/Library/Application Support/SwiftBar/Plugins/tunnel-monitor.30s.sh` | optional SwiftBar plugin |

Re-running the pkg is safe — `preinstall` stashes `config.env`, `state.json`,
`monitor.log`, and `.ssh/` and `postinstall` restores them.

### 3b. Developer path: `install.sh` from a clone

```bash
sudo bash Private/install/install.sh
sudo vi /opt/tunnel-monitor/config.env
tunnel-check --test-email
tunnel-check --test-notify
sudo bash Private/install/verify.sh
```

The installer is idempotent — re-running it never destroys `config.env` or
`state.json`. Pre-flight checks ensure `jq`, `dig`, `ssh-keygen`, and `curl`
are present (it will `brew install jq` if missing).

The first time you run a notification it may not appear — macOS needs you to
grant Notification permission to "Script Editor" / `osascript`. Look in
**System Settings → Notifications → Script Editor** (or whatever entry
appears) and enable banners. The next notification will display.

If you don't have SwiftBar yet:

```bash
brew install --cask swiftbar
open /Applications/SwiftBar.app
```

---

## 4. Daily commands

| Command                     | What it does                                        |
|-----------------------------|-----------------------------------------------------|
| `tunnel-check`              | Pretty-print current health from `state.json`       |
| `sudo tunnel-check --check-now`  | Force a launchd-triggered run right now        |
| `tunnel-check --test-email` | Send a synthetic email through `send-email.sh`      |
| `tunnel-check --test-notify`| Fire a synthetic banner through `notify.sh`         |
| `sudo tunnel-check --reset` | Reset `state.json` to a fresh `UP/0`                |
| `tunnel-check --tail`       | `tail -f /opt/tunnel-monitor/monitor.log`           |
| `tunnel-check --history`    | Last 50 log lines                                   |
| `tunnel-check --ssh-test`   | Verify SSH-based UDR7 dedup works                   |
| `tunnel-check --status`     | `launchctl print system/com.ruter.tunnel-monitor`   |

---

## 5. Alert response runbook

The diagnosis is included in every email subject and visible in the SwiftBar
dropdown.

### `TUNNEL_DOWN`

The tunnel gateway is unreachable but everything else looks fine.

```bash
ssh root@192.168.1.1
journalctl -fu strongswan -n 100
ipsec statusall            # what does the SA look like?
ipsec restart              # last resort: bounce daemon
```

### `DDNS_DRIFT`

`gamandbeeu.onthewifi.com` resolves to something other than `75.73.219.205`.
This is expected if her Comcast IP changed and No-IP DUC isn't set
(it isn't — by design).

1. Log into <https://my.noip.com/dynamic-dns/hostnames>.
2. Edit `gamandbeeu.onthewifi.com` to point at the new public IP.
3. The next monitor cycle will recover.

### `REMOTE_INTERNET_DOWN`

Her Comcast WAN is down. Nothing on your end to fix. Wait or call her.

### `UDR7_UNREACHABLE`

The Mac can't SSH to the UDR7 even though the tunnel is also down. Usually
the UDR7 itself is wedged.

1. Walk to the rack.
2. Power-cycle the UDR7 if it doesn't ping.
3. If repeated: check uptime, recent firmware update.

### `DISAGREEMENT`

UDR7 says the tunnel is fine; Mac can't reach `192.168.0.1`. This is a
Mac-side issue.

1. From the Mac: `ping 192.168.1.1` (UDR7 LAN reachable?)
2. `route -n get 192.168.0.0` — does the Mac have a route through the tunnel?
3. Restart networking: turn Wi-Fi/Ethernet off and on.
4. If the Mac is on Wi-Fi guest VLAN by accident, switch back.

### `OUR_INTERNET_DOWN`

Your home internet is down. The monitor holds state and does **not** alert
(can't email anyway). When internet comes back, the state machine resumes.

---

## 6. Notification permission grant

When the first banner fires from the daemon, macOS may silently drop it
because Notification Center has not yet been told to allow notifications
from `osascript`. To fix:

1. Run `tunnel-check --test-notify` (this triggers the consent prompt).
2. Approve banners for the prompt that appears.
3. **System Settings → Notifications** — find "Script Editor" (or
   `osascript`) in the list and confirm "Allow Notifications" is on.
4. Style: Banners (auto-dismiss) is fine; Alerts (sticky) is better for
   tunnel down events but more intrusive — your call.

---

## 7. Recovery from macOS updates

The LaunchDaemon plist at `/Library/LaunchDaemons/com.ruter.tunnel-monitor.plist`
survives macOS updates (it's not in `/System/`, so SIP doesn't touch it).
If a major OS upgrade leaves the daemon unloaded:

```bash
sudo launchctl bootstrap system /Library/LaunchDaemons/com.ruter.tunnel-monitor.plist
sudo launchctl enable system/com.ruter.tunnel-monitor
sudo bash Private/install/verify.sh
```

If anything else looks off, just re-run the installer:

```bash
sudo bash Private/install/install.sh
```

---

## 8. File layout

```
/opt/tunnel-monitor/
├── monitor.sh                # health check + state machine + alert dispatch
├── send-email.sh             # iCloud SMTP submission (curl)
├── notify.sh                 # native macOS banner via launchctl asuser
├── tunnel-check              # operator CLI (symlinked to /usr/local/bin/)
├── ssh-udr7-state.sh         # reads UDR7 state file via SSH for dedup
├── config.env                # SMTP creds + topology + tuning (chmod 0600)
├── config.env.template       # safe-to-share template
├── state.json                # current health state (machine + human readable)
├── monitor.log               # rolling log (rotates at 1 MB)
├── launchd.stdout.log        # launchd-captured stdout
├── launchd.stderr.log        # launchd-captured stderr
└── .ssh/
    ├── id_ed25519            # private SSH key for UDR7 dedup (chmod 0600)
    ├── id_ed25519.pub
    └── known_hosts

/Library/LaunchDaemons/
└── com.ruter.tunnel-monitor.plist        # 5-min interval, RunAtLoad

/usr/local/bin/
└── tunnel-check -> /opt/tunnel-monitor/tunnel-check

~/Library/Application Support/SwiftBar/Plugins/
└── tunnel-monitor.30s.sh
```

---

## 9. Tuning

All knobs live in `/opt/tunnel-monitor/config.env`.

| Var                  | Default                       | Notes                                         |
|----------------------|-------------------------------|-----------------------------------------------|
| `REMOTE_LAN_IP`      | `192.168.0.1`                 | What we ping over the tunnel                  |
| `REMOTE_WAN_IP`      | `75.73.219.205`               | Her Comcast public IP (compared to DDNS)      |
| `REMOTE_DDNS`        | `gamandbeeu.onthewifi.com`    | Hostname we resolve to detect drift           |
| `UDR7_HOST`          | `192.168.1.1`                 | Where to SSH for dedup state                  |
| `UDR7_USER`          | `root`                        | SSH user                                      |
| `UDR7_KEY`           | `/opt/tunnel-monitor/.ssh/id_ed25519` | SSH key path                          |
| `UDR7_STATE_PATH`    | `/data/tunnel-monitor/state`  | Remote file the UDR7 monitor maintains        |
| `FAILURE_THRESHOLD`  | `3`                           | Consecutive failures before alerting          |
| `PING_COUNT`         | `3`                           | Pings per check                               |
| `PING_TIMEOUT`       | `2`                           | Seconds; converted to ms for `ping -W`        |
| `SUBJECT_PREFIX`     | `[STUDIO]`                    | Prepended to every Mac email subject          |
| `NOTIFY_SOUND_DOWN`  | `Glass`                       | macOS sound name for DOWN banner              |
| `NOTIFY_SOUND_RECOVERY` | `Hero`                     | macOS sound name for RECOVERY banner          |

To change the check interval, edit
`/Library/LaunchDaemons/com.ruter.tunnel-monitor.plist`'s `StartInterval`,
then reload: `sudo launchctl bootout system <plist> && sudo launchctl bootstrap system <plist>`.
**Do not poll faster than 30 s.**

---

## 10. Testing each failure mode manually

### Force a `DDNS_DRIFT`

```bash
echo "10.99.99.99 gamandbeeu.onthewifi.com" | sudo tee -a /etc/hosts
sudo dscacheutil -flushcache
sudo tunnel-check --check-now
sudo tunnel-check --check-now   # repeat 3 times to cross threshold
sudo tunnel-check               # diagnosis should be DDNS_DRIFT
# Cleanup:
sudo sed -i '' '/gamandbeeu.onthewifi.com/d' /etc/hosts
```

### Force a `TUNNEL_DOWN`

Easiest: temporarily disable the IPsec tunnel from the UDR7 console. Or, on
the Mac side, point `REMOTE_LAN_IP` at a black-hole IP in `config.env`:

```bash
sudo sed -i '' 's/^REMOTE_LAN_IP=.*/REMOTE_LAN_IP="10.255.255.255"/' /opt/tunnel-monitor/config.env
for _ in 1 2 3; do sudo tunnel-check --check-now; sleep 2; done
sudo tunnel-check               # should be TUNNEL_DOWN
# Cleanup: restore config.env from config.env.template values
```

### Force a `UDR7_UNREACHABLE`

Point `UDR7_HOST` at an unreachable address temporarily:

```bash
sudo sed -i '' 's/^UDR7_HOST=.*/UDR7_HOST="10.255.255.254"/' /opt/tunnel-monitor/config.env
sudo tunnel-check --ssh-test    # should FAIL
# Combine with a forced TUNNEL_DOWN above to see UDR7_UNREACHABLE diagnosis.
# Cleanup: restore UDR7_HOST="192.168.1.1"
```

### Force a `DISAGREEMENT`

Force `TUNNEL_DOWN` (above) while the UDR7 still sees the tunnel up. The Mac
will diagnose as `DISAGREEMENT` because `ssh-udr7-state.sh` returns `0:UP`.

### Force a `REMOTE_INTERNET_DOWN`

Without messing with the UDR7, this requires her Comcast actually being down,
or pointing `REMOTE_WAN_IP` at a black-hole and `REMOTE_LAN_IP` at a
black-hole simultaneously while UDR7 returns a non-zero non-DOWN state. Not
worth synthesizing in a test — trust the unit logic.

### Force a recovery email

After triggering any DOWN above, undo the change and run `--check-now` until
state is `HEALTHY`. The transition will fire the recovery email + banner.

### OpenVPN fallback (upstream modem blocks UDP 500/4500)

If an ISP gateway (for example Comcast XB7) wedges IPsec but general UDP flows
still work, rebuild the UniFi tunnel as OpenVPN rather than patching the Mac
daemon. Operators should follow **[OpenVPN Site-to-Site migration](Public/docs/openvpn-site-to-site-migration.md)** and use **[Universal/scripts/gen-openvpn-s2s-key-remote.sh](Universal/scripts/gen-openvpn-s2s-key-remote.sh)** to mint the UniFi UI key blob on the Banana UDR7.

After OpenVPN is live, install **[WAN Guard](Public/docs/wan-guard-openvpn-failover.md)** on the UDR7 so T-Mobile failover does not poison **`bananaudm.onthewifi.com`** with a CGNAT address.

---

## 11. Uninstall

```bash
sudo bash Private/install/uninstall.sh           # interactive — asks before destroying config + state
sudo bash Private/install/uninstall.sh --keep    # keep config.env + state.json
sudo bash Private/install/uninstall.sh --yes     # remove everything, no prompts
```

If you installed via the `.pkg`, the same `uninstall.sh` script ships at
`/Library/Application Support/Tunnel Monitor/scripts/uninstall.sh`:

```bash
sudo bash "/Library/Application Support/Tunnel Monitor/scripts/uninstall.sh"
sudo rm -rf "/Applications/Tunnel Monitor.app"
sudo rm -rf "/Library/Application Support/Tunnel Monitor"
```

---

## 12. Building the `.pkg` yourself

The installer pkg is reproducible from a clean clone:

```bash
# Build just the .app bundle
VERSION=1.0.0 bash Private/build/build-app.sh

# Build the full distributable .pkg (calls build-app.sh if needed)
VERSION=1.0.0 bash Private/build/build-pkg.sh
```

Output lands in `Private/build/dist/`:

```
Private/build/dist/Tunnel Monitor.app
Private/build/dist/Tunnel-Monitor-1.0.0.pkg
```

### Codesigning + notarization

Set these environment variables before running `build-pkg.sh` to produce a
signed, notarized, stapled pkg suitable for GitHub distribution:

| Env var | Example | Purpose |
|---|---|---|
| `DEVELOPER_ID_APPLICATION` | `Developer ID Application: Jane Doe (ABCDE12345)` | sign the `.app` |
| `DEVELOPER_ID_INSTALLER`   | `Developer ID Installer: Jane Doe (ABCDE12345)`   | sign the `.pkg` |
| `APPLE_ID`                 | `you@example.com`                                 | notary submission |
| `APPLE_TEAM_ID`            | `ABCDE12345`                                      | notary submission |
| `APPLE_APP_SPECIFIC_PASSWORD` | `xxxx-xxxx-xxxx-xxxx`                          | notary auth |

If only `DEVELOPER_ID_APPLICATION` + `DEVELOPER_ID_INSTALLER` are set, the
pkg is signed but **not** notarized — recipients will need to right-click →
Open the first time.

### GitHub Actions release

Pushing a tag like `v1.0.0` to GitHub triggers
`.github/workflows/release.yml`, which builds the signed+notarized `.pkg`
and attaches it to the corresponding GitHub Release. The workflow expects
the following repository secrets:

- `DEVELOPER_ID_APPLICATION`
- `DEVELOPER_ID_INSTALLER`
- `APPLE_ID`
- `APPLE_TEAM_ID`
- `APPLE_APP_SPECIFIC_PASSWORD`
- `MACOS_CERT_P12_BASE64` (base64-encoded `.p12` containing both Developer ID certs + private keys)
- `MACOS_CERT_P12_PASSWORD`
