#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]] || [[ ! -f "$1" ]]; then
    echo "Usage: $0 <path_to_binary>"
    exit 1
fi

TARGET="$1"
echo -e "\n\033[1;36m[+] Target Triage: $TARGET\033[0m"
echo "--------------------------------------------------"
file -b "$TARGET"
echo "SHA256: $(sha256sum "$TARGET" | awk '{print $1}')"

if command -v readelf &> /dev/null; then
    echo -e "\n\033[1;33m[*] Headers & Security Mitigations:\033[0m"
    readelf -h "$TARGET" | grep -E "Class:|Machine:|Entry point" || true
    
    if readelf -l "$TARGET" | grep -q "GNU_STACK.*RWE"; then
        echo "NX (DEP) : DISABLED (Executable Stack!)"
    else
        echo "NX (DEP) : Enabled"
    fi

    if readelf -s "$TARGET" | grep -q "__stack_chk_fail"; then
        echo "Canary   : Enabled"
    else
        echo "Canary   : Not Found"
    fi

    echo -e "\n\033[1;33m[*] Shared Libraries:\033[0m"
    readelf -d "$TARGET" | grep "NEEDED" | awk '{print "  -> " $5}' || echo "  Statically linked (or non-ELF)"
fi

echo -e "\n\033[1;33m[*] Interesting Strings (URL / IP / Paths / APIs):\033[0m"
strings -n 6 "$TARGET" | grep -E "(https?://|/bin/|/etc/|[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}|ptrace|execve|system)" | head -n 25 || true

