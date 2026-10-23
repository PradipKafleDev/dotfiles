#!/usr/bin/env bash
# Fedora Hyprland (LionHeartP) + Noctalia dotfiles installer
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${HOME}/.local/share/dotfiles-backups/$(date +%Y%m%d-%H%M%S)"
DRY_RUN=1

usage() {
  cat <<USAGE
Usage: ./install.sh [--apply]
  (no args)  Preview changes without modifying the system.
  --apply    Install packages and link dotfiles (backs up existing files).

Run this script from your cloned dotfiles repository on Fedora 44+.
USAGE
}
case "${1:-}" in
  "") ;;
  --apply) DRY_RUN=0 ;;
  -h|--help) usage; exit 0 ;;
  *) usage >&2; exit 2 ;;
esac

[[ -r /etc/os-release ]] || { echo 'Cannot identify OS' >&2; exit 1; }
# shellcheck disable=SC1091
source /etc/os-release
[[ "${ID:-}" == fedora ]] || { echo 'This installer supports Fedora only.' >&2; exit 1; }
[[ "${VERSION_ID%%.*}" =~ ^[0-9]+$ ]] && (( VERSION_ID >= 44 )) || {
  echo 'Fedora 44 or newer is required for this tested setup.' >&2; exit 1;
}
[[ $EUID -ne 0 ]] || { echo 'Run as your normal user, not root.' >&2; exit 1; }
command -v dnf >/dev/null || { echo 'dnf not found' >&2; exit 1; }

run() {
  printf '+ '; printf '%q ' "$@"; printf '\n'
  if (( ! DRY_RUN )); then "$@"; fi
}

link_config() {
  local src="$1" dest="$2" existing
  if [[ ! -e "$src" && ! -L "$src" ]]; then
    echo "SKIP missing repository file: $src"
    return
  fi
  if [[ -L "$dest" ]]; then
    existing="$(readlink -- "$dest")"
    if [[ "$existing" == "$src" ]]; then
      echo "OK already linked: $dest"
      return
    fi
  fi
  if [[ -e "$dest" || -L "$dest" ]]; then
    echo "BACKUP $dest -> $BACKUP_DIR/${dest#"$HOME"/}"
    if (( ! DRY_RUN )); then
      mkdir -p -- "$BACKUP_DIR/$(dirname -- "${dest#"$HOME"/}")"
      mv -- "$dest" "$BACKUP_DIR/${dest#"$HOME"/}"
    fi
  fi
  run mkdir -p -- "$(dirname -- "$dest")"
  run ln -s -- "$src" "$dest"
}

printf '\n=== Fedora Hyprland + Noctalia setup ===\n'
if (( DRY_RUN )); then echo 'PREVIEW ONLY: rerun with --apply to make changes.'; fi
printf 'Repository: %s\n' "$ROOT"

# Install the COPR builds that provide the Lua-based Hyprland configuration.
run sudo dnf -y install 'dnf-command(copr)'
run sudo dnf -y copr enable lionheartp/Hyprland
run sudo dnf -y install hyprland-git noctalia-git kitty zsh dolphin git

# The Lua configuration uses a generated Noctalia integration file.
# Preserve it if already present; do not invent or overwrite generated content.
link_config "$ROOT/hypr/hyprland.lua" "$HOME/.config/hypr/hyprland.lua"
link_config "$ROOT/hypr/config" "$HOME/.config/hypr/config"
link_config "$ROOT/noctalia/config.toml" "$HOME/.config/noctalia/config.toml"

# Optional application dotfiles: only link when exact source files exist.
link_config "$ROOT/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
link_config "$ROOT/zsh/.zshrc" "$HOME/.zshrc"

cat <<'NEXT'

NEXT STEPS:
  1. Confirm your installed Hyprland build supports hyprland.lua.
  2. Keep or regenerate ~/.config/hypr/noctalia.lua (used by require("noctalia")).
  3. Review monitor names and absolute wallpaper/screenshot paths for this machine.
  4. Install/enable any Noctalia plugins and fonts used by your setup.
  5. Select the Hyprland session at your login screen; log out/in to test.
  6. Noctalia GUI changes are saved separately under ~/.local/state/noctalia/.

This script does not change the display manager, install drivers, or reboot.
NEXT
if (( ! DRY_RUN )); then echo "Existing configs (if any) backed up under: $BACKUP_DIR"; fi
