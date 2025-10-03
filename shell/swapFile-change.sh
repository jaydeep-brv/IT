#!/bin/bash
# Script: recreate_swap.sh
# Purpose: Delete current swapfile and create a new one equal to total RAM size

echo "===== Swapfile Recreation Script ====="

# Get current swap info
echo ">> Current Swap Information:"
swapon --show
cat /proc/swaps
echo "--------------------------------------"

# Get total RAM size in MB
RAM_MB=$(free -m | awk '/^Mem:/ {print $2}')
echo "Total RAM detected: ${RAM_MB} MB"
CURRENT_SWAP_MB=$(free -m | awk '/^Swap:/ {print $2}')

# Check if swap size equals RAM size
if [ "$CURRENT_SWAP_MB" -ge "$RAM_MB" ]; then
    echo "Current swap size ($CURRENT_SWAP_MB MB) is equal or larger than RAM ($RAM_MB MB). No changes needed."
    exit 0
fi

# Detect swapfile path (default /swapfile, else detect from swapon)
SWAPFILE=$(swapon --show=NAME --noheadings | head -n1)
if [ -z "$SWAPFILE" ]; then
    SWAPFILE="/swapfile"
fi
echo "Detected swapfile: $SWAPFILE"

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

#
## Get swap size (user input or default = RAM size)
#if [ -n "$1" ]; then
#    SWAP_MB=$1
#    echo "User requested swap size: ${SWAP_MB} MB"
#else
#    SWAP_MB=$(free -m | awk '/^Mem:/ {print $2}')
#    echo "No size given, using RAM size: ${SWAP_MB} MB"
#fi

# Create new swapfile
echo ">> Creating new swapfile..."
sudo dd if=/dev/zero of=/swapfile bs=1M count=$RAM_MB status=progress
sudo chmod 600 /swapfile

# Format and enable swap
echo ">> Formatting swapfile..."
sudo mkswap /swapfile
echo ">> Enabling swap..."
sudo swapon /swapfile

# Add swapfile entry to /etc/fstab if not already present
if ! grep -q "^/swapfile" /etc/fstab; then
    echo ">> Adding swapfile entry to /etc/fstab"
    echo "/swapfile swap swap sw 0 0" | sudo tee -a /etc/fstab
else
    echo ">> Swapfile entry already exists in /etc/fstab"
fi


# Final Reboot Prompt
echo -e "\n\e[32m===============================================\e[0m"
echo -e "\e[32mSwap File Resize Complete!\e[0m"
echo -e "The new swap file is active and configured to persist on reboot."
echo -e "\e[32m===============================================\e[0m"

read -r -p "A reboot is highly recommended to finalize changes. Reboot now? (y/N): " REBOOT_CONFIRMATION

if [[ "$REBOOT_CONFIRMATION" =~ ^[Yy]$ ]]; then
    echo -e "\e[34mSystem rebooting in 5 seconds...\e[0m"
    sleep 5
    reboot
else
    echo -e "\e[34mReboot skipped. Please reboot the system manually at your earliest convenience.\e[0m"
fi

# Show final result
echo "--------------------------------------"
echo ">> New Swap Information:"
swapon --show
free -h
echo "===== DONE ====="
