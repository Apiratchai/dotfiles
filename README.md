# Dotfiles

**moving to Fedora Workstation soon**
- OS: Debian GNU/Linux 13 (trixie)
- Kernel: 6.12.85+deb13-amd64
- Shell: zsh 5.9 
- DE: GNOME 48.7
- WM: Mutter (Wayland)
- Terminal: kitty
- Theme: Adwaita [GTK2/3/4]
- Icons: Adwaita [GTK2/3/4]
---

## Contents
- [Utilities](#utilities)
- [Kitty Terminal](#kitty-terminal)  
- [Zsh Configuration (.zshrc)](#zsh-configuration-zshrc)  
- [GNOME Extensions](#gnome-extensions)
- [Color palette](#color-palette)
- [Unsqueeze: ASUS Vivobook power/fan fix](#unsqueeze-asus-vivobook-powerfan-fix)
- [Btrfs snapshots: Snapper setup & how it works](#btrfs-snapshots-snapper-setup--how-it-works)

---

## Utilities
credits : https://github.com/ibraheemdev/modern-unix 
- [bat](https://github.com/sharkdp/bat) : A `cat` clone with syntax highlighting and Git integration.
- [lsd](https://github.com/Peltoche/lsd) : The next gen file listing command. Backwards compatible with `ls`.  
add `alias lsd='lsd --color=always --icon=always'` to .zshrc to force output in colors and icons.
- ~~[gtop](https://github.com/aksakalli/gtop) : System monitoring dashboard for terminal. (written in JS, slower than btop)~~
- [btop](https://github.com/aristocratos/btop) : Resource monitor that shows usage and stats for processor, memory, disks, network and processes.
C++ version and continuation of [bashtop](https://github.com/aristocratos/bashtop) and [bpytop](https://github.com/aristocratos/bpytop). (written in C++, this one is so much faster than gtop.)
- [dust](https://github.com/bootandy/dust) : A more intuitive version of `du` written in rust.
- [tldr](https://github.com/tldr-pages/tldr) : A community effort to simplify `man` pages with practical examples.

![screenshot1](other/screenshot1.png "screenshot1")  
`gtop` on left, `dust` on top-right, `tldr` on bottom-right.

## Kitty Terminal

- nightly kitty built. ( v.0.37.0 or newer should work )
    ```bash
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin \
    installer=nightly
    ```
- theme: Desert

    ```bash
    THEME=https://raw.githubusercontent.com/dexpota/kitty-themes/master/themes/Desert.conf
    wget "$THEME" -P ~/.config/kitty/kitty-themes/themes
    ```
    ```bash
    cd ~/.config/kitty
    ln -s ./kitty-themes/themes/Desert.conf ~/.config/kitty/theme.conf
    ```
- custom theme (currently using): inspired by Everforest Theme  
[github.com/bgrnwd/everforest-kitty](https://github.com/bgrnwd/everforest-kitty)  
hard coded into `~/.config/kitty/kitty.conf`

---

## Zsh Configuration (.zshrc)

- Zsh shell setup with plugins and aliases.
- fix nvm performance issue on load  
    guide here [varun.ch/posts/slow-nvm/](https://varun.ch/posts/slow-nvm/)
    ```bash
    nvm install rc
- Oh-My-Zsh.
- theme: Comfyline (custom)
    - [gitlab.com/imnotpua/comfyline_prompt.git](https://gitlab.com/imnotpua/comfyline_prompt)
- Config file path:
    - `~/.zshrc`
    - `~/.oh-my-zsh/custom/themes/`


---

## Fonts

- Firacode 
  - sudo dnf install fira-code-fonts
- [IBM Plex Sans Thai Looped](https://fonts.google.com/specimen/IBM+Plex+Sans+Thai+Looped)
  - mv the fonts to  `/usr/share/fonts`
  - `sudo fc-cache -f -v`

---

## GNOME Extensions

- List of GNOME extensions I use to improve desktop productivity.  
- Installation via GNOME Extensions website.
- Extentions used:  
  - [**Blur My Shell**](https://github.com/aunetx/blur-my-shell) - add blur to gnome shell  
  - [**Clipboard Histroy**](https://github.com/SUPERCILEX/gnome-clipboard-history) - clipborad manager
    - [setting](other/clipboard_history.png)

  - [**Hibernate Status Button**](https://github.com/arelange/gnome-shell-extension-hibernate-status)
  - [**Open Bar**](https://github.com/neuromorph/openbar)
    - [setting](gnome/openbar_setting)
  - [**Rounded Window Corners**](https://github.com/yilozt/rounded-window-corners)
  - [**Show Desktop Applet**](https://github.com/Valent-in/Show-Desktop-Applet) - add windows-like show desktop icon and shortkey
    - [setting](other/show_desktop_applet.png)
  - ~~[**Tiling Assistant**](https://github.com/Leleat/Tiling-Assistant) - better tiling tool~~
    - ~~[setting](other/tiling-asistant.png)~~
  - [**gnome-snapnine**](https://github.com/Apiratchai/gnome-snapnine) - replaces Tiling Assistant
    - my keybindings has 2 conflicts with GNOME. please change the "Switch to workspace to the left/right"
  - [**Reorder Workspace**](https://github.com/smmr0/gnome-reorder-workspaces)
    - [setting](other/reorder_workspace.png)

![image of currently activated](other/gnome_extensions.png)
currently activated extensions (13/05/2026)

---
 
### Firefox theme
main theme is [`Rose`](https://addons.mozilla.org/en-US/firefox/addon/aobcgffnbkbipbflopponndoiommhn/?utm_source=addons.mozilla.org&utm_medium=referral&utm_content=search) by user lce1670

---

## Color palette
for Open Bar and firefox theme
![palette](other/pallete.png "palette")  
  
Extracted from wallpaper
  
![wallpaper](wallpaper/wallpaper.png "wallpaper")

![new wallpaper](wallpaper/BigSur.jpg)

---

## Unsqueeze: ASUS Vivobook power/fan fix

**The problem:** ASUS ships Vivobooks (e.g. X1502ZA) with the CPU power capped at 15W and a fan curve that never spins up. Under load the laptop crawls at half speed while staying cold — a "lazy mode" with no firmware switch to fix it.

**The fix:** an interactive installer that
- raises the power cap to **40W on AC / 25W on battery** (via the MMIO RAPL registers — the same ones Intel XTU touches on Windows; 40W measured as the sweet spot, 45W throttles at the 92°C ceiling)
 - fan daemon: **full ≥85°C** sustained ~30 s, quiet **auto ≤75°C** (aggressive profile 72/62). The trigger reads the **package sensor** (`x86_pkg_temp`, EC's own), with median-of-3 + `HOT_POLLS` debounce so a single spike doesn't fire it — old `avg` mode hid heat (91°C pkg while avg ~62°C) and stayed quiet through throttling. Full speed is reserved for sustained heat.
- re-applies everything at boot (systemd) and after AC/battery switches

**Install (Fedora, needs sudo):**
```bash
sudo bash -c "$(curl -sL https://raw.githubusercontent.com/Apiratchai/dotfiles/main/other/unsqueeze/install.sh)"
```
(Or from a clone: `sudo bash other/unsqueeze/install.sh`. Note: don't use `|` or `<( )` — sudo closes extra file descriptors and a pipe replaces the keyboard, which breaks the interactive menus.)
7-stage wizard (arrow-key menus): AC power budget (40W recommended / 45W max / 35W quiet), fan behavior (balanced/aggressive/auto), battery budget (25W recommended / 28W / 15W). Choices saved to `/etc/unsqueeze.conf` — re-run any time to change.

**Verify:**
```bash
cat /sys/class/powercap/intel-rapl-mmio:0/constraint_0_power_limit_uw   # 45000000, not 15000000
openssl speed -multi 16 sha256     # ~19 GB/s vs ~11 GB/s before the fix
```

**Result (measured, Geekbench 7, i5-12500H, same CPU on all runs):** this machine after the fix: multi-core **7523** ([permalink](https://browser.geekbench.com/v7/cpu/116647)). Public reference runs of sibling Vivobooks (K3402ZA/K3502ZA, Windows): clamped units 5127–6751, healthy ~7730. Cross-machine comparison — for a same-machine before/after, the openssl check above (11.3 → 19.2 GB/s) is the controlled measurement.

**Notes:** the fan is full-on or auto only (no duty cycle on this platform). The fix removes a design cap — the remaining gap to gaming laptops is cooling, not the bug.

---

## Btrfs snapshots: Snapper setup & how it works

Hourly timeline snapshots for `/` and `/home`, with retention tuned so that deleting a big file doesn't hold its blocks hostage for weeks. `~/Downloads` lives in its own nested subvolume with a separate, shorter policy.

### Why

Btrfs snapshots are copy-on-write: they don't copy data, they *pin* it. Any file that existed when a snapshot was taken keeps its disk blocks allocated until **every** snapshot referencing them is deleted. With Fedora's default-ish hourly snapshots and generous retention, a 15 GB ISO you download and delete next week stays on disk long after `rm` — the classic "one way trip". This setup makes reclaim time predictable and short.

### Retention policy

| Config | Scope | HOURLY | DAILY | Worst-case pin after deleting a big file |
|---|---|---|---|---|
| `root` | system | 12 | 14 | ~14 days |
| `home` | `/home` (except nested subvols) | 12 | 14 | ~14 days |
| `downloads` | `~/Downloads` only | 12 | 0 | **~12 hours** |

Sleep-one-night rule of thumb: 12 hourly snapshots ≈ half a day, so anything deleted before bed is still recoverable in the morning.

### Setup (after a fresh Fedora install)

Fedora already uses btrfs with subvolumes `root` → `/` and `home` → `/home`.

1. Install snapper and enable its timers:
    ```bash
    sudo dnf install snapper
    sudo systemctl enable --now snapper-timeline.timer snapper-cleanup.timer
    ```
2. Create configs (one per subvolume):
    ```bash
    sudo snapper create-config /
    sudo snapper create-config /home
    ```
3. Set retention — 12 hours + 2 weeks:
    ```bash
    sudo snapper -c root set-config 'TIMELINE_LIMIT_HOURLY=12' 'TIMELINE_LIMIT_DAILY=14'
    sudo snapper -c home set-config 'TIMELINE_LIMIT_HOURLY=12' 'TIMELINE_LIMIT_DAILY=14'
    ```
4. Convert `~/Downloads` into a nested subvolume so it escapes `/home` snapshots entirely
   (btrfs snapshots never descend into child subvolumes; must be done from outside the dir, no live USB needed):
    ```bash
    mv ~/Downloads ~/Downloads.old
    sudo btrfs subvolume create /home/apiratchai/Downloads
    sudo chown apiratchai:apiratchai /home/apiratchai/Downloads
    cp -a --reflink=auto ~/Downloads.old/. ~/Downloads/
    du -sh ~/Downloads ~/Downloads.old   # sizes must match
    rm -rf ~/Downloads.old               # only after verifying
    # verify: device ID should differ from regular dirs
    stat -c '%D %n' ~/Downloads ~/Documents
    ```
5. Give Downloads its own short-retention config (safety net without space hostage-taking):
    ```bash
    sudo snapper -c downloads create-config /home/apiratchai/Downloads
    sudo snapper -c downloads set-config \
        'TIMELINE_CREATE=yes' 'TIMELINE_LIMIT_HOURLY=12' \
        'TIMELINE_LIMIT_DAILY=0' 'TIMELINE_LIMIT_WEEKLY=0'
    ```
6. Keep quotas **off** (Fedora default). They exist only as a measuring tool:
    ```bash
    # temporarily enable to see which snapshot eats what...
    sudo btrfs quota enable / && sudo btrfs quota rescan -w /
    sudo btrfs qgroup show --sync --sort=-excl / | head -30
    sudo btrfs quota disable /          # ...then always turn back off.
    ```
    Quotas add accounting overhead to every extent operation — mass snapshot deletions become slow and cause UI stutter. Don't leave them enabled.

### How it works (mental model)

- A snapshot = a frozen view sharing all blocks with the live filesystem. Unchanged files cost **0 extra space**; changed files cost one new block-set per snapshot (≈ incremental backup at block level).
- Deleting a file only decrements block reference counts. Blocks reach zero refs — i.e. actually free — only after every snapshot containing them is pruned by cleanup. That's why `df` lags behind big deletions by up to the retention window. Expected behaviour, not a bug.
- `snapper-timeline.timer` takes an hourly snapshot of each config; `snapper-cleanup.timer` (every ~35 min) prunes whatever exceeds the limits above.
- Restoring: browse `/.snapshots/<N>/snapshot/...` or `/home/.snapshots/<N>/snapshot/...` and copy files out, or use `sudo snapper -c <cfg> undochange <ID>..0 <path>`.
- Never delete the `.snapshots` directories themselves.

### Cheat sheet

```bash
snapper list-configs                 # all configs (needs sudo)
sudo snapper -c home list            # restore points + ids
df -h /                              # real free space
uptime                               # load after mass deletions (should settle < ~2)
```

---

Feel free to explore and adapt

