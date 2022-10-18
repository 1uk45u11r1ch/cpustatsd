#!/bin/sh

while true; do
	if mountpoint -q /run; then
		if [ ! -d /run/cpustatsd ];then
			mkdir /run/cpustatsd
			touch /run/cpustatsd/load && chmod 644 /run/cpustatsd/load
			touch /run/cpustatsd/maxclk && chmod 644 /run/cpustatsd/maxclk
			touch /run/cpustatsd/minclk && chmod 644 /run/cpustatsd/minclk
		fi
		readarray lines < <(turbostat -i 0.2 -n 1 -q)
		
		# cpu load
		cpuload=$(echo ${lines[1]} | awk '{print $4}')
		int=$(echo $cpuload | awk -F . '{print $1}')
		float=$(echo $cpuload | awk -F . '{print $2}')
		
		# cpu clock
		maxclk=0
		minclk=9999
		declare -i i=0
		for line in "${lines[@]}"; do
			clk=$(echo $line | awk '{print $3}')
			if [[ "$i" -gt "1" ]]; then
				if [ "$clk" -lt "$minclk" ]; then
					minclk="$clk"
				fi
				if [ "$clk" -gt "$maxclk" ]; then
					maxclk="$clk"
				fi
			fi
			i+=1
		done
		
		# output
		printf -- "$(printf %3s $(echo $int))"".""$float" > /run/cpustatsd/load
		printf %4s "$maxclk" > /run/cpustatsd/maxclk
		printf %4s "$minclk" > /run/cpustatsd/minclk
	else
		sleep 1
	fi
done
