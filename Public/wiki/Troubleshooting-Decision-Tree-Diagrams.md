# Troubleshooting decision tree diagrams

Mermaid flowcharts for every branch in [[Troubleshooting-Decision-Trees]]. **First match wins** unless noted.

Text tables: [[Troubleshooting-Decision-Trees]] · Step-by-step: [[Troubleshooting]] · General workflows: [[Workflow-Diagrams]]

---

## 1. Master triage

Start here when an alert fires or `tunnel-check` looks wrong.

```mermaid
flowchart TD
    START([Symptom or alert]) --> Q1{Mac can reach<br/>internet?<br/>ping 1.1.1.1}
    Q1 -- no --> OID[OUR_INTERNET_DOWN<br/>fix local ISP<br/>no email sent]:::skip
    Q1 -- yes --> Q2{tunnel-check<br/>HEALTHY?}
    Q2 -- yes --> Q2B{Remote device<br/>still unreachable?}
    Q2B -- yes --> CLIENT[Client or firewall<br/>on remote LAN<br/>not monitor bug]:::skip
    Q2B -- no --> OK[No action needed]:::ok
    Q2 -- no --> Q3{Both Mac and gateway<br/>emailed DOWN?}
    Q3 -- yes --> TUNNEL[Go to tunnel down tree]:::alert
    Q3 -- no --> Q4{Only Mac alert<br/>gateway silent?}
    Q4 -- yes --> DEDUP[Expected dedup<br/>gateway N:DOWN<br/>read Mac banner]:::skip
    Q4 -- no --> Q5{Dual-WAN hub<br/>primary WAN down?}
    Q5 -- yes --> WAN[Go to dual-WAN tree]:::alert
    Q5 -- no --> TUNNEL

    classDef ok fill:#e6f4ea,stroke:#137333,color:#0a3d20
    classDef skip fill:#eceff1,stroke:#546e7a,color:#1c2a33
    classDef alert fill:#fce8e6,stroke:#c5221f,color:#5b0f0a
```

---

## 2. Tunnel down — identify diagnosis

Mac `tunnel-check` shows DOWN (after local internet is OK).

```mermaid
flowchart TD
    START([tunnel-check DOWN]) --> Q1{SSH to ROUTER_HOST<br/>succeeds?}
    Q1 -- no --> RU[ROUTER_UNREACHABLE<br/>power-cycle hub<br/>fix SSH key]:::alert
    Q1 -- yes --> Q2{Gateway state<br/>== 0:UP?}
    Q2 -- yes --> DIS[DISAGREEMENT<br/>Mac path issue]:::alert
    Q2 -- no --> Q3{ping REMOTE_WAN_IP?}
    Q3 -- no --> RID[REMOTE_INTERNET_DOWN<br/>wait for remote ISP]:::alert
    Q3 -- yes --> Q4{dig REMOTE_DDNS<br/>== REMOTE_WAN_IP?}
    Q4 -- no --> DD[DDNS_DRIFT<br/>update remote DDNS]:::alert
    Q4 -- yes --> VPN[VPN path down<br/>see OpenVPN tree]:::alert

    classDef alert fill:#fce8e6,stroke:#c5221f,color:#5b0f0a
```

---

## 3. OpenVPN / VPN path down

Remote WAN reachable and remote DDNS correct, but tunnel ping fails.

```mermaid
flowchart TD
    START([VPN path down]) --> Q1{dig WAN_GUARD_HOSTNAME<br/>private or CGNAT?}
    Q1 -- yes --> FIXDNS[Fix DDNS to public IP<br/>enable WAN Guard<br/>disable backup WAN DDNS]:::alert
    Q1 -- no --> Q2{Hub DDNS public<br/>but tunnel down?}
    Q2 -- yes --> OUTAGE[Primary WAN outage likely<br/>wan-guard cgnat_blocked<br/>wait for restore]:::skip
    Q2 -- no --> Q3{Hub ping REMOTE_LAN_IP OK<br/>spoke UI offline?}
    Q3 -- yes --> SPOKE[Fix remote spoke<br/>tunnel or policy]:::alert
    Q3 -- no --> Q4{Logs show<br/>ping-restart timeout?}
    Q4 -- yes --> ROUTE[Route stuck on backup WAN<br/>toggle tunnel in UniFi]:::alert
    Q4 -- no --> Q5{New config<br/>never connected?}
    Q5 -- yes --> NEW[Match 512-char key<br/>DMZ or port 1194<br/>try 8443 both ends]:::alert
    Q5 -- no --> LOGS[journalctl openvpn<br/>see OpenVPN migration guide]:::alert

    classDef alert fill:#fce8e6,stroke:#c5221f,color:#5b0f0a
    classDef skip fill:#eceff1,stroke:#546e7a,color:#1c2a33
```

