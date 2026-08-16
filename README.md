<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0057FF,100:FF003C&height=180&section=header&text=HTB%20setup%20automation&fontSize=40&fontColor=FFFFFF&animation=fadeIn&desc=make%20it%20ready%20to%20hunt&descAlignY=75&descSize=18" width="100%"/>

![OS](https://img.shields.io/badge/Parrot%20OS%20HTB%20Edition-0057FF?style=for-the-badge&logo=parrotsecurity&logoColor=white)

![Status](https://img.shields.io/badge/Status-currently%20working-FF003C?style=for-the-badge)

![Purpose](https://img.shields.io/badge/Purpose-save%20time%20configuring%20and%20cleaning%20parrot%20os-0057FF?style=for-the-badge)

</div>

One command cleans up heavy/old packages, speed mode using parallel, quiet by default
Install in less than 10 minutes

---

## 🚀 Installation

```bash
git clone https://github.com/LucidIP/htb-pwnbox-automation.git
cd htb-pwnbox-automation
chmod +x start_automation.sh scripts/*.sh
./start_automation.sh
```

**Flags**
- `--skip-clean` — skip cleanup.sh, just update tools
- `--path DIR` — install into `DIR` instead of `/opt` (nested paths allowed, `/data/tools`)

## 📦 What's Included

- `start_automation.sh` — cleanup + every `scripts/install_*.sh` in parallel (4 at a time), timing summary at the end
- `scripts/cleanup.sh` — clean stale installs + logs/cache/temp + desktop animations, safe to re-run
- `scripts/_common.sh` — quiet output, flock-safe apt/PATH/toolchain, time log capacity

**`scripts/install_*.sh`**
- `ad_tools` — Certipy, Impacket, NetExec, BloodyAD *(uv)*
- `bloodhound` — BloodHound CE + Neo4j *(Docker; port 8088, 8080 is Burp; auto-retries on unhealthy start)*
- `pivot` — chisel + ligolo-ng + proxychains4 *(install only, no auto-chain yet)*
- `enum_tools` — linPEAS/winPEAS + mimikatz/Rubeus/RunasCs
- `hashcat` — latest release binary
- `rusthound` — RustHound-CE *(cargo)*
- `reference` — SecLists+rockyou + PayloadsAllTheThings
- `evilwinrm` — evil-winrm *(gem, user-mode)*
- `manspider` — SMB crawler *(uv)*
- `cli_tools` — Responder, sqlmap, rlwrap, exiftool *(apt)*
- `workstation` — tmux (pwnbox theme, mouse on) + Firefox (FoxyProxy/uBlock/Wappalyzer → Burp `127.0.0.1:8080`)

## 📁 Directory Layout

Everything except pivot/enum/hashcat/rusthound/reference lands in its normal apt/uv spot (no custom dir).

```
$HTB_BASE_DIR (default /opt)
├── pivot/       chisel, chisel.exe, ligolo-ng-proxy-*, ligolo-ng-agent-*
├── peas/        linPEAS, winPEAS
├── sharp/       mimikatz, Rubeus, RunasCs
├── bloodhound/server/   docker-compose.yaml, initial-password.txt
├── hashcat/
├── rusthound/
├── SecLists/    + linked to /usr/share/wordlists/rockyou.txt
└── PayloadsAllTheThings/
```

---

## 🛠️ Future content

| Update | Info |
|---|---|
|**proxychains4 config automation**|auto-chain proxychains4 with chisel/ligolo pivots|
|**coming**|**soon**|

---

## ⚠️ Disclaimer

Not tested with other kernel versions. Prioritize speed, organization and a stable htb ready system.
Always git clone the main branch, dev branch is for future updates.
Bash AI assisted based on my private python automation.

<div align="center">
<img src="https://capsule-render.vercel.app/api?type=waving&color=0:FF003C,100:0057FF&height=100&section=footer" width="100%"/>
</div>
