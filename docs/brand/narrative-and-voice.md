# Brand narrative and voice guide — Universal VPN Monitor (uvpn)

**Audience for this document:** Anyone writing docs, wiki pages, CLI/GUI copy, release notes, or internal explanations.

**Product fact (established):** uvpn is a **Linux and macOS** monitoring tool. One Python engine powers CLI, terminal menu, Linux GTK GUI, and macOS menu bar GUI. It reads vendor VPN status where available, probes reachability, and emits a single diagnosis per check. See [system-design.md](../architecture/system-design.md).

**Scope fact (established):** uvpn is **not** a VPN client. It does not connect you to a VPN. It watches an existing client or routed path.

**Platform note:** Scenarios below mention **iOS** where freelancers and students often work; uvpn today runs on **macOS and Linux hosts** only. When writing for iOS-only users, be explicit: monitor from a Mac/Linux machine on the same network, or use `generic` probes toward resources you need—not an App Store agent (hypothetical future).

---

## 1. Why this exists — the backstory

### The afternoon everyone remembers

Picture a Tuesday that should have been ordinary.

**Maya** is a contract project manager. She is on a **MacBook** at home, **GlobalProtect** green in the menu bar, and a client demo in twenty minutes. She opens the project share and gets spinning beachballs—not a password prompt, not a polite error, just nothing. She reboots the laptop, reconnects VPN, still nothing. Forty-five minutes later she learns the tunnel was “up” while only a slice of routes were pushed—a **split-tunnel** policy her client’s IT team configured last month. Maya did nothing wrong. The UI did not lie; it just did not tell the whole story.

Same week, different building: **Jordan** is a graduate student on **Ubuntu**, using the university’s **Pulse/Ivanti** client to reach a lab file share for thesis data. The client says connected. `ping` to the lab subnet does not answer. Jordan files a ticket. Three days pass. The fix is a **Trusted Server** entry missing on a rebuilt laptop image—not mysterious internet gremlins.

**Alex** freelances across two clients: **FortiClient** for one, **Pulse** for another, both on the same **Mac**. Alex is not confused about credentials; Alex is tired of being the help desk for their own livelihood. Every new client means another icon, another policy, another “it works on my machine” call.

And **Sam**—the only person who is also “the network person” at a twelve-person company—gets the Slack ping while shipping a feature: “VPN’s broken again.” Sam SSHs, checks logs, pings, checks DDNS, discovers the remote office router got a new DHCP lease and the **DDNS** record is stale. Sam fixes it in ten minutes but loses an evening. Sam’s company cannot afford a NOC; Sam *is* the NOC.

None of these people failed at technology. They failed at **visibility**: the gap between *the VPN client thinks it is fine* and *the work you need to do is actually reachable*.

### What uvpn is for

**Universal VPN Monitor** lives in that gap.

It runs on a **Mac or Linux** machine you control—your laptop, a small office server, a studio Linux box—and asks two honest questions on a schedule you choose:

1. What does the **VPN control plane** say? (FortiClient, GlobalProtect, Pulse, Cisco Secure Client, OpenVPN management, WireGuard handshakes, strongSwan SAs—when installed.)
2. Can we still **reach** the host or network that matters for your work?

When those answers disagree, uvpn does not moralize. It names the kind of mismatch—**`VPN_NEGOTIATION_FAILED`** when the client says connected but your LAN probe fails; **`DDNS_DRIFT`** when DNS and config disagree; **`REMOTE_INTERNET_DOWN`** when the far side’s WAN is gone—so the next step is obvious instead of theatrical.

That is the whole brand promise: **know which kind of broken you have before you burn an hour fixing the wrong thing.**

### Hypothetical vs fact

| In the story above | Status |
|--------------------|--------|
| Split tunnel can show “connected” while some subnets are unreachable | **Established** — common enterprise VPN behavior; uvpn maps many cases to `VPN_NEGOTIATION_FAILED` |
| Pulse Linux CLI may require Trusted Server policy | **Established** — documented in [pulse-ivanti.md](../vpn-solutions/pulse-ivanti.md) |
| DDNS can drift when remote ISP changes IP | **Established** — uvpn checks `remote_ddns` vs `remote_wan_ip` |
| uvpn runs on iOS or monitors iOS VPN directly | **Not shipped** — hypothetical / future; say so if referenced |
| uvpn replaces IT ticketing or vendor support | **False** — it reduces guesswork; it does not open firewall tickets |

---

## 2. Who we speak to

### Remote workers and students

- **Need:** “Is it me, my Wi‑Fi, the VPN, or the site?”
- **Tone:** Calm, specific, no blame. Assume intelligence, assume interruption.
- **Proof:** `uvpn check` + `uvpn explain` in plain language.

### Freelancers and contractors

- **Need:** Repeatable checks across **different clients and VPN products** without relearning each UI.
- **Tone:** Respect juggling acts. One config file per machine; link to the right platform guide.
- **Proof:** Adapter matrix and per-vendor docs—not “one VPN to rule them all.”

### Resource-constrained IT / “accidental infrastructure”

- **Need:** Scriptable monitoring, scheduling (systemd/LaunchAgent), honest limitations, no sales fog.
- **Tone:** Peer engineer. Short paths to logs and flowcharts. Acknowledge you are not getting a 24/7 SOC.
- **Proof:** [troubleshooting/](../troubleshooting/README.md) with Mermaid flows, fixture-validated enterprise parsers.

### Skeptical IT directors

- **Need:** Risk clarity, scope boundaries, version pins.
- **Tone:** Factual, citable vendor docs, no whimsy in security claims.
- **Proof:** Citations sections in platform guides; `adapter-version-matrix.md`.

