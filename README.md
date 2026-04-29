# 🚀 Modern Terminal Setup

A beautiful, modern, and feature-rich terminal configuration for macOS using Alacritty, Zsh, and Oh My Zsh.

## ✨ Features

### 🎨 Visual Enhancements
- **Powerlevel10k Theme**: Modern, fast, and highly customizable prompt
- **Tokyo Night Color Scheme**: Beautiful dark theme with vibrant colors
- **JetBrains Mono Nerd Font**: Crisp, readable font with icon support
- **Transparent Background**: Subtle opacity for a modern look
- **Syntax Highlighting**: Real-time command syntax highlighting

### 🔌 Powerful Plugins
- **zsh-autosuggestions**: Fish-like autosuggestions
- **zsh-syntax-highlighting**: Command syntax highlighting
- **zsh-completions**: Additional completion definitions
- **Git Integration**: Enhanced git commands and status
- **Docker & Kubernetes**: Built-in support for containerization tools

### 🛠️ Modern CLI Tools
- **lsd**: Modern replacement for `ls` with icons and colors
- **bat**: Syntax-highlighted `cat` replacement
- **fd**: Fast and user-friendly `find` alternative
- **ripgrep**: Ultra-fast text search tool
- **fzf**: Fuzzy finder for files and commands
- **htop**: Interactive process viewer
- **dust**: Intuitive `du` replacement
- **duf**: Modern `df` alternative

### ⚡ Enhanced Productivity
- **Smart History**: Improved command history with deduplication
- **Intelligent Completion**: Case-insensitive tab completion
- **Quick Navigation**: Efficient directory jumping
- **Useful Functions**: Extract archives, weather info, process management
- **Comprehensive Aliases**: Shortcuts for common commands

## 🚀 Quick Start

1. **Run the setup script (automatically creates backup):**
   ```bash
   ./setup.sh
   ```

2. **Restart your terminal or reload configuration:**
   ```bash
   source ~/.zshrc
   ```

3. **Configure Powerlevel10k:**
   ```bash
   p10k configure
   ```

## 🔄 Backup & Restore

The setup script includes comprehensive backup and restore functionality to keep your configurations safe.

### Available Commands

```bash
./setup.sh install    # Install with automatic backup (default)
./setup.sh backup     # Create backup only
./setup.sh restore    # Restore from most recent backup
./setup.sh list       # List all available backups
./setup.sh help       # Show help message
```

### Backup Features

- **Automatic Backup**: Every installation automatically backs up your existing configuration
- **Timestamped Backups**: Each backup is stored with a unique timestamp
- **Comprehensive Coverage**: Backs up `.zshrc`, Alacritty config, and Powerlevel10k settings
- **Backup Info**: Each backup includes metadata about when and how it was created

### Restore Process

- **Safe Restore**: Creates a backup of current state before restoring
- **Confirmation Required**: Asks for confirmation before overwriting files
- **Multiple Restore Points**: Can restore from any previous backup

### Example Usage

```bash
# Create a backup before making changes
./setup.sh backup

# List all available backups
./setup.sh list

# Restore from the most recent backup
./setup.sh restore

# Restore from a specific backup
./setup.sh restore ~/.dotfiles_backup_20231201_143022
```

## 🗂️ Dotfiles Management

The `dotfiles.sh` script provides dotfiles management with backup integration.

### Management Commands

```bash
./dotfiles.sh copy     # Copy current system configs to repository
./dotfiles.sh save     # Install repository configs to system (with backup)
./dotfiles.sh sync     # Sync repository with current system configs
./dotfiles.sh status   # Show status comparison between repo and system
./dotfiles.sh help     # Show help message
```

### Tracked Files

Both `setup.sh` and `dotfiles.sh` share a `DOTFILES` array at the top of each
file. Add or remove entries there to manage additional dotfiles.

### Status Indicators

- `[OK]` Repository and system files are identical
- `[DIFF]` Files differ — run `copy` or `save` to reconcile
- `[REPO]` File exists only in repository
- `[SYS]` File exists only in system
- `[MISSING]` File missing in both locations

### Integration with Backup System

The dotfiles management script automatically integrates with the setup script's backup system:
- Uses `setup.sh backup` when available for consistent backup format
- Falls back to manual backup if setup script is not present
- Maintains backup history and metadata

## 📁 File Structure

