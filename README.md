# NmapFlow

**Author:** Cracknic
**Version:** 1.0  
**Date:** October 2025

---

## Overview

Advanced Nmap Scanner is a comprehensive network scanning automation tool available in **Bash**.

## 🚀 Key Features

- **Enhanced Visual Interface**: Color-coded output with dynamic progress bars
- **Intelligent Organization**: Automatic result structuring by target and protocol
- **Firewall Evasion**: 15+ interactive evasion techniques
- **Parallel Processing**: Multi-threaded scanning for improved performance
- **Comprehensive Reporting**: Multiple output formats (Normal, XML, Grepeable, HTML)
- **NSE Script Integration**: Vulnerability, safe, exploit, and authentication scripts
- **Professional Documentation**: Complete manuals in English and Spanish

## 📁 Project Structure

```
NmapFlow/                            # Bash implementation
├── NmapFlow.sh                  # Main Bash script
├── install.sh                   # Bash installer
├── MANUAL_EN.md                 # English manual
├── MANUAL_ES.md                 # Spanish manual
└── README.md                    # README
```

## 🔧 Quick Installation



### Bash Version
```bash
cd NmapFlow
sudo ./install.sh
```

## 📖 Documentation

- **English Manuals**: `MANUAL_EN.md` in each directory
- **Spanish Manuals**: `MANUAL_ES.md` in each directory
- **Installation Guides**: Included in each manual
- **Advanced Examples**: Real-world usage scenarios
- **Troubleshooting**: Common issues and solutions

## 🎯 Quick Start

### Basic Usage
```bash
NmapFlow-bash 192.168.1.1
```

### Advanced Examples
```bash
# Comprehensive network audit
NmapFlow -F -U 1000 --script vuln,safe --threads 8 192.168.1.0/24

# Stealthy reconnaissance
NmapFlow -f 500 -sX --firewall --threads 2 target.com

# Quick vulnerability assessment
NmapFlow -f 1000 --script vuln 192.168.1.1
```

## 🔍 Feature Comparison

| Feature | Python Version | Bash Version |
|---------|----------------|--------------|
| **Dependencies** | Python 3.6+ | Bash 4.0+ |
| **Memory Usage** | Higher | Lower |
| **Performance** | Excellent | Very Good |
| **Portability** | Good | Excellent |
| **Customization** | Easy | Very Easy |
| **System Integration** | Good | Excellent |

## 🛠️ System Requirements

### Minimum Requirements
- **OS**: Linux/Unix (any distribution)
- **RAM**: 256 MB (Bash) / 512 MB (Python)
- **Disk**: 50 MB (Bash) / 100 MB (Python)
- **Nmap**: 7.0+

### Required Tools
- `nmap` - Network scanning engine
- `xsltproc` - XML transformation
- `xmllint` - XML validation (Bash version)

## 🎨 Visual Features

Both implementations feature:

- **Color-coded output** for different message types
- **Dynamic progress bars** with completion percentages
- **Professional banners** with author attribution
- **Status indicators** for operation states
- **Hierarchical result organization**

## 🔐 Security Features

- **Multiple scan types**: SYN, Connect, Xmas, Null, FIN, ACK, Window
- **NSE script categories**: Vulnerability, Safe, Exploit, Authentication
- **Firewall evasion techniques**: Fragmentation, decoys, spoofing, timing
- **Privilege management**: Automatic privilege checking and warnings
- **Secure result handling**: Organized output with integrity checks

## 📊 Output Organization

Results are automatically organized in timestamped directories:

```
NmapScan_YYYYMMDD_HHMMSS/
├── [TARGET_IP]/
│   ├── TCP/
│   │   ├── oN/    # Normal format
│   │   ├── oX/    # XML format
│   │   └── oG/    # Grepeable format
│   ├── UDP/
│   │   ├── oN/
│   │   ├── oX/
│   │   └── oG/
│   ├── combined_scan_[IP].xml
│   └── combined_report_[IP].html
├── scan_summary.txt
└── nmap_scan_[timestamp].log
```

## 🤝 Contributing

This project was developed by **Cracknic**. For contributions, bug reports, or feature requests, please contact the author directly.

## 📝 License

This project is provided as-is for educational and professional security assessment purposes and it's under GNU GENERAL PUBLIC LICENSE. Users are responsible for ensuring compliance with applicable laws and regulations.

## 🔗 Additional Resources

- **Nmap Official Documentation**: https://nmap.org/docs.html
- **NSE Script Database**: https://nmap.org/nsedoc/
- **Network Security Best Practices**: Consult your organization's security policies

---

**Developed with by Cracknic**

*For the latest updates and documentation, refer to the individual manual files in each implementation directory.*
