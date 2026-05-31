# OpenVPN

**vpn_type:** `openvpn`

## uvpn at a glance

Uses the OpenVPN **management interface** (`state` / `status` over TCP) when configured; otherwise process-only detection. Always validate with universal probes to `remote_lan_ip`.

---

## Vendor documentation index

| Vendor section | Official document | URL |
|----------------|-------------------|-----|
| Management interface | OpenVPN Management Interface | https://openvpn.net/community-docs/management-interface.html |
| Protocol overview | OpenVPN protocol overview | https://openvpn.net/community-docs/openvpn-protocol--overview.html |
| Reference manual | OpenVPN 2.6 man page | https://openvpn.net/community-resources/reference-manual-for-openvpn-2-6/ |

---

## 1. Product overview

OpenVPN creates encrypted tunnels using SSL/TLS. The **management interface** exposes real-time client state on a local TCP socket (default often `127.0.0.1:7505`).

**uvpn relevance:** Parses `state` for `CONNECTED`; optional `status` for byte counters.

---

## 2. Installation and deployment

Deploy OpenVPN client or server per community / vendor package for your OS. Enable management in config:

```text
management 127.0.0.1 7505
management-query-passwords
```

Without `management`, uvpn cannot query session state reliably.

---

## 3. CLI and management interface

**Management commands** ([management interface](https://openvpn.net/community-docs/management-interface.html)):

| Command | Purpose |
|---------|---------|
| `state` | Connection state machine (CONNECTING, CONNECTED, …) |
| `status` | Routing table + byte counts |
| `log` | Recent log lines |
| `hold release` | Release hold after connect (if hold enabled) |

uvpn connects to `openvpn_management` host:port from config.

---

## 4. Connection lifecycle

| State (vendor) | Meaning |
|----------------|---------|
| CONNECTING | Negotiation in progress |
| CONNECTED | Tunnel up |
| RECONNECTING | Session rebuild |
| EXITING | Shutting down |

---

## 5. Status and monitoring

| Layer | Method |
|-------|--------|
| Control plane | Management `state` |
| Data plane | Ping `remote_lan_ip`, `remote_wan_ip` |
| Logs | Management `log` or file tail (adapter) |

---

## 6. Authentication and certificates

Per OpenVPN config: TLS certs, username/password, 2FA plugins. uvpn does not authenticate — only monitors.

---

## 7. Logging and diagnostics

Management `log` command or `--log` file path in server/client config. uvpn includes recent lines in `state.json` when adapter collects logs.

---

## 8. Exit codes and return values

OpenVPN process exit codes are OS-level; uvpn uses management state, not process exit, during checks.

---

## 9. Vendor troubleshooting

| Issue | Vendor direction |
|-------|------------------|
| Management refused | Check socket bind, firewall, `management` directive |
| Stuck CONNECTING | Cert/auth failure — inspect OpenVPN log |

---

## uvpn configuration

```json
{
  "vpn_type": "openvpn",
  "openvpn_management": "127.0.0.1:7505",
  "remote_lan_ip": "192.168.50.1",
  "remote_wan_ip": "203.0.113.20",
  "remote_ddns": "site.example.com"
}
```

---

## uvpn monitoring

```bash
uvpn preflight && uvpn check && uvpn statistics
```

| Metric | Source |
|--------|--------|
| Connected | Management `state` |
| Bytes / routes | Management `status` |

---

## Supported versions

OpenVPN 2.4+ with management interface. Use `generic` if management disabled.

---

## uvpn troubleshooting

- Management unreachable → set correct host/port or use `"vpn_type": "generic"`.
- CONNECTED but LAN fail → `TUNNEL_DOWN`.

---

## Related

- [plugin-adapters.md](../architecture/plugin-adapters.md)
