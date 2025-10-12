#!/bin/bash

# NmapFlow scanner - NmapFlow
# Author: Cr4acknic
# Description: Installation script for network scanner

set -e

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

readonly SCRIPT_NAME="NmapFlow.sh"
readonly INSTALL_DIR="/usr/local/bin"
readonly SYMLINK_NAME="nmapflow"


show_banner() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════╗"
    echo -e "║            NmapFlow scanner (bash) - NmapFlow            ║"
    echo -e "║                  Author: Cr4cknic                        ║"
    echo -e "╚══════════════════════════════════════════════════════════╝${NC}"
    echo
}

# Log messages with colors
log_message() {
    local level="$1"
    local message="$2"
    
    case "$level" in
        "INFO")
            echo -e "${CYAN}[INFO]${NC} $message"
            ;;
        "SUCCESS")
            echo -e "${GREEN}[SUCCESS]${NC} $message"
            ;;
        "WARNING")
            echo -e "${YELLOW}[WARNING]${NC} $message"
            ;;
        "ERROR")
            echo -e "${RED}[ERROR]${NC} $message"
            ;;
    esac
}

# Check root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_message "ERROR" "This installer must be run as root (use sudo)"
        exit 1
    fi
}

# Detect OS
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VERSION=$VERSION_ID
    else
        log_message "ERROR" "Cannot detect operating system"
        exit 1
    fi
    
    log_message "INFO" "Detected OS: $OS $VERSION"
}

