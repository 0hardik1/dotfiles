#!/bin/bash

# ===============================================
# 🚀 MODERN TERMINAL SETUP SCRIPT
# ===============================================

# Script version
VERSION="1.0.0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Backup directory
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}[SETUP]${NC} $1"
}

print_backup() {
    echo -e "${CYAN}[BACKUP]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "🚀 Modern Terminal Setup Script v$VERSION"
    echo ""
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  install    Install modern terminal configuration (default)"
    echo "  backup     Create backup of current configuration only"
    echo "  restore    Restore from the most recent backup"
    echo "  list       List available backups"
    echo "  help       Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0              # Install with automatic backup"
    echo "  $0 install      # Same as above"
    echo "  $0 backup       # Create backup only"
    echo "  $0 restore      # Restore from latest backup"
    echo "  $0 list         # Show available backups"
    echo ""
}

# Function to create backup
create_backup() {
    print_header "Creating backup of existing configuration..."
    
    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    
    # Backup .zshrc if it exists
    if [ -f "$HOME/.zshrc" ]; then
        cp "$HOME/.zshrc" "$BACKUP_DIR/.zshrc"
        print_backup "Backed up ~/.zshrc"
    fi
    
    # Backup Alacritty config if it exists
    if [ -f "$HOME/.config/alacritty/alacritty.yml" ]; then
        mkdir -p "$BACKUP_DIR/.config/alacritty"
        cp "$HOME/.config/alacritty/alacritty.yml" "$BACKUP_DIR/.config/alacritty/alacritty.yml"
        print_backup "Backed up ~/.config/alacritty/alacritty.yml"
    fi
    
    # Backup Powerlevel10k config if it exists
    if [ -f "$HOME/.p10k.zsh" ]; then
        cp "$HOME/.p10k.zsh" "$BACKUP_DIR/.p10k.zsh"
        print_backup "Backed up ~/.p10k.zsh"
    fi
    
    # Create backup info file
    cat > "$BACKUP_DIR/backup_info.txt" << EOF
Backup created: $(date)
Script version: $VERSION
Hostname: $(hostname)
User: $(whoami)
Backup directory: $BACKUP_DIR

Files backed up:
$(ls -la "$BACKUP_DIR" | grep -v "^total" | grep -v "^d")

To restore this backup, run:
$0 restore $BACKUP_DIR
EOF
    
    print_success "Backup created at: $BACKUP_DIR"
    return 0
}

# Function to list backups
list_backups() {
    print_header "Available backups:"
    
    backup_count=0
    for backup in "$HOME"/.dotfiles_backup_*; do
        if [ -d "$backup" ]; then
            backup_count=$((backup_count + 1))
            backup_name=$(basename "$backup")
            backup_date=$(echo "$backup_name" | sed 's/.*_\([0-9]\{8\}_[0-9]\{6\}\)/\1/' | sed 's/_/ /')
            
            echo ""
            echo -e "${CYAN}[$backup_count]${NC} $backup_name"
            echo -e "    📅 Date: $backup_date"
            echo -e "    📁 Path: $backup"
            
            if [ -f "$backup/backup_info.txt" ]; then
                echo -e "    📝 Info: $(head -n 1 "$backup/backup_info.txt" | cut -d: -f2-)"
            fi
        fi
    done
    
    if [ $backup_count -eq 0 ]; then
        print_warning "No backups found"
        echo "Create a backup with: $0 backup"
    else
        echo ""
        print_status "To restore a backup, run: $0 restore [backup_path]"
    fi
}

# Function to restore backup
restore_backup() {
    local backup_path="$1"
    
    # If no path provided, find the most recent backup
    if [ -z "$backup_path" ]; then
        backup_path=$(ls -td "$HOME"/.dotfiles_backup_* 2>/dev/null | head -n 1)
        if [ -z "$backup_path" ]; then
            print_error "No backups found to restore"
            echo "Available commands:"
            echo "  $0 list     # List available backups"
            echo "  $0 backup   # Create a new backup"
            return 1
        fi
        print_status "Using most recent backup: $(basename "$backup_path")"
    fi
    
    # Verify backup exists
    if [ ! -d "$backup_path" ]; then
        print_error "Backup directory not found: $backup_path"
        return 1
    fi
    
    print_header "Restoring configuration from backup..."
    print_warning "This will overwrite your current configuration!"
    
    # Ask for confirmation
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Restore cancelled"
        return 0
    fi
    
    # Create a backup of current state before restoring
    print_status "Creating backup of current state before restore..."
    create_backup
    
    # Restore files
    if [ -f "$backup_path/.zshrc" ]; then
        cp "$backup_path/.zshrc" "$HOME/.zshrc"
        print_success "Restored ~/.zshrc"
    fi
    
    if [ -f "$backup_path/.config/alacritty/alacritty.yml" ]; then
        mkdir -p "$HOME/.config/alacritty"
        cp "$backup_path/.config/alacritty/alacritty.yml" "$HOME/.config/alacritty/alacritty.yml"
        print_success "Restored ~/.config/alacritty/alacritty.yml"
    fi
    
    if [ -f "$backup_path/.p10k.zsh" ]; then
        cp "$backup_path/.p10k.zsh" "$HOME/.p10k.zsh"
        print_success "Restored ~/.p10k.zsh"
    fi
    
    print_success "🎉 Configuration restored successfully!"
    print_warning "Please restart your terminal or run: source ~/.zshrc"
}

