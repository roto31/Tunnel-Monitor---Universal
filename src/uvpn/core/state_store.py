from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path

from uvpn.core.config import state_path
from uvpn.core.models import CheckSnapshot


def _atomic_write(path: Path, payload: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    tmp.replace(path)


class StateStore:
    def __init__(self, path: Path | None = None) -> None:
        self.path = path or state_path()

    def read(self) -> dict | None:
        if not self.path.is_file():
            return None
        return json.loads(self.path.read_text(encoding="utf-8"))

    def write_snapshot(self, snapshot: CheckSnapshot) -> None:
        _atomic_write(self.path, snapshot.to_dict())

    def read_failure_count(self) -> int:
        data = self.read()
        if not data:
            return 0
        fc = data.get("failure_count", 0)
        return int(fc) if isinstance(fc, int) else 0

    def read_alert_state(self) -> str:
        data = self.read()
        if not data:
            return "UP"
        st = data.get("alert_state", "UP")
        return st if st in ("UP", "DOWN") else "UP"
