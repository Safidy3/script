#!/bin/bash

print_info() {
        printf "#Architecture: $(uname -a)\n"        
        printf "#CPU physical: $(lscpu | grep Socket | awk '{print $2}')\n"
        printf "#vCPU: $(nproc)\n"
        
        cmd1=$(free | grep Mem | awk '{print $3}')
        cmd2=$(free | grep Mem | awk '{print $2}')
        cmd3=$(free | grep Mem | awk '{print $3/$2 * 100}')
        printf "#Memory Usage: $cmd1/$cmd2%s ($cmd3%%)\n" "MB"
        
        cmd1=$(df -h --block-size=G --total | tail -n 1 | awk '{print $3}' | cut -d G -f1)
        cmd2=$(df -h --block-size=G --total | tail -n 1 | awk '{print $2}' | cut -d G -f1)
        cmd3=$(df -h --block-size=G --total | tail -n 1 | awk '{print $5}' | cut -d % -f1)
        printf "#Disk Usage: $cmd1/$cmd2%s ($cmd3%%)\n" "Gb"

        cpuload=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')
        printf "#CPU load: $cpuload%%\n"
        printf "\n#Last boot: $(who -b | awk '{print $3 " " $4}')\n"
        
        cmd=$(cat /etc/fstab | grep /dev/mapper | wc -l)
        printf "#LVM use: "
        if [ $cmd -gt 0 ]
        then
                printf "yes\n"
        else
                printf "no\n"
        fi
        
        printf "#Connections TCP: $(echo "$(ss -t -H | wc -l)") ESTABLISHED\n"
        printf "#User log: $(w -h | wc -l)\n"
        
        ip=$(ip address | grep enp | grep inet | awk '{print $2}' | cut -d / -f 1)
        mac=$(ip address | grep enp -A 2 | grep inet6 | awk '{print $2}' | cut -d / -f 1)
        printf "#Network: IP $ip ($mac)\n"

        printf "#Sudo: 42 cmd\n"
}

print_info | wall