---

## 3. Voice principles

| Do | Don’t |
|----|--------|
| Name the user’s next action | Dump jargon without translation |
| Use short scenes to open major docs | Perform cuteness (mascots, forced puns every paragraph) |
| Separate **fact** vs **example** | Present hypotheticals as universal law |
| Celebrate small wins (“preflight passed”) | Promise zero false positives |
| Acknowledge ICMP filtering, split tunnel, MFA | Pretend one diagnosis fits every vendor |

### Personality in one sentence

**A careful colleague who already checked the obvious things and wrote down what they found.**

### Grammar and style

- **Second person** (“you”) for operators; **we** sparingly for the product team.
- **Present tense** for behavior; past tense for stories.
- **Sentence length:** mix short declarative with one technical clause max.
- **Headings:** task-oriented (“Fix DDNS drift”) not marketing (“Experience excellence”).
- **Humor:** dry, rare, never at the user’s expense.

### Technical thoroughness

- Keep tables, flowcharts, CLI blocks, and diagnosis order **accurate**.
- Whimsy belongs in **openers, transitions, and runbook framing**—not in replacing probe logic.
- Link to platform troubleshooting for vendor-specific branches.

---

## 4. Narrative connective tissue (use everywhere)

Rotate these motifs; do not paste all into every page.

1. **The green icon lie** — connected UI ≠ reachable work (when true for that stack).
2. **The wrong hour** — fixing DNS when the client was disconnected.
3. **Sam’s Tuesday** — one person, many hats; uvpn as checklist not hero.
4. **Before the demo / before the deadline** — stakes without melodrama.

**Standard doc opener (optional, 2–3 sentences):**

> You are here because something you need across a VPN did not respond—and the client may still look fine. uvpn separates *client state* from *path health* so you can fix the right layer. The steps below are technical on purpose; the goal is to save you one wrong detour.

**Standard troubleshooting closer:**

> When this page is not enough, capture `uvpn check`, redact secrets from `config.json`, and attach your vendor’s status output. You should leave with a named problem, not a mystery.

---

## 5. Channel guide

### README / wiki home

- Open with problem + who it helps (one short paragraph).
- Then facts: platforms, adapters, version.
- Link to brand doc for writers.

### Setup guides

- Frame install as **insurance**, not homework.
- “Preflight” = handshake before trust.

### Platform guides (vpn-solutions)

- Keep incorporated vendor structure (sections 1–9).
- Add 1–2 sentence **“Why uvpn cares”** under §5 Status and monitoring.
- Citations stay formal at bottom.

### Troubleshooting

- Keep Mermaid and diagnosis order.
- Beginner blocks: empathetic one-liner, then steps.
- Advanced blocks: unchanged rigor.

### CLI / `uvpn explain` / GUI

- Use [messaging-snippets.md](messaging-snippets.md) diagnosis one-liners.
- Steps: imperative verbs, max 3–5 bullets unless runbook requires more.

### Error / preflight lines

- Format: **What happened** → **What you can do** → **Doc link** (if any).
- Never shame (“misconfigured”) — prefer “not set yet” / “not found in PATH”.

### Status / traffic light

- Green: “Path looks good.”
- Yellow: “Something’s off; not counted as down yet” (threshold).
- Red: “Sustained failure—see diagnosis.”
- Grey: “Can’t read this stack yet.”

---

## 6. Platform scenarios (reference library)

Use as sidebar stories in docs—label **Example** when fictionalized.

| Persona | Platform | VPN stack (example) | Pain | uvpn helps by |
|---------|----------|----------------------|------|----------------|
| Maya | macOS | GlobalProtect | Connected UI, app unreachable | `globalprotect` + LAN probe → `VPN_NEGOTIATION_FAILED` |
| Jordan | Linux | Pulse/Ivanti | Trusted Server / policy | `pulse` + guides for Linux CLI |
| Alex | macOS | Forti + Pulse (sequential) | Context switching | Separate configs or `vpn_type` per host |
| Sam | Linux server | WireGuard site-to-site | DDNS drift | `wireguard` or `generic` + `DDNS_DRIFT` |
| Student lab | Linux | OpenVPN to campus | Management port disabled | `openvpn` + enable management or `generic` |
| Contractor | macOS | Cisco Secure Client | Wrong macOS user session | `cisco_anyconnect` + run as GUI user |

**iOS (hypothetical user, factual limitation):** A freelancer checks client email on **iPhone**; uvpn does not run on the phone today. Document: run uvpn on the **Mac** that shares the tunnel or monitor a **bastion** IP with `generic`.

---

## 7. What we are not claiming

- uvpn does not configure VPNs, rotate passwords, or bypass MFA.
- uvpn does not guarantee detection of every vendor edge case—unsupported stdout yields `supported=False`.
- Lab-validated on fixtures + vendor docs; your site may differ—capture stdout for maintainers.
- Legacy bash UniFi monitor is a **different product line** under `legacy/`.

---

## 8. Checklist for reviewers

Before publishing user-facing copy:

- [ ] Opens with user outcome, not feature list?
- [ ] Platform scope (Linux/macOS) accurate?
- [ ] Hypotheticals labeled if not universally true?
- [ ] Diagnosis names match `Diagnosis` enum in code?
- [ ] Links to troubleshooting flow for that `vpn_type`?
- [ ] Tone helpful, not patronizing or salesy?

---

## 9. Related

- [messaging-snippets.md](messaging-snippets.md)
- [troubleshooting/universal.md](../troubleshooting/universal.md)
- [Public legacy troubleshooting](../legacy/Public/docs/troubleshooting.md) (UniFi-specific; different voice OK)
