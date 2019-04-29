#!/bin/bash
echo -e "\e[94m #:Bus  Pwr PL  PM  PS  CU MU F  T  Core CM   Mem  MM   Name  \e[0m"
R=`nvidia-smi --query-gpu=index,pci.bus,pstate,power.draw,fan.speed,temperature.gpu,utilization.gpu,clocks.sm,clocks.max.sm,clocks.mem,clocks.max.memory,gpu_name,utilization.memory,power.limit,power.max_limit --format=csv`
INDEX=0
readarray GPUNAMES < <(lspci -vnn | grep VGA -A 12  | grep Subsystem | cut -c 13-)
COLWIDTH=`stty size | cut -d ' ' -f 2`
echo "$R" | while read line ; do
        if [ "$INDEX" -gt "0" ]; then
                #aline=${line// MHz/}
                #aline=${aline// %/}
                fline=$(echo " $line" | tr " " "_")
                parts=$(echo $fline | tr ", " "\n")
                lineResult=()
                for x in $parts
                do
                        val=$(echo $x | tr "_" " ")
                        val2=`echo $val | cut -c1-`
                        lineResult+=("$val2")
                done
                gpuIndex=`printf "%2s" ${lineResult[0]}`
                watt=${lineResult[3]}
                watt=${watt// W/}
                watt=`printf "%3.0f" $watt`
                wattLim=${lineResult[13]}
                wattLim=${watt// W/}
                wattLim=`printf "%3.0f" $wattLim`
                wattMax=${lineResult[14]}
                wattMax=${wattMax// W/}
                wattMax=`printf "%3.0f" $wattMax`
                fan=${lineResult[4]}
                fan=${fan// %/}
                fan=`printf "%4s" $fan`
        if [ $fan -gt 95 ];
        then
                fan="$fan"
        else
                fan="\e[33m$fan\e[0m"
        fi
                usage=${lineResult[6]}
                usage=${usage// %/}
                usage=`printf "%3s" $usage`
        if [ $usage -gt 99 ];
        then
                usage="$usage"
        else
                usage="\e[33m$usage\e[0m"
        fi
                usageMem=${lineResult[12]}
                usageMem=${usageMem// %/}
                usageMem=`printf "%3s" $usageMem`
        if [ $usageMem -gt 90 ];
        then
                usageMem="\e[33m$usageMem\e[0m"
        else
                usageMem="$usageMem"
        fi
                currentCoreSpeed=${lineResult[7]}
                currentCoreSpeed=${currentCoreSpeed// MHz/}
                currentCoreSpeed=`printf "%4s" $currentCoreSpeed`
                maxCoreSpeed=${lineResult[8]}
                maxCoreSpeed=${maxCoreSpeed// MHz/}
                maxCoreSpeed=`printf "%4s" $maxCoreSpeed`
                currentMemSpeed=${lineResult[9]}
                currentMemSpeed=${currentMemSpeed// MHz/}
                currentMemSpeed=`printf "%4s" $currentMemSpeed`
                maxMemSpeed=${lineResult[10]}
                maxMemSpeed=${maxMemSpeed// MHz/}
                maxMemSpeed=`printf "%4s" $maxMemSpeed`
                gpuName=`echo "${GPUNAMES[$gpuIndex]}" | tr -d '\n' | rev | cut -c13- | rev`
                gpuTemp=${lineResult[5]}
                gpuTempClr=$gpuTemp
if [ $gpuTemp \> 70 ];
then
        if [ $gpuTemp \> 80 ];
        then
                gpuTempClr="\e[95m$gpuTemp\e[0m"
        else
                gpuTempClr="\e[93m$gpuTemp\e[0m"
        fi
else
    gpuTempClr="\e[92m$gpuTemp\e[0m"
fi;
                row="\e[90m$gpuIndex:${lineResult[1]}\e[0m $watt \e[37m$wattLim $wattMax\e[0m ${lineResult[2]} $usage $usageMem $fan $gpuTempClr $currentCoreSpeed \e[37m$maxCoreSpeed\e[0m $currentMemSpeed\e[37m $maxMemSpeed\e[0m \e[90m$gpuName\e[0m"
                rowWidthCtr=`echo -n $row | wc -c`
                rowWidthChr=`echo -e $row | wc -c`
                ctrLength=$(($rowWidthCtr-$rowWidthChr))
                rowLength=$(($COLWIDTH+5*$ctrLength+4))
                rowCut=`echo $row | cut -c 1-${rowLength}`
                rowCut="$rowCut\e[0m"
                echo -e $rowCut
        fi
   INDEX=$((INDEX+1))
done