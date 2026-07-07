#!/bin/bash

# ===============================================
# MODERN TERMINAL SETUP SCRIPT
# ===============================================

set -u

VERSION="1.1.0"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Managed dotfiles, formatted as "<repo-relative-path>:<system-path>".
# Edit this list to add/remove tracked files.
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
print_header()  { echo -e "${PURPLE}[SETUP]${NC} $1"; }
print_backup()  { echo -e "${CYAN}[BACKUP]${NC} $1"; }

show_usage() {
    cat <<EOF
Modern Terminal Setup Script v$VERSION

Usage: $0 [OPTION]

Options:
  install    Install modern terminal configuration (default)
  backup     Create backup of current configuration only
  restore    Restore from the most recent backup
  list       List available backups
  help       Show this help message

Examples:
  $0              # Install with automatic backup
  $0 install      # Same as above
  $0 backup       # Create backup only
  $0 restore      # Restore from latest backup
  $0 list         # Show available backups
EOF
}

# Iterate over DOTFILES, splitting "repo:system" pairs.
# Usage: for_each_dotfile <callback>
# Callback receives: $1=repo path, $2=system path
for_each_dotfile() {
    local cb="$1"
    local entry repo sys
    for entry in "${DOTFILES[@]}"; do
        repo="${entry%%:*}"
        sys="${entry#*:}"
        "$cb" "$repo" "$sys"
    done
}

_backup_one() {
    local _repo="$1" sys="$2"
    if [[ -f "$sys" ]]; then
        local rel="${sys#$HOME/}"
        local dest="$BACKUP_DIR/$rel"
        mkdir -p "$(dirname "$dest")"
        cp "$sys" "$dest"
        print_backup "Backed up $sys"
    fi
}

create_backup() {
    print_header "Creating backup of existing configuration..."
    mkdir -p "$BACKUP_DIR"

    for_each_dotfile _backup_one

    cat > "$BACKUP_DIR/backup_info.txt" <<EOF
Backup created: $(date)
Script version: $VERSION
Hostname: $(hostname)
User: $(whoami)
Backup directory: $BACKUP_DIR
EOF

    print_success "Backup created at: $BACKUP_DIR"
}

list_backups() {
    print_header "Available backups:"

    local backup_count=0 backup
    for backup in "$HOME"/.dotfiles_backup_*; do
        [[ -d "$backup" ]] || continue
        backup_count=$((backup_count + 1))
        local backup_name backup_date
        backup_name=$(basename "$backup")
        backup_date=$(echo "$backup_name" | sed 's/.*_\([0-9]\{8\}_[0-9]\{6\}\)/\1/' | sed 's/_/ /')

        echo ""
        echo -e "${CYAN}[$backup_count]${NC} $backup_name"
        echo -e "    Date: $backup_date"
        echo -e "    Path: $backup"
    done

    if [[ $backup_count -eq 0 ]]; then
        print_warning "No backups found"
        echo "Create a backup with: $0 backup"
    else
        echo ""
        print_status "To restore a backup, run: $0 restore [backup_path]"
    fi
}

_restore_one() {
    local _repo="$1" sys="$2"
    local rel="${sys#$HOME/}"
    local src="$RESTORE_FROM/$rel"
    if [[ -f "$src" ]]; then
        mkdir -p "$(dirname "$sys")"
        cp "$src" "$sys"
        print_success "Restored $sys"
    fi
}

restore_backup() {
    local backup_path="${1:-}"

    if [[ -z "$backup_path" ]]; then
        backup_path=$(ls -td "$HOME"/.dotfiles_backup_* 2>/dev/null | head -n 1)
        if [[ -z "$backup_path" ]]; then
            print_error "No backups found to restore"
            return 1
        fi
        print_status "Using most recent backup: $(basename "$backup_path")"
    fi

    if [[ ! -d "$backup_path" ]]; then
        print_error "Backup directory not found: $backup_path"
        return 1
    fi

    print_header "Restoring configuration from backup..."
    print_warning "This will overwrite your current configuration!"
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Restore cancelled"
        return 0
    fi

    print_status "Creating backup of current state before restore..."
    create_backup

    RESTORE_FROM="$backup_path"
    for_each_dotfile _restore_one
    unset RESTORE_FROM

    print_success "Configuration restored successfully!"
    print_warning "Please restart your terminal or run: source ~/.zshrc"
}

_install_one() {
    local repo="$1" sys="$2"
    local src="$SCRIPT_DIR/$repo"
    if [[ -f "$src" ]]; then
        mkdir -p "$(dirname "$sys")"
        cp "$src" "$sys"
        print_success "Installed $sys"
    else
        print_warning "$repo not found in repository — skipping"
    fi
}

install_setup() {
    echo "Setting up your modern terminal environment..."

    print_header "Step 1: Creating backup of existing configuration"
    create_backup
    echo ""

    print_header "Step 2: Checking dependencies"
    if ! command -v brew &> /dev/null; then
        print_error "Homebrew is not installed. Please install it first:"
        echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
    print_status "Updating Homebrew..."
    brew update
    echo ""

    print_header "Step 3: Installing essential tools"
    brew install --quiet \
        lsd \
        bat \
        fd \
        ripgrep \
        htop \
        dust \
        duf \
        git \
        curl \
        wget \
        speedtest-cli
    echo ""

    print_header "Step 4: Installing fonts"
    brew install --cask --quiet font-jetbrains-mono-nerd-font
    echo ""

    print_header "Step 5: Setting up Oh My Zsh"
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        print_success "Oh My Zsh is already installed"
    fi
    echo ""

    print_header "Step 6: Installing Powerlevel10k theme"
    if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    else
        print_success "Powerlevel10k is already installed"
    fi
    echo ""

    print_header "Step 7: Installing zsh plugins"
    local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    if [[ ! -d "$custom_dir/plugins/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$custom_dir/plugins/zsh-autosuggestions"
    else
        print_success "zsh-autosuggestions is already installed"
    fi

    if [[ ! -d "$custom_dir/plugins/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$custom_dir/plugins/zsh-syntax-highlighting"
    else
        print_success "zsh-syntax-highlighting is already installed"
    fi

    if [[ ! -d "$custom_dir/plugins/zsh-completions" ]]; then
        git clone https://github.com/zsh-users/zsh-completions "$custom_dir/plugins/zsh-completions"
    else
        print_success "zsh-completions is already installed"
    fi
    echo ""

    print_header "Step 8: Installing configuration files"
    for_each_dotfile _install_one
    echo ""

    print_header "Step 9: Installing optional tools"
    brew install --quiet \
        fzf \
        tree \
        jq \
        tldr \
        neofetch \
        figlet \
        cowsay

    if command -v fzf &> /dev/null; then
        print_status "Setting up fzf key bindings..."
        "$(brew --prefix)/opt/fzf/install" --all --no-bash --no-fish
    fi
    echo ""

    print_success "Modern terminal setup complete!"
    echo ""
    print_warning "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. Configure Powerlevel10k by running: p10k configure"
    echo "  3. Make sure JetBrains Mono Nerd Font is selected in your terminal"
    echo ""
    print_status "Your original configuration has been backed up to:"
    echo "  $BACKUP_DIR"
    echo ""
    print_status "To restore your original configuration, run:"
    echo "  $0 restore"
}

case "${1:-install}" in
    install)         install_setup ;;
    backup)          create_backup ;;
    restore)         restore_backup "${2:-}" ;;
    list)            list_backups ;;
    help|-h|--help)  show_usage ;;
    *)
        print_error "Unknown option: $1"
        echo ""
        show_usage
        exit 1
        ;;
esac
