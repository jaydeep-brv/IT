#!/bin/bash
# system_baseline.sh
# Collects key system info for performance diagnostics

OUTFILE="system_baseline_$(hostname)_$(date +%Y%m%d_%H%M%S).log"

echo "===== SYSTEM BASELINE REPORT =====" | tee "$OUTFILE"
echo "Generated on: $(date)" | tee -a "$OUTFILE"
echo "" | tee -a "$OUTFILE"

# --- CPU Info ---
echo "############ CPU INFO ############" | tee -a "$OUTFILE"
lscpu | grep -E 'Model name|Socket|Core|Thread|MHz|CPU max|CPU min' | tee -a "$OUTFILE"
echo "" | tee -a "$OUTFILE"

# --- Memory Info ---
echo "############ MEMORY INFO ############" | tee -a "$OUTFILE"
free -h | tee -a "$OUTFILE"
swapon --show | tee -a "$OUTFILE"
echo "" | tee -a "$OUTFILE"

# --- Disk Info ---
echo "############ DISK INFO ############" | tee -a "$OUTFILE"
df -h --total | grep -E 'Filesystem|/dev/' | tee -a "$OUTFILE"
echo "" | tee -a "$OUTFILE"

# Quick disk speed test (read speed)
echo "############ DISK I/O TEST (READ) ############" | tee -a "$OUTFILE"
sudo hdparm -Tt /dev/$(df / | tail -1 | cut -d' ' -f1 | sed 's#/dev/##') | tee -a "$OUTFILE"
echo "" | tee -a "$OUTFILE"

# --- System Load ---
echo "############ LOAD AVERAGE ############" | tee -a "$OUTFILE"
uptime | tee -a "$OUTFILE"
echo "" | tee -a "$OUTFILE"

# --- Top Memory/CPU Processes ---
echo "############ TOP PROCESSES ############" | tee -a "$OUTFILE"
ps -eo pid,comm,%cpu,%mem --sort=-%mem | head -15 | tee -a "$OUTFILE"
echo "" | tee -a "$OUTFILE"

# --- Temperature and Throttling ---
if command -v sensors &>/dev/null; then
    echo "############ TEMPERATURE SENSORS ############" | tee -a "$OUTFILE"
    sensors | tee -a "$OUTFILE"
else
    echo "lm-sensors not installed. Run: sudo apt install lm-sensors -y" | tee -a "$OUTFILE"
fi
echo "" | tee -a "$OUTFILE"

# --- GPU Info ---
if command -v lspci &>/dev/null; then
    echo "############ GPU INFO ############" | tee -a "$OUTFILE"
    lspci | grep -E "VGA|3D" | tee -a "$OUTFILE"
fi
echo "" | tee -a "$OUTFILE"

# --- Uptime and Power ---
echo "############ UPTIME & POWER STATUS ############" | tee -a "$OUTFILE"
uptime -p | tee -a "$OUTFILE"
acpi -a 2>/dev/null | tee -a "$OUTFILE"
echo "" | tee -a "$OUTFILE"

# --- Kernel & OS ---
echo "############ OS DETAILS ############" | tee -a "$OUTFILE"
lsb_release -a 2>/dev/null | tee -a "$OUTFILE"
uname -r | tee -a "$OUTFILE"
echo "" | tee -a "$OUTFILE"

echo "Report saved to: $OUTFILE"