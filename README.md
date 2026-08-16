[README.md](https://github.com/user-attachments/files/31110781/README.md)
<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0057FF,100:FF003C&height=180&section=header&text=HTB%20pwnbox%20automation&fontSize=40&fontColor=FFFFFF&animation=fadeIn&desc=make%20it%20ready%20to%20hunt&descAlignY=75&descSize=18" width="100%"/>

![OS](https://img.shields.io/badge/Parrot%20OS%20%2F%20Pwnbox-0057FF?style=for-the-badge&logo=parrotsecurity&logoColor=white)
![Status](https://img.shields.io/badge/Status-working-FF003C?style=for-the-badge)
![Install](https://img.shields.io/badge/Install-~5%20min-0057FF?style=for-the-badge)

**One command.** Clean, install 11 tool sets in parallel, quiet.

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
| `--skip-clean` | update only, no wipe |
| `--path DIR` | install to `DIR`, not `/opt` |
| `HTB_MAX_PARALLEL=n` | override auto-tuned jobs |

Jobs auto-scale: `2×cpu`, max `6`, never > free RAM in GB. Longest jobs first.

---

## 📦 Tools

| Script | Installs | Via |
|---|---|---|
| `ad_tools` | Certipy, Impacket, NetExec, BloodyAD | uv |
| `bloodhound` | BloodHound CE + Neo4j · `:8088` | docker |
| `pivot` | chisel, ligolo-ng, proxychains4 | bin |
| `enum_tools` | linPEAS, winPEAS, mimikatz, Rubeus, RunasCs | bin |
| `rusthound` | RustHound-CE | bin |
| `hashcat` | latest release | bin |
| `reference` | SecLists + rockyou, PayloadsAllTheThings | git |
| `evilwinrm` | evil-winrm | gem |
| `manspider` | SMB crawler | uv |
| `cli_tools` | Responder, sqlmap, rlwrap, exiftool | apt |
| `workstation` | tmux + Firefox proxy stack | conf |

---

## ⚙️ Core

| File | Role |
|---|---|
| `start_automation.sh` | clean → parallel install, prints each as it lands |
| `scripts/cleanup.sh` | tools, logs, cache, temp, animations |
| `scripts/_common.sh` | quiet logs, flock apt/PATH, retries, timers |

Silent while working · `✅ tool (12s)` per finish · `❌` + last log lines on error · logs `/tmp/.htb_logs/`

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

Rest lands in normal apt/uv paths.

---

## 🖥️ Workstation

**tmux** — HTB blue/green/white, truecolor on any terminal, `0`-indexed, vi keys, 200k history, `|` `-` splits.
Mouse scroll + drag-copy across **full scrollback** — selection doesn't end on release, keep scrolling and extending. `xclip` to system clipboard.
Dirs blue to match the bar. Running tmux? `tmux kill-server` to reload.

**Firefox** — FoxyProxy + uBlock + Wappalyzer auto install/update, proxy → Burp `127.0.0.1:8080`. No tabs opened.

---

## 📋 Changelog

**tmux / colors**
- `~` truecolor matches any `*256col*` TERM, not only `xterm-256color`
- `~` `terminal-features` version-guarded — no error on old tmux
- `~` `ncurses-term` for `tmux-256color`, auto-fallback `screen-256color`
- `~` scroll + copy across full history, selection survives release
- `~` `0`-indexed, blue user + blue dirs, auto-reload on install

**speed**
- `~` ligolo + rusthound prebuilt — no Go/rustup/clang, no cross-compile
- `~` one `apt update` per run, not 7
- `~` auto-tuned concurrency, longest-first

**earlier**
- `+` Responder, sqlmap, manspider, PayloadsAllTheThings, proxychains4, rlwrap, exiftool
- `+` Firefox automation · `--skip-clean` · `--path`
- `~` parallel + quiet output · `scripts/` dir · cleanup logs/cache/animations
- `~` bloodhound docker health check + retry · hashcat cleanup perms

**next**
- proxychains4 auto-chain with chisel/ligolo

---

<div align="center">

Parrot OS HTB edition / pwnbox · untested on other kernels
`main` stable · `dev` first

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:FF003C,100:0057FF&height=100&section=footer" width="100%"/>

</div>
