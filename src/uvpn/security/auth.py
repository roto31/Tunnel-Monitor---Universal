from __future__ import annotations

import os
import secrets
from pathlib import Path


def load_bearer_token() -> str | None:
    """Load expected Bearer token from env or file (IA-5: protect at rest with 0600)."""
    direct = os.environ.get("UVPN_STATUS_TOKEN", "").strip()
    if direct:
        return direct
    path_str = os.environ.get("UVPN_STATUS_TOKEN_FILE", "").strip()
    if not path_str:
        return None
    path = Path(path_str)
    if not path.is_file():
        return None
    return path.read_text(encoding="utf-8").strip()


def verify_bearer(authorization: str | None, expected: str | None) -> bool:
    """Constant-time compare; fail closed when token not configured."""
    if not expected:
        return False
    if not authorization or not authorization.startswith("Bearer "):
        return False
    provided = authorization[7:].strip()
    if not provided:
        return False
    return secrets.compare_digest(provided.encode("utf-8"), expected.encode("utf-8"))