```
dotfiles/
├── .zshrc           # Zsh configuration
├── alacritty.toml   # Alacritty terminal config
├── config           # Ghostty terminal config (installed to ~/.config/ghostty/config)
├── setup.sh         # Automated setup script with backup/restore
├── dotfiles.sh      # Dotfiles management script
└── README.md        # This guide
```

## 🎯 Key Aliases

### Git Shortcuts
```bash
g       # git
ga      # git add
gaa     # git add .
gc      # git commit
gcm     # git commit -m
gp      # git push
gpl     # git pull
gs      # git status
gl      # git log --oneline --graph --decorate
```

### Kubernetes Shortcuts
```bash
k       # kubectl
kgp     # kubectl get pods
kgs     # kubectl get services
kaf     # kubectl apply -f
```

### Docker Shortcuts
```bash
d       # docker
dc      # docker-compose
dps     # docker ps
di      # docker images
```

### Navigation
```bash
..      # cd ..
...     # cd ../..
~       # cd ~
-       # cd -
```

### Modern Tools
Modern replacements are exposed under new aliases so the standard commands
stay available for scripts and pipelines:
```bash
l, ll, la, lt   # lsd variants
b               # bat (syntax-highlighted cat)
f               # fd (friendlier find)
rg              # ripgrep (faster grep)
dust, duf       # dust/duf (du/df replacements)
htop            # interactive process viewer
```

## 🛠️ Useful Functions

### `mkcd <directory>`
Create a directory and navigate into it:
```bash
mkcd new-project
```

### `extract <archive>`
Extract any type of archive:
```bash
extract file.tar.gz
extract file.zip
```

### `weather <city>`
Get weather information:
```bash
weather london
weather "new york"
```

### `google <query>`
Quick web search (provided by the OMZ `web-search` plugin):
```bash
google "zsh tips"
```

### `killp <process-name>`
Find and terminate processes by name. Sends SIGTERM by default; pass `-9` for
SIGKILL:
```bash
killp chrome
killp -9 chrome
```

## 🎨 Customization

### Color Scheme
The configuration uses the Tokyo Night color scheme. To change it, modify the `[colors]` section in `alacritty.toml`.

### Font
Currently using JetBrains Mono Nerd Font. To change:
1. Install your preferred Nerd Font
2. Update the `[font]` section in `alacritty.toml`

### Theme
Using Powerlevel10k theme. Reconfigure anytime with:
```bash
p10k configure
```

## 📦 Dependencies

The setup script automatically installs:

### Essential Tools
- lsd, bat, fd, ripgrep, htop, dust, duf
- git, curl, wget

### Optional Tools
- fzf, tree, jq, tldr, neofetch, figlet, cowsay

### Fonts
- JetBrains Mono Nerd Font

### Zsh Components
- Oh My Zsh
- Powerlevel10k theme
- zsh-autosuggestions
- zsh-syntax-highlighting
- zsh-completions

## 🔧 Manual Installation

If you prefer manual installation:

1. **Install Homebrew** (if not already installed):
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Install Oh My Zsh**:
   ```bash
   sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
   ```

3. **Install Powerlevel10k**:
   ```bash
   git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
   ```

4. **Install plugins**:
   ```bash
   git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
   git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
   git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
   ```

5. **Copy configuration files**:
   ```bash
   cp .zshrc ~/.zshrc
   mkdir -p ~/.config/alacritty ~/.config/ghostty
   cp alacritty.toml ~/.config/alacritty/alacritty.toml
   cp config ~/.config/ghostty/config
   ```

## 🎮 Keyboard Shortcuts

### Alacritty Shortcuts
- `Cmd + T`: New window
- `Cmd + W`: Close window
- `Cmd + C`: Copy
- `Cmd + V`: Paste
- `Cmd + F`: Search
- `Cmd + K`: Clear screen
- `Cmd + Plus/Minus`: Increase/decrease font size
- `Cmd + 0`: Reset font size

### Zsh Shortcuts
- `Ctrl + R`: Search command history
- `Ctrl + A`: Move to beginning of line
- `Ctrl + E`: Move to end of line
- `Ctrl + U`: Clear line
- `Alt + Left/Right`: Move by word

## 🤝 Contributing

Feel free to customize and improve this configuration! Some ideas:
- Add more useful aliases
- Include additional plugins
- Customize the color scheme
- Add more utility functions

## 📝 License

This configuration is free to use and modify. Enjoy your modern terminal! 🎉

---

**Happy coding!** 🚀✨ 