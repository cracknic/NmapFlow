#!/bin/bash

# Advanced Nmap Scanner - NmapFlow
# Author: Cracknic
# Description: Comprehensive network scanning tool with advanced features

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly BOLD='\033[1m'
readonly UNDERLINE='\033[4m'
readonly NC='\033[0m'

readonly SCRIPT_NAME=$(basename "$0")
readonly TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
readonly BASE_DIR="NmapScan_${TIMESTAMP}"
readonly LOG_FILE="nmap_scan_${TIMESTAMP}.log"

# Scan config
declare -a TARGETS=()
TCP_PORTS=""
UDP_PORTS=""
SCAN_TYPE="-sS"
declare -a SCRIPTS=()
FIREWALL_EVASION=""
THREADS=4
TIMEOUT=600
FAST_PORTS=500
UDP_FAST_PORTS=200
FULL_TCP=false
FULL_UDP=false
DEBUG=false

# Storage
declare -a ACTIVE_HOSTS=()
declare -A TCP_PORTS_BY_HOST
declare -A UDP_PORTS_BY_HOST
declare -a SCAN_ERRORS=()

# Progress
TOTAL_STEPS=0
CURRENT_STEP=0

show_banner() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════╗"
    echo -e "║                  Advanced Nmap Scanner                   ║"
    echo -e "║                 Author: Cracknic                         ║"
    echo -e "╚══════════════════════════════════════════════════════════╝${NC}"
    echo
}

# Logging
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    case "$level" in
        "ERROR")
            echo -e "${RED}[ERROR]${NC} $message" >&2
            ;;
        "SUCCESS")
            echo -e "${GREEN}[SUCCESS]${NC} $message"
            ;;
        "INFO")
            echo -e "${CYAN}[INFO]${NC} $message"
            ;;
        "WARNING")
            echo -e "${YELLOW}[WARNING]${NC} $message"
            ;;
        "DEBUG")
            if [ "$DEBUG" = true ]; then
                echo -e "${YELLOW}[DEBUG]${NC} $message"
            fi
            ;;
        "COMPLETED")
            echo -e "${GREEN}[COMPLETED]${NC} $message"
            ;;
        *)
            echo "$message"
            ;;
    esac
}

# Progress bar
show_progress() {
    local current=${1:-0}
    local total=${2:-0}
    local description="$3"
    local width=50

    # Ensure total is a valid integer and not zero
    if ! [[ "$total" =~ ^[0-9]+$ ]] || [ "$total" -eq 0 ]; then
        return
    fi

    # Ensure current is a valid integer
    if ! [[ "$current" =~ ^[0-9]+$ ]]; then
        current=0
    fi

    local percent=$((current * 100 / total))
    local filled=$((current * width / total))
    local bar=""

    for ((i=0; i<filled; i++)); do
        bar+="█"
    done

    for ((i=filled; i<width; i++)); do
        bar+="░"
    done

    local color
    if [ "$percent" -lt 30 ]; then
        color="$RED"
    elif [ "$percent" -lt 70 ]; then
        color="$YELLOW"
    else
        color="$GREEN"
    fi

    # Only print progress bar if running in a terminal
    if [ -t 1 ]; then
        printf "\r${CYAN}%s${NC}: ${color}[%s]${NC} %d%% (%d/%d)" "$description" "$bar" "$percent" "$current" "$total"
        if [ "$current" -eq "$total" ]; then
            echo -e " ${GREEN}✓${NC}"
        fi
    fi
}

# Update progress
update_progress() {
    ((CURRENT_STEP++))
    show_progress "$CURRENT_STEP" "$TOTAL_STEPS" "Scan Progress"
}

# Validate dependencies
validate_dependencies() {
    log_message "INFO" "Validating system dependencies..."
    
    local dependencies=("nmap" "xsltproc" "xmllint")
    local missing=()
    
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        log_message "ERROR" "Missing dependencies: ${missing[*]}"
        echo "Please install the missing dependencies and try again."
        exit 1
    fi
    
    log_message "SUCCESS" "All dependencies validated"
}

# Check privileges
check_privileges() {
    if [ "$EUID" -ne 0 ] && [[ "$SCAN_TYPE" =~ ^(-sS|-sF|-sX|-sN)$ ]]; then
        log_message "WARNING" "Some scan types require root privileges"
        read -p "$(echo -e "${CYAN}Continue anyway? (y/N):${NC} ")" -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}Exiting...${NC}"
            exit 1
        fi
    fi
}

# Validate IP
validate_ip_format() {
    local ip="$1"
    
    if [[ $ip =~ ^([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})$ ]]; then
        local IFS='.'
        local -a octets=($ip)
        for octet in "${octets[@]}"; do
            if [ "$octet" -lt 0 ] || [ "$octet" -gt 255 ]; then
                return 1
            fi
        done
        return 0
    fi
    
    if [[ $ip =~ ^([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})/([0-9]{1,2})$ ]]; then
        local ip_part="${ip%/*}"
        local cidr="${ip#*/}"
        
        local IFS='.'
        local -a octets=($ip_part)
        for octet in "${octets[@]}"; do
            if [ "$octet" -lt 0 ] || [ "$octet" -gt 255 ]; then
                return 1
            fi
        done
        
        if [ "$cidr" -lt 1 ] || [ "$cidr" -gt 32 ]; then
            return 1
        fi
        
        return 0
    fi
    
    return 1
}

