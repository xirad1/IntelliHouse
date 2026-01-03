#!/bin/bash
#Monitoring script for BananaPi M3
#Displays system information including uptime, CPU temperature, memory usage, kernel messages, I/O errors, watchdog status, and disk usage.
#xirad 2026-01-03
echo "================== BananaPi M3 Monitor =================="
# 1. Uptime
echo -n "Uptime: "
uptime -p

# 2. Temperature CPU
if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
    temp=$(cat /sys/class/thermal/thermal_zone0/temp)
    temp_c=$(echo "scale=1; $temp/1000" | bc)
    echo "CPU Temperature: $temp_c °C"
else
    echo "CPU Temperature: N/A"
fi

# 3. RAM and swap
free -h | awk 'NR==1{print "\nMemory Usage:"} NR>1{print}'

# 4. Last 20 kernel lines from dmesg
echo -e "\nLast 20 dmesg lines (kernel messages):"
dmesg | tail -20

# 5. Check I/O / mmc errors
echo -e "\nMMC / SD errors (if any):"
dmesg | grep -i mmc | tail -10

# 6. Check watchdog (should be empty because it's disabled)
echo -e "\nWatchdog status:"
dmesg | grep -i watchdog | tail -10

# 7. Free disk space
echo -e "\nDisk usage:"
df -h
