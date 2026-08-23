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
- fan daemon: **full ≥85°C** sustained ~30 s, quiet **auto ≤75°C** (aggressive profile 72/62). The trigger reads the **average of all cores**, so one hot core can't fire it — measured: package at 91°C while the core average sat at ~76°C and the daemon stayed quiet, EC auto curve carrying the load. Full speed is reserved for sustained all-core heat.
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

Feel free to explore and adapt

