<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0057FF,100:FF003C&height=180&section=header&text=HTB%20pwnbox%20automation&fontSize=40&fontColor=FFFFFF&animation=fadeIn&desc=make%20it%20ready%20to%20hunt&descAlignY=75&descSize=18" width="100%"/>

![OS](https://img.shields.io/badge/Parrot%20OS%20%2F%20HTB%20Pwnbox-0057FF?style=for-the-badge&logo=parrotsecurity&logoColor=white)
![Status](https://img.shields.io/badge/Status-working%20August-2026-FF003C?style=for-the-badge)

</div>

---

## 🚀 Install

```bash
git clone https://github.com/LucidIP/htb-pwnbox-automation.git
cd htb-pwnbox-automation
chmod +x st* scripts/*
./start_automation.sh
```

| Flag | Info |
|---|---|
| `--skip-clean` | update tools, skip the wipe |
| `--path DIR` | install to `DIR`, not `/opt` · nested ok `/path/path` |
| `-h` | show flags |

---

## 📦 Tools

| Script | Installs |
|---|---|
| `ad_tools` | Certipy, Impacket, NetExec, BloodyAD |
| `bloodhound` | BloodHound CE + Neo4j |
| `pivot` | chisel, ligolo-ng, proxychains4 |
| `enum_tools` | linPEAS, winPEAS, mimikatz, Rubeus, RunasCs |
| `rusthound` | RustHound-CE |
| `hashcat` | latest release |
| `reference` | SecLists + rockyou, PayloadsAllTheThings |
| `evilwinrm` | evil-winrm |
| `manspider` | SMB crawler |
| `cli_tools` | Responder, sqlmap, rlwrap, exiftool, freerdp3-x11 |
| `workstation` | tmux + Firefox proxy stack + VS Code (ILSpy) |

If you want to add a tool yourself → drop `scripts/install_<name>.sh` in. Picked up automatically.

---

## ⚙️ Core

| File | Role |
|---|---|
| `start_automation.sh` | clean → parallel install → summary |
| `scripts/cleanup.sh` | tools, logs, cache (before **and** after install), RAM, animations, workspaces |
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

**Colors** — HTB's own palette, forced everywhere: tmux, `ls`, and the terminal profile itself (not just filenames).

| | Hex | Used for |
|---|---|---|
| 🟢 green | `#9FEF00` | exec files, active window, prompt accent |
| 🔵 blue | `#004CFF` | dirs, status bar, borders |
| ⬛ navy | `#141A26` | backgrounds — tmux panes + terminal profile |

Green + navy match [hackthebox.com](https://www.hackthebox.com)'s own brand guide; blue/accents match the established HTB terminal scheme ([audibleblink/hackthebox.vim](https://github.com/audibleblink/hackthebox.vim)).

**tmux** — `0`-indexed, vi keys, 200k history, `|` `-` splits.
Mouse scroll + drag-copy, `y` or `Enter` — all pipe straight to `xclip` (system clipboard).

**Terminal** — same palette forced onto MATE/GNOME Terminal's default profile, so a plain window matches too, not only tmux. Best-effort — silently skipped if that desktop's schema isn't present.

**Firefox** — FoxyProxy + uBlock + Wappalyzer auto install/update, proxy → Burp `127.0.0.1:8080`. No tabs opened.
BloodHound serves on `8088`, keeping `8080` free for Burp.

**Performance** — animations off, compositor kept on (smooth redraws on the streamed desktop), single workspace. Cache wiped **before** install (more free RAM/disk for downloads+builds) and again **after** (releases what the installers used, back to you).

**VS Code** — ILSpy .NET decompiler extension, auto-installed if `code` is present.

---

<div align="center">

## 🔮 Next

![Next](https://img.shields.io/badge/proxychains4-auto--chain%20chisel%20%2F%20ligolo-0057FF?style=for-the-badge)
![Soon](https://img.shields.io/badge/more-coming%20soon-FF003C?style=for-the-badge)

Parrot OS HTB edition / pwnbox · untested on other kernels
`main` stable · `dev` first for dev testing

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:FF003C,100:0057FF&height=100&section=footer" width="100%"/>

</div>