# Firewall evasion setup
setup_firewall_evasion() {
    echo -e "\n${PURPLE}[FIREWALL EVASION]${NC} Configure evasion techniques:"
    
    declare -A evasion_options=(
        ["1"]="-f Fragment packets (requires root)"
        ["2"]="--mtu 8 Fragment packets 8-byte MTU (requires root)"
        ["3"]="-D RND:10 Decoy scan with 10 random IPs"
        ["4"]="-g Source port spoofing"
        ["5"]="--data-length Append random data"
        ["6"]="--ttl Set IP time-to-live field"
        ["7"]="--badsum Use bad checksum"
        ["8"]="--scan-delay Delay between probes"
        ["9"]="--mtu Set custom MTU (requires root)"
        ["10"]="--spoof-mac Spoof MAC address"
        ["11"]="--max-scan-delay Maximum delay between probes"
        ["12"]="--max-rate Maximum packet rate"
        ["13"]="--min-rate Minimum packet rate"
        ["14"]="--ip-options IP options (requires root)"
        ["15"]="-D Custom decoy list"
    )
    
    echo -e "\n${BLUE}Available evasion techniques:${NC}"
    for key in $(printf '%s\n' "${!evasion_options[@]}" | sort -n); do
        IFS=' ' read -r option description <<< "${evasion_options[$key]}"
        echo -e "  ${CYAN}$key.${NC} $description"
    done
    
    echo -e "\n${CYAN}Enter options (comma-separated) or 'none':${NC}"
    read -p "Selection: " choices
    
    if [[ "$choices" == "none" ]]; then
        return
    fi
    
    local selected_options=()
    IFS=',' read -ra CHOICE_ARRAY <<< "$choices"
    
    for choice in "${CHOICE_ARRAY[@]}"; do
        choice=$(echo "$choice" | xargs)
        
        if [[ -n "${evasion_options[$choice]}" ]]; then
            IFS=' ' read -r option description <<< "${evasion_options[$choice]}"
            
            case "$choice" in
                "1")
                    selected_options+=("-f")
                    ;;
                "2")
                    selected_options+=("--mtu 8")
                    ;;
                "3")
                    selected_options+=("-D RND:10")
                    ;;
                "7")
                    selected_options+=("--badsum")
                    ;;
                "4") 
                    read -p "$(echo -e "${CYAN}Enter source port (e.g., 53, 80, 443):${NC} ")" source_port
                    selected_options+=("-g $source_port")
                    ;;
                "5") 
                    read -p "$(echo -e "${CYAN}Enter data length (bytes):${NC} ")" data_length
                    selected_options+=("--data-length $data_length")
                    ;;
                "6") 
                    read -p "$(echo -e "${CYAN}Enter TTL value (1-255):${NC} ")" ttl_value
                    selected_options+=("--ttl $ttl_value")
                    ;;
                "8")
                    read -p "$(echo -e "${CYAN}Enter delay (e.g., 1s, 100ms):${NC} ")" scan_delay
                    selected_options+=("--scan-delay $scan_delay")
                    ;;
                "9") 
                    read -p "$(echo -e "${CYAN}Enter MTU value (8, 16, 24, 32):${NC} ")" mtu_value
                    selected_options+=("--mtu $mtu_value")
                    ;;
                "10")
                    read -p "$(echo -e "${CYAN}Enter MAC address or vendor (e.g., 0, Apple, Dell):${NC} ")" mac_addr
                    selected_options+=("--spoof-mac $mac_addr")
                    ;;
                "11")
                    read -p "$(echo -e "${CYAN}Enter maximum delay (e.g., 10s, 1000ms):${NC} ")" max_scan_delay
                    selected_options+=("--max-scan-delay $max_scan_delay")
                    ;;
                "12")
                    read -p "$(echo -e "${CYAN}Enter maximum rate (packets/sec):${NC} ")" max_rate
                    selected_options+=("--max-rate $max_rate")
                    ;;
                "13") 
                    read -p "$(echo -e "${CYAN}Enter minimum rate (packets/sec):${NC} ")" min_rate
                    selected_options+=("--min-rate $min_rate")
                    ;;
                "14")
                    read -p "$(echo -e "${CYAN}Enter IP options (e.g., S, R, T):${NC} ")" ip_options
                    selected_options+=("--ip-options $ip_options")
                    ;;
                "15")
                    read -p "$(echo -e "${CYAN}Enter decoy IPs (comma-separated):${NC} ")" decoy_list
                    selected_options+=("-D $decoy_list")
                    ;;
                *)
                    selected_options+=("$option")
                    ;;
            esac
        fi
    done
    
    FIREWALL_EVASION="${selected_options[*]}"
}

# Directory structure
create_directory_structure() {
    mkdir -p "$BASE_DIR"
    
    for target in "${TARGETS[@]}"; do
        create_target_directory "$target"
    done
    
    log_message "SUCCESS" "Directory structure created: ${UNDERLINE}$BASE_DIR${NC}"
}

