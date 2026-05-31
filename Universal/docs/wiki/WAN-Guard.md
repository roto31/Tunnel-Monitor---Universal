# WAN Guard

**Optional hub-only module** for dual-WAN setups where the remote site dials a **DDNS hostname**.

**Path:** `adapters/unifi-gateway/modules/wan-guard/` or `Public/unifi/wan-guard/`

## Problem it solves

When primary public WAN fails over to a **CGNAT backup** (e.g. T-Mobile), UniFi's built-in DDNS can publish a private IP. Remote OpenVPN then breaks. WAN Guard:

- Reads IP only on the **primary public interface**
- Blocks DDNS updates when IP is RFC1918/CGNAT
- Syncs hostname via No-IP API when public IP changes
- Sends email on CGNAT block (once per bad IP)

## Install

Append keys from `config-additions.env` to `/data/tunnel-monitor/config.env`, then:

```bash
bash modules/wan-guard/install.sh   # or unifi/wan-guard/install.sh
wan-guard --status
```

## Do not install on

- Spoke / remote gateway
- Generic Linux adapter (not bundled)
- Single-WAN sites (unnecessary)

Details: [Public/docs/wan-guard-openvpn-failover.md](https://github.com/roto1231/Tunnel-Monitor---Universal/blob/main/Public/docs/wan-guard-openvpn-failover.md)