---

## 4. Dual-WAN / WAN Guard

Local hub has primary public WAN plus backup CGNAT WAN.

```mermaid
flowchart TD
    START([Dual-WAN symptom]) --> Q1{Alert CGNAT blocked<br/>on primary WAN?}
    Q1 -- yes --> WAIT[Do NOT set DDNS<br/>to backup address<br/>wait for primary]:::skip
    Q1 -- no --> Q2{wan-guard status<br/>cgnat_blocked?}
    Q2 -- yes --> VERIFY[Normal in outage<br/>DNS must not be CGNAT]:::skip
    Q2 -- no --> Q3{Primary restored<br/>not in_sync?}
    Q3 -- yes --> CHECK[wan-guard check<br/>verify WAN_GUARD_INTERFACE]:::alert
    Q3 -- no --> Q4{Missing ALERT_EMAIL?}
    Q4 -- yes --> SMTP[Set ALERT_TO in config<br/>update wan-guard.sh]:::alert
    Q4 -- no --> Q5{CLI config not found?}
    Q5 -- yes --> PATH[Run /data/wan-guard/wan-guard.sh<br/>or reinstall]:::alert
    Q5 -- no --> OK[in_sync — no WAN Guard action]:::ok

    classDef ok fill:#e6f4ea,stroke:#137333,color:#0a3d20
    classDef skip fill:#eceff1,stroke:#546e7a,color:#1c2a33
    classDef alert fill:#fce8e6,stroke:#c5221f,color:#5b0f0a
```

Runbook: [[WAN-Guard-OpenVPN-Failover]].

---

## 5. DDNS_DRIFT (remote)

`REMOTE_DDNS` resolves to something other than `REMOTE_WAN_IP`.

```mermaid
flowchart TD
    START([DDNS_DRIFT]) --> Q1{Remote site<br/>has internet?}
    Q1 -- yes --> UPDATE[Update DDNS A record<br/>to current public IP]:::alert
    Q1 -- no --> RID[REMOTE_INTERNET_DOWN]:::alert
    UPDATE --> WAIT[Wait 5 min or<br/>check-now x3]:::ok

    classDef ok fill:#e6f4ea,stroke:#137333,color:#0a3d20
    classDef alert fill:#fce8e6,stroke:#c5221f,color:#5b0f0a
```

---

## 6. REMOTE_INTERNET_DOWN

```mermaid
flowchart TD
    START([REMOTE_INTERNET_DOWN]) --> Q1{ping REMOTE_WAN_IP<br/>fails Mac and gateway?}
    Q1 -- yes --> WAIT[Remote ISP outage<br/>no local fix]:::skip
    Q1 -- no --> Q2{Remote modem<br/>reports up?}
    Q2 -- yes --> MODEM[Check upstream modem<br/>power-cycle]:::alert
    Q2 -- no --> WAIT

    classDef skip fill:#eceff1,stroke:#546e7a,color:#1c2a33
    classDef alert fill:#fce8e6,stroke:#c5221f,color:#5b0f0a
```

---

## 7. ROUTER_UNREACHABLE

Mac cannot SSH to `ROUTER_HOST` for dedup.

```mermaid
flowchart TD
    START([ROUTER_UNREACHABLE]) --> Q1{ping ROUTER_HOST?}
    Q1 -- no --> POWER[Power or network<br/>at local gateway]:::alert
    Q1 -- yes --> Q2{tunnel-check<br/>--ssh-test OK?}
    Q2 -- no --> SSH[Fix authorized_keys<br/>rm known_hosts on Mac]:::alert
    Q2 -- yes --> OK[SSH OK — re-run triage]:::ok
    SSH --> Q3{After firmware<br/>still fails?}
    Q3 -- yes --> REINST[Re-run Mac and gateway<br/>install.sh]:::alert

    classDef ok fill:#e6f4ea,stroke:#137333,color:#0a3d20
    classDef alert fill:#fce8e6,stroke:#c5221f,color:#5b0f0a
```

---

## 8. DISAGREEMENT

Gateway state `0:UP`, Mac cannot ping `REMOTE_LAN_IP`.

```mermaid
flowchart TD
    START([DISAGREEMENT]) --> Q1{Mac on trusted<br/>local LAN?}
    Q1 -- no --> VLAN[Leave guest VLAN<br/>rejoin main LAN]:::alert
    Q1 -- yes --> Q2{route to REMOTE_LAN_IP<br/>via tunnel?}
    Q2 -- no --> NET[Toggle Mac networking<br/>verify hub routes subnet]:::alert
    Q2 -- yes --> Q3{Hub SSH ping OK<br/>Mac still fails?}
    Q3 -- yes --> FW[Compare hub vs Mac ping<br/>check Mac firewall]:::alert
    Q3 -- no --> NET

    classDef alert fill:#fce8e6,stroke:#c5221f,color:#5b0f0a
```

