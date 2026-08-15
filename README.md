<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0057FF,100:FF003C&height=180&section=header&text=HTB%20Pwnbox%20Automation&fontSize=40&fontColor=FFFFFF&animation=fadeIn&desc=make%20it%20ready%20to%20hunt%20in%20less%20than%2010%minutes&descAlignY=75&descSize=18" width="100%"/>

![OS](https://img.shields.io/badge/Parrot%20OS%20HTB%20Edition-0057FF?style=for-the-badge&logo=parrotsecurity&logoColor=white)

![Status](https://img.shields.io/badge/Status-working%2015/08/2026-FF003C?style=for-the-badge)

![Purpose](https://img.shields.io/badge/Purpose-save%20time%20configuring%20and%20cleaning%20parrot%20os-0057FF?style=for-the-badge)

</div>

## Ready in less than 8 minutes while you prepare your break fast. 

## 📦 What's Included

**Main workflow scripts**
- `start_automation.sh` — runs `cleanup.sh`, then every `install_*.sh`.
- `cleanup.sh` — removes all stale/system installs + disables desktop animations for perf (safe to re-run)
- `_common.sh` — shared helper (sourced, not run directly): noninteractive apt, quiet output (spinner + log file, errors surface immediately), flock-safe apt/PATH/toolchain helpers so parallel scripts don't collide, per-script timing.

**Install scripts**
- `install_ad_tools.sh` — Certipy, Impacket, NetExec, BloodyAD *(via uv)*
- `install_bloodhound.sh` — BloodHound CE + Neo4j *(via Docker; stops itself after setup)* **(port 8088, 8080 is Burp)**
- `install_pivot.sh` — chisel + ligolo-ng → `/opt/pivot`, + proxychains4 *(apt, install only for now)*
- `install_enum_tools.sh` — linPEAS/winPEAS + mimikatz/Rubeus/RunasCs → `/opt/{peas,sharp}`
- `install_hashcat.sh` — latest hashcat release binary
- `install_rusthound.sh` — RustHound-CE *(via cargo)*
- `install_reference.sh` — SecLists+rockyou + PayloadsAllTheThings → `/opt/{SecLists,PayloadsAllTheThings}`
- `install_evilwinrm.sh` — evil-winrm *(via gem, user-mode)*
- `install_manspider.sh` — MANSPIDER SMB crawler *(via uv, no `/opt`)*
- `install_cli_tools.sh` — Responder, sqlmap, rlwrap, exiftool *(apt, no `/opt`)*
- `install_workstation.sh` — tmux (pwnbox blue/green/white, mouse on) + Firefox (FoxyProxy/uBlock/Wappalyzer, proxy → `**127.0.0.1:8080**`)

## 📁 Directory Layout

```
/opt/pivot/     chisel, chisel.exe, ligolo-ng-proxy-*, ligolo-ng-agent-*
/opt/peas/ (linPEAS, winPEAS)
/opt/sharp/ (mimikatz, Rubeus, RunasCs)
/opt/bloodhound/server/   docker-compose.yaml, initial-password.txt, restart with docker compose up -d
/opt/hashcat/ updated hashcat
/opt/rusthound/ community edition rust hound for windows machines
/opt/SecLists/ also linked to /usr/share/wordlists/rockyou.txt + destroy gz file to save disk space
/opt/PayloadsAllTheThings/ payload reference db
```
Responder, sqlmap, proxychains4, manspider, rlwrap, exiftool — no `/opt`, land in their normal apt/uv spots instead.

---

## 🚀 Installation

```bash
git clone https://github.com/LucidIP/bash-setup-htb-pwnbox-automation.git
cd bash-setup-htb-pwnbox-automation
chmod +x *.sh
./start_automation.sh
# wait 10 minutes
```

## 🛠️ Future content

Some being tested at the LucidIP-dev branch some are still offline or at python database.

| Update | Info |
|---|---|
|**proxychains4 config automation**|auto-chain proxychains4 with chisel/ligolo pivots|
|**coming**|**soon**|

---

## ⚠️ Disclaimer

Built for parrot os htb build edition or htb pwnbox

Prioritize speed, organization and a stable htb ready system

Always git clone the main branch

Dev branch is for future updates

Constant development and usage will be applied

Bash AI assisted based on my private python automation

Errors may appear as most text is human based text

<div align="center">
<img src="https://capsule-render.vercel.app/api?type=waving&color=0:FF003C,100:0057FF&height=100&section=footer" width="100%"/>
</div>
