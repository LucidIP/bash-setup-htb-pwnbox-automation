<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0D0D0D,100:6A0DAD&height=180&section=header&text=HTB%20setup%20automation&fontSize=40&fontColor=FFFFFF&animation=fadeIn&desc=make%20it%20ready%20to%20hunt&descAlignY=75&descSize=18" width="100%"/>

![OS](https://img.shields.io/badge/Parrot%20OS%20HTB%20Edition-6A0DAD?style=for-the-badge&logo=parrotsecurity&logoColor=white)

![Status](https://img.shields.io/badge/Status-currently%20working-000000?style=for-the-badge)

![Purpose](https://img.shields.io/badge/Purpose-save%20time%20configuring%20and%20cleaning%20parrot%20os-6A0DAD?style=for-the-badge)

</div>

One command cleans up heavy and old system packages, then installs everything needed for HTB machine flag hunt.
Mainly built to work via `uv`, `cargo`, `gem`, and Docker.

---

## 📦 What's Included

**Main workflow scripts**
- `start_automation.sh` — runs `cleanup.sh`, then every `install_*.sh` in order, with a grand-total timer ( for debugging purpose)
- `cleanup.sh` — removes all stale/system installs before a fresh provision (safe to re-run)
- `_common.sh` — shared helper (sourced, not run directly): non interactive bash file, fix retry-on-failure installs because of docker and other tools, and timing every single script.

**Install scripts**
- `install_ad_tools.sh` — Certipy, Impacket, NetExec, BloodyAD *(via uv)*
- `install_bloodhound.sh` — BloodHound CE + Neo4j *(via Docker; stops itself after setup to keep ports closed)* **(changed port of bloodhound to 8088 because 8080 is used for burp)**
- `install_pivot.sh` — chisel (linux + windows) + ligolo-ng, built from source → `/opt/pivot`
- `install_enum_tools.sh` — linPEAS/winPEAS + mimikatz/Rubeus/RunasCs → `/opt/tools/{peas,sharp}`
- `install_hashcat.sh` — latest hashcat release binary
- `install_rusthound.sh` — RustHound-CE *(via cargo)*
- `install_seclists.sh` — SecLists + rockyou.txt, linked into `/usr/share/wordlists`
- `install_evilwinrm.sh` — evil-winrm *(via gem, user-mode)*

## 📁 Directory Layout

```
/opt/pivot/     chisel, chisel.exe, ligolo-ng-proxy-*, ligolo-ng-agent-*
/opt/peas/ (linPEAS, winPEAS)
/opt/sharp/ (mimikatz, Rubeus, RunasCs)
/opt/bloodhound/server/   docker-compose.yaml, initial-password.txt and info about how to initiate the docker, run docker compose up -d (while pwd is bloodhound/server endpoint.)
/opt/hashcat/ updated hashcat
/opt/rusthound/ community edition rust hound for windows machines
/opt/SecLists/ also linked to /usr/share/wordlist/rockyou.txt + destroy gz file to save disk space.
```

---

## 🚀 Installation

```bash
git clone https://github.com/LucidIP/bash-setup-htb-pwnbox-automation.git
cd bash-setup-htb-pwnbox-automation
chmod +x *.sh
./start_automation.sh (wait up to 15 minutes and you're ready to hunt) 
```

## 🛠️ Future content

Some being tested at the LucidIP-dev branch some are still offline or at python database.

| Update | Info |
|---|---|
|**responder**|poisoner/listener|
|**payloadsallthethings**|payload db|
|**manspider**|SMB crawler|
|**sqlmap**|SQL pentesting tool|
|**proxychains4 + automation config**|pivot with chisel/ligolo|
|**tmux GUI**|GUI looks like HTB pwnbox|
|**tmux config**|fix some configs to improve hacking speed and efficiency|
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
<img src="https://capsule-render.vercel.app/api?type=waving&color=0:6A0DAD,100:0D0D0D&height=100&section=footer" width="100%"/>
</div>
