#!/bin/bash
# Script: recreate_swap.sh
# Purpose: Delete current swapfile and create a new one equal to total RAM size

echo "===== Swapfile Recreation Script ====="
echo "This script will delete existing swap file and generate new swapfile which has size equals to current system RAM size."

# Get current swap info
echo ">> Current Swap Information:"
swapon --show
cat /proc/swaps
echo "--------------------------------------"

# Check if swap size equals RAM size
# Get total RAM size in MB
RAM_MB=$(free -m | awk '/^Mem:/ {print $2}')
TARGET_SWAP_MB=$((RAM_MB + 100))  # Add 100MB buffer
echo "Total RAM detected: ${RAM_MB} MB"
echo "--------------------------------------"
echo "Target swap size: ${TARGET_SWAP_MB} MB"
echo "--------------------------------------"

# Get current swap size
CURRENT_SWAP_MB=$(free -m | awk '/^Swap:/ {print $2}')
echo "Current swap size: ${CURRENT_SWAP_MB} MB"
echo "--------------------------------------"

# Swap size comparison logic
DIFF=$((TARGET_SWAP_MB - CURRENT_SWAP_MB))

if [ "$DIFF" -le 0 ]; then
    echo "Current swap size ($CURRENT_SWAP_MB MB) is sufficient (≥ Target: $TARGET_SWAP_MB MB)."
    echo "No changes needed. Exiting."
    exit 0
elif [ "$DIFF" -lt 1024 ]; then
    echo "Swap size is slightly less than target ($DIFF MB difference)."
    echo "This is acceptable. No changes needed."
    exit 0
else
    echo "Current swap is too small (difference: $DIFF MB). Proceeding to recreate swapfile..."
fi


# Detect swapfile path (default /swapfile, else detect from swapon)
SWAPFILE=$(swapon --show=NAME --noheadings | head -n1)
if [ -z "$SWAPFILE" ]; then
    SWAPFILE="/swapfile"
fi
echo "Detected swapfile: $SWAPFILE"
echo "--------------------------------------"

# Disable and remove old swapfile
if [ -f "$SWAPFILE" ]; then
    echo ">> Disabling swap..."
    sudo swapoff "$SWAPFILE"

    echo ">> Deleting old swapfile: $SWAPFILE"
    sudo rm -f "$SWAPFILE"
else
    echo ">> No existing swapfile found, creating new."
fi
echo "--------------------------------------"

echo "New swap size will be equal to RAM."
echo "--------------------------------------"

# Create new swapfile
echo ">> Creating new swapfile..."
sudo dd if=/dev/zero of=/swapfile bs=1M count=$RAM_MB status=progress
sudo chmod 600 /swapfile
echo "--------------------------------------"

# Format and enable swap
echo ">> Formatting swapfile..."
sudo mkswap /swapfile
echo ">> Enabling swap..."
sudo swapon /swapfile
echo "--------------------------------------"

# Add swapfile entry to /etc/fstab if not already present
if ! grep -q "^/swapfile" /etc/fstab; then
    echo ">> Adding swapfile entry to /etc/fstab"
    echo "/swapfile swap swap sw 0 0" | sudo tee -a /etc/fstab
else
    echo ">> Swapfile entry already exists in /etc/fstab"
fi

# Final Reboot Prompt
echo  "==============================================="
echo  "Swap File Resize Complete!"
echo  "The new swap file is active and configured to persist on reboot."
echo  "==============================================="

read -p "Rebooting your system is recommended, would you like to reboot? (Y/N): " choice

case "$choice" in
  [Yy]* )
    echo "Rebooting in 5 seconds..."
    sleep 5
    sudo reboot
    ;;
  [Nn]* )
    echo "Reboot canceled. Please reboot manually later."
    ;;
  * )
    echo "Invalid input. Please enter Y or N."
    ;;
esac

# Show final result
echo "===================================="
echo ">> New Swap Information:"
swapon --show
free -h
echo "===== DONE ====="