<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0057FF,100:FF003C&height=180&section=header&text=HTB%20pwnbox%20automation&fontSize=40&fontColor=FFFFFF&animation=fadeIn&desc=make%20it%20ready%20to%20hunt&descAlignY=75&descSize=18" width="100%"/>

![OS](https://img.shields.io/badge/Parrot%20OS%20%2F%20HTB%20Pwnbox-0057FF?style=for-the-badge&logo=parrotsecurity&logoColor=white)
![Status](https://img.shields.io/badge/Status-working%2016--08--2026-FF003C?style=for-the-badge)
![Shell](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)

**Parallel, idempotent provisioning for HTB Pwnbox / Parrot OS** — AD tooling, wordlists, and a themed workstation, installed concurrently and safe to re-run.

</div>

---

## Description

Provisions a fully-loaded HTB Pwnbox / Parrot OS box in a single run: Active Directory tooling, web fuzzing, password cracking, wordlists, and pivoting utilities — installed in parallel, idempotent by design, safe to re-run any time to update in place.

Ships a themed workstation on top: tmux, Firefox wired straight into Burp, and VS Code extensions for .NET decompilation and vulnerability scanning. Every piece of it — colors, tmux, Firefox, VS Code — is individually skippable.

```bash
git clone https://github.com/LucidIP/htb-pwnbox-automation.git
cd htb-pwnbox-automation
chmod +x start_automation.sh scripts/*.sh
./start_automation.sh
```

See [Flags](#-flags) for `--skip-*` options and custom install paths.

---

## 🚩 Flags

| Flag | Info |
|---|---|
| `--skip-clean` | update tools, skip the wipe |
| `--skip-colors` | don't force the HTB palette (tmux, ls) |
| `--skip-tmux` | don't touch tmux config |
| `--skip-firefox` | don't touch Firefox config |
| `--skip-code` | don't touch VS Code (extensions, codium removal) |
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
| `reference` | SecLists + rockyou |
| `evilwinrm` | evil-winrm |
| `manspider` | SMB crawler |
| `cli_tools` | Responder, sqlmap, rlwrap, exiftool, freerdp3-x11, ffuf, feroxbuster |
| `workstation` | tmux + Firefox proxy stack + VS Code (ILSpy, Snyk) |

Add a tool → drop `scripts/install_<name>.sh` in. Picked up automatically.

---

## ⚙️ Core

| File | Role |
|---|---|
| `start_automation.sh` | clean → parallel install → summary |
| `scripts/cleanup.sh` | tools, logs, cache (before **and** after install), RAM, animations, workspaces |
| `scripts/_common.sh` | quiet logs, flock apt/PATH, retries, timers |

---

## 🐞 Debug

Silent while working with few reports and saved logs. First result can take ~200s (bloodhound's docker pulls go first) — normal, not stuck.

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
└── SecLists/             → /usr/share/wordlists/rockyou.txt
```

---

## 🖥️ Workstation

| Part | What | Skip |
|---|---|---|
| Colors | HTB palette forced on tmux and `ls` | `--skip-colors` |
| tmux | `0`-indexed, vi keys, 200k history, `\|` `-` splits, mouse scroll, copy → OS clipboard (xclip/wl-copy/pbcopy) | `--skip-tmux` |
| Firefox | FoxyProxy + uBlock + Wappalyzer → Burp `127.0.0.1:8080`, BloodHound stays on `8088` | `--skip-firefox` |
| VS Code | ILSpy + Snyk installed; codium dropped only if `code` is also present | `--skip-code` |

🟢 `#9FEF00` files/accent · 🔵 `#004CFF` dirs/status · ⬛ `#141A26` backgrounds · ⬜ `#FFFFFF` text

Colors verified: green + navy from [hackthebox.com](https://www.hackthebox.com)'s own brand guide, blue/accents from the established HTB terminal scheme ([audibleblink/hackthebox.vim](https://github.com/audibleblink/hackthebox.vim)). Forced inside tmux only.

Snyk needs a one-time sign-in per user to sync. Not an error, just avoiding storing a token for you.

**Boosted Performance** — animations off, compositor kept on (avoids flicker on the streamed desktop), single workspace. Cache wiped before install (more free RAM/disk) and after (releases what the installers used).

---

<div align="center">

## 🔮 Next

![Next](https://img.shields.io/badge/proxychains4-auto--chain%20chisel%20%2F%20ligolo-0057FF?style=for-the-badge)
![Soon](https://img.shields.io/badge/more-coming%20soon-FF003C?style=for-the-badge)

[Parrot OS HTB edition](https://parrotsec.org/download/) / [HTB Pwnbox](https://help.hackthebox.com/en/articles/5185608-introduction-to-pwnbox) · untested on other kernels
`main` stable · `dev`  test

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:FF003C,100:0057FF&height=100&section=footer" width="100%"/>

</div>