# Function to install modern terminal setup
install_setup() {
    echo "🎨 Setting up your modern terminal environment..."
    
    # Create backup first
    print_header "Step 1: Creating backup of existing configuration"
    create_backup
    echo ""
    
    # Check if Homebrew is installed
    print_header "Step 2: Checking dependencies"
    if ! command -v brew &> /dev/null; then
        print_error "Homebrew is not installed. Please install it first:"
        echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
    
    print_status "Updating Homebrew..."
    brew update
    echo ""
    
    # Install essential tools
    print_header "Step 3: Installing essential tools"
    print_status "Installing modern CLI tools..."
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
        wget
    echo ""
    
    # Install fonts
    print_header "Step 4: Installing fonts"
    print_status "Installing Nerd Fonts..."
    brew tap homebrew/cask-fonts
    brew install --cask --quiet font-jetbrains-mono-nerd-font
    echo ""
    
    # Install Oh My Zsh if not already installed
    print_header "Step 5: Setting up Oh My Zsh"
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        print_status "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        print_success "Oh My Zsh is already installed"
    fi
    echo ""
    
    # Install Powerlevel10k theme
    print_header "Step 6: Installing Powerlevel10k theme"
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
        print_status "Installing Powerlevel10k theme..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    else
        print_success "Powerlevel10k is already installed"
    fi
    echo ""
    
    # Install zsh plugins
    print_header "Step 7: Installing zsh plugins"
    
    # zsh-autosuggestions
    if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
        print_status "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    else
        print_success "zsh-autosuggestions is already installed"
    fi
    
    # zsh-syntax-highlighting
    if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
        print_status "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    else
        print_success "zsh-syntax-highlighting is already installed"
    fi
    
    # zsh-completions
    if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions" ]; then
        print_status "Installing zsh-completions..."
        git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
    else
        print_success "zsh-completions is already installed"
    fi
    echo ""
    
    # Create Alacritty config directory if it doesn't exist
    print_header "Step 8: Setting up configurations"
    print_status "Setting up Alacritty configuration directory..."
    mkdir -p ~/.config/alacritty
    
    # Copy configurations
    print_status "Installing new configuration files..."
    cp .zshrc ~/.zshrc
    cp alacritty.yml ~/.config/alacritty/alacritty.yml
    
    print_success "Configuration files installed!"
    echo ""
    
    # Optional: Install additional tools
    print_header "Step 9: Installing optional tools"
    print_status "Installing additional modern CLI tools..."
    brew install --quiet \
        fzf \
        tree \
        jq \
        tldr \
        neofetch \
        figlet \
        cowsay
    
    # Setup fzf key bindings
    if command -v fzf &> /dev/null; then
        print_status "Setting up fzf key bindings..."
        $(brew --prefix)/opt/fzf/install --all --no-bash --no-fish
    fi
    echo ""
    
    print_success "🎉 Modern terminal setup complete!"
    echo ""
    print_warning "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. Configure Powerlevel10k by running: p10k configure"
    echo "  3. Make sure JetBrains Mono Nerd Font is selected in Alacritty"
    echo "  4. Enjoy your modern terminal! 🚀"
    echo ""
    print_status "Your original configuration has been backed up to:"
    echo "  $BACKUP_DIR"
    echo ""
    print_status "To restore your original configuration, run:"
    echo "  $0 restore"
    echo ""
    print_status "Useful commands to try:"
    echo "  • ls (enhanced with lsd)"
    echo "  • cat filename (enhanced with bat)"
    echo "  • find . -name '*.txt' (enhanced with fd)"
    echo "  • grep 'pattern' file (enhanced with ripgrep)"
    echo "  • weather london (get weather info)"
    echo "  • neofetch (system info)"
    echo ""
}

# Main script logic
case "${1:-install}" in
    "install")
        install_setup
        ;;
    "backup")
        create_backup
        ;;
    "restore")
        restore_backup "$2"
        ;;
    "list")
        list_backups
        ;;
    "help"|"-h"|"--help")
        show_usage
        ;;
    *)
        print_error "Unknown option: $1"
        echo ""
        show_usage
        exit 1
        ;;
esac 