# Install dependencies
install_dependencies() {
    log_message "INFO" "Installing system dependencies..."
    
    case "$OS" in
        *"Ubuntu"*|*"Debian"*|*"Linux Mint"*|*"Elementary"*|*"Pop"*|*"Zorin"*)
            apt update
            apt install -y bash coreutils util-linux procps findutils grep sed gawk nmap xsltproc libxml2-utils curl wget git tree
            ;;
        *"CentOS"*|*"Red Hat"*|*"Rocky"*|*"AlmaLinux"*|*"Oracle Linux"*)
            if command -v dnf &> /dev/null; then
                dnf update -y
                dnf install -y bash coreutils util-linux procps-ng findutils grep sed gawk nmap libxslt libxml2 curl wget git tree
            else
                yum update -y
                yum install -y bash coreutils util-linux procps-ng findutils grep sed gawk nmap libxslt libxml2 curl wget git tree
            fi
            ;;
        *"Fedora"*)
            dnf update -y
            dnf install -y bash coreutils util-linux procps-ng findutils grep sed gawk nmap libxslt libxml2 curl wget git tree
            ;;
        *"Arch"*|*"Manjaro"*|*"EndeavourOS"*|*"Garuda"*|*"ArcoLinux"*)
            pacman -Syu --noconfirm
            pacman -S --noconfirm bash coreutils util-linux procps-ng findutils grep sed gawk nmap libxslt libxml2 curl wget git tree
            ;;
        *"openSUSE"*|*"SUSE"*)
            zypper refresh
            zypper install -y bash coreutils util-linux procps findutils grep sed gawk nmap libxslt-tools libxml2-tools curl wget git tree
            ;;
        *"Alpine"*)
            apk update
            apk add bash coreutils util-linux procps findutils grep sed gawk nmap libxslt libxml2-utils curl wget git tree
            ;;
        *"Gentoo"*)
            emerge --sync
            emerge -av app-shells/bash sys-apps/coreutils sys-apps/util-linux sys-process/procps sys-apps/findutils sys-apps/grep sys-apps/sed sys-apps/gawk net-analyzer/nmap dev-libs/libxslt dev-libs/libxml2 net-misc/curl net-misc/wget dev-vcs/git app-text/tree
            ;;
        *"Void"*)
            xbps-install -Syu
            xbps-install -y bash coreutils util-linux procps-ng findutils grep sed gawk nmap libxslt libxml2 curl wget git tree
            ;;
        *"Solus"*)
            eopkg update-repo
            eopkg install -y bash coreutils util-linux procps-ng findutils grep sed gawk nmap libxslt-devel libxml2-devel curl wget git tree
            ;;
        *"Clear Linux"*)
            swupd update
            swupd bundle-add shells-basic sysadmin-basic network-basic curl git
            ;;
        *"NixOS"*)
            log_message "INFO" "NixOS detected. Please add to your configuration.nix:"
            log_message "INFO" "environment.systemPackages = with pkgs; [ bash coreutils util-linux procps findutils gnugrep gnused gawk nmap libxslt libxml2 curl wget git tree ];"
            ;;
        *"Slackware"*)
            log_message "INFO" "Slackware detected. Please install manually using slackpkg or sbopkg:"
            log_message "INFO" "Required packages: bash, coreutils, util-linux, procps, findutils, grep, sed, gawk, nmap, libxslt, libxml2, curl, wget, git"
            ;;
        *"Kali"*|*"Parrot"*|*"BlackArch"*)
            if command -v apt &> /dev/null; then
                apt update
                apt install -y bash coreutils util-linux procps findutils grep sed gawk nmap xsltproc libxml2-utils curl wget git tree
            elif command -v pacman &> /dev/null; then
                pacman -Syu --noconfirm
                pacman -S --noconfirm bash coreutils util-linux procps-ng findutils grep sed gawk nmap libxslt libxml2 curl wget git tree
            fi
            ;;
        *"Amazon Linux"*)
            yum update -y
            yum install -y bash coreutils util-linux procps-ng findutils grep sed gawk nmap libxslt libxml2 curl wget git tree
            ;;
        *"Mageia"*)
            urpmi --auto-update
            urpmi bash coreutils util-linux procps-ng findutils grep sed gawk nmap libxslt libxml2 curl wget git tree
            ;;
        *"PCLinuxOS"*)
            apt update
            apt install bash coreutils util-linux procps findutils grep sed gawk nmap libxslt-tools libxml2-utils curl wget git tree
            ;;
        *"MX Linux"*|*"antiX"*)
            apt update
            apt install -y bash coreutils util-linux procps findutils grep sed gawk nmap xsltproc libxml2-utils curl wget git tree
            ;;
        *"Deepin"*|*"UOS"*)
            apt update
            apt install -y bash coreutils util-linux procps findutils grep sed gawk nmap xsltproc libxml2-utils curl wget git tree
            ;;
        *"Peppermint"*|*"LXLE"*)
            apt update
            apt install -y bash coreutils util-linux procps findutils grep sed gawk nmap xsltproc libxml2-utils curl wget git tree
            ;;
        *)
            log_message "WARNING" "Unsupported or unrecognized OS: $OS"
            log_message "INFO" "Attempting generic installation..."
            log_message "INFO" "Please install manually if this fails:"
            log_message "INFO" "  - bash (4.0+)"
            log_message "INFO" "  - coreutils (ls, cat, mkdir, etc.)"
            log_message "INFO" "  - util-linux (basic system utilities)"
            log_message "INFO" "  - procps (ps, kill, etc.)"
            log_message "INFO" "  - findutils (find, xargs)"
            log_message "INFO" "  - grep, sed, gawk (text processing)"
            log_message "INFO" "  - nmap (7.0+)"
            log_message "INFO" "  - xsltproc and libxml2 tools"
            log_message "INFO" "  - curl, wget, git, tree"
            
            # Try common package managers
            if command -v apt &> /dev/null; then
                log_message "INFO" "Trying apt package manager..."
                apt update && apt install -y bash coreutils util-linux procps findutils grep sed gawk nmap xsltproc libxml2-utils curl wget git tree
            elif command -v dnf &> /dev/null; then
                log_message "INFO" "Trying dnf package manager..."
                dnf install -y bash coreutils util-linux procps-ng findutils grep sed gawk nmap libxslt libxml2 curl wget git tree
            elif command -v yum &> /dev/null; then
                log_message "INFO" "Trying yum package manager..."
                yum install -y bash coreutils util-linux procps-ng findutils grep sed gawk nmap libxslt libxml2 curl wget git tree
            elif command -v pacman &> /dev/null; then
                log_message "INFO" "Trying pacman package manager..."
                pacman -S --noconfirm bash coreutils util-linux procps-ng findutils grep sed gawk nmap libxslt libxml2 curl wget git tree
            elif command -v zypper &> /dev/null; then
                log_message "INFO" "Trying zypper package manager..."
                zypper install -y bash coreutils util-linux procps findutils grep sed gawk nmap libxslt-tools libxml2-tools curl wget git tree
            elif command -v apk &> /dev/null; then
                log_message "INFO" "Trying apk package manager..."
                apk add bash coreutils util-linux procps findutils grep sed gawk nmap libxslt libxml2-utils curl wget git tree
            else
                log_message "ERROR" "No supported package manager found"
                read -p "Continue anyway? (y/N): " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    exit 1
                fi
            fi
            ;;
    esac
    
    log_message "SUCCESS" "System dependencies installation completed"
}

