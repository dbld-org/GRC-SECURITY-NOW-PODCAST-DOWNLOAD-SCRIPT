#! /usr/bin/bash

declare -a url_list
declare -a pid

url_list[${#url_list[*]}]=450,http://www.grc.com/sn/sn-450.pdf
url_list[${#url_list[*]}]=450,http://www.grc.com/sn/sn-450.htm
url_list[${#url_list[*]}]=450,http://www.grc.com/sn/sn-450-notes.pdf
url_list[${#url_list[*]}]=451,http://www.grc.com/sn/sn-451.pdf
url_list[${#url_list[*]}]=451,http://www.grc.com/sn/sn-451.htm
url_list[${#url_list[*]}]=451,http://www.grc.com/sn/sn-451-notes.pdf
url_list[${#url_list[*]}]=452,http://www.grc.com/sn/sn-452.pdf
url_list[${#url_list[*]}]=452,http://www.grc.com/sn/sn-452.htm
url_list[${#url_list[*]}]=452,http://www.grc.com/sn/sn-452-notes.pdf

function start_download() {
  local ep_number=$1
	local url=$2 		# primary url for current episode 

	echo "${homeclr}Downloading ${url##*\.} file for episode ${ep_number} from url ${url} ..."

 	tpid=`wget $skip_wget_digital_check $new_download_home -U "$wget_agent_name" -N -c -qb "$url"`
 	ttpid=(`echo $tpid | cut -d " " -f 5 | cut -d "." -f 1`)
 	pid[$ep_number]=$ttpid
}
# for i in ${url_list[@]}; do echo "${i}" ; done

dp=3
used=0

for i in ${url_list[@]}; do
    if [[ $used -lt $dp ]] ; then    
        IFS="," read ep url <<< "$i"
        start_download $ep $url
        ((used++))
        continue
    fi
        pid2=("${pid[@]}") # Copy the array so the unset operation does not mess with the for loop ordering.
        echo " will loop over those jobs : ${pid2}"
        while true; do

            # Check all wget download PIDs to see if they are still going.
            for m in "${!pid[@]}";do
                if ! $(ps -p ${pid[$m]} >/dev/null 2>&1); then
                    echo "UnSetting PID: ${pid[$m]}"
                    unset pid[$m] # Remove the old process from the array
                    ((used--))
                fi
            done

            #If the above loop has noticed finished downloads, then break from this one so we can download more.
            if [ ${#pid2[@]} -ne ${#pid[@]} ]; then
                break # from this sleep loop so another download -pd batch can startup. Danger here is the tiny time in between can allow another download to finish and it may not be accounted for. Can we pause a PID ? kill -STOP pid; kill -CONT pid
            fi

            # If nothing has finished downloading, loop again for continuous checking.
            sleep 5 # Check every few seconds to see if a download finished.
        done
    done
# done


exit 0