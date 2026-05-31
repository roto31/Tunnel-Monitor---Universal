from __future__ import annotations

import json
import logging
import os
import time
import uuid
from typing import Any, Callable

from uvpn.api.platform import MonitorAPI
from uvpn.security.auth import load_bearer_token, verify_bearer
from uvpn.security.redaction import to_public_diagnostics, to_public_status

logger = logging.getLogger("uvpn.statusd.audit")

_MUTATING = {"POST", "PUT", "PATCH", "DELETE"}


def _mask_ips_enabled() -> bool:
    return os.environ.get("UVPN_STATUS_MASK_IPS", "").strip() in ("1", "true", "yes")


def create_app(api: MonitorAPI | None = None) -> Any:
    try:
        from fastapi import Depends, FastAPI, Request
        from fastapi.responses import HTMLResponse, JSONResponse
        from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
    except ImportError as exc:
        raise ImportError(
            "Status portal requires optional dependencies: pip install 'uvpn[portal]'"
        ) from exc

    monitor = api or MonitorAPI()
    expected_token = load_bearer_token()
    bearer_scheme = HTTPBearer(auto_error=False)

    app = FastAPI(
        title="uvpn status portal",
        description="Read-only VPN monitor status (private overlay)",
        version="1.0.0",
        docs_url=None,
        redoc_url=None,
    )

    @app.middleware("http")
    async def audit_and_block_mutations(request: Request, call_next: Callable) -> Any:
        request_id = str(uuid.uuid4())
        request.state.request_id = request_id
        if request.method in _MUTATING:
            logger.warning(
                json.dumps(
                    {
                        "ts": time.time(),
                        "event": "mutation_blocked",
                        "request_id": request_id,
                        "method": request.method,
                        "path": request.url.path,
                        "src_ip": request.client.host if request.client else "",
                    }
                )
            )
            return JSONResponse(
                status_code=405,
                content={"detail": "Method not allowed"},
                headers={"Cache-Control": "no-store"},
            )
        response = await call_next(request)
        if request.url.path.startswith("/api/"):
            logger.info(
                json.dumps(
                    {
                        "ts": time.time(),
                        "event": "api_access",
                        "request_id": request_id,
                        "method": request.method,
                        "path": request.url.path,
                        "status": response.status_code,
                        "src_ip": request.client.host if request.client else "",
                    }
                )
            )
        return response

    def require_auth(
        credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
    ) -> None:
        header = None
        if credentials is not None:
            header = f"Bearer {credentials.credentials}"
        if not verify_bearer(header, expected_token):
            from fastapi import HTTPException

            raise HTTPException(status_code=401, detail="Unauthorized")

    @app.get("/health")
    async def health() -> dict[str, str]:
        return {"status": "ok"}

    @app.get("/api/v1/status")
    async def api_status(_: None = Depends(require_auth)) -> JSONResponse:
        raw = monitor.get_status()
        dto = to_public_status(raw, mask_ips=_mask_ips_enabled())
        return JSONResponse(
            content=dto.to_dict(),
            headers={"Cache-Control": "no-store"},
        )

    @app.get("/api/v1/diagnostics")
    async def api_diagnostics(_: None = Depends(require_auth)) -> JSONResponse:
        raw = monitor.get_diagnostics()
        dto = to_public_diagnostics(raw, mask_ips=_mask_ips_enabled())
        return JSONResponse(
            content=dto.to_dict(),
            headers={"Cache-Control": "no-store"},
        )

    @app.get("/", response_class=HTMLResponse)
    async def index(_: None = Depends(require_auth)) -> HTMLResponse:
        raw = monitor.get_status()
        dto = to_public_status(raw, mask_ips=_mask_ips_enabled())
        d = dto.to_dict()
        if not d.get("present"):
            body = f"<p>{d.get('message', 'No data')}</p>"
        else:
            light = d.get("traffic_light", "grey")
            diag = d.get("diagnosis", "UNKNOWN")
            alert = d.get("alert_state", "")
            body = (
                f"<p><strong>Status</strong>: {alert} "
                f"(<span>{light}</span>)</p>"
                f"<p><strong>Diagnosis</strong>: {diag}</p>"
                f"<p><small>{d.get('timestamp', '')}</small></p>"
            )
        html = (
            "<!DOCTYPE html><html><head>"
            "<meta charset=utf-8><meta name=viewport content=width=device-width>"
            "<title>uvpn status</title></head><body>"
            f"{body}"
            "</body></html>"
        )
        return HTMLResponse(
            content=html,
            headers={
                "Cache-Control": "no-store",
                "Content-Security-Policy": "default-src 'none'; style-src 'unsafe-inline'",
            },
        )

    return app
