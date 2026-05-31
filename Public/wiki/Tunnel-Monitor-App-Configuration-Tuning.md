# Configuration — tuning & notifications

[← Hub](Tunnel-Monitor-App) · Configuration window

![Tuning and notifications](https://raw.githubusercontent.com/roto31/UniFi-Tunnel-Monitor/main/docs/tunnel-monitor/images/setup-tuning.png)

---

## Fields

| Key | Label | Default | Notes |
|-----|-------|---------|-------|
| `SUBJECT_PREFIX` | Email subject prefix | `[MAC]` | |
| `FAILURE_THRESHOLD` | Consecutive failures before alert | `3` | × 5 min ≈ **15 minutes** |
| `PING_COUNT` | Pings per check | `3` | |
| `PING_TIMEOUT` | Ping timeout (seconds) | `2` | |
| `NOTIFY_SOUND_DOWN` | Banner sound (down) | `Glass` | `/System/Library/Sounds/` |
| `NOTIFY_SOUND_RECOVERY` | Banner sound (recovery) | `Hero` | |

---

## Banner sounds

Use exact sound names from `/System/Library/Sounds/` (without `.aiff`).

Test with **Test Notify** in [[Tunnel-Monitor-App-Menu-Bar]].

---

## Related

- [[Tunnel-Monitor-App-Configuration-SMTP]]
- [[Tunnel-Monitor-App-Configuration-Topology]]
- [[Tunnel-Monitor-App-Configuration-Gateway-SSH]]
