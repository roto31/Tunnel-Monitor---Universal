# Security Policy

## Supported versions

| Version | Supported |
|---------|-----------|
| 1.1.x   | Yes |
| 1.0.x   | Best effort |
| 0.2.x and earlier | No (pre-release) |

## Reporting a vulnerability

**Do not** open public GitHub issues for security vulnerabilities.

Use one of:

1. **GitHub:** Repository → **Security** → **Report a vulnerability** (private reporting), if enabled.
2. **Maintainer:** Open a private security advisory or contact the repository owner through GitHub with the details below.

Include:

- Affected version or git tag (e.g. `uvpn-v1.1.0`)
- Platform (macOS / Linux)
- Whether the optional **status portal** (`uvpn-statusd`, `pip install -e ".[portal]"`) is in use
- Steps to reproduce and expected vs actual behavior
- Impact assessment (confidentiality of `config.json`, `state.json`, or API tokens)

We aim to acknowledge reports within **14 days** and provide a fix or mitigation timeline when confirmed.

## Scope

**In scope**

- Python package `uvpn` (monitoring engine, adapters, CLI)
- Optional read-only HTTP status portal (`uvpn-statusd`)
- Install scripts and unit files under `src/deploy/`
- Documentation and examples that could lead to unsafe deployment

**Out of scope**

- Third-party VPN clients (GlobalProtect, FortiClient, Cisco Secure Client, Pulse/Ivanti, etc.)
- Your organization’s VPN policies, firewalls, or credentials
- Host operating system vulnerabilities outside this project’s configuration guidance

## Operator security documentation

For deployment hardening (TLS, tokens, firewall, DLP redaction):

- [docs/security/README.md](docs/security/README.md)
- [docs/security/threat-model.md](docs/security/threat-model.md)
- [docs/deploy/status-portal.md](docs/deploy/status-portal.md)

## Safe use reminders

- uvpn is a **monitor**, not a VPN client. It does not connect you to a VPN.
- Do not commit `config.json`, `status-token`, or SMTP/credentials to the repository.
- The status portal is **opt-in**; bind to private overlay networks and use TLS + Bearer authentication in production.
- Review scripts before running with elevated privileges (`sudo` install paths).

## License

This project is released under the [MIT License](LICENSE).
