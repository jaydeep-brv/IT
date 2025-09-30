#!/bin/bash
#
# Ubuntu System Info Script
# Collects hardware & system information for troubleshooting performance issues
#

OUTPUT_FILE="system_report_$(date +%F_%H.%M.%S).txt"
echo "======== Gathering system information ========"

# Helper: print to both terminal and file
log() {
    echo -e "$1" | tee -a "$OUTPUT_FILE"
}

log "========================================"
log "  Ubuntu System Information Report"
log "  Generated on: $(date)"
log "========================================"
log ""

# OS & Kernel
log ">> OS & Kernel"
lsb_release -a 2>/dev/null | tee -a "$OUTPUT_FILE"
uname -a | tee -a "$OUTPUT_FILE"
log ""

# CPU Info
log ">> CPU Information"
lscpu | grep -Ei 'Architecture|CPU op-mode|Model name|Thread|Core|CPU max MHz|CPU min MHz' | tee -a "$OUTPUT_FILE"
log ""

# GPU Info
log ">> GPU Information"
lspci | grep -E "VGA|3D" | tee -a "$OUTPUT_FILE"
log ""

# RAM Info
log ">> Memory (RAM)"
free -h | tee -a "$OUTPUT_FILE"
log ""

# Swap Info
log ">> Swap"
swapon --show | tee -a "$OUTPUT_FILE"
cat /proc/swaps | tee -a "$OUTPUT_FILE"
log ""

# Disk Usage
log ">> Disk Usage"
df -hT --total | tee -a "$OUTPUT_FILE"
log ""

# Disk Hardware Info
log ">> Disk Hardware"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE,MODEL | tee -a "$OUTPUT_FILE"
log ""

# Encryption Status
log ">> Encryption Status"
lsblk -o NAME,MOUNTPOINT,FSTYPE | grep "crypt" | tee -a "$OUTPUT_FILE"
log ""

# Virtualization
log ">> Virtualization"
systemd-detect-virt | tee -a "$OUTPUT_FILE"
log ""

# Network Info
log ">> Network Info"
ip -br addr show | tee -a "$OUTPUT_FILE"
log ""

# Final message
echo "======== DONE ========"
echo " Report saved to $OUTPUT_FILE"
echo "======================"
