#!/bin/bash
# Description: running make in linux-kernel for multiple times and get the page counter of each page
#
#  Author: wujing(wulin_cqu@cqu.edu.cn)
#
#  Revision History:
#       2018/1/1 Make the functions work for /mnt/pmfs

done_flag=0
total_make_times=100
current_make_ran_times=0

start_new_build_in_pmfs()
{
	make -j16 O=/mnt/pmfs/ -s -i 2>&1 > /dev/null
}

start_new_build_in_nova()
{
	make -j16 O=/mnt/nova/ -s -i 2>&1 > /dev/null
}

#This function takes 1 parameter, the filesystem name (e.g., nova, simfs, pmfs)
get_fs_usage()
{
	fs="pmfs"
	pmfs_usage=`df | grep $fs | awk '{print $5}' | awk -F"%" '{print $1}'`
	echo "$fs usage:$pmfs_usage"
	fs="nova"
	nova_usage=`df | grep $fs | awk '{print $5}' | awk -F"%" '{print $1}'`
	echo "$fs usage:$nova_usage"
	if [ $pmfs_usage -gt 90 ] && [ $nova_usage -gt 90 ]
	then
			echo "File System Full, Killing Make..."
			pkill -9 make
			
			((current_make_ran_times++))
			echo "current_make_ran_times:$current_make_ran_times"
			
			sed 1,2d /proc/pmfs_page_counter > /dev/shm/pmfs-make-$current_make_ran_times
			sed 1,2d /proc/nova_page_counter > /dev/shm/nova-make-$current_make_ran_times

			if [ $current_make_ran_times -gt $total_make_times ]
			then
				echo "Finished all $total_make_times make tasks"
				
				done_flag=1
			else
				echo "Starting a new build task..."
				
				cd /dev/shm/linux-4.4.30
				make clean O=/mnt/pmfs/ 2>&1 > /dev/null
				start_new_build_in_pmfs &

				cd /dev/shm/linux-4.4.30
				make clean O=/mnt/nova/ 2>&1 > /dev/null
				#The new make task has to be in background mode
				start_new_build_in_nova &
			fi
	fi
}




#Input parameter: the fs name
test_fs_and_kill()
{
	#cp /boot/config-4.4.30 /mnt/pmfs/.config
	#cp /boot/config-4.4.30 /mnt/nova/.config
	cd /dev/shm/linux-4.4.30
	make allmodconfig O=/mnt/pmfs/
	make clean O=/mnt/pmfs/ 2>&1 > /dev/null
	start_new_build_in_pmfs &

	cd /dev/shm/linux-4.4.30
	make allmodconfig O=/mnt/nova/
	make clean O=/mnt/nova/ 2>&1 > /dev/null
	start_new_build_in_nova &

	while true
	do
		get_fs_usage 
		sleep 1
		if [ $done_flag -eq 1 ]
		then
			echo "Exiting..."
			pkill -9 make 
			exit 1
		fi

	done
}

test_fs_and_kill



