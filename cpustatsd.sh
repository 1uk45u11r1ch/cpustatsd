#!/bin/sh

while true; do
	if mountpoint -q /run; then
		if [ ! -d /run/cpustatsd ];then
			mkdir /run/cpustatsd
			touch /run/cpustatsd/load && chmod 644 /run/cpustatsd/load
			touch /run/cpustatsd/maxclk && chmod 644 /run/cpustatsd/maxclk
			touch /run/cpustatsd/minclk && chmod 644 /run/cpustatsd/minclk
			touch /run/cpustatsd/corpwr && chmod 644 /run/cpustatsd/corpwr
			touch /run/cpustatsd/pkgpwr && chmod 644 /run/cpustatsd/pkgpwr
		fi
		readarray lines < <(turbostat -i 0.2 -n 1 -q)
		
		# cpu load
		load="$(echo ${lines[1]} | awk '{print $4}')"
		load_int="$(echo $load | awk -F . '{print $1}')"
		load_float="$(echo $load | awk -F . '{print $2}')"

		# core power
		corpwr="$(echo ${lines[1]} | awk '{print $15}')"
		corpwr_int="$(echo $corpwr | awk -F . '{print $1}')"
		corpwr_float="$(echo $corpwr | awk -F . '{print $2}')"

		# package power
		pkgpwr="$(echo ${lines[1]} | awk '{print $16}')"
		pkgpwr_int="$(echo $pkgpwr | awk -F . '{print $1}')"
		pkgpwr_float="$(echo $pkgpwr | awk -F . '{print $2}')"
		
		# cpu clock
		maxclk=0
		minclk=9999
		declare -i i=0
		for line in "${lines[@]}"; do
			clk="$(echo "$line" | awk '{print $3}')"
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
		printf -- "$(printf %3s $(echo $load_int))"".""$load_float" > /run/cpustatsd/load
		printf -- "$(printf %3s $(echo $corpwr_int))"".""$corpwr_float" > /run/cpustatsd/corpwr
		printf -- "$(printf %3s $(echo $pkgpwr_int))"".""$pkgpwr_float" > /run/cpustatsd/pkgpwr
		printf %4s "$maxclk" > /run/cpustatsd/maxclk
		printf %4s "$minclk" > /run/cpustatsd/minclk
	else
		sleep 1
	fi
done