# Verify bash
check_bash_version() {
    log_message "INFO" "Checking Bash version..."
    
    local bash_version=$(bash --version | head -n1 | grep -oE '[0-9]+\.[0-9]+')
    local major_version=$(echo "$bash_version" | cut -d. -f1)
    
    if [ "$major_version" -lt 4 ]; then
        log_message "ERROR" "Bash version 4.0 or higher required (found: $bash_version)"
        exit 1
    fi
    
    log_message "SUCCESS" "Bash version $bash_version is compatible"
}

# Installer
install_scanner() {
    log_message "INFO" "Installing nmap scanner..."
    
    if [ ! -f "$SCRIPT_NAME" ]; then
        log_message "ERROR" "Scanner script not found: $SCRIPT_NAME"
        exit 1
    fi
    

    cp "$SCRIPT_NAME" "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
    
    # Symbolic link
    ln -sf "$INSTALL_DIR/$SCRIPT_NAME" "$INSTALL_DIR/$SYMLINK_NAME"
    
    log_message "SUCCESS" "Scanner installed to $INSTALL_DIR/$SCRIPT_NAME"
    log_message "SUCCESS" "Symbolic link created: $SYMLINK_NAME"
}

# Man page
create_man_page() {
    local man_dir="/usr/local/man/man1"
    local man_file="$man_dir/nmapflow.1"
    
    log_message "INFO" "Creating man page..."
    
    mkdir -p "$man_dir"
    
    cat > "$man_file" << 'EOF'
.TH nmapflow 1 "2025" "1.0" "NmapFlow scanner"
.SH NAME
nmapflow \- Advanced network scanner using Nmap
.SH SYNOPSIS
.B nmapflow
[\fIOPTIONS\fR] \fITARGET\fR [\fITARGET\fR...]
.SH DESCRIPTION
NmapFlow scanner is a comprehensive network scanning tool that automates
port scanning, service detection, and vulnerability assessment using Nmap.
.SH OPTIONS
.TP
.BR \-f ", " \-\-fast " [" \fIN\fR ]
Fast scan using top N ports (default: 500)
.TP
.BR \-F ", " \-\-full
Full TCP port scan (1-65535)
.TP
.BR \-U ", " \-\-udp " [" \fIN\fR ]
UDP scan using top N ports (default: 500)
.TP
.BR \-FU ", " \-\-fulludp
Full UDP port scan (1-65535)
.TP
.BR \-\-script " " \fICATEGORIES\fR
NSE script categories (vuln,safe,exploit,auth)
.TP
.BR \-fw ", " \-\-firewall
Interactive firewall evasion configuration
.TP
.BR \-sT ", " \-sS ", " \-sX ", " \-sN ", " \-sF ", " \-sA ", " \-sW
Scan type selection
.TP
.BR \-\-threads " " \fIN\fR
Number of parallel threads (default: 4)
.TP
.BR \-\-timeout " " \fIN\fR
Command timeout in seconds (default: 300)
.TP
.BR \-\-debug
detailed output for debugging
.TP
.BR \-h ", " \-\-help
Show help message
.SH EXAMPLES
.TP
nmapflow -f 1000 192.168.1.1
Fast scan of top 1000 ports
.TP
nmapflow -F --script vuln 192.168.1.0/24
Full scan with vulnerability scripts
.TP
sudo nmapflow -sS --threads 8 target.com
SYN scan with 8 threads
.SH AUTHOR
Written by Emilio Dahl Herce.
.SH SEE ALSO
.BR nmap (1)
EOF
    
    gzip "$man_file"
    log_message "SUCCESS" "Man page created"
}

