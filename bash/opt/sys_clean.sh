#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
   echo "Please run this script with sudo."
   exit 1
fi

echo -e "\033[1;36m[+] Disk space BEFORE cleanup:\033[0m"
df -h / | awk 'NR==2 {print "Available: " $4 " of " $2}'

echo -e "\n[*] Vacuuming systemd journals (keeping last 3 days)..."
journalctl --vacuum-time=3d

if command -v apt-get &> /dev/null; then
    echo "[*] Cleaning APT cache and unused dependencies..."
    apt-get autoremove -y -qq
    apt-get autoclean -y -qq
    apt-get clean -y -qq
elif command -v dnf &> /dev/null; then
    echo "[*] Cleaning DNF cache..."
    dnf autoremove -y -q
    dnf clean all -q
fi

if command -v docker &> /dev/null; then
    echo "[*] Pruning dangling Docker images and build cache..."
    docker image prune -f
    docker builder prune -f
fi

echo -e "\n\033[1;32m[+] Disk space AFTER cleanup:\033[0m"
df -h / | awk 'NR==2 {print "Available: " $4 " of " $2}'

