# Configuration — SMTP

[← Hub](Tunnel-Monitor-App) · Configuration window

Open **Configuration** via **Setup…** in [[Tunnel-Monitor-App-Menu-Bar]] or on first launch.

![SMTP section](https://raw.githubusercontent.com/roto31/UniFi-Tunnel-Monitor/main/docs/tunnel-monitor/images/setup-smtp.png)

*SMTP section. Required fields show a red border when empty.*

---

## Fields

| Key | Label | Notes |
|-----|-------|-------|
| `SMTP_SERVER` | SMTP server | e.g. `smtp.mail.me.com`, `smtp.gmail.com` |
| `SMTP_PORT` | SMTP port | Default `587` |
| `SMTP_USER` | SMTP username | Usually your email |
| `SMTP_PASSWORD` | App-specific password | **Not** your login password |
| `ALERT_FROM` | From address | Often must match `SMTP_USER` |
| `ALERT_TO` | Alert recipient | Down/recovery emails |

---

## Example (iCloud)

```bash
SMTP_SERVER="smtp.mail.me.com"
SMTP_PORT="587"
SMTP_USER="you@icloud.com"
SMTP_PASSWORD="<app-specific-password>"
ALERT_FROM="you@icloud.com"
ALERT_TO="alerts@example.com"
```

---

## Verify

From [[Tunnel-Monitor-App-Menu-Bar]]: **Test Email**.

---

## Other configuration sections

- [[Tunnel-Monitor-App-Configuration-Topology]]
- [[Tunnel-Monitor-App-Configuration-Gateway-SSH]]
- [[Tunnel-Monitor-App-Configuration-Tuning]]
