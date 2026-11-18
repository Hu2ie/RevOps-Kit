#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]] || [[ ! -f "$1" ]]; then
    echo "Usage: $0 <path_to_binary>"
    exit 1
fi

if ! command -v strace &> /dev/null; then
    echo "Error: strace is not installed."
    exit 1
fi

TARGET="$1"
LOG_FILE="/tmp/trace_$(basename "$TARGET")_$(date +%s).log"

echo -e "\033[1;36m[+] Tracing syscalls (file, network, process) for: $TARGET\033[0m"
strace -f -e trace=file,network,process -o "$LOG_FILE" "$TARGET" || true

echo -e "\n\033[1;32m[+] Log saved to: $LOG_FILE\033[0m"
echo -e "\033[1;33m[*] First 30 events:\033[0m"
head -n 30 "$LOG_FILE"