create_target_directory() {
    local target="$1"
    local target_clean=$(echo "$target" | sed 's/[\/:]/_/g')
    local target_dir="$BASE_DIR/$target_clean"
    
    log_message "DEBUG" "Creating directory structure for target: $target"
    log_message "DEBUG" "Target directory: $target_dir"
    
    mkdir -p "$target_dir"
    
    for protocol in TCP UDP; do
        local protocol_dir="$target_dir/$protocol"
        mkdir -p "$protocol_dir"
        
        for format_type in oN oX oG; do
            mkdir -p "$protocol_dir/$format_type"
        done
    done
    
    log_message "DEBUG" "Directory structure created for: $target"
}

# Error handling
execute_command() {
    local command="$1"
    local timeout_val="${2:-$TIMEOUT}"
    
    log_message "DEBUG" "=== COMMAND EXECUTION START ==="
    log_message "DEBUG" "Command: $command"
    log_message "DEBUG" "Timeout: ${timeout_val}s"
    log_message "DEBUG" "Current user: $(whoami)"
    log_message "DEBUG" "Current UID: $(id -u)"
    log_message "DEBUG" "Working directory: $(pwd)"
    
    if [[ "$command" == *"nmap"* ]]; then
        echo -e "${CYAN}[EXEC]${NC} $command"
    fi
    
    # Create temporary output
    local temp_output=$(mktemp)
    local start_time=$(date +%s)
    
    log_message "DEBUG" "Starting command execution..."
    
    # Hide output unless in debug mode
    if [[ "$command" == *"nmap"* ]] && [ "$DEBUG" != true ]; then
        if timeout "$timeout_val" bash -c "$command" > "$temp_output" 2>&1; then
            local exit_code=0
        else
            local exit_code=$?
        fi
    else
        if timeout "$timeout_val" bash -c "$command" 2>&1 | tee "$temp_output"; then
            local exit_code=0
        else
            local exit_code=$?
        fi
    fi
    
    if [ $exit_code -eq 0 ]; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        log_message "DEBUG" "Command completed with exit code 0"
        log_message "DEBUG" "Execution time: ${duration}s"
        log_message "DEBUG" "Output file size: $(wc -l < "$temp_output") lines"
        
        if [[ "$command" == *"nmap"* ]]; then
            echo -e "${GREEN}[SUCCESS]${NC} Command completed (${duration}s)"
        fi
        
        log_message "DEBUG" "First 5 lines of output:"
        head -5 "$temp_output" | while read line; do
            log_message "DEBUG" "OUT: $line"
        done
        
        log_message "DEBUG" "Last 5 lines of output:"
        tail -5 "$temp_output" | while read line; do
            log_message "DEBUG" "OUT: $line"
        done
        
    else
        local exit_code=$?
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        log_message "DEBUG" "Command failed with exit code $exit_code"
        log_message "DEBUG" "Execution time: ${duration}s"
        log_message "DEBUG" "Error output:"
        
        # Error for debugging
        head -10 "$temp_output" | while read line; do
            log_message "DEBUG" "ERR: $line"
        done
        
        if [ $exit_code -eq 124 ]; then
            echo -e "${RED}[ERROR]${NC} Command timed out after ${timeout_val}s"
            log_message "ERROR" "Command timed out after ${timeout_val}s: $command"
        else
            echo -e "${RED}[ERROR]${NC} Command failed (exit code: $exit_code)"
            log_message "ERROR" "Command failed with exit code $exit_code: $command"
        fi
        SCAN_ERRORS+=("Command failed: $command")
    fi
    
    echo "=== Command Output Start ===" >> "$LOG_FILE"
    cat "$temp_output" >> "$LOG_FILE"
    echo "=== Command Output End ===" >> "$LOG_FILE"
    
    rm -f "$temp_output"
    
    log_message "DEBUG" "=== COMMAND EXECUTION END ==="
    return $exit_code
}

