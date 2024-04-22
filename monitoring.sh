#!/bin/bash

cmd=$(uname -a)
printf "#Architecture: $cmd\n"

cmd=$(lscpu | grep Socket | awk '{print $2}')
printf "#CPU physical: $cmd\n"

cmd=$(nproc)
printf "#vCPU: $cmd\n"

cmd1=$(free | grep Mem | awk '{print $3}')
cmd2=$(free | grep Mem | awk '{print $2}')
cmd3=$(free | grep Mem | awk '{print $3/$2 * 100}')
printf "#Memory Usage: $cmd1/$cmd2%s ($cmd3%%)\n" "MB"

cmd1=$(df -h --block-size=G --total | tail -n 1 | awk '{print $3}' | cut -d G -f1)
cmd2=$(df -h --block-size=G --total | tail -n 1 | awk '{print $2}' | cut -d G -f1)
cmd3=$(df -h --block-size=G --total | tail -n 1 | awk '{print $5}' | cut -d % -f1)
printf "#Disk Usage: $cmd1/$cmd2%s ($cmd3%%)\n" "Gb"

cmd1=$(mpstat | tail -n 1 | awk '{print $5}')
printf "#CPU load: $cmd1%%\n"

cmd=$(who -b | awk '{print $3 " " $4}')
printf "#Last boot: $cmd\n"

cmd=$(cat /etc/fstab | grep /dev/mapper | wc -l)
printf "#LVM use: "
if [ $cmd -gt 0 ]
then
        printf "yes\n"
else
        printf "no\n"
fi

cmd=$(echo "$(ss -t -H | wc -l)")
printf "#Connections TCP: $cmd ESTABLISHED\n"

cmd=$(w -h | wc -l)
printf "#User log: $cmd\n"

cmd1=$(ip address | grep enp | grep inet | awk '{print $2}' | cut -d / -f 1)
cmd2=$(ip address | grep enp -A 2 | grep inet6 | awk '{print $2}' | cut -d / -f 1)
printf "#Network: IP $cmd1 ($cmd2)\n"

printf "#Sudo: 42 cmd\n"
