# Cisco AnyConnect / Secure Client

**vpn_type:** `cisco_anyconnect`

## uvpn at a glance

Invokes Cisco Secure Client **`vpn state`** (and `vpn stats` for statistics) on Linux/macOS SSL VPN **client** hosts — not ASA site-to-site on a router.

---

## Vendor documentation index

| Vendor section | Official document | URL |
|----------------|-------------------|-----|
| Admin guide (5.x) | Cisco Secure Client Admin Guide | https://www.cisco.com/c/en/us/td/docs/security/vpn_client/anyconnect/Cisco-Secure-Client-5/admin/guide/b-cisco-secure-client-admin-guide-5-0/customize-localize-anyconnect.html |
| CLI customization | Localize / CLI chapter (same guide) | https://www.cisco.com/c/en/us/td/docs/security/vpn_client/anyconnect/Cisco-Secure-Client-5/admin/guide/b-cisco-secure-client-admin-guide-5-0/customize-localize-anyconnect.html |
| Product page | Cisco Secure Client | https://www.cisco.com/c/en/us/products/security/anyconnect-secure-mobility-client/index.html |

---

## 1. Product overview

Cisco Secure Client (formerly AnyConnect) provides SSL/IPsec VPN to enterprise headends. Local **`vpn`** CLI reports session state for automation.

**uvpn scope:** Client on monitoring host — for site-to-site IPsec on a gateway use `ipsec` adapter or `generic`.

---

## 2. Installation and deployment

Install Secure Client per Cisco package for macOS/Linux. Typical binary paths:

| OS | Path |
|----|------|
| Linux | `/opt/cisco/secureclient/bin/vpn` |
| macOS | `/opt/cisco/secureclient/bin/vpn` |

Set `cisco_vpn_binary` in config if non-standard.

---

## 3. CLI and management interface

**Documented CLI** (admin guide — local CLI / state):

```bash
vpn state
vpn stats
```

Output includes connection state (connected / disconnected / reconnecting). uvpn parses stdout for session status.

---

## 4. Connection lifecycle

| State | Meaning |
|-------|---------|
| Connected | Active VPN session |
| Disconnected | No session |
| Reconnecting | Session rebuild |

---

## 5. Status and monitoring

| Layer | Method |
|-------|--------|
| Control plane | `vpn state` |
| Statistics | `vpn stats` |
| Data plane | Universal probes |

---

## 6. Authentication and certificates

Profile-based auth (cert, SAML, password) — configured in Secure Client profile XML. uvpn does not authenticate.

---

## 7. Logging and diagnostics

Client logs under OS-specific Cisco log directories; enable diagnostic logging via admin policy.

---

## 8. Exit codes and return values

Non-zero `vpn` exit when not installed or no active profile — uvpn surfaces `supported=False` or daemon errors.

---

## 9. Vendor troubleshooting

| Issue | Action |
|-------|--------|
| CLI not found | Install Secure Client; set `cisco_vpn_binary` |
| State disconnected | User must connect profile first |

---

## uvpn configuration

```json
{
  "vpn_type": "cisco_anyconnect",
  "cisco_vpn_binary": "/opt/cisco/secureclient/bin/vpn",
  "remote_lan_ip": "10.1.0.1",
  "remote_wan_ip": "203.0.113.1"
}
```

---

## uvpn monitoring

```bash
vpn state
uvpn check && uvpn explain
```

---

## Supported versions

Cisco Secure Client 5.x CLI documented in admin guide linked above.

---

## uvpn troubleshooting

- Run `vpn` as user with active VPN session (keychain/session context on macOS).
- Connected + LAN fail → `TUNNEL_DOWN`.

---

## Related

- [cisco-anyconnect.md](cisco-anyconnect.md) wiki mirror
