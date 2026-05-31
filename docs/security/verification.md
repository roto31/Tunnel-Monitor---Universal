# Verification and audit plan — status portal

Evidence for **NIST SP 800-53 Rev 5 Moderate** mapping lives in [ctm-portal.csv](ctm-portal.csv). Update **Last_Tested** after each activity.

---

## Automated (CI)

| Check | Tool | Workflow | Evidence |
|-------|------|----------|----------|
| Unit tests | pytest | `uvpn-ci.yml` job `portal` | Pass/fail log |
| SAST | bandit | `uvpn-ci.yml` | Report artifact |
| Dependencies | pip-audit | `uvpn-ci.yml` on `[portal]` | CVE report |

```bash
pip install -e ".[portal,dev]"
pytest -q tests/test_redaction.py tests/test_statusd.py
bandit -r src/uvpn/interfaces/statusd src/uvpn/security -ll
pip-audit -r <(pip freeze)
```

---

## Staging / production (private overlay)

| Control | Method | Maps to |
|---------|--------|---------|
| AC-3, AC-17 | `curl` without token; from disallowed IP | 403 + firewall drop |
| IA-5 | Rotate token; old token fails | Change record |
| SC-8, 800-52 | `testssl.sh` or `sslyze` against HTTPS endpoint | SP 800-52 Rev 2 Sec 3.1–3.2 checklist |
| AU-2, AU-3 | Inspect one audit JSON line | No secrets in body |
| CM-6 | `systemd-analyze security uvpn-statusd.service` | Score ≥ target |
| SI-10 | `curl -X POST /api/v1/status` | HTTP 405 |

### SP 800-52 manual checklist (TLS terminator)

- [ ] TLS 1.0/1.1 disabled (**Sec. 3.1**)
- [ ] TLS 1.3 or 1.2 with AEAD ciphers only (**Sec. 3.2**)
- [ ] Certificate chain valid; key file mode `0600` (**Sec. 4**)
- [ ] No sensitive topology on `/health` (**Sec. 5**)

---

## Cadence

| Interval | Activity |
|----------|----------|
| Weekly | CI dep scan; review failed auth count |
| Monthly | Firewall rules; token age; cert expiry |
| Quarterly | Token rotation drill; CTM row updates |
| Annual | Tabletop: revoke token, stop unit; optional private-net pen test (CA-8) |

---

## CSF 2.0 organizational profile

Document **Current** vs **Target** for PR.DS (data protection) and DE.CM (monitoring). Portal adoption moves Target toward authenticated read-only status on private overlay.