# Setup targets
host_discovery() {
    echo -e "\n${PURPLE}[HOST DISCOVERY]${NC} Scanning for active hosts..."
    
    ACTIVE_HOSTS=()
    
    for target in "${TARGETS[@]}"; do
        # Check CIDR or IP
        if [[ "$target" == *"/"* ]]; then
            echo -e "${BLUE}[INFO]${NC} Performing host discovery on network: ${UNDERLINE}$target${NC}"
            
            local target_clean=$(echo "$target" | sed 's/[\/:]/_/g')
            local target_dir="$BASE_DIR/$target_clean"
            mkdir -p "$target_dir"/{oN,oX,oG}
            
            local output_files=(
                "-oG $target_dir/oG/nmap_hostdiscovery_${target_clean}_oG.gnmap"
                "-oN $target_dir/oN/nmap_hostdiscovery_${target_clean}_oN.nmap"
                "-oX $target_dir/oX/nmap_hostdiscovery_${target_clean}_oX.xml"
            )
            
            # Use quiet mode unless debug
            if [ "$DEBUG" = true ]; then
                local command="nmap -sn -vvv ${output_files[*]} $target"
            else
                local command="nmap -sn ${output_files[*]} $target"
            fi
            
            if execute_command "$command"; then
                # Parse active hosts
                local gnmap_file="$target_dir/oG/nmap_hostdiscovery_${target_clean}_oG.gnmap"
                if [[ -f "$gnmap_file" ]]; then
                    while IFS= read -r line; do
                        if [[ "$line" == *"Status: Up"* ]]; then
                            local ip=$(echo "$line" | awk '{print $2}')
                            if [[ -n "$ip" ]]; then
                                ACTIVE_HOSTS+=("$ip")
                                echo -e "${GREEN}[FOUND]${NC} Active host: ${BOLD}$ip${NC}"
                            fi
                        fi
                    done < "$gnmap_file"
                else
                    echo -e "${YELLOW}[WARNING]${NC} Could not parse host discovery results"
                    ACTIVE_HOSTS+=("$target")
                fi
            else
                echo -e "${YELLOW}[WARNING]${NC} Host discovery failed for $target"
                ACTIVE_HOSTS+=("$target")
            fi
        else
            # Single IP
            echo -e "${BLUE}[INFO]${NC} Single IP target: ${UNDERLINE}$target${NC}"
            ACTIVE_HOSTS+=("$target")
        fi
    done
    
    if [[ ${#ACTIVE_HOSTS[@]} -eq 0 ]]; then
        echo -e "${RED}[ERROR]${NC} No active hosts found"
        exit 1
    fi
    
    # Remove duplicates
    local unique_hosts=()
    local seen=()
    for host in "${ACTIVE_HOSTS[@]}"; do
        local found=false
        for seen_host in "${seen[@]}"; do
            if [[ "$host" == "$seen_host" ]]; then
                found=true
                break
            fi
        done
        if [[ "$found" == false ]]; then
            unique_hosts+=("$host")
            seen+=("$host")
        fi
    done
    
    ACTIVE_HOSTS=("${unique_hosts[@]}")
    echo -e "${GREEN}[SUCCESS]${NC} ${#ACTIVE_HOSTS[@]} active host(s) discovered"
}

# TCP port
port_scan_tcp() {
    local target="$1"
    
    create_target_directory "$target"
    
    local target_clean=$(echo "$target" | sed 's/[\/:]/_/g')
    local target_dir="$BASE_DIR/$target_clean/TCP"
    
    # Port range
    local ports_arg
    if [ "$FULL_TCP" = true ]; then
        ports_arg="-p 1-65535"
    else
        ports_arg="--top-ports $FAST_PORTS"
    fi
    
    local output_files=(
        "$target_dir/oG/nmap_ports_${target_clean}_oG.gnmap"
        "$target_dir/oN/nmap_ports_${target_clean}_oN.nmap"
        "$target_dir/oX/nmap_ports_${target_clean}_oX.xml"
    )
    
    # Check sudo
    local sudo_prefix=""
    if [[ "$SCAN_TYPE" == "-sS" || "$SCAN_TYPE" == "-sF" || "$SCAN_TYPE" == "-sX" || "$SCAN_TYPE" == "-sN" ]]; then
        if [ "$EUID" -ne 0 ]; then
            sudo_prefix="sudo "
        fi
    fi
    
    if [ "$DEBUG" = true ]; then
        local command="${sudo_prefix}nmap $ports_arg $SCAN_TYPE -n -Pn --min-rate 2000 -vvv $FIREWALL_EVASION -oG ${output_files[0]} -oN ${output_files[1]} -oX ${output_files[2]} $target"
    else
        local command="${sudo_prefix}nmap $ports_arg $SCAN_TYPE -n -Pn --min-rate 2000 $FIREWALL_EVASION -oG ${output_files[0]} -oN ${output_files[1]} -oX ${output_files[2]} $target"
    fi
    
    if execute_command "$command"; then
        # Parse open ports
        local open_ports=()
        if [ -f "${output_files[0]}" ]; then
            while IFS= read -r line; do
                if [[ $line == *"Ports:"* ]]; then
                    local ports_section=$(echo "$line" | sed 's/.*Ports: //' | cut -d$'\t' -f1)
                    IFS=', ' read -ra port_array <<< "$ports_section"
                    for port_info in "${port_array[@]}"; do
                        if [[ $port_info == *"/open/"* ]]; then
                            local port=$(echo "$port_info" | cut -d'/' -f1)
                            open_ports+=("$port")
                        fi
                    done
                fi
            done < "${output_files[0]}"
        fi
        
        local ports_str=$(IFS=','; echo "${open_ports[*]}")
        TCP_PORTS_BY_HOST["$target"]="$ports_str"
        
        update_progress
        return 0
    else
        update_progress
        return 1
    fi
}

# TCP service/script detection
service_detection() {
    local target="$1"
    local ports="$2"
    
    if [ -z "$ports" ]; then
        return
    fi
    
    local target_clean=$(echo "$target" | sed 's/[\/:]/_/g')
    local target_dir="$BASE_DIR/$target_clean/TCP"
    
    local output_files=(
        "$target_dir/oG/nmap_service_${target_clean}_oG.gnmap"
        "$target_dir/oN/nmap_service_${target_clean}_oN.nmap"
        "$target_dir/oX/nmap_service_${target_clean}_oX.xml"
    )
    
    local script_args=""
    if [ ${#SCRIPTS[@]} -gt 0 ]; then
        local scripts_str=$(IFS=','; echo "${SCRIPTS[*]}")
        script_args="--script $scripts_str"
    fi
    
    # Check sudo
    local sudo_prefix=""
    if [ "$EUID" -ne 0 ]; then
        sudo_prefix="sudo "
    fi
    
    local command="${sudo_prefix}nmap -sV -sC -p $ports $FIREWALL_EVASION $script_args $target -oG ${output_files[0]} -oN ${output_files[1]} -oX ${output_files[2]}"
    
    execute_command "$command"
    update_progress
}

# UDP port scan
port_scan_udp() {
    local target="$1"
    
    create_target_directory "$target"
    
    local target_clean=$(echo "$target" | sed 's/[\/:]/_/g')
    local target_dir="$BASE_DIR/$target_clean/UDP"
    
    local output_files=(
        "$target_dir/oG/nmap_udp_${target_clean}_oG.gnmap"
        "$target_dir/oN/nmap_udp_${target_clean}_oN.nmap"
        "$target_dir/oX/nmap_udp_${target_clean}_oX.xml"
    )
    
    local command
    # Check if sudo
    local sudo_prefix=""
    if [ "$EUID" -ne 0 ]; then
        sudo_prefix="sudo "
    fi
    
    # Use verbose in debug
    if [ "$FULL_UDP" = true ]; then
        if [ "$DEBUG" = true ]; then
            command="${sudo_prefix}nmap -sU -p 1-65535 -vvv $target -oG ${output_files[0]} -oN ${output_files[1]} -oX ${output_files[2]}"
        else
            command="${sudo_prefix}nmap -sU -p 1-65535 $target -oG ${output_files[0]} -oN ${output_files[1]} -oX ${output_files[2]}"
        fi
    else
        if [ "$DEBUG" = true ]; then
            command="${sudo_prefix}nmap -sU --top-ports $UDP_FAST_PORTS -vvv $target -oG ${output_files[0]} -oN ${output_files[1]} -oX ${output_files[2]}"
        else
            command="${sudo_prefix}nmap -sU --top-ports $UDP_FAST_PORTS $target -oG ${output_files[0]} -oN ${output_files[1]} -oX ${output_files[2]}"
        fi
    fi
    
    if execute_command "$command"; then
        # Parse UDP ports
        local open_ports=()
        if [ -f "${output_files[0]}" ]; then
            while IFS= read -r line; do
                if [[ $line == *"Ports:"* ]]; then
                    local ports_section=$(echo "$line" | sed 's/.*Ports: //' | cut -d$'\t' -f1)
                    IFS=', ' read -ra port_array <<< "$ports_section"
                    for port_info in "${port_array[@]}"; do
                        if [[ $port_info == *"/open/"* ]]; then
                            local port=$(echo "$port_info" | cut -d'/' -f1)
                            open_ports+=("$port")
                        fi
                    done
                fi
            done < "${output_files[0]}"
        fi
        
        # Store UDP results
        local ports_str=$(IFS=','; echo "${open_ports[*]}")
        UDP_PORTS_BY_HOST["$target"]="$ports_str"
        
        update_progress
        return 0
    else
        update_progress
        return 1
    fi
}

# UDP service detection
udp_service_detection() {
    local target="$1"
    local ports="$2"
    
    if [ -z "$ports" ]; then
        return
    fi
    
    local target_clean=$(echo "$target" | sed 's/[\/:]/_/g')
    local target_dir="$BASE_DIR/$target_clean/UDP"
    
    local output_files=(
        "$target_dir/oG/nmap_udp_service_${target_clean}_oG.gnmap"
        "$target_dir/oN/nmap_udp_service_${target_clean}_oN.nmap"
        "$target_dir/oX/nmap_udp_service_${target_clean}_oX.xml"
    )
    
    # UDP scripts
    local udp_scripts=()
    for script in "${SCRIPTS[@]}"; do
        case "$script" in
            "vuln")
                udp_scripts+=("dns-zone-transfer" "snmp-info" "ntp-info")
                ;;
            "safe")
                udp_scripts+=("dhcp-discover" "dns-service-discovery")
                ;;
        esac
    done
    
    local script_args=""
    if [ ${#udp_scripts[@]} -gt 0 ]; then
        local scripts_str=$(IFS=','; echo "${udp_scripts[*]}")
        script_args="--script $scripts_str"
    fi
    
    # Check sudo
    local sudo_prefix=""
    if [ "$EUID" -ne 0 ]; then
        sudo_prefix="sudo "
    fi
    
    local command="${sudo_prefix}nmap -sU -sV -p $ports $script_args $target -oG ${output_files[0]} -oN ${output_files[1]} -oX ${output_files[2]}"
    
    execute_command "$command"
    update_progress
}

# Consolidate XML files
consolidate_xml_files() {
    local target="$1"
    local target_clean=$(echo "$target" | sed 's/[\/:]/_/g')
    local target_dir="$BASE_DIR/$target_clean"
    
    # Collect XML
    local xml_files=()
    for protocol in TCP UDP; do
        local xml_dir="$target_dir/$protocol/oX"
        if [ -d "$xml_dir" ]; then
            while IFS= read -r -d '' file; do
                xml_files+=("$file")
            done < <(find "$xml_dir" -name "*.xml" -print0)
        fi
    done
    
    if [ ${#xml_files[@]} -eq 0 ]; then
        return
    fi
    
    # Create combined XML
    local combined_xml="$target_dir/combined_scan_${target_clean}.xml"
    
    {
        echo '<?xml version="1.0" encoding="UTF-8"?>'
        echo '<nmaprun>'
        
        for xml_file in "${xml_files[@]}"; do
            if [ -f "$xml_file" ]; then
                sed -n '/<nmaprun/,/<\/nmaprun>/p' "$xml_file" | sed '1d;$d'
            fi
        done
        
        echo '</nmaprun>'
    } > "$combined_xml"
    
    # HTML report
    local html_file="$target_dir/combined_report_${target_clean}.html"
    
    local xsl_paths=(
        "/usr/share/nmap/nmap.xsl"
        "/usr/local/share/nmap/nmap.xsl"
        "/opt/nmap/nmap.xsl"
    )
    
    local xsl_file=""
    for path in "${xsl_paths[@]}"; do
        if [ -f "$path" ]; then
            xsl_file="$path"
            break
        fi
    done
    
    if [ -n "$xsl_file" ]; then
        if xsltproc -o "$html_file" "$xsl_file" "$combined_xml" 2>/dev/null; then
            log_message "SUCCESS" "HTML report generated: ${UNDERLINE}$html_file${NC}"
        else
            log_message "WARNING" "Failed to generate HTML report for $target"
        fi
    else
        log_message "WARNING" "Nmap XSL stylesheet not found"
    fi
}

# Target scanning
scan_target() {
    local target="$1"
    log_message "INFO" "Scanning target: ${BOLD}$target${NC}"
    show_progress
    
    # TCP port scan
    port_scan_tcp "$target"
    update_progress
    
    # TCP service detection
    local tcp_ports="${TCP_PORTS_BY_HOST[$target]}"
    if [ -n "$tcp_ports" ]; then
        service_detection "$target" "$tcp_ports"
        update_progress
    else
        update_progress
    fi
    
    # UDP port scan
    port_scan_udp "$target"
    
    # UDP service detection
    local udp_ports="${UDP_PORTS_BY_HOST[$target]}"
    if [ -n "$udp_ports" ]; then
        udp_service_detection "$target" "$udp_ports"
        update_progress
    else
        update_progress
    fi
    
    # Generate report
    consolidate_xml_files "$target"
    update_progress
    
    log_message "COMPLETED" "Target scan finished: ${BOLD}$target${NC}"
}

# Execute all scans with parallel processing
run_scans() {
    local targets_to_scan=("${ACTIVE_HOSTS[@]}")
    
    if [ ${#targets_to_scan[@]} -eq 0 ]; then
        echo -e "${RED}[ERROR]${NC} No active hosts found to scan"
        return 1
    fi
    
    echo -e "${CYAN}[INFO]${NC} Starting comprehensive scan for ${BOLD}${#targets_to_scan[@]}${NC} active host(s)"
    echo -e "${BLUE}[HOSTS]${NC} Active hosts discovered: ${targets_to_scan[*]}"
    
    # Configure progress tracking
    local total_steps=$((${#targets_to_scan[@]} * 4)) 
    if [[ "$UDP_FAST_PORTS" -eq 0 && "$FULL_UDP" != true ]]; then
        total_steps=$((${#targets_to_scan[@]} * 2)) 
    fi
    
    local current_step=0
    local successful_scans=0
    local failed_scans=0
    
    # Execute scans with controlled parallelism
    local pids=()
    local active_jobs=0
    
    for target in "${targets_to_scan[@]}"; do
        # Thread pool
        while [ "$active_jobs" -ge "$THREADS" ]; do
            for i in "${!pids[@]}"; do
                if ! kill -0 "${pids[$i]}" 2>/dev/null; then
                    wait "${pids[$i]}"
                    local exit_code=$?
                    if [ $exit_code -eq 0 ]; then
                        ((successful_scans++))
                        echo -e "${GREEN}[COMPLETED]${NC} Host scan finished: ${BOLD}${target}${NC}"
                    else
                        ((failed_scans++))
                        echo -e "${RED}[FAILED]${NC} Host scan failed: ${BOLD}${target}${NC}"
                    fi
                    unset "pids[$i]"
                    ((active_jobs--))
                fi
            done
            sleep 0.1
        done
        
        # Launch new scan job
        echo -e "${BLUE}[STARTING]${NC} Scanning host: ${BOLD}${target}${NC}"
        scan_target "$target" &
        pids+=($!)
        ((active_jobs++))
    done
    
    # Wait for all jobs
    for pid in "${pids[@]}"; do
        wait "$pid"
        local exit_code=$?
        if [ $exit_code -eq 0 ]; then
            ((successful_scans++))
        else
            ((failed_scans++))
        fi
    done
    
    echo -e "\n${GREEN}[SCAN SUMMARY]${NC}"
    echo -e "  ${GREEN}✓${NC} Successful scans: ${BOLD}${successful_scans}${NC}"
    echo -e "  ${RED}✗${NC} Failed scans: ${BOLD}${failed_scans}${NC}"
}

# Summary report
generate_summary_report() {
    local summary_file="$BASE_DIR/scan_summary.txt"
    
    {
        echo "Advanced Nmap Scanner - Summary Report"
        echo "Author: Cracknic"
        echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "=========================================================="
        echo
        
        echo "Scan Configuration:"
        echo "  Targets: ${TARGETS[*]}"
        echo "  Scan Type: $SCAN_TYPE"
        echo "  TCP Ports: $([ "$FULL_TCP" = true ] && echo "Full scan" || echo "Top $FAST_PORTS")"
        echo "  UDP Ports: $([ "$FULL_UDP" = true ] && echo "Full scan" || echo "Top $UDP_FAST_PORTS")"
        echo "  Scripts: $([ ${#SCRIPTS[@]} -gt 0 ] && echo "${SCRIPTS[*]}" || echo "None")"
        echo "  Firewall Evasion: $([ -n "$FIREWALL_EVASION" ] && echo "$FIREWALL_EVASION" || echo "None")"
        echo "  Threads: $THREADS"
        echo
        
        echo "Results Summary:"
        echo "  Active Hosts: ${#ACTIVE_HOSTS[@]}"
        
        local total_tcp_ports=0
        local total_udp_ports=0
        
        for target in "${!TCP_PORTS_BY_HOST[@]}"; do
            local tcp_ports="${TCP_PORTS_BY_HOST[$target]}"
            if [ -n "$tcp_ports" ]; then
                local count=$(echo "$tcp_ports" | tr ',' '\n' | wc -l)
                ((total_tcp_ports += count))
            fi
        done
        
        for target in "${!UDP_PORTS_BY_HOST[@]}"; do
            local udp_ports="${UDP_PORTS_BY_HOST[$target]}"
            if [ -n "$udp_ports" ]; then
                local count=$(echo "$udp_ports" | tr ',' '\n' | wc -l)
                ((total_udp_ports += count))
            fi
        done
        
        echo "  Total TCP Ports Found: $total_tcp_ports"
        echo "  Total UDP Ports Found: $total_udp_ports"
        echo "  Errors Encountered: ${#SCAN_ERRORS[@]}"
        echo
        
        if [ ${#ACTIVE_HOSTS[@]} -gt 0 ]; then
            echo "Host Details:"
            for host in "${ACTIVE_HOSTS[@]}"; do
                local tcp_ports="${TCP_PORTS_BY_HOST[$host]}"
                local udp_ports="${UDP_PORTS_BY_HOST[$host]}"
                local tcp_count=$([ -n "$tcp_ports" ] && echo "$tcp_ports" | tr ',' '\n' | wc -l || echo 0)
                local udp_count=$([ -n "$udp_ports" ] && echo "$udp_ports" | tr ',' '\n' | wc -l || echo 0)
                echo "  $host: TCP($tcp_count) UDP($udp_count)"
            done
            echo
        fi
        
        if [ ${#SCAN_ERRORS[@]} -gt 0 ]; then
            echo "Error Log:"
            for error in "${SCAN_ERRORS[@]}"; do
                echo "  - $error"
            done
        fi
    } > "$summary_file"
    
    log_message "SUCCESS" "Summary report generated: ${UNDERLINE}$summary_file${NC}"
}

# Scan failures
handle_scan_failure() {
    local error_msg="$1"
    log_message "ERROR" "$error_msg"
    
    while true; do
        read -p "$(echo -e "${CYAN}Do you want to (r)etry, (c)ontinue, or (q)uit?${NC} ")" -n 1 -r
        echo
        case $REPLY in
            [Rr])
                return 0 
                ;;
            [Cc])
                return 1
                ;;
            [Qq])
                exit 1
                ;;
            *)
                echo -e "${YELLOW}Please enter 'r', 'c', or 'q'${NC}"
                ;;
        esac
    done
}

# Help information
show_help() {
    echo -e "${BOLD}${PURPLE}Advanced Nmap Scanner (Bash Implementation)${NC}"
    echo -e "${PURPLE}Author: Cracknic${NC}"
    echo
    echo -e "${BOLD}USAGE:${NC}"
    echo -e "    $SCRIPT_NAME [OPTIONS] TARGET [TARGET...]"
    echo
    echo -e "${BOLD}TARGETS:${NC}"
    echo -e "    IP addresses or CIDR ranges (e.g., 192.168.1.1 or 192.168.1.0/24)"
    echo
    echo -e "${BOLD}TCP PORT OPTIONS:${NC}"
    echo -e "    -f, --fast [N]      Fast scan - top N ports (default: 500)"
    echo -e "    -F, --full          Full TCP port scan (1-65535)"
    echo
    echo -e "${BOLD}UDP PORT OPTIONS:${NC}"
    echo -e "    -U, --udp [N]       UDP scan - top N ports (default: 500)"
    echo -e "    -FU, --fulludp      Full UDP port scan (1-65535)"
    echo
    echo -e "${BOLD}SCRIPT OPTIONS:${NC}"
    echo -e "    --script CATEGORIES NSE script categories (comma-separated: vuln,safe,exploit,auth)"
    echo
    echo -e "${BOLD}SCAN TYPE OPTIONS:${NC}"
    echo -e "    -sT                 TCP connect scan"
    echo -e "    -sS                 TCP SYN scan (default)"
    echo -e "    -sX                 TCP Xmas scan"
    echo -e "    -sN                 TCP Null scan"
    echo -e "    -sF                 TCP FIN scan"
    echo -e "    -sA                 TCP ACK scan"
    echo -e "    -sW                 TCP Window scan"
    echo
    echo -e "${BOLD}OTHER OPTIONS:${NC}"
    echo -e "    -fw, --firewall     Interactive firewall evasion configuration"
    echo -e "    --threads N         Number of parallel threads (default: 4)"
    echo -e "    --timeout N         Command timeout in seconds (default: 300)"
    echo -e "    --debug             Enable detailed debug logging"
    echo -e "    -h, --help          Show this help message"
    echo
    echo -e "${BOLD}EXAMPLES:${NC}"
    echo -e "    $SCRIPT_NAME -f 1000 --script vuln,safe 192.168.1.1"
    echo -e "    $SCRIPT_NAME -F -U 500 --firewall 192.168.1.0/24"
    echo -e "    $SCRIPT_NAME -sS --threads 8 192.168.1.1 192.168.1.2"
    echo
    echo -e "${BOLD}OUTPUT:${NC}"
    echo -e "    Results are saved in NmapScan_[timestamp]/ directory with organized subdirectories"
    echo -e "    for each target, protocol (TCP/UDP), and output format (oN/oX/oG)."
    echo -e "    Combined HTML reports are generated for each target."
    echo
}

# Parse and validate arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -f|--fast)
                if [[ -n $2 && $2 =~ ^[0-9]+$ ]]; then
                    FAST_PORTS="$2"
                    shift 2
                else
                    FAST_PORTS=500
                    shift
                fi
                ;;
            -F|--full)
                FULL_TCP=true
                shift
                ;;
            -U|--udp)
                if [[ -n $2 && $2 =~ ^[0-9]+$ ]]; then
                    UDP_FAST_PORTS="$2"
                    shift 2
                else
                    UDP_FAST_PORTS=500
                    shift
                fi
                ;;
            -FU|--fulludp)
                FULL_UDP=true
                shift
                ;;
            --script)
                if [[ -n $2 ]]; then
                    IFS=',' read -ra SCRIPTS <<< "$2"
                    # Validate script categories
                    local valid_scripts=("vuln" "safe" "exploit" "auth")
                    for script in "${SCRIPTS[@]}"; do
                        if [[ ! " ${valid_scripts[*]} " =~ " ${script} " ]]; then
                            log_message "ERROR" "Invalid script category: $script"
                            echo "Valid categories: ${valid_scripts[*]}"
                            exit 1
                        fi
                    done
                    shift 2
                else
                    log_message "ERROR" "--script requires an argument"
                    exit 1
                fi
                ;;
            -fw|--firewall)
                setup_firewall_evasion
                shift
                ;;
            -sT|-sS|-sX|-sN|-sF|-sA|-sW)
                SCAN_TYPE="$1"
                shift
                ;;
            --threads)
                if [[ -n $2 && $2 =~ ^[0-9]+$ ]]; then
                    THREADS="$2"
                    shift 2
                else
                    log_message "ERROR" "--threads requires a numeric argument"
                    exit 1
                fi
                ;;
            --timeout)
                if [[ -n $2 && $2 =~ ^[0-9]+$ ]]; then
                    TIMEOUT="$2"
                    shift 2
                else
                    log_message "ERROR" "--timeout requires a numeric argument"
                    exit 1
                fi
                ;;
            --debug)
                DEBUG=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            -*)
                log_message "ERROR" "Unknown option: $1"
                echo "Use -h or --help for usage information"
                exit 1
                ;;
            *)
                # Validate and store target
                if validate_ip_format "$1"; then
                    TARGETS+=("$1")
                else
                    log_message "ERROR" "Invalid IP format: $1"
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Check target
    if [ ${#TARGETS[@]} -eq 0 ]; then
        log_message "ERROR" "No targets specified"
        echo "Use -h or --help for usage information"
        exit 1
    fi
}

# Application entry point
main() {
    show_banner
    show_progress
    # Parse arguments
    parse_arguments "$@"
    
    # Validate dependencies
    validate_dependencies
    
    # Check privileges
    check_privileges
    
    # Directory structure
    create_directory_structure
    
    # Scanning process
    local start_time=$(date +%s)
    
    # Handle interruption
    trap 'echo -e "\n${YELLOW}[INTERRUPTED]${NC} Scan interrupted by user"; exit 1' INT
    
    # Setup targets 
    host_discovery
    # Execute scans
    run_scans
    # Generate report
    generate_summary_report
    
    local end_time=$(date +%s)
    local total_time=$((end_time - start_time))
    
    echo
    log_message "COMPLETED" "All scans finished successfully!"
    log_message "INFO" "Total execution time: ${BOLD}${total_time}${NC} seconds"
    log_message "INFO" "Results saved in: ${UNDERLINE}$BASE_DIR${NC}"
}

main "$@"
