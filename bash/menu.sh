#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_banner() {
    clear
    echo -e "\033[1;36m=========================================\033[0m"
    echo -e "\033[1;37m          RevOps-Kit :: Linux            \033[0m"
    echo -e "\033[1;36m=========================================\033[0m"
}

while true; do
    show_banner
    echo " [1] Static ELF Triage (elf_triage.sh)"
    echo " [2] Syscall Tracing (trace_syscalls.sh)"
    echo " [3] System Cleanup & Optimization (sys_clean.sh)"
    echo " [0] Exit"
    echo ""
    read -rp "Select an option: " CHOICE

    case "$CHOICE" in
        1)
            read -rp "Enter target binary path: " TARGET
            "$SCRIPT_DIR/rev/elf_triage.sh" "$TARGET"
            read -rp "Press Enter to continue..."
            ;;
        2)
            read -rp "Enter target binary path: " TARGET
            "$SCRIPT_DIR/rev/trace_syscalls.sh" "$TARGET"
            read -rp "Press Enter to continue..."
            ;;
        3)
            sudo "$SCRIPT_DIR/opt/sys_clean.sh"
            read -rp "Press Enter to continue..."
            ;;
        0)
            exit 0
            ;;
        *)
            echo "Invalid selection."
            sleep 1
            ;;
    esac
done

