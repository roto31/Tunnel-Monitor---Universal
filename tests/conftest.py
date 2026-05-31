from __future__ import annotations

from pathlib import Path

FIXTURES_ROOT = Path(__file__).resolve().parent / "fixtures" / "adapters"


def load_fixture(adapter: str, name: str) -> str:
    path = FIXTURES_ROOT / adapter / name
    return path.read_text(encoding="utf-8")
