# User Manual - NmapFlow Network Scanner (Bash)

**Author:** Cracknic  
**Version:** 1.0  
**Date:** October 2025  
**Language:** Bash 4.0+

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Key Features](#2-key-features)
3. [System Requirements](#3-system-requirements)
4. [Installation](#4-installation)
5. [Basic Usage](#5-basic-usage)
6. [Arguments and Options](#6-arguments-and-options)
7. [Scan Types](#7-scan-types)
8. [NSE Scripts](#8-nse-scripts)
9. [Firewall Evasion](#9-firewall-evasion)
10. [Output Structure](#10-output-structure)
11. [Advanced Examples](#11-advanced-examples)
12. [Troubleshooting](#12-troubleshooting)
13. [Best Practices](#13-best-practices)
14. [Frequently Asked Questions](#14-frequently-asked-questions)

---

## 1. Introduction

The **NmapFlow Network Scanner** Bash version is a network scanning tool developed entirely in shell script that automates and simplifies the security auditing process using Nmap. This implementation is designed for environments where native compatibility with Unix/Linux systems is preferred without additional Python dependencies.

### Design Philosophy

The Bash version maintains the same principles as the Python version, but with focus on:

- **Universal Compatibility**: Works on any system with Bash 4.0+
- **Minimal Dependencies**: Only requires standard Unix/Linux tools
- **Native Performance**: Leverages native shell capabilities
- **Easy Modification**: Easy-to-read and customizable code

### Advantages of Bash Implementation

- **Simplified Installation**: No additional interpreters required
- **Reduced Memory Consumption**: Lower overhead than interpreted implementations
- **Natural Integration**: Integrates seamlessly with system scripts
- **Simple Debugging**: Easy to debug and modify
- **Portability**: Works on embedded systems and minimal containers

---

## 2. Key Features

### 2.1 Advanced Visual System

- **Enhanced color scheme**: 8 different colors for message types
- **Dynamic progress bars**: Visual progress tracking with color coding
- **Custom banner**: Clear identification with ASCII style
- **Status indicators**: Visual symbols for different operation states

### 2.2 Intelligent Process Management

- **Controlled thread pool**: Efficient parallel process management
- **Resource monitoring**: Automatic system load control
- **Error recovery**: Robust failure handling with recovery options
- **Complete logging**: Logging system with automatic rotation

### 2.3 Structured Organization

- **Directory hierarchy**: Automatic organization by target and protocol
- **XML consolidation**: Intelligent XML file combination
- **HTML reports**: Automatic web report generation
- **Statistical summaries**: Automatic result analysis

### 2.4 Flexible Configuration

- **Standard arguments**: Unix-compatible tool syntax
- **Interactive configuration**: Interactive menus for complex options
- **Input validation**: Comprehensive parameter verification
- **Bash autocompletion**: Command autocompletion support

---

## 3. System Requirements

### 3.1 Minimum Requirements

| Component | Minimum Version | Recommended |
|-----------|----------------|-------------|
| **Operating System** | Linux/Unix (any distribution) | Ubuntu 20.04+ / CentOS 8+ |
| **Bash** | 4.0+ | 5.0+ |
| **RAM** | 256 MB | 1 GB+ |
| **Disk Space** | 50 MB | 500 MB+ |
| **Nmap** | 7.0+ | 7.80+ |

### 3.2 System Dependencies

#### Required Tools
```bash
# Check existing dependencies
which bash nmap xsltproc xmllint

# Debian/Ubuntu-based distributions
sudo apt update
sudo apt install bash coreutils util-linux procps findutils grep sed gawk nmap xsltproc libxml2-utils curl wget git tree
# Supports: Ubuntu, Debian, Linux Mint, Elementary OS, Pop!_OS, Zorin OS, Kali Linux, Parrot OS, MX Linux, antiX, Deepin, UOS, Peppermint, LXLE

# Red Hat-based distributions
sudo dnf update -y  # or yum for older versions
sudo dnf install bash coreutils util-linux procps-ng findutils grep sed gawk nmap libxslt libxml2 curl wget git tree
# Supports: CentOS, RHEL, Rocky Linux, AlmaLinux, Oracle Linux, Fedora, Amazon Linux

# Arch-based distributions
sudo pacman -Syu --noconfirm
sudo pacman -S bash coreutils util-linux procps-ng findutils grep sed gawk nmap libxslt libxml2 curl wget git tree
# Supports: Arch Linux, Manjaro, EndeavourOS, Garuda Linux, ArcoLinux, BlackArch

# openSUSE/SUSE
sudo zypper refresh
sudo zypper install bash coreutils util-linux procps findutils grep sed gawk nmap libxslt-tools libxml2-tools curl wget git tree

# Alpine Linux
sudo apk update
sudo apk add bash coreutils util-linux procps findutils grep sed gawk nmap libxslt libxml2-utils curl wget git tree

# Gentoo Linux
sudo emerge --sync
sudo emerge -av app-shells/bash sys-apps/coreutils sys-apps/util-linux sys-process/procps sys-apps/findutils sys-apps/grep sys-apps/sed sys-apps/gawk net-analyzer/nmap dev-libs/libxslt dev-libs/libxml2 net-misc/curl net-misc/wget dev-vcs/git app-text/tree

# Void Linux
sudo xbps-install -Syu
sudo xbps-install -y bash coreutils util-linux procps-ng findutils grep sed gawk nmap libxslt libxml2 curl wget git tree

# Solus
sudo eopkg update-repo
sudo eopkg install -y bash coreutils util-linux procps-ng findutils grep sed gawk nmap libxslt-devel libxml2-devel curl wget git tree

# Clear Linux
sudo swupd update
sudo swupd bundle-add shells-basic sysadmin-basic network-basic curl git

# Mageia
sudo urpmi --auto-update
sudo urpmi bash coreutils util-linux procps-ng findutils grep sed gawk nmap libxslt libxml2 curl wget git tree

# PCLinuxOS
sudo apt update
sudo apt install bash coreutils util-linux procps findutils grep sed gawk nmap libxslt-tools libxml2-utils curl wget git tree
```

#### Optional Tools
```bash
# For advanced features (already included in above installations)
# - tree: directory structure visualization
# - curl/wget: file downloading
# - git: version control
```

### 3.3 Compatibility Verification

#### Check Bash Version
```bash
# Check installed version
bash --version

# Check required features
bash -c 'echo ${BASH_VERSION}'

# Check associative array support (Bash 4.0+)
bash -c 'declare -A test_array; echo "Compatible"'
```

#### Verify System Tools
```bash
# Quick verification script
for tool in bash nmap xsltproc xmllint; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "✓ $tool: $(command -v "$tool")"
    else
        echo "✗ $tool: Not found"
    fi
done
```

---

## 4. Installation

### 4.1 Automatic Installation

The recommended method is using the included installation script:

```bash
# Navigate to Bash version directory
cd nmap-automation/bash

# Run installer (requires administrator privileges)
sudo ./install.sh
```

#### Installer Functions

The installation script performs the following operations:

1. **Operating system detection** and version
2. **Bash version verification** (4.0+ required)
3. **Automatic system dependencies installation**
4. **Script copy** to `/usr/local/bin/nmap_scanner.sh`
5. **Symbolic link creation** `nmap-scanner-bash`
6. **Man page generation** in `/usr/local/man/man1/`
7. **Bash autocompletion configuration** in `/etc/bash_completion.d/`
8. **Desktop entry creation** (optional)
9. **Complete installation verification**

### 4.2 Manual Installation

For custom installations or specific systems:

```bash
# 1. Verify and install dependencies
sudo apt install bash nmap xsltproc libxml2-utils  # Ubuntu/Debian

# 2. Make script executable
chmod +x nmap_scanner.sh

# 3. Copy to system directory (optional)
sudo cp nmap_scanner.sh /usr/local/bin/

# 4. Create symbolic link (optional)
sudo ln -s /usr/local/bin/nmap_scanner.sh /usr/local/bin/nmap-scanner-bash

# 5. Verify installation
nmap-scanner-bash --help
```

### 4.3 Container Installation

For containerized environments or minimal systems:

```bash
# Example Dockerfile
FROM ubuntu:20.04
RUN apt-get update && apt-get install -y bash nmap xsltproc libxml2-utils
COPY nmap_scanner.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/nmap_scanner.sh
ENTRYPOINT ["/usr/local/bin/nmap_scanner.sh"]
```

### 4.4 Uninstallation

To completely remove the tool:

```bash
# Use included uninstaller
sudo ./install.sh --uninstall

# Or uninstall manually
sudo rm -f /usr/local/bin/nmap_scanner.sh
sudo rm -f /usr/local/bin/nmap-scanner-bash
sudo rm -f /usr/local/man/man1/nmap-scanner-bash.1.gz
sudo rm -f /usr/share/applications/nmap-scanner-bash.desktop
sudo rm -f /etc/bash_completion.d/nmap-scanner-bash
```

---

## 5. Basic Usage

### 5.1 General Syntax

```bash
nmap-scanner-bash [OPTIONS] <TARGET1> [TARGET2] ...
```

### 5.2 Getting Started

#### Installation Verification
```bash
# Show complete help
nmap-scanner-bash --help

# Check version and dependencies
nmap-scanner-bash --version  # (if implemented)

# Show man page
man nmap-scanner-bash
```

#### Basic Scan
```bash
# Quick scan of top 500 most common ports
nmap-scanner-bash 192.168.1.1

# Scan of top 1000 most common ports
nmap-scanner-bash -f 1000 192.168.1.1

# Scan without root privileges
nmap-scanner-bash -sT 192.168.1.1
```

#### Network Scan
```bash
# Scan complete subnet
nmap-scanner-bash 192.168.1.0/24

# Scan multiple specific hosts
nmap-scanner-bash 192.168.1.1 192.168.1.2 192.168.1.3

# Scan IP range
nmap-scanner-bash 192.168.1.1-50
```

### 5.3 Progress Monitoring

The tool provides detailed visual feedback:

```bash
# Example output during execution
╔══════════════════════════════════════════════════════════╗
║                 NmapFlow Network Scanner                 ║
║                     Author: Cracknic                     ║
╚══════════════════════════════════════════════════════════╝

[INFO] Validating system dependencies...
[SUCCESS] All dependencies validated
[SUCCESS] Directory structure created: NmapScan_20251002_143000
[INFO] Setting up targets for scanning...
[SUCCESS] Targets configured: 1

Scan Progress: [████████████████████████████████████████████████] 100.0% (4/4) [2.3s] ✓

[COMPLETED] All scans finished successfully!
[INFO] Total execution time: 2 seconds
[INFO] Results saved in: NmapScan_20251002_143000
```

---

## 6. Arguments and Options

### 6.1 Target Specification

Targets can be specified in multiple formats:

| Format | Example | Description | Validation |
|--------|---------|-------------|------------|
| **Individual IP** | `192.168.1.1` | Single host | Octets 0-255 |
| **CIDR Range** | `192.168.1.0/24` | Complete subnet | CIDR 1-32 |
| **Multiple IPs** | `192.168.1.1 192.168.1.2` | Host list | Space-separated |
| **Consecutive Range** | `192.168.1.1-10` | IP range | start-end format |

### 6.2 TCP Port Options

#### Fast Scan (`-f`, `--fast`)
```bash
# Use default value (500 ports)
nmap-scanner-bash -f 192.168.1.1
nmap-scanner-bash --fast 192.168.1.1

# Specify number of ports
nmap-scanner-bash -f 1000 192.168.1.1
nmap-scanner-bash --fast 2000 192.168.1.1
```

**Characteristics:**
- Uses Nmap's `--top-ports` option
- Scans most common ports according to Nmap statistics
- Optimized execution time
- Ideal for initial reconnaissance

#### Full Scan (`-F`, `--full`)
```bash
# Scan all TCP ports (1-65535)
nmap-scanner-bash -F 192.168.1.1
nmap-scanner-bash --full 192.168.1.1
```

**Characteristics:**
- Scans all 65535 TCP ports
- Considerably longer execution time
- Complete service coverage
- Recommended for comprehensive audits

### 6.3 UDP Port Options

#### Fast UDP Scan (`-U`, `--udp`)
```bash
# Use default value (500 UDP ports)
nmap-scanner-bash -U 192.168.1.1
nmap-scanner-bash --udp 192.168.1.1

# Specify number of UDP ports
nmap-scanner-bash -U 200 192.168.1.1
nmap-scanner-bash --udp 1000 192.168.1.1
```

#### Full UDP Scan (`-FU`, `--fulludp`)
```bash
# Scan all UDP ports (1-65535)
nmap-scanner-bash -FU 192.168.1.1
nmap-scanner-bash --fulludp 192.168.1.1
```

**⚠️ WARNING:** Full UDP scans can take hours or days

### 6.4 NSE Scripts (`--script`)

```bash
# Individual category
nmap-scanner-bash --script vuln 192.168.1.1
nmap-scanner-bash --script safe 192.168.1.1

# Multiple categories
nmap-scanner-bash --script vuln,safe 192.168.1.1
nmap-scanner-bash --script vuln,safe,exploit 192.168.1.1

# All categories (use with caution)
nmap-scanner-bash --script vuln,safe,exploit,auth 192.168.1.1
```

### 6.5 Performance Options

#### Thread Configuration (`--threads`)
```bash
# Conservative configuration
nmap-scanner-bash --threads 2 192.168.1.0/24

# Balanced configuration (default)
nmap-scanner-bash --threads 4 192.168.1.0/24

# Aggressive configuration
nmap-scanner-bash --threads 8 192.168.1.0/24

# Maximum configuration (use carefully)
nmap-scanner-bash --threads 16 192.168.1.0/24
```

#### Command Timeout (`--timeout`)
```bash
# Short timeout for quick scans
nmap-scanner-bash --timeout 120 192.168.1.1

# Standard timeout (default: 300 seconds)
nmap-scanner-bash --timeout 300 192.168.1.1

# Extended timeout for slow networks
nmap-scanner-bash --timeout 600 192.168.1.1

# Very long timeout for comprehensive scans
nmap-scanner-bash --timeout 1800 192.168.1.1
```

### 6.6 Firewall Evasion (`-fw`, `--firewall`)

```bash
# Activate interactive evasion mode
nmap-scanner-bash --firewall 192.168.1.1
nmap-scanner-bash -fw 192.168.1.1
```

Interactive mode presents a menu with 15 different evasion techniques.

---

## 7. Scan Types

### 7.1 Available TCP Scan Types

#### TCP SYN Scan (`-sS`) - Default
```bash
nmap-scanner-bash -sS 192.168.1.1
# Or simply (it's the default):
nmap-scanner-bash 192.168.1.1
```

**Technical characteristics:**
- Sends SYN packets and analyzes SYN-ACK responses
- Doesn't complete TCP handshake (half-open scan)
- Requires root privileges to create raw sockets
- Faster than TCP Connect scan
- Less detectable in application logs

**Advantages:**
- High speed
- Relative stealth
- Lower load on target services

**Disadvantages:**
- Requires administrative privileges
- Can be detected by IDS/IPS

#### TCP Connect Scan (`-sT`)
```bash
nmap-scanner-bash -sT 192.168.1.1
```

**Technical characteristics:**
- Uses the connect() system call
- Completes full TCP handshake
- Doesn't require special privileges
- Generates logs on target services
- Compatible with all operating systems

**Advantages:**
- Doesn't require root privileges
- Works through proxies and NAT
- More reliable on complex networks

**Disadvantages:**
- Slower than SYN scan
- More detectable
- Higher load on target services

#### TCP Xmas Scan (`-sX`)
```bash
nmap-scanner-bash -sX 192.168.1.1
```

**Technical characteristics:**
- Sends packets with FIN, PSH, and URG flags set
- Based on RFC 793 for closed port detection
- Works better on Unix/Linux systems
- Doesn't work against Windows systems

**Recommended use:**
- Stateless firewall evasion
- Unix/Linux target systems
- When maximum stealth is required

#### TCP Null Scan (`-sN`)
```bash
nmap-scanner-bash -sN 192.168.1.1
```

**Technical characteristics:**
- Sends TCP packets with no flags set
- Extremely stealthy
- Based on RFC 793 behavior
- Inconsistent results on Windows

**Recommended use:**
- Maximum stealth required
- Basic IDS evasion
- Passive reconnaissance

#### TCP FIN Scan (`-sF`)
```bash
nmap-scanner-bash -sF 192.168.1.1
```

**Technical characteristics:**
- Sends packets with only FIN flag set
- Stealthy approach
- Works on Unix/Linux systems
- Can evade some firewalls

**Recommended use:**
- Firewall evasion
- Stealthy reconnaissance
- When SYN scan is blocked

#### TCP ACK Scan (`-sA`)
```bash
nmap-scanner-bash -sA 192.168.1.1
```

**Technical characteristics:**
- Sends packets with ACK flag set
- Doesn't determine if ports are open
- Useful for firewall rule mapping
- Works on all systems

**Recommended use:**
- Firewall configuration analysis
- Network topology mapping
- IDS/IPS testing

#### TCP Window Scan (`-sW`)
```bash
nmap-scanner-bash -sW 192.168.1.1
```

**Technical characteristics:**
- Similar to ACK scan but analyzes window field
- Can distinguish open ports on some systems
- System-specific behavior
- Advanced technique

**Recommended use:**
- Detailed system analysis
- Specific Unix system fingerprinting
- Advanced reconnaissance

### 7.2 Scan Type Comparison

| Type | Privileges | Speed | Stealth | Compatibility | Recommended Use |
|------|-----------|-------|---------|---------------|-----------------|
| **-sS** | Root | High | High | Universal | General scans |
| **-sT** | User | Medium | Low | Universal | No privileges |
| **-sX** | Root | Medium | High | Unix/Linux | Evasion |
| **-sN** | Root | Medium | Very High | Unix/Linux | Reconnaissance |
| **-sF** | Root | Medium | High | Unix/Linux | Evasion |
| **-sA** | Root | High | High | Universal | Firewall analysis |
| **-sW** | Root | Medium | High | Specific | Detailed analysis |

---

## 8. NSE Scripts

### 8.1 Available Script Categories

#### Vulnerabilities (`vuln`)
```bash
nmap-scanner-bash --script vuln 192.168.1.1
```

**Included scripts:**
- Known vulnerability detection (CVE)
- Insecure configuration analysis
- Security patch verification
- Known backdoor detection

**Examples of detected vulnerabilities:**
- MS17-010 (EternalBlue)
- Heartbleed (OpenSSL)
- Shellshock (Bash)
- SMB vulnerabilities

#### Safe Scripts (`safe`)
```bash
nmap-scanner-bash --script safe 192.168.1.1
```

**Included scripts:**
- Service version detection
- Basic information enumeration
- Non-intrusive configuration analysis
- Common service detection

**Characteristics:**
- Don't cause service interruptions
- Minimal performance impact
- Safe for production environments

#### Exploitation Scripts (`exploit`)
```bash
nmap-scanner-bash --script exploit 192.168.1.1
```

**⚠️ WARNING:** These scripts may cause service interruptions

**Included scripts:**
- Known vulnerability exploitation
- Brute force attacks
- Authentication bypasses
- Privilege escalation exploits

**Recommended use:**
- Only in test environments
- With explicit authorization
- During penetration testing

#### Authentication Scripts (`auth`)
```bash
nmap-scanner-bash --script auth 192.168.1.1
```

**Included scripts:**
- Brute force attacks against services
- Default credential detection
- Authentication mechanism analysis
- User enumeration

### 8.2 Script Combinations

#### Conservative Scan
```bash
nmap-scanner-bash --script safe 192.168.1.1
```

#### Audit Scan
```bash
nmap-scanner-bash --script vuln,safe 192.168.1.1
```

#### Aggressive Scan (Test Environments Only)
```bash
nmap-scanner-bash --script vuln,safe,exploit,auth 192.168.1.1
```

### 8.3 Protocol-Specific Scripts

#### TCP Scripts
Most NSE scripts are designed for TCP services:
- HTTP/HTTPS (ports 80, 443, 8080, etc.)
- SSH (port 22)
- FTP (port 21)
- SMB (ports 139, 445)
- SMTP (port 25)

#### UDP Scripts
Specific scripts for UDP services:
- DNS (port 53)
- SNMP (port 161)
- DHCP (port 67)
- NTP (port 123)

---

## 9. Firewall Evasion

### 9.1 Interactive Mode

When using the `--firewall` option, the tool presents an interactive menu with 15 different evasion techniques:

```bash
nmap-scanner-bash --firewall 192.168.1.1
```

### 9.2 Available Evasion Techniques

#### 1. Packet Fragmentation
- **Option 1**: `-f` - Basic fragmentation
- **Option 2**: `-ff` - Fragmentation in 8-byte fragments

**Use:** Evade firewalls that don't properly reassemble fragments

#### 2. Decoys
- **Option 3**: `-D RND:10` - Use 10 random IPs as decoys

**Use:** Hide the real attacker IP among multiple fake IPs

#### 3. Source IP Spoofing
- **Option 4**: `-S <IP>` - Specify fake source IP

**Use:** Make traffic appear to come from another source

#### 4. Source Port Spoofing
- **Option 5**: `-g <port>` - Specify source port

**Use:** Use ports that are typically allowed (53, 80, 443)

#### 5. Data Manipulation
- **Option 6**: `--data-length <bytes>` - Add random data

**Use:** Change packet size to evade detection

#### 6. IP Options
- **Option 7**: `--ip-options <options>` - Custom IP options

**Use:** Manipulate IP headers for advanced evasion

#### 7. TTL Manipulation
- **Option 8**: `--ttl <value>` - Set Time To Live

**Use:** Evade systems that filter by TTL

#### 8. Incorrect Checksums
- **Option 9**: `--badsum` - Use incorrect checksums
- **Option 10**: `--adler32` - Use Adler32 checksums

**Use:** Evade systems that don't validate checksums

#### 9. MTU Manipulation
- **Option 11**: `--mtu <value>` - Set custom MTU

**Use:** Control packet fragmentation

#### 10. MAC Spoofing
- **Option 12**: `--spoof-mac <MAC>` - Fake MAC address

**Use:** Evade MAC-based filters (local network only)

#### 11. Timing Control
- **Option 13**: `--scan-delay <time>` - Delay between probes
- **Option 14**: `--max-rate <pps>` - Maximum speed
- **Option 15**: `--min-rate <pps>` - Minimum speed

**Use:** Evade intrusion detection systems based on speed

### 9.3 Evasion Strategies by Scenario

#### Basic Firewall (Stateless)
```bash
# Use fragmentation and common source port
Recommended options: 1, 5 (port 53 or 80)
```

#### Advanced Firewall (Stateful)
```bash
# Combine multiple techniques
Recommended options: 2, 3, 13 (slow timing)
```

#### Intrusion Detection System (IDS)
```bash
# Stealthy approach with controlled timing
Recommended options: 1, 13, 15 (very low speed)
```

#### Corporate Network
```bash
# Simulate legitimate traffic
Recommended options: 5 (port 443), 8 (normal TTL), 13 (natural timing)
```

---

## 10. Output Structure

### 10.1 Directory Hierarchy

```
NmapScan_20251002_143000/
├── 192.168.1.1/                    # Directory per target
│   ├── TCP/                        # TCP results
│   │   ├── oN/                     # Normal format
│   │   │   ├── nmap_ports_192.168.1.1_oN.nmap
│   │   │   └── nmap_service_192.168.1.1_oN.nmap
│   │   ├── oX/                     # XML format
│   │   │   ├── nmap_ports_192.168.1.1_oX.xml
│   │   │   └── nmap_service_192.168.1.1_oX.xml
│   │   └── oG/                     # Grepeable format
│   │       ├── nmap_ports_192.168.1.1_oG.gnmap
│   │       └── nmap_service_192.168.1.1_oG.gnmap
│   ├── UDP/                        # UDP results
│   │   ├── oN/
│   │   ├── oX/
│   │   └── oG/
│   ├── combined_scan_192.168.1.1.xml      # Consolidated XML
│   └── combined_report_192.168.1.1.html   # HTML report
├── 192.168.1.2/                    # Second target
│   └── ...
├── nmap_scan_20251002_143000.log   # Execution log
└── scan_summary.txt                # Executive summary
```

### 10.2 Output File Types

#### Normal Format (.nmap)
```
# Example content
Starting Nmap 7.80 ( https://nmap.org ) at 2025-10-02 14:30 UTC
Nmap scan report for 192.168.1.1
Host is up (0.0010s latency).

PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.5
80/tcp   open  http    Apache httpd 2.4.41
443/tcp  open  https   Apache httpd 2.4.41 ((Ubuntu))
```

**Characteristics:**
- Human-readable format
- Ideal for manual analysis
- Contains detailed service information

#### XML Format (.xml)
```xml
<?xml version="1.0" encoding="UTF-8"?>
<nmaprun scanner="nmap" args="nmap -sV -sC -p 22,80,443">
  <host>
    <address addr="192.168.1.1" addrtype="ipv4"/>
    <ports>
      <port protocol="tcp" portid="22">
        <state state="open" reason="syn-ack"/>
        <service name="ssh" product="OpenSSH" version="8.2p1"/>
      </port>
    </ports>
  </host>
</nmaprun>
```

**Characteristics:**
- Structured format for automatic processing
- Ideal for integration with other tools
- Contains complete scan metadata

#### Grepeable Format (.gnmap)
```
# Example content
Host: 192.168.1.1 ()    Status: Up
Host: 192.168.1.1 ()    Ports: 22/open/tcp//ssh//OpenSSH 8.2p1/, 80/open/tcp//http//Apache httpd 2.4.41/, 443/open/tcp//https//Apache httpd 2.4.41/
```

**Characteristics:**
- Format optimized for grep searches
- One line per host
- Ideal for post-processing scripts

### 10.3 Consolidated HTML Report

The `combined_report_[IP].html` file contains:

- **Executive summary** with general statistics
- **Open port list** with identified services
- **NSE script results** organized by category
- **Charts and visualizations** (when available)
- **Links to original output files**

### 10.4 Executive Summary

The `scan_summary.txt` file includes:

```
NmapFlow Network Scanner - Summary Report
Author: Cracknic
Generated: 2025-10-02 14:35:22
==========================================================

Scan Configuration:
  Targets: 192.168.1.1, 192.168.1.2
  Scan Type: -sS
  TCP Ports: Top 1000
  UDP Ports: Top 500
  Scripts: vuln,safe
  Firewall Evasion: -f --scan-delay 100ms
  Threads: 4

Results Summary:
  Active Hosts: 2
  Total TCP Ports Found: 8
  Total UDP Ports Found: 2
  Errors Encountered: 0

Host Details:
  192.168.1.1: TCP(5) UDP(1)
  192.168.1.2: TCP(3) UDP(1)
```

---

## 11. Advanced Examples

### 11.1 Complete Corporate Network Audit

```bash
# Comprehensive corporate subnet scan
nmap-scanner-bash -F -U 1000 --script vuln,safe --threads 16 --timeout 900 192.168.0.0/16
```

**Explanation:**
- `-F`: Full TCP scan (65535 ports)
- `-U 1000`: Top 1000 UDP ports
- `--script vuln,safe`: Vulnerability and safe scripts
- `--threads 16`: 16 parallel threads for speed
- `--timeout 900`: 15-minute timeout per command
- `192.168.0.0/16`: Complete corporate network (65536 hosts)

### 11.2 Stealthy Analysis of Specific Target

```bash
# Stealthy scan with firewall evasion
nmap-scanner-bash -f 2000 -sX --firewall --threads 2 --timeout 600 target.company.com
```

**Interactive evasion configuration:**
```
Select options: 1,5,13
- Packet fragmentation
- Source port 443 (HTTPS)
- 2-second delay between probes
```

### 11.3 Quick Attack Surface Assessment

```bash
# Quick scan focused on web services
nmap-scanner-bash -f 100 --script safe -sT --threads 8 web1.company.com web2.company.com web3.company.com
```

### 11.4 Network Segmentation Analysis

```bash
# Scan multiple segments to verify isolation
nmap-scanner-bash -f 500 -sT --threads 4 192.168.1.0/24 192.168.10.0/24 192.168.100.0/24
```

### 11.5 Critical Vulnerability Detection

```bash
# Specific focus on known vulnerabilities
nmap-scanner-bash -f 1000 --script vuln --threads 6 --timeout 1200 192.168.1.0/24
```

### 11.6 Critical UDP Services Scan

```bash
# Specific analysis of common UDP services
nmap-scanner-bash -U 200 --script safe,auth -sT 192.168.1.0/24
```

### 11.7 Compliance Audit

```bash
# Complete scan for compliance audit
nmap-scanner-bash -F -FU --script vuln,safe,auth --threads 8 --timeout 1800 192.168.0.0/24
```

---

## 12. Troubleshooting

### 12.1 Common Problems and Solutions

#### Error: "Missing dependencies"
```bash
# Problem: Dependencies not installed
[ERROR] Missing dependencies: nmap, xsltproc

# Solution:
sudo apt install nmap xsltproc libxml2-utils  # Ubuntu/Debian
sudo dnf install nmap libxslt libxml2         # Fedora/CentOS 8+
```

#### Error: "Bash version 4.0 or higher required"
```bash
# Problem: Old Bash version
[ERROR] Bash version 4.0 or higher required (found: 3.2)

# Solution: Update Bash
sudo apt update && sudo apt install bash  # Ubuntu/Debian
sudo dnf update bash                       # Fedora/CentOS
```

#### Error: "Permission denied"
```bash
# Problem: Insufficient permissions for scan types
[WARNING] Some scan types require root privileges

# Solutions:
# Option 1: Run with sudo
sudo nmap-scanner-bash -sS 192.168.1.1

# Option 2: Use TCP Connect scan
nmap-scanner-bash -sT 192.168.1.1
```

#### Error: "Invalid IP format"
```bash
# Problem: Incorrect IP format
[ERROR] Invalid IP format: 192.168.1.256

# Solution: Verify IP format
nmap-scanner-bash 192.168.1.1      # Valid IP
nmap-scanner-bash 192.168.1.0/24   # Valid CIDR
```

### 12.2 Performance Issues

#### Very Slow Scans
```bash
# Problem: Scans taking too long

# Solutions:
# 1. Reduce number of ports
nmap-scanner-bash -f 100 192.168.1.1  # Instead of -f 1000

# 2. Increase threads (carefully)
nmap-scanner-bash --threads 8 192.168.1.1

# 3. Reduce timeout
nmap-scanner-bash --timeout 120 192.168.1.1

# 4. Avoid full UDP scans
nmap-scanner-bash -U 100 192.168.1.1  # Instead of -FU
```

#### High System Load
```bash
# Problem: High CPU/memory usage

# Solutions:
# 1. Reduce number of threads
nmap-scanner-bash --threads 2 192.168.1.0/24

# 2. Scan in smaller batches
nmap-scanner-bash 192.168.1.1-50
nmap-scanner-bash 192.168.1.51-100
```

### 12.3 Script-Specific Issues

#### Bash Compatibility Issues
```bash
# Problem: Script doesn't work on older systems

# Diagnosis:
bash --version  # Check Bash version

# Solution: Use compatible syntax or update Bash
```

#### Process Management Issues
```bash
# Problem: Zombie processes or hung scans

# Diagnosis:
ps aux | grep nmap  # Check running processes

# Solution: Kill hung processes
pkill -f nmap
```

### 12.4 Output File Issues

#### XML Processing Errors
```bash
# Problem: XML files cannot be processed

# Diagnosis:
xmllint --noout combined_scan_192.168.1.1.xml

# Solution: Check XML syntax and re-run scan
```

#### HTML Generation Failures
```bash
# Problem: HTML reports not generated

# Diagnosis:
which xsltproc
ls -la /usr/share/nmap/nmap.xsl

# Solution: Install xsltproc and verify XSL file
sudo apt install xsltproc
```

### 12.5 Advanced Debugging

#### Enable Debug Mode
```bash
# Add debug flag to script execution
bash -x nmap_scanner.sh 192.168.1.1
```

#### Check Log Files
```bash
# Review detailed logs
tail -f nmap_scan_*.log

# Check system logs
journalctl -f | grep nmap
```

#### Manual Command Testing
```bash
# Extract and test individual commands
nmap --top-ports 500 -sS -n -Pn --min-rate 2000 -vvv 192.168.1.1
```

---

## 13. Best Practices

### 13.1 Scan Planning

#### Before Scanning
1. **Obtain written authorization** for all scans
2. **Identify maintenance windows** for intensive scans
3. **Notify operations team** about scanning activities
4. **Prepare documentation** of objectives and scope
5. **Set up monitoring** for scan progress

#### Target Selection Strategy
```bash
# Start with limited scans
nmap-scanner-bash -f 100 -sT 192.168.1.1

# Gradually expand scope
nmap-scanner-bash -f 500 -sT 192.168.1.1-10
nmap-scanner-bash -f 1000 -sT 192.168.1.0/24
```

### 13.2 Optimal Configuration by Scenario

#### Internal Security Audit
```bash
# Balanced configuration for internal networks
nmap-scanner-bash -f 1000 -U 200 --script vuln,safe --threads 6 --timeout 600 192.168.0.0/16
```

#### External Assessment (Internet)
```bash
# Conservative configuration for external targets
nmap-scanner-bash -f 500 -sT --script safe --threads 2 --timeout 300 target.com
```

#### Red Team Exercise
```bash
# Stealthy configuration for red team exercises
nmap-scanner-bash -f 200 -sX --firewall --threads 1 --timeout 900 target.internal
```

#### Compliance Scanning
```bash
# Comprehensive configuration for compliance
nmap-scanner-bash -F -U 1000 --script vuln,safe,auth --threads 4 --timeout 1200 192.168.0.0/24
```

### 13.3 Results Management

#### File Organization
```bash
# Create project structure
mkdir -p audit_2025/
cd audit_2025/

# Run scans with descriptive names
nmap-scanner-bash -f 1000 --script vuln 192.168.1.0/24  # Generates NmapScan_[timestamp]
mv NmapScan_* internal_network_scan/

nmap-scanner-bash -f 500 -sT external.company.com
mv NmapScan_* external_scan/
```

#### Backup and Archiving
```bash
# Compress results for archiving
tar -czf audit_results_$(date +%Y%m%d).tar.gz NmapScan_*/

# Create checksums for integrity
sha256sum audit_results_*.tar.gz > checksums.txt
```

### 13.4 Performance Optimization

#### System Resource Management
```bash
# Monitor system resources during scans
htop  # or top

# Adjust thread count based on system capacity
nmap-scanner-bash --threads $(nproc) 192.168.1.0/24  # Use all CPU cores
nmap-scanner-bash --threads $(($(nproc)/2)) 192.168.1.0/24  # Use half cores
```

#### Network Bandwidth Considerations
```bash
# Limit scan rate for bandwidth-constrained environments
nmap-scanner-bash --firewall 192.168.1.0/24
# Select option 15 (min-rate) with low value
```

### 13.5 Security Considerations

#### Data Protection
- **Encrypt result files** with sensitive information
- **Limit access** to scan files using proper permissions
- **Delete temporary data** after analysis
- **Use secure channels** for result transfer

#### Impact Minimization
```bash
# Low impact configuration
nmap-scanner-bash -f 100 -sT --threads 1 --timeout 120 --script safe 192.168.1.1
```

#### Detection Avoidance
```bash
# Techniques to reduce detection
nmap-scanner-bash --firewall -f 200 --threads 1 --timeout 600 192.168.1.1

# Stealthy timing configuration in interactive mode:
# Select: fragmentation (1), slow timing (13)
```

---

## 14. Frequently Asked Questions

### 14.1 General Questions

**Q: What are the advantages of the Bash version over Python?**
A: The Bash version has lower memory usage, no additional dependencies, better integration with system scripts, and works on minimal systems where Python might not be available.

**Q: Can I run this on macOS?**
A: Yes, but you'll need to install GNU Bash 4.0+ and the required tools (nmap, xsltproc) using Homebrew or MacPorts.

**Q: Does this work on embedded systems?**
A: Yes, as long as the system has Bash 4.0+ and the required tools. It's particularly well-suited for embedded Linux systems.

**Q: How does performance compare to the Python version?**
A: The Bash version typically uses less memory but may be slightly slower for complex operations due to shell overhead.

### 14.2 Technical Questions

**Q: Why do I get "Bash version 4.0 or higher required"?**
A: The script uses associative arrays and other features introduced in Bash 4.0. Update your Bash installation or use a system with a newer version.

**Q: Can I modify the script for custom needs?**
A: Yes, the script is designed to be easily readable and modifiable. All functions are well-documented and modular.

**Q: How do I add custom NSE scripts?**
A: Modify the script categories in the `parse_arguments()` function and update the script execution logic in the scanning functions.

**Q: Can I integrate this with other Bash scripts?**
A: Yes, you can source the script and use its functions, or call it from other scripts and parse its output.

### 14.3 Troubleshooting Questions

**Q: The script hangs during execution**
A: Check for zombie processes with `ps aux | grep nmap` and kill them with `pkill -f nmap`. Also verify network connectivity and reduce timeout values.

**Q: XML files are corrupted or empty**
A: This usually indicates nmap command failures. Check the log file for error messages and verify target accessibility.

**Q: Autocompletion doesn't work**
A: Restart your terminal after installation, or manually source the completion file: `source /etc/bash_completion.d/nmap-scanner-bash`

### 14.4 Integration Questions

**Q: Can I use this in CI/CD pipelines?**
A: Yes, the script returns appropriate exit codes and can be easily integrated into automated workflows.

**Q: How do I parse the results programmatically?**
A: Use the `.gnmap` files for easy parsing, or process the XML files with tools like `xmllint` or `xmlstarlet`.

**Q: Can I run multiple instances simultaneously?**
A: Yes, each instance creates its own timestamped directory, so multiple runs won't interfere with each other.

### 14.5 Development Questions

**Q: How do I contribute to the project?**
A: The tool was developed by Cracknic. Contact the author directly for contributions or modifications.

**Q: Is there a plugin system?**
A: Currently no, but the modular design makes it easy to add custom functions and extend functionality.

**Q: Can I create a GUI for this?**
A: Yes, you can create a GUI wrapper that calls the script and parses its output. The structured output makes this straightforward.

---

## Contact Information and Support

**Author:** Cracknic  
**Manual Version:** 1.0  
**Last Update:** October 2025

For issues, improvements, or additional features, contact the author directly.

**Additional Resources:**
- Man page: `man nmap-scanner-bash`
- Bash completion: Available after installation
- Log files: Check `nmap_scan_*.log` for detailed execution logs

---

*This manual is part of the NmapFlow Network Scanner project and is subject to periodic updates. Check the latest version for the most current information.*
