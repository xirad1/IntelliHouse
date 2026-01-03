#!/bin/bash
#Monitoring script for BananaPi M3
#Displays system information including uptime, CPU temperature, memory usage, kernel messages, I/O errors, watchdog status, and disk usage.
#xirad 2026-01-03
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${BOLD}================== BananaPi M3 Monitor ==================${RESET}"
# 1. Uptime
echo -n "Uptime: "
uptime -p

# 2. Temperature CPU
if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
    temp=$(cat /sys/class/thermal/thermal_zone0/temp)
    temp_c=$(echo "scale=1; $temp/1000" | bc)
    temp_int=$(printf '%.0f' "${temp_c}")
    if [ "$temp_int" -ge 85 ]; then
        echo -e "CPU Temperature: ${RED}${temp_c} °C [CRITICAL]${RESET}"
    elif [ "$temp_int" -ge 75 ]; then
        echo -e "CPU Temperature: ${YELLOW}${temp_c} °C [WARN]${RESET}"
    else
        echo -e "CPU Temperature: ${GREEN}${temp_c} °C [OK]${RESET}"
    fi
else
    echo "CPU Temperature: N/A"
fi

# 3. RAM and swap
echo -e "\nMemory Usage:"
mem_line=$(free -m | awk '/Mem:/ {print $2, $3, $7}')
mem_total=$(echo "$mem_line" | awk '{print $1}')
mem_used=$(echo "$mem_line" | awk '{print $2}')
mem_avail=$(echo "$mem_line" | awk '{print $3}')
mem_used_pct=$(awk -v tot="$mem_total" -v avail="$mem_avail" 'BEGIN {printf("%d", (1- (avail/tot))*100)}')
if [ "$mem_used_pct" -ge 90 ]; then
    mem_color="$RED"; mem_state="CRITICAL"
elif [ "$mem_used_pct" -ge 80 ]; then
    mem_color="$YELLOW"; mem_state="WARN"
else
    mem_color="$GREEN"; mem_state="OK"
fi
echo -e "RAM: ${mem_color}${mem_used_pct}% used${RESET} (${mem_used} MiB of ${mem_total} MiB) [${mem_state}]"
swap_line=$(free -m | awk '/Swap:/ {print $2, $3}')
swap_total=$(echo "$swap_line" | awk '{print $1}')
swap_used=$(echo "$swap_line" | awk '{print $2}')
if [ "$swap_total" -gt 0 ]; then
    swap_used_pct=$(awk -v tot="$swap_total" -v used="$swap_used" 'BEGIN {printf("%d", (used/tot)*100)}')
    if [ "$swap_used_pct" -ge 50 ]; then
        swap_color="$YELLOW"; swap_state="WARN"
    else
        swap_color="$GREEN"; swap_state="OK"
    fi
    echo -e "Swap: ${swap_color}${swap_used_pct}% used${RESET} (${swap_used} MiB of ${swap_total} MiB) [${swap_state}]"
else
    echo -e "Swap: ${BLUE}disabled or 0 MiB${RESET}"
fi

# 4. Last 20 kernel lines from dmesg
echo -e "\n${BOLD}Last 20 dmesg lines (kernel messages):${RESET}"
dmesg | tail -20

# 5. Check I/O / mmc errors
mmc_lines=$(dmesg | grep -iE 'mmc|mmcblk|sdio')
mmc_err=$(echo "$mmc_lines" | grep -iE 'error|fail|timeout|crc|reset|io error|i/o')
mmc_err_count=$(echo "$mmc_err" | sed '/^\s*$/d' | wc -l)
if [ "$mmc_err_count" -gt 0 ]; then
    echo -e "\n${RED}MMC / SD errors detected (${mmc_err_count}):${RESET}"
    echo "$mmc_err" | tail -20
else
    echo -e "\n${GREEN}MMC / SD errors: none${RESET}"
fi

# 6. Check watchdog (should be empty because it's disabled)
wdog_count=$(dmesg | grep -i watchdog | wc -l)
if [ "$wdog_count" -gt 0 ]; then
    echo -e "\n${YELLOW}Watchdog messages detected (${wdog_count}):${RESET}"
    dmesg | grep -i watchdog | tail -10
else
    echo -e "\n${GREEN}Watchdog: no messages${RESET}"
fi

# 7. Free disk space
echo -e "\n${BOLD}Disk usage:${RESET}"
df -h
echo -e "\nDisk usage alerts:"
df -P | awk 'NR>1 {print $6, $5, $1}' | while read -r mount pct dev; do
    use=${pct%%%}
    if [ "$use" -ge 90 ]; then
        echo -e "${RED}[CRITICAL]${RESET} $mount ($dev) ${use}%"
    elif [ "$use" -ge 80 ]; then
        echo -e "${YELLOW}[WARN]${RESET}     $mount ($dev) ${use}%"
    else
        echo -e "${GREEN}[OK]${RESET}       $mount ($dev) ${use}%"
    fi
done