# Setup auto-completion (Testing phase)
setup_bash_completion() {
    local completion_dir="/etc/bash_completion.d"
    local completion_file="$completion_dir/nmapflow"
    
    if [ -d "$completion_dir" ]; then
        log_message "INFO" "Setting up bash completion..."
        
        cat > "$completion_file" << 'EOF'
# Bash completion for nmapflow
_NmapFlow_bash() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    opts="-f --fast -F --full -U --udp -FU --fulludp --script -fw --firewall
          -sT -sS -sX -sN -sF -sA -sW --threads --timeout -h --help"
    
    case ${prev} in
        --script)
            COMPREPLY=( $(compgen -W "vuln safe exploit auth" -- ${cur}) )
            return 0
            ;;
        --threads|--timeout|-f|--fast|-U|--udp)
            COMPREPLY=( $(compgen -W "1 2 4 8 16 100 500 1000" -- ${cur}) )
            return 0
            ;;
        *)
            ;;
    esac
    
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    return 0
}

complete -F _NmapFlow_bash nmapflow
EOF
        
        log_message "SUCCESS" "Bash completion configured"
    fi
}

# Verify installation
verify_installation() {
    log_message "INFO" "Verifying installation..."
    
    if command -v "$SYMLINK_NAME" &> /dev/null; then
        log_message "SUCCESS" "Installation verified successfully"
        
        # Basic Test
        if "$SYMLINK_NAME" --help &> /dev/null; then
            log_message "SUCCESS" "Scanner is working correctly"
        else
            log_message "WARNING" "Scanner installed but may have issues"
        fi
    else
        log_message "ERROR" "Installation verification failed"
        exit 1
    fi
}

# Usage information
show_usage() {
    echo -e "\n${BOLD}Installation Complete!${NC}"
    echo -e "\n${CYAN}Usage:${NC}"
    echo -e "  $SYMLINK_NAME [options] <target>"
    echo -e "  $SYMLINK_NAME --help"
    echo -e "  man nmapflow"
    echo -e "\n${CYAN}Examples:${NC}"
    echo -e "  $SYMLINK_NAME -f 1000 192.168.1.1"
    echo -e "  $SYMLINK_NAME -F --script vuln 192.168.1.0/24"
    echo -e "  sudo $SYMLINK_NAME -sS --threads 8 target.com"
    echo -e "\n${YELLOW}Note:${NC} Some scan types require root privileges"
    echo -e "${YELLOW}Note:${NC} Restart your terminal for bash completion to work"
    echo
}

# Uninstaller
uninstall() {
    log_message "INFO" "Uninstalling nmap scanner..."
    
    rm -f "$INSTALL_DIR/$SCRIPT_NAME"
    rm -f "$INSTALL_DIR/$SYMLINK_NAME"
    rm -f "/usr/local/man/man1/nmapflow.1.gz"
    rm -f "/usr/share/applications/nmapflow.desktop"
    rm -f "/etc/bash_completion.d/nmapflow"
    
    log_message "SUCCESS" "Uninstallation completed"
}

main() {
    show_banner
    
    if [[ "$1" == "--uninstall" ]]; then
        check_root
        uninstall
        exit 0
    fi
    
    log_message "INFO" "Starting installation process..."
    
    check_root
    detect_os
    check_bash_version
    
    install_dependencies
    install_scanner
    create_man_page
    setup_bash_completion
    
    verify_installation
    
    show_usage
    
    log_message "SUCCESS" "Installation completed successfully!"
}

# Help
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "NmapFlow scanner - Bash Version Installer"
    echo "Author: Emilio Dahl Herce"
    echo
    echo "Usage: $0 [--uninstall]"
    echo
    echo "Options:"
    echo "  --uninstall    Remove the scanner from the system"
    echo "  --help         Show this help message"
    echo
    exit 0
fi

main "$@"