---

## 9. OUR_INTERNET_DOWN (Mac)

```mermaid
flowchart TD
    START([Local internet suspect]) --> Q1{ping 1.1.1.1<br/>from Mac?}
    Q1 -- no --> FIX[Fix local ISP<br/>monitor suppresses alerts]:::skip
    Q1 -- yes --> Q2{Stale DOWN state<br/>after restore?}
    Q2 -- yes --> CHECK[check-now until HEALTHY]:::ok
    Q2 -- no --> OK[Not OUR_INTERNET_DOWN]:::ok

    classDef ok fill:#e6f4ea,stroke:#137333,color:#0a3d20
    classDef skip fill:#eceff1,stroke:#546e7a,color:#1c2a33
```

---

## 10. Email and alerting

```mermaid
flowchart TD
    START([Alert delivery issue]) --> Q1{Banner works<br/>no email?}
    Q1 -- yes --> SMTP[Check SMTP app password<br/>test-email]:::alert
    Q1 -- no --> Q2{Duplicate emails<br/>Mac and gateway?}
    Q2 -- yes --> DEDUP[Fix SSH dedup<br/>--ssh-test]:::alert
    Q2 -- no --> Q3{Gateway emails<br/>Mac silent on DOWN?}
    Q3 -- yes --> EXPECT[Expected dedup<br/>N:DOWN on gateway]:::skip
    Q3 -- no --> SMTP

    classDef skip fill:#eceff1,stroke:#546e7a,color:#1c2a33
    classDef alert fill:#fce8e6,stroke:#c5221f,color:#5b0f0a
```

---

## 11. Post–firmware update (gateway)

```mermaid
flowchart TD
    START([After UniFi firmware]) --> Q1{tunnel-check<br/>missing or timer dead?}
    Q1 -- yes --> TM[Re-run tunnel-monitor<br/>install.sh]:::alert
    Q1 -- no --> Q2{wan-guard timer<br/>inactive?}
    Q2 -- yes --> WG[Re-run wan-guard<br/>install.sh]:::alert
    Q2 -- no --> Q3{Wrong WAN_GUARD<br/>interface?}
    Q3 -- yes --> IFACE[ip -4 addr<br/>update config]:::alert
    Q3 -- no --> OK[Monitors OK]:::ok

    classDef ok fill:#e6f4ea,stroke:#137333,color:#0a3d20
    classDef alert fill:#fce8e6,stroke:#c5221f,color:#5b0f0a
```

---

## 12. Legacy IPsec

```mermaid
flowchart TD
    START([IPsec problem]) --> Q1{Modem known to block<br/>UDP 500 and 4500?}
    Q1 -- yes --> OVPN[Migrate to OpenVPN]:::alert
    Q1 -- no --> Q2{Tune IKE and keys<br/>still failing?}
    Q2 -- yes --> OVPN
    Q2 -- no --> Q3{OpenVPN up<br/>ipsec empty?}
    Q3 -- yes --> RETIRE[Disable legacy IPsec<br/>in UniFi UI]:::ok
    Q3 -- no --> IKE[Continue IPsec debug]:::alert

    classDef ok fill:#e6f4ea,stroke:#137333,color:#0a3d20
    classDef alert fill:#fce8e6,stroke:#c5221f,color:#5b0f0a
```

Guide: [[OpenVPN-Site-to-Site-Migration]].

---

## 13. Mac alert dedup (email vs banner)

Applied after a DOWN diagnosis when threshold is crossed.

```mermaid
flowchart TD
    START([Mac threshold crossed]) --> Q1{Diagnosis<br/>ROUTER_UNREACHABLE<br/>or DISAGREEMENT?}
    Q1 -- yes --> FULL[Banner plus email<br/>no dedup suppress]:::alert
    Q1 -- no --> Q2{Gateway state<br/>N:DOWN?}
    Q2 -- yes --> BAN[Banner only<br/>email suppressed]:::suppress
    Q2 -- no --> FULL

    classDef alert fill:#fce8e6,stroke:#c5221f,color:#5b0f0a
    classDef suppress fill:#fff8e1,stroke:#a8741f,color:#3e2a04
```

Same logic as [[Architecture]] dedup tree.

---

## Legend

| Color | Meaning |
|-------|---------|
| Green | Healthy / done |
| Grey | Expected / no action / wait |
| Red | Action required |
| Yellow | Dedup — banner only |
