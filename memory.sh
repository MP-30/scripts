#!/bin/bash

# Read username
username=$(whoami)
echo "Hello, $username"
# Read free storage size
echo "You have this much storage available in your system"
df -h / | tail -1 | awk '{print $4}'
echo "We will use some space from this to increase your memory on your input"

# Read RAM size
total_memory=$(grep "MemTotal" /proc/meminfo | awk '{print $2}')
total_memory_gb=$(echo "scale=2; $total_memory/1024/1024" | bc)
echo "This much RAM you have in your system: $total_memory_gb GB"

available_swap=$(free -h | grep Swap)
echo "The amount of swap you already have is $available_swap "

# Ask for swap size
read -p "Enter the amount of swap in GB's you want to create eg. 4,8,12,16: " swap_size
echo "Swap Size: $swap_size GB"

# Validate numeric input
if ! [[ $swap_size =~ ^[0-9]+$ ]]; then
    echo "Invalid input. Please enter a valid numeric value."
    exit 1
fi

# Ask for user confirmation before closing applications
read -p "This will close large applications. Are you sure? (y/n): " confirm
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
    echo "Closing large applications..."
    pkill -f chrome
    pkill -f firefox
    pkill -f eclipse
    pkill -f pycharm
    pkill -f code
else
    echo "Operation cancelled."
    exit 1
fi



# Creating swap file
sudo swapoff /swapfile

# Create new swap file
sudo fallocate -l ${swap_size}G /swapfile
if [ $? -ne 0 ]; then
    echo "Failed to create swap file. Please check your disk space and permissions."
    exit 1
fi

sudo chmod 600 /swapfile
ls -hl /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Add swapfile to /etc/fstab
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Set vm.swappiness to 60
echo "Setting vm.swappiness to 60. This value controls how aggressively the system will swap memory pages."
echo "A lower value will make the system try to avoid swapping whenever possible."
echo "A higher value will make the system more prone to swapping."
sysctl vm.swappiness=60

echo "Bye Bye $username process complete"