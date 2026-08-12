<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0D0D0D,100:6A0DAD&height=180&section=header&text=pwnbox_automation&fontSize=40&fontColor=FFFFFF&animation=fadeIn&desc=HTB%20Pwnbox%20Provisioning%20Automation&descAlignY=75&descSize=18" width="100%"/>

![OS](https://img.shields.io/badge/OS-Parrot%20Security-6A0DAD?style=for-the-badge&logo=parrotsecurity&logoColor=white)
![Shell](https://img.shields.io/badge/Shell-Bash-000000?style=for-the-badge&logo=gnubash&logoColor=white)
![Package%20Manager](https://img.shields.io/badge/Powered%20By-uv-6A0DAD?style=for-the-badge&logo=python&logoColor=white)
![Status](https://img.shields.io/badge/Status-Active-000000?style=for-the-badge)
![Purpose](https://img.shields.io/badge/Purpose-HTB%20%2F%20CPTS%20Prep-6A0DAD?style=for-the-badge)

</div>

One-command provisioning for a fresh HTB Pwnbox — cleans up stale system packages, then installs everything needed for AD/pentest work via `uv`, `cargo`, `gem`, and Docker. Self-contained, idempotent, and built to grow.

---

## 📦 What's Included

**Orchestration**
- `start_automation.sh` — runs `cleanup.sh`, then every `install_*.sh` in order, with a grand-total timer
- `cleanup.sh` — removes all stale/system installs before a fresh provision (safe to re-run)
- `_common.sh` — shared helper (sourced, not run directly): noninteractive apt, retry-on-failure installs, per-script timing

**Install scripts**
- `install_ad_tools.sh` — Certipy, Impacket, NetExec, BloodyAD *(via uv)*
- `install_bloodhound.sh` — BloodHound CE + Neo4j *(via Docker; stops itself after setup to keep ports closed)*
- `install_pivot.sh` — chisel (linux + windows) + ligolo-ng, built from source → `/opt/pivot`
- `install_enum_tools.sh` — linPEAS/winPEAS + mimikatz/Rubeus/RunasCs → `/opt/tools/{peas,sharp}`
- `install_hashcat.sh` — latest hashcat release binary
- `install_rusthound.sh` — RustHound-CE *(via cargo)*
- `install_seclists.sh` — SecLists + rockyou.txt, linked into `/usr/share/wordlists`
- `install_evilwinrm.sh` — evil-winrm *(via gem, user-mode)*
- `install_shell_tools.sh` — Penelope shell handler + rlwrap

## 📁 Directory Layout

```
/opt/pivot/     chisel, chisel.exe, ligolo-ng-proxy-*, ligolo-ng-agent-*
/opt/tools/     peas/ (linPEAS, winPEAS)   sharp/ (mimikatz, Rubeus, RunasCs)
/opt/bloodhound/server/   docker-compose.yaml, initial-password.txt
/opt/hashcat/   /opt/rusthound/   /opt/SecLists/
```

---

## 🚀 Installation

```bash
git clone https://github.com/RPG-Study/pwnbox_automation.git
cd pwnbox_automation
chmod +x *.sh
./start_automation.sh
```

## 🛠️ Usage

| Goal | Command |
|---|---|
| Full provision (fresh pwnbox) | `./start_automation.sh` |
| Wipe old installs only | `./cleanup.sh` |
| Install/refresh one tool | `./install_<name>.sh` — each is self-contained, safe to run alone |
| BloodHound creds + restart cmd | `cat /opt/bloodhound/server/initial-password.txt` |
| Bring BloodHound back up | `cd /opt/bloodhound/server && sudo docker compose up -d` |
| Check how long a script took | look for `⏱️ DEBUG_TIME[script.sh]=Ns` at the end of its output |

**Adding a new tool:** create `install_<name>.sh`, `source "$(dirname "$0")/_common.sh"` at the top, use `apt_install`/`apt_update` for any apt packages. `start_automation.sh` picks it up automatically — no other file needs editing.

---

## 🔜 Pending / Suggestions

Not installed yet — future candidates:

- **Responder** — LLMNR/NBT-NS/mDNS poisoning
- **mitm6** — IPv6 DNS takeover, pairs with ntlmrelayx
- **Coercer** — automates PetitPotam/PrinterBug-style coercion
- **manspider** — crawls SMB shares for interesting files/creds
- **ldeep** / **ldapdomaindump** — lightweight LDAP enum without a full BloodHound collection
- **socat** / **proxychains4** — pairs with chisel/ligolo tunnels
- **tmux** — persistent sessions so a dropped SSH doesn't kill a listener
- **mingw-w64** — cross-compile small Windows payloads locally
- Rubeus built from source (currently a trusted community-compiled binary — see comment in `install_enum_tools.sh`)
- `certificate_manager.py` — argv flag to toggle normal vs `msPKI-Certificate-Name-Flag=1` templates *(in progress)*

---

## ⚠️ Disclaimer

For personal use on HTB/lab environments and systems you're explicitly authorized to test. Several tools here (mimikatz, Rubeus, RunasCs, chisel, ligolo-ng) are dual-use offensive security tools — do not run them against systems you don't own or don't have permission to test.

<div align="center">
<img src="https://capsule-render.vercel.app/api?type=waving&color=0:6A0DAD,100:0D0D0D&height=100&section=footer" width="100%"/>
</div>
