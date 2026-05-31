from __future__ import annotations

from datetime import datetime, timezone

from uvpn.adapters.registry import get_adapter
from uvpn.core.config import MonitorConfig
from uvpn.core.diagnosis import RUNBOOKS, compute_diagnosis, traffic_light_for
from uvpn.core.models import CheckSnapshot, Diagnosis
from uvpn.core.probes import dns_matches_expected, run_universal_probes
from uvpn.core.state_store import StateStore


class MonitorEngine:
    """Single Python monitoring engine shared by CLI, TUI, and GUIs."""

    SCHEMA_VERSION = 1

    def __init__(self, config: MonitorConfig | None = None, store: StateStore | None = None) -> None:
        self.config = config or MonitorConfig.load()
        self.store = store or StateStore()

    def _resolve_vpn_type(self) -> str:
        if self.config.vpn_type and self.config.vpn_type.lower() != "auto":
            return self.config.vpn_type.lower()
        return "generic"

    def run_check(self) -> CheckSnapshot:
        vpn_type = self._resolve_vpn_type()
        cfg_dict = {
            "openvpn_management": self.config.openvpn_management,
            "wireguard_interface": self.config.wireguard_interface,
            "interface_name": self.config.interface_name,
            "ipsec_tool": self.config.ipsec_tool,
            "cisco_vpn_binary": self.config.cisco_vpn_binary,
            **self.config.extra,
        }
        adapter = get_adapter(vpn_type).probe(cfg_dict)
        probes = run_universal_probes(
            self.config.remote_lan_ip,
            self.config.remote_wan_ip,
            self.config.remote_ddns,
        )
        dns_match = dns_matches_expected(probes["dns"], self.config.remote_wan_ip)
        diagnosis = compute_diagnosis(probes, adapter, dns_match)

        prev_fail = self.store.read_failure_count()
        prev_alert = self.store.read_alert_state()
        if diagnosis == Diagnosis.HEALTHY:
            failure_count = 0
            alert_state = "UP"
        elif diagnosis == Diagnosis.OUR_INTERNET_DOWN:
            failure_count = prev_fail
            alert_state = prev_alert
        else:
            failure_count = prev_fail + 1
            alert_state = (
                "DOWN"
                if failure_count >= self.config.failure_threshold
                else prev_alert
            )

        traffic = traffic_light_for(diagnosis, failure_count, self.config.failure_threshold)
        summary, steps = RUNBOOKS.get(diagnosis, RUNBOOKS[Diagnosis.UNKNOWN])
        issues = [summary]
        if adapter.detail:
            issues.append(adapter.detail)

        now = datetime.now(timezone.utc).astimezone().isoformat()
        snapshot = CheckSnapshot(
            schema_version=self.SCHEMA_VERSION,
            timestamp=now,
            vpn_type=vpn_type,
            diagnosis=diagnosis,
            traffic_light=traffic,
            alert_state=alert_state,
            failure_count=failure_count,
            probes=probes,
            adapter=adapter,
            issues=issues,
            recommended_steps=steps,
        )
        self.store.write_snapshot(snapshot)
        return snapshot

    def explain(self, diagnosis_code: str | None = None) -> str:
        data = self.store.read()
        code = diagnosis_code or (data or {}).get("diagnosis", "UNKNOWN")
        try:
            diag = Diagnosis(code)
        except ValueError:
            diag = Diagnosis.UNKNOWN
        summary, steps = RUNBOOKS.get(diag, RUNBOOKS[Diagnosis.UNKNOWN])
        lines = [f"Diagnosis: {diag.value}", "", summary, "", "Steps:"]
        lines.extend(f"  {i}. {s}" for i, s in enumerate(steps, 1))
        return "\n".join(lines)

    def preflight(self) -> tuple[int, list[str]]:
        import shutil

        lines: list[str] = []
        fails = 0
        for cmd in ("python3", "ping", "dig"):
            if shutil.which(cmd):
                lines.append(f"OK   {cmd}")
            else:
                lines.append(f"FAIL {cmd}")
                fails += 1
        if self.config.remote_lan_ip:
            lines.append(f"OK   remote_lan_ip={self.config.remote_lan_ip}")
        else:
            lines.append("FAIL remote_lan_ip not set")
            fails += 1
        if self.config.remote_wan_ip:
            lines.append(f"OK   remote_wan_ip={self.config.remote_wan_ip}")
        else:
            lines.append("WARN remote_wan_ip not set")
        adapter = get_adapter(self._resolve_vpn_type())
        status = adapter.probe(
            {
                "openvpn_management": self.config.openvpn_management,
                "wireguard_interface": self.config.wireguard_interface,
                "ipsec_tool": self.config.ipsec_tool,
                "cisco_vpn_binary": self.config.cisco_vpn_binary,
            }
        )
        lines.append(
            f"{'OK' if status.supported else 'WARN'} adapter {status.adapter_id}: {status.detail}"
        )
        return fails, lines
