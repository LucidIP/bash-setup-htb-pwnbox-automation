<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0057FF,100:FF003C&height=180&section=header&text=HTB%20pwnbox%20automation&fontSize=40&fontColor=FFFFFF&animation=fadeIn&desc=make%20it%20ready%20to%20hunt&descAlignY=75&descSize=18" width="100%"/>

![OS](https://img.shields.io/badge/Parrot%20OS%20%2F%20HTB%20Pwnbox-0057FF?style=for-the-badge&logo=parrotsecurity&logoColor=white)
![Status](https://img.shields.io/badge/Status-working%2016--08--2026-FF003C?style=for-the-badge)

</div>

---

## 🚀 Install

```bash
git clone https://github.com/LucidIP/htb-pwnbox-automation.git
cd htb-pwnbox-automation
chmod +x start_automation.sh scripts/*.sh
./start_automation.sh
```

| Flag | Effect |
|---|---|
| `--skip-clean` | update tools, skip the wipe |
| `--path DIR` | install to `DIR`, not `/opt` · nested ok `/path/path` |
| `-h` | show flags |

---

## 📦 Tools

| Script | Installs | Via |
|---|---|---|
| `ad_tools` | Certipy, Impacket, NetExec, BloodyAD | uv |
| `bloodhound` | BloodHound CE + Neo4j | docker |
| `pivot` | chisel, ligolo-ng, proxychains4 | bin |
| `enum_tools` | linPEAS, winPEAS, mimikatz, Rubeus, RunasCs | bin |
| `rusthound` | RustHound-CE | bin |
| `hashcat` | latest release | bin |
| `reference` | SecLists + rockyou, PayloadsAllTheThings | git |
| `evilwinrm` | evil-winrm | gem |
| `manspider` | SMB crawler | uv |
| `cli_tools` | Responder, sqlmap, rlwrap, exiftool | apt |
| `workstation` | tmux + Firefox proxy stack | conf |

Add a tool → drop `scripts/install_<name>.sh` in. Picked up automatically.

---

## ⚙️ Core

| File | Role |
|---|---|
| `start_automation.sh` | clean → parallel install → summary |
| `scripts/cleanup.sh` | tools, logs, cache, RAM, animations, workspaces |
| `scripts/_common.sh` | quiet logs, flock apt/PATH, retries, timers |

---

## 🐞 Debug

Silent while working with few reports and saved logs.

Full output per tool → `/tmp/.htb_logs/<name>.log`.

---

## 📁 Layout

```
$HTB_BASE_DIR (default /opt)
├── pivot/                chisel, ligolo-proxy, ligolo-agent(.exe)
├── peas/                 linPEAS, winPEAS
├── sharp/                mimikatz, Rubeus, RunasCs
├── bloodhound/server/    compose + initial-password.txt
├── hashcat/  rusthound/
├── SecLists/             → /usr/share/wordlists/rockyou.txt
└── PayloadsAllTheThings/
```

## 🖥️ Workstation

**tmux** — pwnbox color, `0`-indexed, vi keys, 200k history, `|` `-` splits.
White text, green files, blue dirs. Mouse scroll + drag-copy across window with scroll. `xclip` to system clipboard.

**Firefox** — FoxyProxy + uBlock + Wappalyzer auto install/update, proxy → Burp `127.0.0.1:8080`. No tabs opened.
BloodHound serves on `8088`, keeping `8080` free for Burp.

**Performance** — animations off, single workspace, caches freed, performance setup.

---

<div align="center">

## 🔮 Next

![Next](https://img.shields.io/badge/proxychains4-auto--chain%20chisel%20%2F%20ligolo-0057FF?style=for-the-badge)
![Soon](https://img.shields.io/badge/more-coming%20soon-FF003C?style=for-the-badge)

Parrot OS HTB edition / pwnbox · untested on other kernels
`main` stable · `dev` first for dev testing

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:FF003C,100:0057FF&height=100&section=footer" width="100%"/>

</div>
