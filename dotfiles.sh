#!/bin/bash

# ===============================================
# DOTFILES MANAGEMENT SCRIPT
# ===============================================

set -u

VERSION="2.1.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Managed dotfiles, formatted as "<repo-relative-path>:<system-path>".
# Keep this in sync with setup.sh.
DOTFILES=(
    ".zshrc:$HOME/.zshrc"
    "alacritty.toml:$HOME/.config/alacritty/alacritty.toml"
    "config:$HOME/.config/ghostty/config"
    "bat.config:$HOME/.config/bat/config"
    ".p10k.zsh:$HOME/.p10k.zsh"
)

print_status()  { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error()   { echo -e "${RED}[ERROR]${NC} $1"; }
print_header()  { echo -e "${PURPLE}[DOTFILES]${NC} $1"; }

show_usage() {
    cat <<EOF
Dotfiles Management Script v$VERSION

Usage: $0 [OPTION]

Options:
  copy       Copy dotfiles from system to repository
  save       Save dotfiles from repository to system (with backup)
  sync       Sync dotfiles (copy from system to repo)
  status     Show status of dotfiles
  help       Show this help message

Examples:
  $0 copy     # Copy current system configs to repo
  $0 save     # Install repo configs to system
  $0 sync     # Update repo with current system configs
  $0 status   # Check differences between repo and system
EOF
}

for_each_dotfile() {
    local cb="$1"
    local entry repo sys
    for entry in "${DOTFILES[@]}"; do
        repo="${entry%%:*}"
        sys="${entry#*:}"
        "$cb" "$repo" "$sys"
    done
}

_copy_one() {
    local repo="$1" sys="$2"
    if [[ -f "$sys" ]]; then
        mkdir -p "$(dirname "$DOTFILES_DIR/$repo")"
        cp "$sys" "$DOTFILES_DIR/$repo"
        print_success "Copied $sys -> $repo"
    else
        print_warning "$sys not found"
    fi
}

copy_dotfiles() {
    print_header "Copying dotfiles from system to repository..."
    for_each_dotfile _copy_one
    print_success "Dotfiles copied to repository successfully!"
}

_save_one() {
    local repo="$1" sys="$2"
    if [[ -f "$DOTFILES_DIR/$repo" ]]; then
        mkdir -p "$(dirname "$sys")"
        cp "$DOTFILES_DIR/$repo" "$sys"
        print_success "Installed $sys"
    else
        print_warning "$repo not found in repository"
    fi
}

save_dotfiles() {
    print_header "Installing dotfiles from repository to system..."

    if [[ -f "$DOTFILES_DIR/setup.sh" ]]; then
        print_status "Creating backup using setup script..."
        "$DOTFILES_DIR/setup.sh" backup
    else
        print_warning "setup.sh not found, creating manual backup..."
        local backup_dir="$HOME/.dotfiles_manual_backup_$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$backup_dir"
        local entry sys rel
        for entry in "${DOTFILES[@]}"; do
            sys="${entry#*:}"
            if [[ -f "$sys" ]]; then
                rel="${sys#$HOME/}"
                mkdir -p "$(dirname "$backup_dir/$rel")"
                cp "$sys" "$backup_dir/$rel"
            fi
        done
        print_status "Manual backup created at: $backup_dir"
    fi

    for_each_dotfile _save_one

    print_success "Dotfiles installed successfully!"
    print_warning "Please restart your terminal or run: source ~/.zshrc"
}

_status_one() {
    local repo="$1" sys="$2"
    local repo_path="$DOTFILES_DIR/$repo"
    if [[ -f "$repo_path" && -f "$sys" ]]; then
        if diff -q "$repo_path" "$sys" > /dev/null; then
            echo "[OK]      $repo: identical"
        else
            echo "[DIFF]    $repo: differs from $sys"
        fi
    elif [[ -f "$repo_path" ]]; then
        echo "[REPO]    $repo: only in repository"
    elif [[ -f "$sys" ]]; then
        echo "[SYS]     $repo: only in system ($sys)"
    else
        echo "[MISSING] $repo: not present in either location"
    fi
}

show_status() {
    print_header "Dotfiles status comparison..."
    echo ""
    for_each_dotfile _status_one
    echo ""
    print_status "Legend:"
    echo "  [OK]      Files are synchronized"
    echo "  [DIFF]    Files differ - consider running 'copy' or 'save'"
    echo "  [REPO]    File only in repository"
    echo "  [SYS]     File only in system"
    echo "  [MISSING] File missing in both locations"
}

case "${1:-help}" in
    copy|sync)       copy_dotfiles ;;
    save)            save_dotfiles ;;
    status)          show_status ;;
    help|-h|--help)  show_usage ;;
    *)
        print_error "Unknown option: $1"
        echo ""
        show_usage
        exit 1
        ;;
esac
