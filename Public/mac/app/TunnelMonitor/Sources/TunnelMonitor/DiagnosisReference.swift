import Foundation

/// Operator runbooks aligned with `Universal/vendor/core/lib/operator-lib.sh`.
enum DiagnosisReference {

    struct Guide: Equatable {
        let summary: String
        let technicalDetail: String
        let steps: [String]
    }

    static func normalize(_ code: String) -> String {
        switch code {
        case "UDR7_UNREACHABLE", "ROUTER_UNREACHABLE":
            return "GATEWAY_UNREACHABLE"
        case "RESET", "PENDING_FIRST_RUN":
            return "UNKNOWN"
        default:
            return code
        }
    }

    static func guide(for code: String) -> Guide {
        let normalized = normalize(code)
        switch normalized {
        case "HEALTHY":
            return Guide(
                summary: "All probes passed; tunnel LAN reachable.",
                technicalDetail: """
                Decision tree stopped at tunnel ping OK. Gateway dedup may still show \
                N:DOWN while the tunnel is up — email is suppressed in that case.
                """,
                steps: ["No action required.", "Optional: run Preflight from Actions or `tunnel-check --preflight`."]
            )
        case "OUR_INTERNET_DOWN":
            return Guide(
                summary: "Local internet down; failure counter frozen; no tunnel alert.",
                technicalDetail: """
                Probe to 1.1.1.1 failed before tunnel logic. Alerts are suppressed until \
                local internet recovers to avoid false tunnel-down pages during ISP outages.
                """,
                steps: [
                    "Fix local internet (router, ISP, DNS).",
                    "Force Check after recovery."
                ]
            )
        case "GATEWAY_UNREACHABLE":
            return Guide(
                summary: "Gateway SSH dedup failed; this LAN client owns alerting.",
                technicalDetail: """
                Tunnel ping failed and SSH to the gateway sidecar did not return a valid \
                state line. Common causes: gateway offline, SSH blocked on :22, wrong key, \
                stale known_hosts, or sidecar not running.
                """,
                steps: [
                    "Ping gateway LAN IP; run SSH Test.",
                    "Allow LAN→gateway:22 on firewall.",
                    "On gateway: confirm sidecar monitor and state file.",
                    "Clear known_hosts if the host key changed."
                ]
            )
        case "DISAGREEMENT":
            return Guide(
                summary: "Gateway reports tunnel UP (0:UP) but LAN cannot reach remote LAN.",
                technicalDetail: """
                strongSwan/UniFi may show an established SA while policy routing, remote \
                LAN firewall, or stale SA prevents ICMP over the tunnel. Remote WAN can still \
                ping while LAN routing over VPN is broken.
                """,
                steps: [
                    "On gateway: verify VPN SA / UniFi VPN status.",
                    "Compare ping to REMOTE_LAN_IP from gateway vs this Mac.",
                    "Review policy routes and VPN interface binding.",
                    "Bounce VPN on gateway if SA looks stale."
                ]
            )
        case "DDNS_DRIFT":
            return Guide(
                summary: "DDNS hostname does not match configured remote WAN IP.",
                technicalDetail: """
                After a WAN IP change, peers keyed on hostname may dial the wrong address \
                until DDNS or REMOTE_WAN_IP in config.env is corrected.
                """,
                steps: [
                    "Resolve DDNS from this Mac and compare to REMOTE_WAN_IP.",
                    "Update DDNS A record or config.env."
                ]
            )
        case "REMOTE_INTERNET_DOWN":
            return Guide(
                summary: "Remote site WAN unreachable from this vantage.",
                technicalDetail: """
                REMOTE_WAN_IP ICMP failed. Confirm remote ISP outage; some sites filter \
                inbound ICMP which can produce false remote-down readings.
                """,
                steps: [
                    "Confirm remote site power and ISP status.",
                    "If ICMP is filtered, treat WAN probe with caution."
                ]
            )
        case "TUNNEL_DOWN":
            return Guide(
                summary: "Remote WAN and DDNS OK but tunnel LAN ping failed.",
                technicalDetail: """
                VPN data plane issue. IPsec: UDP 500/4500 blocked (IKE no response), PSK \
                mismatch, or peer ID errors. OpenVPN: port forward/DMZ and static key/certs. \
                WAN reachable does not imply IKE or tunnel interface is working.
                """,
                steps: [
                    "Inspect gateway VPN logs (charon / UniFi VPN).",
                    "If ISP blocks IPsec, consider OpenVPN on alternate port (see docs).",
                    "Verify PSK/certs and peer addresses on both gateways.",
                    "Force Check after changes."
                ]
            )
        default:
            return Guide(
                summary: "No stable diagnosis yet.",
                technicalDetail: "State may be reset or awaiting first daemon cycle (every 5 minutes).",
                steps: [
                    "Run Preflight or `tunnel-check --preflight`.",
                    "Force Check, then review again."
                ]
            )
        }
    }
}
